----------------------------------------------
-------Copyright (c) 2022 David Sirius--------
----------------------------------------------

SetSize = class( nil )
SetSize.maxChildCount = 0
SetSize.maxParentCount = 0
SetSize.connectionInput = sm.interactable.connectionType.logic
SetSize.connectionOutput = sm.interactable.connectionType.none
SetSize.poseWeightCount = 1

SetSize.sizeTable = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

--Server
function SetSize.server_onCreate( self )
	--读取储存的尺寸索引
	self.sizeIndex = self.storage:load()
	--有效值保护
	if self.sizeIndex == nil then
		self.sizeIndex = 1
		self.storage:save(self.sizeIndex)
	end
	--发送尺寸索引给客户端
	self.network:sendToClients("client_getUIData", self.sizeIndex)
end

function SetSize.server_request( self )
	--读取储存的尺寸索引
	self.sizeIndex = self.storage:load()
	--有效值保护
	if self.sizeIndex == nil then
		self.sizeIndex = 1
		self.storage:save(self.sizeIndex)
	end
	--发送尺寸索引给客户端
	--print("服务端已广播")
	self.network:sendToClients("client_getUIData", self.sizeIndex)
end

function SetSize.server_sizeChange( self, sizeIndex )
	--接收客户端改变后的尺寸索引
	self.sizeIndex = sizeIndex
	
	--储存改变后的尺寸索引
	self.storage:save(self.sizeIndex)
	--广播改变后的尺寸索引至全部客户端
	self.network:sendToClients("client_getUIData", self.sizeIndex)
end


--Client--
function SetSize.client_onCreate( self )
	--请求服务端发送尺寸索引
	self.network:sendToServer("server_request")
end

function SetSize.client_getUIData(self, UIPosIndex )
	--print("已接收服务端广播")
	--print("UIPosIndex:"..UIPosIndex)
	self.UIPosIndex = UIPosIndex
	self.sizeSet = self.sizeTable[self.UIPosIndex]
	self.interactable:setPoseWeight( 0, self.sizeSet/20 )
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function SetSize.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Set Size 设置大小")
		self.gui:setText("Interaction", "")		
		--self.gui:setIconImage("Icon", sm.uuid.new(""))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.sizeTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Size设置大小:"..self.sizeTable[self.UIPosIndex].."")
	self.gui:open()
end

function SetSize.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Size设置大小: "..self.sizeTable[newIndex].."")
	end
	self.network:sendToServer("server_sizeChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function SetSize.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置大小 Set Size")
	return true
end