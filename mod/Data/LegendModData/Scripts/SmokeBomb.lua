----------------------------------------------
-------Copyright (c) 2019 David Sirius--------
----------------------------------------------

SmokeBomb = class()
SmokeBomb.maxParentCount = 1
SmokeBomb.maxChildCount = 0
SmokeBomb.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
SmokeBomb.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
SmokeBomb.colorNormal = sm.color.new( 0xcb0a00ff )
SmokeBomb.colorHighlight = sm.color.new( 0xee0a00ff )
SmokeBomb.poseWeightCount = 1

SmokeBomb.fireDelay = 20 --ticks (2 seconds)
SmokeBomb.fuseDelay = 0.0625

SmokeBomb.destoryTime = 2400 --ticks


--[[ Server ]]

-- (Event) Called upon creation on server
function SmokeBomb.server_onCreate( self )
	self:server_init()
	self.destoryCounting = 1
end

-- (Event) Called when script is refreshed (in [-dev])
function SmokeBomb.server_onRefresh( self )
	self:server_init()
end

-- Initialize SmokeBomb
function SmokeBomb.server_init( self )
	self.alive = true
	self.counting = false
	self.fireDelayProgress = 0

	-- Default values. Overwritten by data.
	self.destructionLevel = 1
	self.destructionRadius = 1.0
	self.impulseRadius = 12.0
	self.impulseMagnitude = 400.0

	-- Read data from interactive.json. See "scripted": "data".
	if self.data then
		if self.data.destructionLevel then
			self.destructionLevel = self.data.destructionLevel
		end
		if self.data.destructionRadius then
			self.destructionRadius = self.data.destructionRadius
		end
		if self.data.impulseRadius then
			self.impulseRadius = self.data.impulseRadius
		end
		if self.data.impulseMagnitude then
			self.impulseMagnitude = self.data.impulseMagnitude
		end
	end
end

-- (Event) Called upon game tick. (40 times a second)
function SmokeBomb.server_onFixedUpdate( self, timeStep )
	Parent = self.interactable:getSingleParent()
	if self.counting then
		self.fireDelayProgress = self.fireDelayProgress + 1
		if self.fireDelayProgress >= self.fireDelay then
			self.network:sendToClients("client_smokeEffect",true)
			self.selfDestoryStart = true
		else
			self.selfDestoryStart = false
		end
		
	elseif Parent then
		if  Parent:isActive() == true then
			self.network:sendToClients("client_smokeEffect",true)
			self.selfDestoryStart = true
		else
			self.network:sendToClients("client_smokeEffect",false)
			self.selfDestoryStart = false
		end
	else
		self.network:sendToClients("client_smokeEffect",false)
		self.selfDestoryStart = false
	end

	if self.selfDestoryStart == true then
		self.destoryCounting = self.destoryCounting +1
	end
	
	if self.destoryCounting == self.destoryTime then
		sm.shape.destroyPart( self.shape )
	end
end

-- (Event) Called upon getting hit by a projectile.
function SmokeBomb.server_onProjectile( self, hitPos, hitTime, hitVelocity, hitType )
	if self.alive then
		if self.counting then
			self.fireDelayProgress = self.fireDelayProgress + self.fireDelay * 0.5
		else
			-- Trigger explosion countdown
			self:server_startCountdown()
			self.network:sendToClients( "client_hitActivation", hitPos )
		end
	end
end

-- (Event) Called upon getting hit by a sledgehammer.
function SmokeBomb.server_onSledgehammer( self, hitPos, player )
	if self.alive then
		if self.counting then
			self.fireDelayProgress = self.fireDelayProgress + self.fireDelay * 0.5
		else
			-- Trigger explosion countdown
			self:server_startCountdown()
			self.network:sendToClients( "client_hitActivation", hitPos )
		end
	end
end

-- (Event) Called upon collision with an explosion nearby
function SmokeBomb.server_onExplosion( self, center, destructionLevel )
	-- Explode within a few ticks
	if self.alive then
		self.fireDelay = 5
		self.counting = true
	end
end

