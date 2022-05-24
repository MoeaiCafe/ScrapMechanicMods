----------------------------------------------------------
-------Copyright (c) 2020 FreshFish & David Sirius--------
----------------------------------------------------------

EffectsGenerator3 = class( nil )
EffectsGenerator3.maxParentCount = 1
EffectsGenerator3.maxChildCount = -1
EffectsGenerator3.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
EffectsGenerator3.connectionOutput = sm.interactable.connectionType.logic
EffectsGenerator3.colorNormal = sm.color.new(0xff00b4ff)
EffectsGenerator3.colorHighlight = sm.color.new(0xff33c2ff)
EffectsGenerator3.poseWeightCount = 1

--Particles and Effects List
local PEList = {
	--Environment
	{PE_name = "Forest - Grassblowing" },
	{PE_name = "Smoke - GroundSmokeMassive" },
	{PE_name = "Forest - SmallFog" },
	{PE_name = "Forest - MassiveFog" },
	{PE_name = "Smoke - embers" },
	{PE_name = "Forest - Fireflies" },
	{PE_name = "ChemicalLakes - SurfaceBubblesBig" },
	
	--Thruster
	{PE_name = "Thruster - Level 1" },
	{PE_name = "Thruster - Level 2" },
	{PE_name = "Thruster - Level 3" },
	{PE_name = "Thruster - Level 4" },
	{PE_name = "Thruster - Level 5" },
	{PE_name = "Builderbot - Thruster" },
	{PE_name = "Mechanic - JetpackThruster" },
	
	--Critters
	{PE_name = "Critter - Butterfly01" },
	{PE_name = "Critter - Butterfly02" },
	{PE_name = "Critter - NightMoth" },
	{PE_name = "Critter - Fly" },
	{PE_name = "Critter - Rottingsmoke" },
	{PE_name = "beehive - beeswarm" },
	
	--Other
	{PE_name = "sledgehammer_destruct_glass" },
	{PE_name = "spudgun_impact_glass" },
	{PE_name = "Woc - Destruct" },
	{PE_name = "CelebrationBot - Confetti" },
	{PE_name = "Vacuumpipe - Suction" },
	{PE_name = "Vacuumpipe - Blowout" },
	{PE_name = "Hideout - PumpSuction" },
	{PE_name = "BuildMode - Floor" },
	{PE_name = "Boop - Floor" },
	{PE_name = "Buildarea - Oncreate" },
	{PE_name = "Goal - Oncreate" },
	{PE_name = "challenge_goal_activate" },
	{PE_name = "Chest - Arrow" },
	{PE_name = "Oilgeyser - OilgeyserLoop"},
	{PE_name = "SlimyClam - Bubbles"},
	{PE_name = "Lakes - bubbles" },
	{PE_name = "Mechanic - KoLoop"},
	{PE_name = "DebriPart" },
	{PE_name = "Banana_Impact" },
	{PE_name = "Pineapple_Impact" },
	{PE_name = "Tomato_Impact" },
	{PE_name = "Orange_Impact" }
	
}

