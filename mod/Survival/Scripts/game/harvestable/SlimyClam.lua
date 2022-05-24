dofile("$SURVIVAL_DATA/Scripts/game/survival_loot.lua")

SlimyClam = class()


function SlimyClam.server_onMelee( self, hitPos, attacker, damage )
	self:sv_onHit()
end

function SlimyClam.server_onExplosion( self, center, destructionLevel )
	self:sv_onHit()
end

function SlimyClam.sv_onHit( self )
	if not self.harvested and sm.exists( self.harvestable ) then
		if SurvivalGame then
			local lootList = {}
			local count = randomStackAmountAvg2()
			for i = 1, count do
				lootList[i] = { uuid = obj_resources_slimyclam, quantity = 100 }
			end
			SpawnLoot( self.harvestable, lootList, self.harvestable.worldPosition + sm.vec3.new( 0, 0, 0.25 ), math.pi / 36 )
		end

		sm.effect.playEffect("SlimyClam - Destruct", self.harvestable.worldPosition, nil, self.harvestable.worldRotation )
		sm.harvestable.create( hvs_farmables_slimyclam_broken, self.harvestable.worldPosition, self.harvestable.worldRotation )
		sm.harvestable.destroy( self.harvestable )
		self.harvested = true
	end
end

function SlimyClam.client_onCreate( self )
	self.cl = {}
	self.cl.bubbleEffect = sm.effect.createEffect( "SlimyClam - Bubbles" )
	self.cl.bubbleEffect:setPosition( self.harvestable.worldPosition )
	self.cl.bubbleEffect:setRotation( self.harvestable.worldRotation )
	self.cl.bubbleEffect:start()
end

function SlimyClam.client_onDestroy( self )
	self.cl.bubbleEffect:stop()
	self.cl.bubbleEffect:destroy()
end