----------------------------------------------
-------Copyright (c) 2019 David Sirius--------
----------------------------------------------

AirCannon = class( nil )
AirCannon.maxChildCount = 0
AirCannon.maxParentCount = 1
AirCannon.connectionInput = sm.interactable.connectionType.logic
AirCannon.connectionOutput = sm.interactable.connectionType.none
AirCannon.colorNormal = sm.color.new( 0xcb0a00ff )
AirCannon.colorHighlight = sm.color.new( 0xee0a00ff )
AirCannon.poseWeightCount = 1
AirCannon.fireDelay = 120 --ticks
AirCannon.spreadDeg = 0.0
AirCannon.fireForceTable = { 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000}

function AirCannon.server_onCreate( self ) 
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

function AirCannon.server_forceChange( self, forceIndex )
	self.forceIndex = forceIndex
	self.fireForce = self.fireForceTable[self.forceIndex]
	self.storage:save(self.forceIndex)
end

function AirCannon.server_init( self ) 
	self.fireDelayProgress = 0
	self.canFire = true
	self.parentActive = false
end

function AirCannon.server_onRefresh( self )
	self:server_init()
end

function AirCannon.server_onFixedUpdate( self, timeStep )
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
end

function AirCannon.server_tryFire( self )
	local parent = self.interactable:getSingleParent()
	if parent then
		if parent:isActive() and not self.parentActive and self.canFire then
			self.canFire = false
			local firePos = sm.vec3.new( 0.0, 0.0, 0.45 )

			local dir = sm.noise.gunSpread( sm.vec3.new( 0.0, 0.0, 1.0 ), self.spreadDeg )
			
			--print("self.fireForce"..self.fireForce)
			sm.projectile.shapeFire( self.shape, "potato", firePos, dir * self.fireForce )
			
			self.network:sendToClients( "client_onShoot" )
			local mass = sm.projectile.getProjectileMass( "potato" )
			local impulse = dir * -self.fireForce * mass *0
			sm.physics.applyImpulse( self.shape, impulse )
		end
	end
end

-- Client

function AirCannon.client_onCreate( self )
	self.boltValue = 0.0
	self.shootEffect = sm.effect.createEffect( "AirCannonShell" )
end

function AirCannon.client_onUpdate( self, dt )
	if self.boltValue > 0.0 then
		self.boltValue = self.boltValue - dt * 10
	end
	if self.boltValue ~= self.prevBoltValue then
		self.interactable:setPoseWeight( 0, self.boltValue ) --Clamping inside
		self.prevBoltValue = self.boltValue
	end
	
	local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
	local pos = sm.shape.getWorldPosition( self.shape ) + self.shape.up * 0.625
	self.shootEffect:setPosition( pos )
	self.shootEffect:setRotation( rot )
end

function AirCannon.client_onShoot( self )
	self.boltValue = 1.0
	local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
	self.shootEffect:start()
end

function AirCannon.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
end

function AirCannon.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Air Cannon空气炮")
		self.gui:setText("Interaction", "Set Fire Force 设置开火力量")		
		self.gui:setIconImage("Icon", sm.uuid.new("5007aaba-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.fireForceTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Fire Force 开火力量: "..self.fireForceTable[self.UIPosIndex])
	self.gui:open()
end

function AirCannon.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Fire Force 开火力量"..self.fireForceTable[newIndex])
	end
	self.network:sendToServer("server_forceChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function AirCannon.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置开火力量 Set Fire Force")
	return true
end


