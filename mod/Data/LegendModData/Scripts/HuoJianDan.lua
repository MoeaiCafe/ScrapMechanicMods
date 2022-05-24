-----------------------------------------------
--This script contains code from Brent Batch---
--------Copyright (c) 2020 Brent Batch---------
------------Modified by David Sirius-----------
-----------------------------------------------

HuoJianDan = class( nil )
HuoJianDan.maxParentCount = 1
HuoJianDan.maxChildCount = 0
HuoJianDan.connectionInput = sm.interactable.connectionType.logic
HuoJianDan.connectionOutput = sm.interactable.connectionType.none
HuoJianDan.colorNormal = sm.color.new( 0xcb0a00ff )
HuoJianDan.colorHighlight = sm.color.new( 0xee0a00ff )
HuoJianDan.poseWeightCount = 1
HuoJianDan.fireDelay = 160 --ticks
HuoJianDan.minForce = 150
HuoJianDan.maxForce = 150
HuoJianDan.spreadDeg = 0.4
HuoJianDan.recoilForce = 0.0	--后坐力倍数
HuoJianDan.destructionRadius = 3.5	--破坏半径
HuoJianDan.shellMass = 5		--炮弹质量

function HuoJianDan.server_onCreate( self ) 
	self:server_init()
end

function HuoJianDan.server_init( self ) 
	self.fireDelayProgress = 0
	self.canFire = true
	self.parentActive = false
end

function HuoJianDan.server_onRefresh( self )
	self:server_init()
end

function HuoJianDan.server_onFixedUpdate( self, timeStep )

	if not self.canFire then
		self.fireDelayProgress = self.fireDelayProgress + 1
		if self.fireDelayProgress >= self.fireDelay then
			self.fireDelayProgress = 0
			self.canFire = true	
		end
	end
	self:server_tryFire()
	
	if self.canFire == true then
		self.shellVisible = true
	else
		self.shellVisible = false
	end
	self.network:sendToClients("client_shellVisible", self.shellVisible)
	
	local parent = self.interactable:getSingleParent()
	if parent then
		self.parentActive = parent:isActive()
	end
	
	for k, bullet in pairs(self.bullets) do
		if bullet then
			if bullet.hit or bullet.alive > 200 then --lives for 2 sec, clean up after
				if bullet.hit then
					--position, level, destructionRadius, impulseRadius, magnitude
					sm.physics.explode( bullet.result, 8, self.destructionRadius, 12 , 40,"PropaneTank - ExplosionBig")
				end
				self.bullets[k] = nil
			end
		end
	end
end

function HuoJianDan.server_tryFire( self )
	local parent = self.interactable:getSingleParent()
	if parent then
		if parent:isActive() and not self.parentActive and self.canFire then
			self.canFire = false
			--local firePos = sm.vec3.new( 0.0, 0.0, 0.375 )
			
			local fireForce = math.random( self.minForce, self.maxForce )
			local dir = sm.noise.gunSpread( self.shape.up, self.spreadDeg )
		
			self.network:sendToClients( "client_onShoot", {dir = dir*fireForce, gravity = sm.physics.getGravity()})

			local impulse = dir * -fireForce * self.shellMass * self.recoilForce
			sm.physics.applyImpulse( self.shape, impulse )
			
			
			local shapePos = sm.shape.getWorldPosition(self.shape)
			local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
			local offSetPos = (self.shape.right * 0) + (self.shape.up * 1.0) + (self.shape.at * 0.0)
			local effectPos = shapePos + offSetPos
			sm.effect.playEffect( "HuoJianDanShot", effectPos, nil, rot )
			
			
		end
	end
end

-- Client

function HuoJianDan.client_onCreate( self )
	self.boltValue = 0.0
	self.bullets = {}
	
	posaudio = sm.shape.getWorldPosition( self.shape ) + self.shape.up * 0.625
		
	rot = sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), self.shape.up )
	
	--self.shootEffect = sm.effect.createEffect( "Cannon1Shot", self.interactable )
	
end

function HuoJianDan.client_onFixedUpdate( self, dt )

	if self.shellVisible == true then
		self.interactable:setPoseWeight( 0, 0 )
	else
		self.interactable:setPoseWeight( 0, 1 )
	end
	
	--print(self.bullets)
	for k, bullet in pairs(self.bullets) do
		if bullet then
			if bullet.hit or bullet.alive > 200 then --lives for 2 sec, clean up after
				bullet.effect:stop()
				bullet.thrust:stop()
			end
			if bullet and not bullet.hit then --movement
				
				bullet.direction = bullet.direction*0.997 - sm.vec3.new(0,0,bullet.grav*dt)
				
				local right = sm.vec3.new(0,0,1):cross(bullet.direction)
				if right:length()<0.001 then right = sm.vec3.new(1,0,0) else right = right:normalize() end
				local up = self.shape.up:cross(right)
				
				local hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 , self.shape)
				if not hit then 
					hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 + up/4 + right/4, self.shape)
					if not hit then 
						hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 + up/4 - right/4, self.shape)
						if not hit then 
							hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 - up/4 - right/4, self.shape)
							if not hit then 
								hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 - up/4 + right/4, self.shape)
							end
						end
					end
				end
				--print(bullet.pos)
				if hit then
					bullet.hit = true
					bullet.result = result.pointWorld
					bullet.effect:setPosition(sm.vec3.new(0,0,1000000))
					bullet.thrust:setPosition(sm.vec3.new(0,0,1000000))
				else
					bullet.pos = bullet.pos + bullet.direction * dt
					bullet.effect:setPosition(bullet.pos)
					bullet.thrust:setPosition(bullet.pos - self.shape.up)
					self:paint_smoke(bullet.pos)
					bullet.alive = bullet.alive + dt
				end
			end
		end
	end
end

function HuoJianDan.client_onShoot( self, data )
	self.boltValue = 1.0
	
	local rot = sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), self.shape.up )
	local rot1 = sm.vec3.getRotation( sm.vec3.new( 0, 0, -1 ), self.shape.up )
	local position = self.shape.worldPosition
	
	local bullet = {effect = sm.effect.createEffect("HuoJianDanShell"),thrust = sm.effect.createEffect("Thruster - Level 1"), pos = position, direction = data.dir, alive = 0, grav = data.gravity*0.2} -- -  self.shape.up*0.5
	
	bullet.effect:setPosition( position )
	bullet.effect:setRotation( rot )
	
	bullet.thrust:setPosition( position )
	bullet.thrust:setRotation( rot1 )
	
	print(position)
	
	bullet.effect:start()
	bullet.thrust:start()
	
	self.bullets[#self.bullets+1] = bullet

	--self.shootEffect:start()
	--sm.audio.play("Gas Explosion", self.pos1 )
	
	
end

function HuoJianDan.client_shellVisible(self, Data)
	self.shellVisible = Data
end


function getLocal(shape, vec)
    return sm.vec3.new(sm.shape.getRight(shape):dot(vec), sm.shape.getAt(shape):dot(vec), sm.shape.getUp(shape):dot(vec))
end

function HuoJianDan.paint_smoke(self, smokePos)
	self.color = sm.color.new( 0xeeeeeeff )
	if nil ~= self then
		sm.particle.createParticle("paint_smoke", smokePos, nil, self.color)
	end
end
