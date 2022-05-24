----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

NoFlameThruster = class( nil )
NoFlameThruster.maxChildCount = 0
NoFlameThruster.maxParentCount = 1
NoFlameThruster.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
NoFlameThruster.connectionOutput = sm.interactable.connectionType.none
NoFlameThruster.colorNormal = sm.color.new( 0x35d7d9ff )
NoFlameThruster.colorHighlight = sm.color.new( 0x40fdffff )
NoFlameThruster.poseWeightCount = 2

NoFlameThruster.forceTable = { 100, 200, 400, 600, 800, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 12000, 14000, 16000, 18000, 20000, 30000, 40000, 60000, 80000, 100000, 150000, 200000, 250000, 300000, 400000, 500000}

--Server
function NoFlameThruster.server_onCreate( self )
	--读取储存的尺寸索引
	savedforceIndex = self.storage:load()
	
	if savedforceIndex == nil then	--未储存过的喷射器
		--print("1")
		self.forceIndex = 1
		self.newSavedData = {self.forceIndex}
		self.storage:save(self.newSavedData)
	elseif type(savedforceIndex) == "number" then	--储存数据类型为number的老版喷射器
		--print("2")
		self.forceIndex = savedforceIndex +13
		self.newSavedData = {self.forceIndex}
		self.storage:save(self.newSavedData)
	else									--储存数据为数组的新版喷射器
		--print("3")
		print(self.forceIndex)
		self.forceIndex = savedforceIndex[1]
		self.newSavedData = {self.forceIndex}
		self.storage:save(self.newSavedData)
	end
	
	self.network:sendToClients("client_getUIData", self.forceIndex)
end

function NoFlameThruster.server_request( self )
	self.network:sendToClients("client_getUIData", self.forceIndex)
end

function NoFlameThruster.server_forceChange( self, forceIndex )
	self.forceIndex = forceIndex
	
	--储存改变后的尺寸索引（新版储存类型为数组）
	self.newSavedData = {self.forceIndex}
	self.storage:save(self.newSavedData)
	--广播改变后的尺寸索引至全部客户端
	self.network:sendToClients("client_getUIData", self.forceIndex)
end

function NoFlameThruster.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputPower = self.input:getPower()
		--self.inputActive = self.input:isActive()
		if self.inputPower == 1 then
			self.interactable:setActive(true)
			
			self.force = - self.forceTable[self.forceIndex]
			--print(self.forceTable[self.forceIndex])
			sm.physics.applyImpulse(self.shape, sm.vec3.new(0, 0, self.force) * timeStep )
			
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
			self.Invisible = true
		else
			self.Invisible = false
		end
	else
		self.Invisible = false
	end
	--print(self.Invisible)
	self.network:sendToClients("client_ModelAnim", self.Invisible)
end


--Client--
function NoFlameThruster.client_onCreate( self )
	self.UIPosIndex = 2
	self.network:sendToServer("server_request")
end

function NoFlameThruster.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function NoFlameThruster.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Thruster 喷射器")
		self.gui:setText("Interaction", "Drug to adjust power 拖动以调整推力")		
		self.gui:setIconImage("Icon", sm.uuid.new("4037aace-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.forceTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Force 推力大小:"..self.forceTable[self.UIPosIndex].."")
	self.gui:open()
end

function NoFlameThruster.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Force 推力大小:"..self.forceTable[newIndex].."")
	end
	self.network:sendToServer("server_forceChange", newIndex)
	--print("newIndex"..newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function NoFlameThruster.client_ModelAnim( self, Invisible )
	if Invisible == true then
		self.interactable:setPoseWeight( 0, 0 )
		self.interactable:setPoseWeight( 1, 1 )
	else
		if self.interactable:isActive() == true then
			self.interactable:setPoseWeight( 0, 1 )
		else
			self.interactable:setPoseWeight( 0, 0 )
		end
		self.interactable:setPoseWeight( 1, 0 )
	end
end

function NoFlameThruster.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置推力大小 Set power")
	return true
end