-- (Event) Called upon collision with another object
function SmokeBomb.server_onCollision( self, other, collisionPosition, selfPointVelocity, otherPointVelocity, collisionNormal )
	local collisionDirection = (selfPointVelocity - otherPointVelocity):normalize()
	local diffVelocity = (selfPointVelocity - otherPointVelocity):length()
	local selfPointVelocityLength = selfPointVelocity:length()
	local otherPointVelocityLength = otherPointVelocity:length()
	local scaleFraction = 1.0 - ( self.fireDelayProgress / self.fireDelay )
	local dotFraction = math.abs( collisionDirection:dot( collisionNormal ) )

	local hardTrigger = diffVelocity * dotFraction >= 10 * scaleFraction
	local lightTrigger = diffVelocity * dotFraction >= 6 * scaleFraction

	if self.alive then
		if hardTrigger  then
			-- Trigger explosion immediately
			self.counting = true
			self.fireDelayProgress = self.fireDelayProgress + self.fireDelay
		elseif lightTrigger then
			-- Trigger explosion countdown
			if not self.counting then
				self:server_startCountdown()
			else
				self.fireDelayProgress = self.fireDelayProgress + self.fireDelay * ( 1.0 - scaleFraction )
			end
		end
	end
end

-- Start countdown and update clients
function SmokeBomb.server_startCountdown( self )
	self.counting = true
	self.network:sendToClients( "client_startCountdown" )
end


--[[ Client ]]

-- (Event) Called upon creation on client
function SmokeBomb.client_onCreate( self )
	self.client_counting = false
	self.client_fuseDelayProgress = 0
	self.client_fireDelayProgress = 0
	self.client_poseScale = 0
	self.client_effect_doOnce = true

	-- Default values. Overwritten by data.
	self.explosionEffectName = "PropaneTank - ExplosionBig"
	self.activateEffectName = "PropaneTank - ActivateBig"

	-- Read data from interactive.json. See "scripted": "data".
	if self.data then
		if self.data.effectExplosion then
			self.explosionEffectName = self.data.effectExplosion
		end
		if self.data.effectActivate then
			self.activateEffectName = self.data.effectActivate
		end
	end

	self.somkeEffect = sm.effect.createEffect( "Smoke Bomb", self.interactable )
	self.somkeEffect:setOffsetRotation( sm.quat.angleAxis( math.rad(-90.0), sm.vec3.new( 1, 0, 0 ) )) 
end

-- (Event) Called upon every frame. (Same as fps)
function SmokeBomb.client_onUpdate( self, dt )
	if self.client_counting then
		self.interactable:setPoseWeight( 0,(self.client_fuseDelayProgress*1.5) +self.client_poseScale )
		self.client_fuseDelayProgress = self.client_fuseDelayProgress + dt
		self.client_poseScale = self.client_poseScale +(0.25*dt)

		if self.client_fuseDelayProgress >= self.fuseDelay then
			self.client_fuseDelayProgress = self.client_fuseDelayProgress - self.fuseDelay
		end

		self.client_fireDelayProgress = self.client_fireDelayProgress + dt
	end
end

-- Called from server upon getting triggered by a hit
function SmokeBomb.client_hitActivation( self, hitPos )
	local localPos = self.shape:transformPoint( hitPos )

	local smokeDirection = ( hitPos - self.shape.worldPosition ):normalize()
	local worldRot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), smokeDirection )
	local localRot = self.shape:transformRotation( worldRot )
end

-- Called from server upon countdown start
function SmokeBomb.client_startCountdown( self )
	self.client_counting = true

	local offsetRotation = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), sm.vec3.new( 0, 1, 0 ) ) * sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), sm.vec3.new( 0, 1, 0 ) )
end

function SmokeBomb.client_smokeEffect( self, playEffect )
	if playEffect == true then
		if not self.somkeEffect:isPlaying() then
			self.somkeEffect:start()
		end
	else
		if self.somkeEffect:isPlaying() then
			self.somkeEffect:stop()
		end
	end
end

function SmokeBomb.client_onDestroy(self )
	self.somkeEffect:stop()
end
