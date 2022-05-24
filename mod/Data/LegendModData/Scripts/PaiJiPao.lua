-----------------------------------------------
--This script contains code from Brent Batch---
--------Copyright (c) 2020 Brent Batch---------
------------Modified by David Sirius-----------
-----------------------------------------------

PaiJiPao = class( nil )
PaiJiPao.maxParentCount = 1
PaiJiPao.maxChildCount = 0
PaiJiPao.connectionInput = sm.interactable.connectionType.logic
PaiJiPao.connectionOutput = sm.interactable.connectionType.none
PaiJiPao.colorNormal = sm.color.new( 0xcb0a00ff )
PaiJiPao.colorHighlight = sm.color.new( 0xee0a00ff )
PaiJiPao.poseWeightCount = 1
PaiJiPao.fireDelay = 120 --ticks
PaiJiPao.spreadDeg = 1
PaiJiPao.recoilForce = 0.05	--后坐力倍数
PaiJiPao.destructionRadius = 5	--破坏半径
PaiJiPao.shellMass = 20.0		--炮弹质量
PaiJiPao.fireForceTable = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100}

function PaiJiPao.server_onCreate( self ) 
	self:server_init()
	
	self.forceIndex = self.storage:load()
	if self.forceIndex == nil then
		self.forceIndex = 5
		self.fireForce = self.fireForceTable[self.forceIndex]
		self.storage:save(self.forceIndex)
	else
		self.fireForce = self.fireForceTable[self.forceIndex]
	end
	
	self.network:sendToClients("client_getUIData", self.forceIndex)
end

function PaiJiPao.server_forceChange( self, forceIndex )
	self.forceIndex = forceIndex
	self.fireForce = self.fireForceTable[self.forceIndex]
	self.storage:save(self.forceIndex)
end

function PaiJiPao.server_init( self ) 
	self.fireDelayProgress = 0
	self.canFire = true
	self.parentActive = false
end

function PaiJiPao.server_onRefresh( self )
	self:server_init()
end

function PaiJiPao.server_onFixedUpdate( self, timeStep )

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
					sm.physics.explode( bullet.result, 8, self.destructionRadius, 12 , 40,"PropaneTank - ExplosionBig")
				end
				self.bullets[k] = nil
			end
		end
	end	
end

function PaiJiPao.server_tryFire( self )
	local parent = self.interactable:getSingleParent()
	if parent then
		if parent:isActive() and not self.parentActive and self.canFire then
			self.canFire = false
			--local firePos = sm.vec3.new( 0.0, 0.0, 0.375 )
			
			--local fireForce = math.random( self.minForce, self.maxForce )
			local dir = sm.noise.gunSpread( self.shape.up, self.spreadDeg )
		
			self.network:sendToClients( "client_onShoot", {dir = dir*self.fireForce, gravity = sm.physics.getGravity()})

			local impulse = dir * -self.fireForce * self.shellMass * self.recoilForce
			sm.physics.applyImpulse( self.shape, impulse )
			
			local shapePos = sm.shape.getWorldPosition(self.shape)
			local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
			local offSetPos = (self.shape.right * 0) + (self.shape.up * 1.0) + (self.shape.at * 0.0)
			local effectPos = shapePos + offSetPos
			sm.effect.playEffect( "PaiJiPaoShot", effectPos, nil, rot )
		end
	end
end

-- Client

function PaiJiPao.client_onCreate( self )
	self.boltValue = 0.0
	self.bullets = {}
	
	posaudio = sm.shape.getWorldPosition( self.shape ) + self.shape.up * 0.625
		
	rot = sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), self.shape.up )
	
	--self.shootEffect = sm.effect.createEffect( "Cannon1Shot", self.interactable )
	
end

function PaiJiPao.client_onFixedUpdate( self, dt )

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
				
				local hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 )
				if not hit then 
					hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 + up/4 + right/4)
					if not hit then 
						hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 + up/4 - right/4)
						if not hit then 
							hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 - up/4 - right/4)
							if not hit then 
								hit, result = sm.physics.raycast( bullet.pos, bullet.pos + bullet.direction * dt*1.1 - up/4 + right/4)
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

function PaiJiPao.client_onShoot( self, data )
	self.boltValue = 1.0
	local rot = sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), self.shape.up )

	local position = self.shape.worldPosition + self.shape.up*0.2
	local bullet = {effect = sm.effect.createEffect("PaiJiPaoShell"), pos = position, direction = data.dir, alive = 0, grav = data.gravity} -- -  self.shape.up*0.5
	bullet.effect:setPosition( position )
	bullet.effect:setRotation( rot )
	
	--print(position)
	
	bullet.effect:start()
	self.bullets[#self.bullets+1] = bullet

	--self.shootEffect:start()	
	
	--sm.audio.play("Gas Explosion", self.pos1 )
end


function getLocal(shape, vec)
    return sm.vec3.new(sm.shape.getRight(shape):dot(vec), sm.shape.getAt(shape):dot(vec), sm.shape.getUp(shape):dot(vec))
end

function PaiJiPao.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
end

function PaiJiPao.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Mortar迫击炮")
		self.gui:setText("Interaction", "Set Fire Force 设置开火力量")		
		self.gui:setIconImage("Icon", sm.uuid.new("5002aacd-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.fireForceTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Fire Force 开火力量: "..self.fireForceTable[self.UIPosIndex])
	self.gui:open()
end

function PaiJiPao.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Fire Force 开火力量"..self.fireForceTable[newIndex])
	end
	self.network:sendToServer("server_forceChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function PaiJiPao.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置开火力量 Set Fire Force")
	return true
end
