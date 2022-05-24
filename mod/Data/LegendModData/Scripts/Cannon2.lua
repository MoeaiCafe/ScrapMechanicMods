-----------------------------------------------
--This script contains code from Brent Batch---
--------Copyright (c) 2020 Brent Batch---------
------------Modified by David Sirius-----------
-----------------------------------------------

Cannon2 = class( nil )
Cannon2.maxParentCount = 1
Cannon2.maxChildCount = 0
Cannon2.connectionInput = sm.interactable.connectionType.logic
Cannon2.connectionOutput = sm.interactable.connectionType.none
Cannon2.colorNormal = sm.color.new( 0xcb0a00ff )
Cannon2.colorHighlight = sm.color.new( 0xee0a00ff )
Cannon2.poseWeightCount = 1
Cannon2.fireDelay = 2 --ticks
Cannon2.minForce = 300
Cannon2.maxForce = 300
Cannon2.spreadDeg = 0.1
Cannon2.recoilForce = 0.02	--后坐力倍数
Cannon2.destructionRadius = 0.2	--破坏半径
Cannon2.shellMass = 3.0		--炮弹质量

function Cannon2.server_onCreate( self ) 
	self:server_init()
end

function Cannon2.server_init( self ) 
	self.fireDelayProgress = 0
	self.canFire = true
	self.parentActive = false
end

function Cannon2.server_onRefresh( self )
	self:server_init()
end

function Cannon2.server_onFixedUpdate( self, timeStep )

	if not self.canFire then
		self.fireDelayProgress = self.fireDelayProgress + 1
		if self.fireDelayProgress >= self.fireDelay then
			self.fireDelayProgress = 0
			self.canFire = true	
		end
	end
	self:server_tryFire()
	local parent = self.interactable:getSingleParent()
	if parent then
		self.parentActive = parent:isActive()
	end
	
	for k, bullet in pairs(self.bullets) do
		if bullet then
			if bullet.hit or bullet.alive > 200 then --lives for 2 sec, clean up after
				if bullet.hit then
					--position, level, destructionRadius, impulseRadius, magnitude
					sm.physics.explode( bullet.result, 7, self.destructionRadius, 12 , 40,"PropaneTank - ExplosionSmall")
				end
				self.bullets[k] = nil
			end
		end
	end	
end

function Cannon2.server_tryFire( self )
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
			local offSetPos = (self.shape.right * 0) + (self.shape.up * 0.8) + (self.shape.at * 0.0)
			local effectPos = shapePos + offSetPos
			sm.effect.playEffect( "Cannon2Shot", effectPos, nil, rot )
		end
	end
end

-- Client

function Cannon2.client_onCreate( self )
	self.boltValue = 0.0
	self.bullets = {}
	
	posaudio = sm.shape.getWorldPosition( self.shape ) + self.shape.up * 0.625
		
	--rot = sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), self.shape.up )
	
	--self.shootEffect = sm.effect.createEffect( "Cannon2Shot", self.interactable )
	
end

function Cannon2.client_onFixedUpdate( self, dt )

	self.pos1 = sm.shape.getWorldPosition(self.shape)
	--print(self.pos1)

	if self.boltValue > 0.0 then
		self.boltValue = self.boltValue - dt * 5
	end
	if self.boltValue ~= self.prevBoltValue then
		self.interactable:setPoseWeight( 0, self.boltValue ) --Clamping inside
		self.prevBoltValue = self.boltValue
	end
	--print(self.bullets)
	for k, bullet in pairs(self.bullets) do
		if bullet then
			if bullet.hit or bullet.alive > 200 then --lives for 2 sec, clean up after
				bullet.effect:stop()
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
				else
					bullet.pos = bullet.pos + bullet.direction * dt
					bullet.effect:setPosition(bullet.pos)
					bullet.alive = bullet.alive + dt
				end
			end
		end
	end
end

function Cannon2.client_onShoot( self, data )
	self.boltValue = 1.0
	local rot = sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), self.shape.up )

	local position = self.shape.worldPosition
	local bullet = {effect = sm.effect.createEffect("Cannon2Shell"), pos = position, direction = data.dir, alive = 0, grav = data.gravity} -- -  self.shape.up*0.5
	bullet.effect:setPosition( position )
	bullet.effect:setRotation( rot )
	
	--print(position)
	
	bullet.effect:start()
	self.bullets[#self.bullets+1] = bullet

	--self.shootEffect:start()	
	
	sm.audio.play("PotatoRifle - Shoot", self.pos1 )
end


function getLocal(shape, vec)
    return sm.vec3.new(sm.shape.getRight(shape):dot(vec), sm.shape.getAt(shape):dot(vec), sm.shape.getUp(shape):dot(vec))
end
