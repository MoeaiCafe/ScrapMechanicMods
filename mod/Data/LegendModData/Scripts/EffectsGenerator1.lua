----------------------------------------------------------
-------Copyright (c) 2020 FreshFish & David Sirius--------
----------------------------------------------------------

EffectsGenerator1 = class( nil )
EffectsGenerator1.maxParentCount = 1
EffectsGenerator1.maxChildCount = -1
EffectsGenerator1.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
EffectsGenerator1.connectionOutput = sm.interactable.connectionType.logic
EffectsGenerator1.colorNormal = sm.color.new(0xff00b4ff)
EffectsGenerator1.colorHighlight = sm.color.new(0xff33c2ff)
EffectsGenerator1.poseWeightCount = 1

--Particles and Effects List
local PEList = {
	--Smoke
	{PE_name = "paint_smoke" },	
	{PE_name = "Smoke - blowing01" }, 
	{PE_name = "Smoke - blowing02" }, 
	{PE_name = "Smoke - blowing03" }, 
	{PE_name = "Smoke - pillar01" }, 
	{PE_name = "Smoke - pillar02" }, 
	{PE_name = "Smoke - pillar03" },
	{PE_name = "Fire- Smoke Medium01" },
	{PE_name = "Smoke Bomb" },
	{PE_name = "PropaneTank - ActivateBig" },
	{PE_name = "PistonExhaust" },
	{PE_name = "Stone - CrackRock"},
	{PE_name = "Packingstation - Shoot" },
	
	--Fire and Explosion
	{PE_name = "Fire" },
	{PE_name = "Fire - lowburn" },
	{PE_name = "Fire - small01" },
	{PE_name = "Fire -medium01" },
	{PE_name = "Fire - large01" },
	{PE_name = "Fire - vertical" },
	{PE_name = "Fire - Shipwreck" },
	{PE_name = "Fire -medium01_putout" },
	{PE_name = "Fire - large01_putout" },
	{PE_name = "PropaneTank - SingleActivate" },
	{PE_name = "PropaneTank - ExplosionSmall" },
	{PE_name = "PropaneTank - ExplosionBig" },
	
	--Water
	{PE_name = "Watercanon_Muzzelflash" },
	{PE_name = "Water - HitWaterSmall" },
	{PE_name = "Water - Waterleak01" },
	{PE_name = "Water - Waterleak02" }
	
}

local ChineseList = {
	--Smoke
	{Chinese_name = "可喷漆烟雾  [SMOKE烟雾效果]" },	
	{Chinese_name = "冒出的烟01  [SMOKE烟雾效果]" }, 
	{Chinese_name = "冒出的烟02  [SMOKE烟雾效果]" }, 
	{Chinese_name = "冒出的烟03  [SMOKE烟雾效果]" }, 
	{Chinese_name = "烟柱01  [SMOKE烟雾效果]" }, 
	{Chinese_name = "烟柱02  [SMOKE烟雾效果]" }, 
	{Chinese_name = "烟柱03  [SMOKE烟雾效果]" },
	{Chinese_name = "着火的烟  [SMOKE烟雾效果]" },
	{Chinese_name = "烟雾弹  [SMOKE烟雾效果]" },
	{Chinese_name = "煤气罐引爆的烟  [SMOKE烟雾效果]" },
	{Chinese_name = "活塞冒出的烟  [SMOKE烟雾效果]" },
	{Chinese_name = "石头破碎的烟  [SMOKE烟雾效果]"},
	{Chinese_name = "打包站射出的烟  [SMOKE烟雾效果]" },
	
	--Fire and Explosion
	{Chinese_name = "火  [FIRE火效果]" },
	{Chinese_name = "微弱的火苗  [FIRE火效果]" },
	{Chinese_name = "火(小)  [FIRE火效果]" },
	{Chinese_name = "火(中)  [FIRE火效果]" },
	{Chinese_name = "火(大)  [FIRE火效果]" },
	{Chinese_name = "垂直燃烧的火  [FIRE火效果]" },
	{Chinese_name = "坠毁飞船的火  [FIRE火效果]" },
	{Chinese_name = "扑灭火(中)  [FIRE火效果]" },
	{Chinese_name = "扑灭火(大)  [FIRE火效果]" },
	{Chinese_name = "煤气罐引爆的火  [FIRE火效果]" },
	{Chinese_name = "煤气罐爆炸(小)  [FIRE火效果]" },
	{Chinese_name = "煤气罐爆炸(大)  [FIRE火效果]" },
	
	--Water
	{Chinese_name = "水炮射出  [WATER水效果]" },
	{Chinese_name = "撞击的水  [WATER水效果]" },
	{Chinese_name = "泄露的水01  [WATER水效果]" },
	{Chinese_name = "泄露的水02  [WATER水效果]" }
	
}