local ChineseList = {
	--Environment
	{Chinese_name = "风吹起的蒲公英和草  [ENVIRONMENT环境效果]" },
	{Chinese_name = "地面大量的烟  [ENVIRONMENT环境效果]" },
	{Chinese_name = "雾(小)  [ENVIRONMENT环境效果]" },
	{Chinese_name = "雾(大)  [ENVIRONMENT环境效果]" },
	{Chinese_name = "火星  [ENVIRONMENT环境效果]" },
	{Chinese_name = "萤火虫  [ENVIRONMENT环境效果]" },
	{Chinese_name = "化学品池的泡泡  [ENVIRONMENT环境效果]" },
	
	--Thruster
	{Chinese_name = "1级喷射器  [THRUSTER喷射器效果]" },
	{Chinese_name = "2级喷射器  [THRUSTER喷射器效果]" },
	{Chinese_name = "3级喷射器  [THRUSTER喷射器效果]" },
	{Chinese_name = "4级喷射器  [THRUSTER喷射器效果]" },
	{Chinese_name = "5级喷射器  [THRUSTER喷射器效果]" },
	{Chinese_name = "建造机器人喷射的火焰  [THRUSTER喷射器效果]" },
	{Chinese_name = "机械师的喷射背包  [THRUSTER喷射器效果]" },
	
	--Critter
	{Chinese_name = "蝴蝶01  [CRITTER动物效果]" },
	{Chinese_name = "蝴蝶02  [CRITTER动物效果]" },
	{Chinese_name = "夜蛾  [CRITTER动物效果]" },
	{Chinese_name = "苍蝇  [CRITTER动物效果]" },
	{Chinese_name = "腐烂的臭气  [CRITTER动物效果]" },
	{Chinese_name = "蜂巢的蜜蜂  [CRITTER动物效果]" },
	
	--Other
	{Chinese_name = "大锤击碎玻璃  [OTHER其他效果]" },
	{Chinese_name = "土豆枪击中玻璃  [OTHER其他效果]" },
	{Chinese_name = "沃克牛被杀死  [OTHER其他效果]" },
	{Chinese_name = "庆祝机器人的五彩纸屑  [OTHER其他效果]" },
	{Chinese_name = "真空管吸入  [OTHER其他效果]" },
	{Chinese_name = "真空管喷出  [OTHER其他效果]" },
	{Chinese_name = "老头藏身处的泵  [OTHER其他效果]" },
	{Chinese_name = "挑战模式建造模式的地板  [OTHER其他效果]" },
	{Chinese_name = "挑战模式的地板  [OTHER其他效果]" },
	{Chinese_name = "挑战模式的建造区  [OTHER其他效果]" },
	{Chinese_name = "挑战模式的终点  [OTHER其他效果]" },
	{Chinese_name = "挑战模式成功到达的终点  [OTHER其他效果]" },
	{Chinese_name = "指示箱子的箭头  [OTHER其他效果]" },
	{Chinese_name = "石油间歇泉冒出的石油  [OTHER其他效果]"},
	{Chinese_name = "胶蛤的气泡  [OTHER其他效果]"},
	{Chinese_name = "湖水的气泡  [OTHER其他效果]" },
	{Chinese_name = "倒地的机械师  [OTHER其他效果]"},
	{Chinese_name = "被炸坏的方块  [OTHER其他效果]" },
	{Chinese_name = "击碎的香蕉  [OTHER其他效果]" },
	{Chinese_name = "击碎的菠萝  [OTHER其他效果]" },
	{Chinese_name = "击碎的番茄  [OTHER其他效果]" },
	{Chinese_name = "击碎的橙子  [OTHER其他效果]" }
	
}

--Server

function EffectsGenerator3.server_onCreate( self )
	--载入存档
	self:server_loadSavedData()

	--通知客户端初始化
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

