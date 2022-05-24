dofile("$SURVIVAL_DATA/Scripts/game/survival_loot.lua")

BrokenSlimyClam = class()

local GrowTickTime = DAYCYCLE_TIME_TICKS * 2.5

-- Server
function BrokenSlimyClam.server_onCreate( self )
	self.sv = self.storage:load()
	if self.sv == nil then
		self.sv = {}
		self.sv.lastTickUpdate = sm.game.getCurrentTick()
		self.sv.growTicks = 0
	end
end

function BrokenSlimyClam.server_onReceiveUpdate( self )
	self:sv_performUpdate()
end

function BrokenSlimyClam.sv_performUpdate( self )
	local currentTick = sm.game.getCurrentTick()
	local ticks = currentTick - self.sv.lastTickUpdate
	ticks = math.max( ticks, 0 )
	self.sv.lastTickUpdate = currentTick
	self:sv_updateTicks( ticks )
	
	self.storage:save( self.sv )
end

function BrokenSlimyClam.sv_updateTicks( self, ticks )
	if not self.sv.repaired and sm.exists( self.harvestable ) then
		self.sv.growTicks = math.min( self.sv.growTicks + ticks, GrowTickTime )
		local growFraction = self.sv.growTicks / GrowTickTime
		if growFraction >= 1.0 then
			sm.harvestable.create( hvs_farmables_slimyclam, self.harvestable.worldPosition, self.harvestable.worldRotation )
			sm.harvestable.destroy( self.harvestable )
			self.sv.repaired = true
		end
	end
end

-- Client
function BrokenSlimyClam.client_onCreate( self )
	sm.effect.playEffect("SlimyClam - Destruct", self.harvestable.worldPosition, nil, self.harvestable.worldRotation )
end
