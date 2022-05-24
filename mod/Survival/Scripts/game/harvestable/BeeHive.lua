dofile("$SURVIVAL_DATA/Scripts/game/survival_loot.lua")

BeeHive = class()

function BeeHive.server_onProjectile( self, hitPos, hitTime, hitVelocity, projectileName, attacker, damage )
	self:sv_onHit()
end

function BeeHive.server_onMelee( self, hitPos, attacker, damage )
	self:sv_onHit()
end

function BeeHive.server_onExplosion( self, center, destructionLevel )
	self:sv_onHit()
end

function BeeHive.sv_onHit( self )
	if not self.destroyed and sm.exists( self.harvestable ) then

		local lootList = {}
		local slots = math.random( 9, 10 )
		for i = 1, slots do
			lootList[i] = { uuid = obj_resource_beewax, quantity = 1 }
		end
		SpawnLoot( self.harvestable, lootList )
		
		sm.harvestable.create( hvs_farmables_beehive_broken, self.harvestable.worldPosition, self.harvestable.worldRotation )
		
		self.harvestable:destroy()
		self.destroyed = true
	end
end

function BeeHive.client_onCreate( self )
	self.cl = {}
	self.cl.swarmEffect = sm.effect.createEffect( "beehive - beeswarm" )
	self.cl.swarmEffect:setPosition( self.harvestable.worldPosition )
	self.cl.swarmEffect:setRotation( self.harvestable.worldRotation )
	self.cl.swarmEffect:start()
end

function BeeHive.client_onDestroy( self )
	self.cl.swarmEffect:stop()
	self.cl.swarmEffect:destroy()
end