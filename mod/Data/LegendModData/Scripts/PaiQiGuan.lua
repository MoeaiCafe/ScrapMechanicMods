----------------------------------------------------------
-------Copyright (c) 2021 FreshFish & David Sirius--------
----------------------------------------------------------

PaiQiGuan = class( nil )
PaiQiGuan.maxParentCount = 1
PaiQiGuan.maxChildCount = 0
PaiQiGuan.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
PaiQiGuan.connectionOutput = sm.interactable.connectionType.none
PaiQiGuan.colorNormal = sm.color.new(0x666666ff)
PaiQiGuan.colorHighlight = sm.color.new(0x777777ff)
PaiQiGuan.poseWeightCount = 1

--Particles and Effects List
local PEList = {
	{PE_name = "paint_smoke" },	
	{PE_name = "Thruster - Level 3" }	
}

local ChineseList = {
	--Smoke
	{Chinese_name = "烟 Smoke" },	
	{Chinese_name = "火焰 Fire" }
	
}

--Server

function PaiQiGuan.server_onCreate( self )
	--载入存档
	self:server_loadSavedData()

	--通知客户端初始化
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

function PaiQiGuan.server_onFixedUpdate( self, dt )

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
		end
		
	end
	self.lastPos = sm.shape.getWorldPosition(self.shape)
end

function PaiQiGuan.server_saveData(self,data)
	self.storage:save( data )
end

function PaiQiGuan.server_loadSavedData(self)
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

function PaiQiGuan.server_onChangeEffectRequest(self,reverse)
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

function PaiQiGuan.server_brocastEffectState(self)
	self:server_loadSavedData()
	--通知客户端
	self.network:sendToClients("client_onEffectChanged",self.currentEffect)
end

--Client
function PaiQiGuan.client_onCreate(self)
	--先给一个有效值
	self.currentEffect = 1

	--创建粒子效果并缓存
	self.Effect = {}
	for i, effect in ipairs( PEList ) do
		self.Effect[i] = sm.effect.createEffect( effect.PE_name, self.interactable)
		
		--请求服务器广播
		self.network:sendToServer("server_brocastEffectState")
	end
end

function PaiQiGuan.client_canInteract(self) 

	--有效值保护
	if self.currentEffect == nil or self.currentEffect == 0 or self.currentEffect > table.maxn(PEList) then
		self.currentEffect = 1
	end

	--刷新提示文本
	local NameofPE = PEList[self.currentEffect].PE_name
	local ChineseNameofPE = ChineseList[self.currentEffect].Chinese_name
	sm.gui.displayAlertText("当前效果Current Effect: "..ChineseNameofPE,2.0)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "切换特效 Switch Effect")
	--sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "切换到上一个 Swtich to previous one")

	return true
end


function PaiQiGuan.client_onInteract(self,char,state)
	if state then
		local crouching = sm.localPlayer.getPlayer().character:isCrouching()
		local reverse = crouching
		
		--请求服务端更改效果索引
		self.network:sendToServer("server_onChangeEffectRequest",reverse);	
	end
end


function PaiQiGuan.client_onFixedUpdate( self, dt )
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

function PaiQiGuan.client_Invisible( self, pw )
	self.interactable:setPoseWeight( 0, pw )
end

function PaiQiGuan.client_onDestroy(self )
	--销毁粒子效果
	self.Effect[self.currentEffect]:stop()
	for i, effect in ipairs( PEList ) do
		if self.Effect[i] then
			self.Effect[i]:destroy()
			self.Effect[i] = nil
		end
	end
end


function PaiQiGuan.client_onEffectChanged(self,index)
	if self.playingEffect ~= nil then
		self.playingEffect:stop()
	end
	--写入当前粒子
	self.currentEffect = index
end


--Particles
function PaiQiGuan.paint_smoke(self, lastPos)
	self.color = sm.color.new(0xbbbbbbff)
	if nil ~= self then
		local shapePos = sm.shape.getWorldPosition(self.shape)
		local posOffset = (self.shape.right * 0) + (self.shape.up * 0.4) + (self.shape.at * 0.0)
		
		local pos1 = shapePos + posOffset
		local pos2 = lastPos + posOffset
		sm.particle.createParticle("paint_smoke", pos1, nil, self.color)
		sm.particle.createParticle("paint_smoke", pos2, nil, self.color)
	end
end

