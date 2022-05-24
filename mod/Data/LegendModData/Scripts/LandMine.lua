----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

LandMine = class()
LandMine.maxParentCount = 1
LandMine.maxChildCount = 0
LandMine.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
LandMine.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
LandMine.colorNormal = sm.color.new( 0xcb0a00ff )
LandMine.colorHighlight = sm.color.new( 0xee0a00ff )
LandMine.poseWeightCount = 1
LandMine.fireDelay = 0 --ticks (2 seconds)
LandMine.fuseDelay = 0.0001


--[[ Server ]]

-- (Event) Called upon creation on server
function LandMine.server_onCreate( self )
	self:server_init()
end

-- (Event) Called when script is refreshed (in [-dev])
function LandMine.server_onRefresh( self )
	self:server_init()
end

-- Initialize LandMine
function LandMine.server_init( self )
	self.alive = true
	self.counting = false
	self.fireDelayProgress = 0

	-- Default values. Overwritten by data.
	self.destructionLevel = 1
	self.destructionRadius = 1.0
	self.impulseRadius = 12.0
	self.impulseMagnitude = 400.0
	self.TriggerDistance = 1
	

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
		if self.data.TriggerDistance then
			self.TriggerDistance = self.data.TriggerDistance
		end
	end
end

function LandMine.server_getPlayerDistance( self )
	self.nearestDistance = nil
	local shapePos = sm.shape.getWorldPosition(self.shape)
	
	for id,Player in pairs(sm.player.getAllPlayers()) do
		self.playerDistance = sm.vec3.length2(shapePos - Player.character:getWorldPosition())
		if self.nearestDistance == nil or self.playerDistance < self.nearestDistance then
			self.nearestDistance = self.playerDistance
		end
	end
	--print(self.playerDistance)
	if self.nearestDistance < self.TriggerDistance then
		self.playTrigger = true
	else
		self.playTrigger = false
	end
end

-- (Event) Called upon game tick. (40 times a second)
function LandMine.server_onFixedUpdate( self, timeStep )
	self:server_getPlayerDistance()
	if self.counting then
		self.fireDelayProgress = self.fireDelayProgress + 1
		if self.fireDelayProgress >= self.fireDelay then
			self:server_tryExplode()
		end
	elseif self.playTrigger == true then
		self:server_tryExplode()
	else
		Parent = self.interactable:getSingleParent()
		if Parent then
			if  Parent:isActive() == true then
				self:server_tryExplode()
			end
		end	
	end
end

-- Attempt to create an explosion
function LandMine.server_tryExplode( self )
	if self.alive and self.shape.body.destructable then
		self.alive = false
		self.counting = false
		self.fireDelayProgress = 0

		-- Create explosion
		sm.physics.explode( self.shape.worldPosition, self.destructionLevel, self.destructionRadius, self.impulseRadius, self.impulseMagnitude, self.explosionEffectName, self.shape )
		sm.shape.destroyPart( self.shape )
	end
end

-- (Event) Called upon getting hit by a projectile.
function LandMine.server_onProjectile( self, hitPos, hitTime, hitVelocity, hitType )
	if self.alive and self.shape.body.destructable then
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
function LandMine.server_onSledgehammer( self, hitPos, player )
	if self.alive and self.shape.body.destructable then
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
function LandMine.server_onExplosion( self, center, destructionLevel )
	-- Explode within a few ticks
	if self.alive and self.shape.body.destructable then
		self.fireDelay = 5
		self.counting = true
	end
end

-- (Event) Called upon collision with another object
function LandMine.server_onCollision( self, other, collisionPosition, selfPointVelocity, otherPointVelocity, collisionNormal )
	local collisionDirection = (selfPointVelocity - otherPointVelocity):normalize()
	local diffVelocity = (selfPointVelocity - otherPointVelocity):length()
	local selfPointVelocityLength = selfPointVelocity:length()
	local otherPointVelocityLength = otherPointVelocity:length()
	local scaleFraction = 1.0 - ( self.fireDelayProgress / self.fireDelay )
	local dotFraction = math.abs( collisionDirection:dot( collisionNormal ) )

	local hardTrigger = diffVelocity * dotFraction >= 0
	local lightTrigger = diffVelocity * dotFraction >= 0
	
	if self.alive and self.shape.body.destructable then
		if hardTrigger  then
			-- Trigger explosion immediately
			self.counting = true
			self.fireDelayProgress = self.fireDelayProgress + self.fireDelay
		elseif lightTrigger then
			-- Trigger explosion countdown
			if not self.counting then
				self:server_startCountdown()
				self.network:sendToClients( "client_hitActivation", collisionPosition )
			else
				self.fireDelayProgress = self.fireDelayProgress + self.fireDelay * ( 1.0 - scaleFraction )
			end
		end
	end
end

-- Start countdown and update clients
function LandMine.server_startCountdown( self )
	self.counting = true
	self.network:sendToClients( "client_startCountdown" )
end


--[[ Client ]]

-- (Event) Called upon creation on client
function LandMine.client_onCreate( self )
	self.client_counting = false
	self.client_fuseDelayProgress = 0
	self.client_fireDelayProgress = 0
	self.client_poseScale = 0
	self.client_effect_doOnce = true

	-- Default values. Overwritten by data.
	self.explosionEffectName = "PropaneTank - ExplosionSmall"
	self.activateEffectName = "PropaneTank - ActivateSmall"

	-- Read data from interactive.json. See "scripted": "data".
	if self.data then
		if self.data.effectExplosion then
			self.explosionEffectName = self.data.effectExplosion
		end
		if self.data.effectActivate then
			self.activateEffectName = self.data.effectActivate
		end
	end

	self.singleHitEffect = sm.effect.createEffect( "PropaneTank - SingleActivate", self.interactable )
	self.activateEffect = sm.effect.createEffect( self.activateEffectName, self.interactable )
end

-- (Event) Called upon every frame. (Same as fps)
function LandMine.client_onUpdate( self, dt )
	if self.client_counting then
		self.interactable:setPoseWeight( 0,(self.client_fuseDelayProgress*1.5) +self.client_poseScale )
		self.client_fuseDelayProgress = self.client_fuseDelayProgress + dt
		self.client_poseScale = self.client_poseScale +(0.25*dt)

		if self.client_fuseDelayProgress >= self.fuseDelay then
			self.client_fuseDelayProgress = self.client_fuseDelayProgress - self.fuseDelay
		end

		self.client_fireDelayProgress = self.client_fireDelayProgress + dt
		self.activateEffect:setParameter( "progress", self.client_fireDelayProgress / ( self.fireDelay * ( 1 / 40 ) ) )
	end
end

-- Called from server upon getting triggered by a hit
function LandMine.client_hitActivation( self, hitPos )
	local localPos = self.shape:transformPoint( hitPos )

	local smokeDirection = ( hitPos - self.shape.worldPosition ):normalize()
	local worldRot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), smokeDirection )
	local localRot = self.shape:transformRotation( worldRot )

	self.singleHitEffect:start()
	self.singleHitEffect:setOffsetRotation( localRot )
	self.singleHitEffect:setOffsetPosition( localPos )
end

-- Called from server upon countdown start
function LandMine.client_startCountdown( self )
	self.client_counting = true
	self.activateEffect:start()

	local offsetRotation = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), sm.vec3.new( 0, 1, 0 ) ) * sm.vec3.getRotation( sm.vec3.new( 1, 0, 0 ), sm.vec3.new( 0, 1, 0 ) )
	self.activateEffect:setOffsetRotation( offsetRotation )
end