--Server

function EffectsGenerator1.server_onCreate( self )
	--载入存档
	self:server_loadSavedData()

	--通知客户端初始化
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

function EffectsGenerator1.server_onFixedUpdate( self, dt )

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

function EffectsGenerator1.server_saveData(self,data)
	self.storage:save( data )
end

function EffectsGenerator1.server_loadSavedData(self)
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

function EffectsGenerator1.server_onChangeEffectRequest(self,reverse)
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

function EffectsGenerator1.server_brocastEffectState(self)
	self:server_loadSavedData()
	--通知客户端
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

--Client
function EffectsGenerator1.client_onCreate(self)
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

function EffectsGenerator1.client_canInteract(self) 

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


function EffectsGenerator1.client_onInteract(self,char,state)
	if state then
		local crouching = sm.localPlayer.getPlayer().character:isCrouching()
		local reverse = crouching
		
		--请求服务端更改效果索引
		self.network:sendToServer("server_onChangeEffectRequest",reverse);	
	end
end


function EffectsGenerator1.client_onFixedUpdate( self, dt )
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

function EffectsGenerator1.client_Invisible( self, pw )
	self.interactable:setPoseWeight( 0, pw )
end

function EffectsGenerator1.client_onDestroy(self )
	--销毁粒子效果
	self.Effect[self.currentEffect]:stop()
	for i, effect in ipairs( PEList ) do
		if self.Effect[i] then
			self.Effect[i]:destroy()
			self.Effect[i] = nil
		end
	end
end


function EffectsGenerator1.client_onEffectChanged(self,index)
	if self.playingEffect ~= nil then
		self.playingEffect:stop()
	end
	--写入当前粒子
	self.currentEffect = index
end


--Particles
function EffectsGenerator1.paint_smoke(self, lastPos)
	self.color = self.shape:getColor()
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local pos1 = shapePos
		local pos2 = lastPos
		sm.particle.createParticle("paint_smoke", pos1, nil, self.color)
		sm.particle.createParticle("paint_smoke", pos2, nil, self.color)
	end
end

function EffectsGenerator1.spudgun_basic_muzzel(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_spudgun_basic_muzzel", shapePos, rot )
	end
end

function EffectsGenerator1.construct_welding(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("construct_welding", shapePos)
	end
end

function EffectsGenerator1.Spark01(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("jiguang", shapePos)
	end
end

function EffectsGenerator1.Spark02(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_sledgehammer_impact_glass", shapePos )
	end
end

function EffectsGenerator1.sledgehammer_destruct_glass(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_sledgehammer_destruct_glass", shapePos )
	end
end

function EffectsGenerator1.spudgun_impact_glass(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_spudgun_impact_glass", shapePos, rot )
	end
end

function EffectsGenerator1.challenge_goal_activate(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_challengemode_hologram_goal_activate", shapePos, rot )
	end
end

function EffectsGenerator1.parts_uppgrade(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_partseffect_parts_uppgrade01", shapePos, rot )
	end
end

function EffectsGenerator1.DebriPart(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("explosion_debri_part", shapePos )
	end
end

function EffectsGenerator1.Laser(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("ballactivation_laser", shapePos, rot )
	end
end

function EffectsGenerator1.Lightning(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_barrier_activation_lightning_01", shapePos)
	end
end

function EffectsGenerator1.Watercanon_Muzzelflash(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
		sm.particle.createParticle("p_watercanon_muzzelflash", shapePos, rot)
	end
end

function EffectsGenerator1.Barrier(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local rot = sm.vec3.getRotation( sm.vec3.new( 0, -1, 0 ), self.shape.up )
		sm.particle.createParticle("p_barrier_deactivation", shapePos, rot)
	end
end

function EffectsGenerator1.Banana_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_banana_impact", shapePos)
	end
end

function EffectsGenerator1.Pineapple_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_pineapple_impact", shapePos)
	end
end

function EffectsGenerator1.Tomato_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_tomato_impact", shapePos)
	end
end

function EffectsGenerator1.Orange_Impact(self)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		sm.particle.createParticle("p_projectile_orange_impact", shapePos)
	end
end