function EffectsGenerator3.server_onFixedUpdate( self, dt )

	--interactle active控制
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
		else
			self.interactable:setActive(false)
		end
	else
		self.interactable:setActive(false)
	end
	--若输入为对象为白色则控制自身隐形
	if self.input then
		self.inputColor = sm.shape.getColor(self.input:getShape())
		local whiteColor = sm.color.new(0xeeeeeeff)
		if self.inputColor == whiteColor then
			self.pw = 1
		else
			self.pw = 0
		end
	else
		self.pw = 0
	end
	self.network:sendToClients("client_Invisible",self.pw)
	
	self.particleName = PEList[self.currentEffect].PE_name
	
	if self.interactable:isActive() then
	
		if self.particleName == "paint_smoke" then
			if self.lastPos then
				self.network:sendToClients("paint_smoke", self.lastPos)
			end
			
		elseif self.particleName == "spudgun_basic_muzzel" then
			self.network:sendToClients("spudgun_basic_muzzel")
			
		elseif self.particleName == "construct_welding" then
			self.network:sendToClients("construct_welding")
			
		elseif self.particleName == "Spark01" then
			self.network:sendToClients("Spark01")
			
		elseif self.particleName == "Spark02" then
			self.network:sendToClients("Spark02")
			
		elseif self.particleName == "sledgehammer_destruct_glass" then
			self.network:sendToClients("sledgehammer_destruct_glass")
			
		elseif self.particleName == "spudgun_impact_glass" then
			self.network:sendToClients("spudgun_impact_glass")
			
		elseif self.particleName == "challenge_goal_activate" then
			self.network:sendToClients("challenge_goal_activate")
		
		elseif self.particleName == "parts_uppgrade" then
			if i then
				if i == 1 or i%10 == 0 then
					self.network:sendToClients("parts_uppgrade")
					i = 1
				end
				i = i+1
			else
				i = 1
			end
		
		elseif self.particleName == "DebriPart" then
			self.network:sendToClients("DebriPart")
			
		elseif self.particleName == "Laser" then
			self.network:sendToClients("Laser")
		
		elseif self.particleName == "Lightning" then
			self.network:sendToClients("Lightning")
		
		elseif self.particleName == "Watercanon_Muzzelflash" then
			self.network:sendToClients("Watercanon_Muzzelflash")
		
		elseif self.particleName == "Barrier" then
			if i then
				if i == 1 or i%5 == 0 then
					self.network:sendToClients("Barrier")
					i = 1
				end
				i = i+1
			else
				i = 1
			end
		
		elseif self.particleName == "Banana_Impact" then
			self.network:sendToClients("Banana_Impact")
			
		elseif self.particleName == "Pineapple_Impact" then
			self.network:sendToClients("Pineapple_Impact")
			
		elseif self.particleName == "Tomato_Impact" then
			self.network:sendToClients("Tomato_Impact")
			
		elseif self.particleName == "Orange_Impact" then
			self.network:sendToClients("Orange_Impact")
		
		end
	end
	self.lastPos = sm.shape.getWorldPosition(self.shape)
end

function EffectsGenerator3.server_saveData(self,data)
	self.storage:save( data )
end

function EffectsGenerator3.server_loadSavedData(self)
	self.loadEffect = self.storage:load()
	if self.loadEffect == nil then
		self.loadEffect = 1
	end

	self.currentEffect = self.loadEffect
	
	--有效值保护
	if self.currentEffect == nil or self.currentEffect == 0 or self.currentEffect > table.maxn(PEList) then
		self.currentEffect = 1
	end
end

function EffectsGenerator3.server_onChangeEffectRequest(self,reverse)
	local currentEffectIndex = self.currentEffect
	
	local targetIndex = (self.currentEffect + (reverse and -1 or 1))
	
	local maxIndex = table.maxn(PEList)
	if targetIndex > maxIndex then
		targetIndex = 1
	elseif targetIndex < 1 then
		targetIndex = maxIndex
	end
	self.currentEffect = targetIndex
	
	--存档
	self:server_saveData(self.currentEffect)
	--通知客户端
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

function EffectsGenerator3.server_brocastEffectState(self)
	self:server_loadSavedData()
	--通知客户端
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

--Client
function EffectsGenerator3.client_onCreate(self)
	--先给一个有效值
	self.currentEffect = 1

	--创建粒子效果并缓存
	self.Effect = {}
	for i, effect in ipairs( PEList ) do
		self.Effect[i] = sm.effect.createEffect( effect.PE_name, self.interactable)
		
		if effect.PE_name == "Packingstation - Shoot" then
			self.Effect[i]:setOffsetPosition(sm.vec3.new(0.0,0.5,0.0) )
		end
		
		if effect.PE_name == "ToteBot - Sparks" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "PlayerStart - Glow" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "beehive - beeswarm" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "Buildarea - Oncreate" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "Goal - Oncreate" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "Chest - Arrow" then
			self.Effect[i]:setOffsetPosition(sm.vec3.new(0.0,0.0,3.0) )
		end
		
		if effect.PE_name == "Oilgeyser - OilgeyserLoop" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "SlimyClam - Bubbles" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(90.0), sm.vec3.new( 1, 0, 0 ) )) 
		end
		
		if effect.PE_name == "Mechanic - KoLoop" then
			self.Effect[i]:setOffsetRotation( sm.quat.angleAxis( math.rad(270.0), sm.vec3.new( 0, 1, 0 ) )) 
		end
		
		--请求服务器广播
		self.network:sendToServer("server_brocastEffectState")
	end
end

