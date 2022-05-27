----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

JiaTeLin = class()
JiaTeLin.maxParentCount = 2
JiaTeLin.maxChildCount = 0
JiaTeLin.connectionInput = bit.bor( sm.interactable.connectionType.logic, sm.interactable.connectionType.ammo )
JiaTeLin.connectionOutput = sm.interactable.connectionType.none
JiaTeLin.colorNormal = sm.color.new( 0xcb0a00ff )
JiaTeLin.colorHighlight = sm.color.new( 0xee0a00ff )
JiaTeLin.poseWeightCount = 1

local FireDelay = 1 --ticks
local MinForce = 410.0
local MaxForce = 390.0
local SpreadDeg = 5.0
local Damage = 60
local recoilForce = 0.2	--后坐力倍数


--[[ Server ]]

-- (Event) Called upon creation on server
function JiaTeLin.server_onCreate( self )
	self:sv_init()
end

-- (Event) Called when script is refreshed (in [-dev])
function JiaTeLin.server_onRefresh( self )
	self:sv_init()
end

-- Initialize mounted gun
function JiaTeLin.sv_init( self )
	self.sv = {}
	self.sv.fireDelayProgress = 0
	self.sv.canFire = true
	self.sv.parentActive = false
end

-- (Event) Called upon game tick. (40 times a second)
function JiaTeLin.server_onFixedUpdate( self, timeStep )
	if not self.sv.canFire then
		self.sv.fireDelayProgress = self.sv.fireDelayProgress + 1
		if self.sv.fireDelayProgress >= FireDelay then
			self.sv.fireDelayProgress = 0
			self.sv.canFire = true
		end
	end
	self:sv_tryFire()
	local logicInteractable, _ = self:getInputs()
	if logicInteractable then
		self.sv.parentActive = logicInteractable:isActive()
	end
end

-- Attempt to fire a projectile
function JiaTeLin.sv_tryFire( self )
	local logicInteractable, ammoInteractable = self:getInputs()
	local active = logicInteractable and logicInteractable:isActive() or false
	local ammoContainer = ammoInteractable and ammoInteractable:getContainer( 0 ) or nil
	local freeFire = not sm.game.getEnableAmmoConsumption() and not ammoContainer
	freeFire = true

	if freeFire then
		if active and not self.sv.parentActive and self.sv.canFire then
			self:sv_fire()
		end
	else
		if active and not self.sv.parentActive and self.sv.canFire and ammoContainer then
			sm.container.beginTransaction()
			sm.container.spend( ammoContainer, obj_plantables_potato, 1 )
			if sm.container.endTransaction() then
				self:sv_fire()
			end
		end
	end
end

function JiaTeLin.sv_fire( self )
	self.sv.canFire = false
	local firePos = sm.vec3.new( 0.0, 0.0, 1.0 )
	local fireForce = math.random( MinForce, MaxForce )

	-- Add random spread
	local dir = sm.noise.gunSpread( sm.vec3.new( 0.0, 0.0, 1.0 ), SpreadDeg )

	-- Fire projectile from the shape
	sm.projectile.shapeProjectileAttack( "potato", Damage, firePos, dir * fireForce, self.shape )

	self.network:sendToClients( "cl_onShoot" )
end


--[[ Client ]]

-- (Event) Called upon creation on client
function JiaTeLin.client_onCreate( self )
	self.cl = {}
	self.cl.boltValue = 0.0
	self.cl.shootEffect = sm.effect.createEffect( "MountedPotatoRifle - Shoot", self.interactable )
end

-- (Event) Called upon every frame. (Same as fps)
function JiaTeLin.client_onUpdate( self, dt )
	if self.cl.boltValue > 0.0 then
		self.cl.boltValue = self.cl.boltValue - dt * 10
	end
	if self.cl.boltValue ~= self.cl.prevBoltValue then
		self.interactable:setPoseWeight( 0, self.cl.boltValue ) --Clamping inside
		self.cl.prevBoltValue = self.cl.boltValue
	end
end

function JiaTeLin.client_getAvailableParentConnectionCount( self, connectionType )
	if bit.band( connectionType, sm.interactable.connectionType.logic ) ~= 0 then
		return 1 - #self.interactable:getParents( sm.interactable.connectionType.logic )
	end
	if bit.band( connectionType, sm.interactable.connectionType.ammo ) ~= 0 then
		return 1 - #self.interactable:getParents( sm.interactable.connectionType.ammo )
	end
	return 0
end

-- Called from server upon the gun shooting
function JiaTeLin.cl_onShoot( self )
	self.cl.boltValue = 1.0
	self.cl.shootEffect:start()
	local impulse = sm.vec3.new( 0, 0, -1 ) * 500 * recoilForce
	sm.physics.applyImpulse( self.shape, impulse )
end

function JiaTeLin.getInputs( self )
	local logicInteractable = nil
	local ammoInteractable = nil
	local parents = self.interactable:getParents()
	if parents[2] then
		if parents[2]:hasOutputType( sm.interactable.connectionType.logic ) then
			logicInteractable = parents[2]
		elseif parents[2]:hasOutputType( sm.interactable.connectionType.ammo ) then
			ammoInteractable = parents[2]
		end
	end
	if parents[1] then
		if parents[1]:hasOutputType( sm.interactable.connectionType.logic ) then
			logicInteractable = parents[1]
		elseif parents[1]:hasOutputType( sm.interactable.connectionType.ammo ) then
			ammoInteractable = parents[1]
		end
	end

	return logicInteractable, ammoInteractable
end