function EffectsGenerator3.client_canInteract(self) 

	--有效值保护
	if self.currentEffect == nil or self.currentEffect == 0 or self.currentEffect > table.maxn(PEList) then
		self.currentEffect = 1
	end

	--刷新提示文本
	local NameofPE = PEList[self.currentEffect].PE_name
	local ChineseNameofPE = ChineseList[self.currentEffect].Chinese_name
	sm.gui.displayAlertText("当前效果Current Effect: "..NameofPE.."  "..ChineseNameofPE,2.0)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "切换到下一个 Switch to next one")
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "切换到上一个 Swtich to previous one")

	return true
end


function EffectsGenerator3.client_onInteract(self,char,state)
	if state then
		local crouching = sm.localPlayer.getPlayer().character:isCrouching()
		local reverse = crouching
		
		--请求服务端更改效果索引
		self.network:sendToServer("server_onChangeEffectRequest",reverse);	
	end
end


function EffectsGenerator3.client_onFixedUpdate( self, dt )
	if self.interactable:isActive() == true then

		local effect = self.Effect[self.currentEffect]
		local isPlaying = effect:isPlaying()
		if not isPlaying  then
			effect:start()
			self.playingEffect = effect
		end
	else
		local effect = self.Effect[self.currentEffect]
		
		if self.Effect[self.currentEffect]:isPlaying() then
			self.Effect[self.currentEffect]:stop()
		end
	end
end

function EffectsGenerator3.client_Invisible( self, pw )
	self.interactable:setPoseWeight( 0, pw )
end

function EffectsGenerator3.client_onDestroy(self )
	--销毁粒子效果
	self.Effect[self.currentEffect]:stop()
	for i, effect in ipairs( PEList ) do
		if self.Effect[i] then
			self.Effect[i]:destroy()
			self.Effect[i] = nil
		end
	end
end


function EffectsGenerator3.client_onEffectChanged(self,index)
	if self.playingEffect ~= nil then
		self.playingEffect:stop()
	end
	--写入当前粒子
	self.currentEffect = index
end


--Particles
function EffectsGenerator3.paint_smoke(self, lastPos)
	self.color = self.shape:getColor()
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local pos1 = shapePos
		local pos2 = lastPos
		sm.particle.createParticle("paint_smoke", pos1, nil, self.color)
		sm.particle.createParticle("paint_smoke", pos2, nil, self.color)
	end
end

function EffectsGenerator3.spudgun_basic_muzzel(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_spudgun_basic_muzzel", shapePos, rot )
	end
end

function EffectsGenerator3.construct_welding(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("construct_welding", shapePos)
	end
end

function EffectsGenerator3.Spark01(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("jiguang", shapePos)
	end
end

function EffectsGenerator3.Spark02(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_sledgehammer_impact_glass", shapePos )
	end
end

function EffectsGenerator3.sledgehammer_destruct_glass(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_sledgehammer_destruct_glass", shapePos )
	end
end

function EffectsGenerator3.spudgun_impact_glass(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_spudgun_impact_glass", shapePos, rot )
	end
end

function EffectsGenerator3.challenge_goal_activate(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_challengemode_hologram_goal_activate", shapePos, rot )
	end
end

function EffectsGenerator3.parts_uppgrade(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_partseffect_parts_uppgrade01", shapePos, rot )
	end
end

function EffectsGenerator3.DebriPart(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("explosion_debri_part", shapePos )
	end
end

function EffectsGenerator3.Laser(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("ballactivation_laser", shapePos, rot )
	end
end

function EffectsGenerator3.Lightning(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_barrier_activation_lightning_01", shapePos)
	end
end

function EffectsGenerator3.Watercanon_Muzzelflash(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_watercanon_muzzelflash", shapePos, rot)
	end
end

function EffectsGenerator3.Barrier(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, -1, 0 ), self.shape.up )
		sm.particle.createParticle("p_barrier_deactivation", shapePos, rot)
	end
end

function EffectsGenerator3.Banana_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_banana_impact", shapePos)
	end
end

function EffectsGenerator3.Pineapple_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_pineapple_impact", shapePos)
	end
end

function EffectsGenerator3.Tomato_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_tomato_impact", shapePos)
	end
end

function EffectsGenerator3.Orange_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_orange_impact", shapePos)
	end
end
