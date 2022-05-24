----------------------------------------------
-------Copyright (c) 2022 David Sirius--------
----------------------------------------------

Camera = class(nil)
Camera.maxParentCount = 1
Camera.maxChildCount = -1
Camera.connectionInput = sm.interactable.connectionType.seated + sm.interactable.connectionType.logic
Camera.connectionOutput = sm.interactable.connectionType.logic
Camera.colorNormal = sm.color.new(0xffff00ff)
Camera.colorHighlight = sm.color.new(0xffff33ff)

Camera.offsetTable = { -400, -350, -300, -250, -200, -150, -100, -80 , -60, -40, -20, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 40, 60, 80, 100, 150, 200, 250, 300, 350, 400}


--Server--

function Camera.server_onCreate( self )
	--读取储存的尺寸索引
	self.offsetIndex = self.storage:load()
	print(self.offsetIndex)
	--有效值保护
	if self.offsetIndex == nil or self.offsetIndex < 1 or self.offsetIndex > 43 then
		self.offsetIndex = 22
		self.storage:save(self.offsetIndex)
	end
	--发送尺寸索引给客户端
	self.network:sendToClients("client_getUIData", self.offsetIndex)
end

function Camera.server_request( self )
	--读取储存的尺寸索引
	self.offsetIndex = self.storage:load()
	--有效值保护
	if self.offsetIndex == nil then
		self.offsetIndex = 20
		self.storage:save(self.offsetIndex)
	end
	--发送尺寸索引给客户端
	--print("服务端已广播")
	self.network:sendToClients("client_getUIData", self.offsetIndex)
end

function Camera.server_offsetChange( self, offsetIndex )
	--接收客户端改变后的尺寸索引
	self.offsetIndex = offsetIndex
	
	--储存改变后的尺寸索引
	self.storage:save(self.offsetIndex)
	--广播改变后的尺寸索引至全部客户端
	self.network:sendToClients("client_getUIData", self.offsetIndex)
end

function Camera.server_onFixedUpdate(self)
	self.offset = self.offsetTable[self.offsetIndex]
	self.OffsetPos = self.shape.right * 0 + self.shape.up * (self.offset+0.1) + self.shape.at * 0
	self.cameraPos = sm.shape.getWorldPosition(self.shape) + self.OffsetPos
	
	--向客户端广播最终的视角坐标
	self.network:sendToClients("client_Camera",self.cameraPos)
end

function Camera.server_ActiveOn( self, dt )
	self.interactable:setActive(true)
    self.interactable:setPower(1)
end

function Camera.server_ActiveOff( self, dt )
	self.interactable:setActive(false)
    self.interactable:setPower(0)
end

--Client--

function Camera.client_onCreate(self)
	self.Active = false
	self.first = true
	
	--请求服务端发送尺寸索引
	self.network:sendToServer("server_request")
end

function Camera.client_getUIData(self, UIPosIndex )
	--print("已接收服务端广播")
	--print("UIPosIndex:"..UIPosIndex)
	self.UIPosIndex = UIPosIndex
	self.offset = self.offsetTable[self.UIPosIndex]
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function Camera.client_getUIData(self, UIPosIndex )
	--print("已接收服务端广播")
	--print("UIPosIndex:"..UIPosIndex)
	self.UIPosIndex = UIPosIndex
	self.offset = self.offsetTable[self.UIPosIndex]
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function Camera.client_Camera(self, cameraPos)
	if self.cameraID == self.interactable:getId() then	--判断是否为当前工作的摄像头
		self.cameraPos = cameraPos
		sm.camera.setPosition( self.cameraPos )
		sm.camera.setDirection(self.shape:getUp())	--设置视角方向为Z+
	end
	
	Parent = self.interactable:getSingleParent()
	--连线断开关闭摄像头视角
	if not Parent then
		if self.cameraID == self.interactable:getId() then
			sm.camera.setCameraState(1)
		end
	end
end

function Camera.client_Display(self, offSet)
	self.offSet = offSet
end

function Camera.client_onInteract(self, char, state )
	Parent = self.interactable:getSingleParent()
	
	if Parent then	--如果检测到已连接至父对象
		if Parent:getSeatCharacter() == char then	--检测座椅上是否有玩家
			if self.first then	--座椅上有玩家则代码只执行一次
				self.first = false
				if state then	--如果相机被按E	
					self.Active = not self.Active	--下一次按E的时候反转按E的效果
					if self.Active == true then
						self.cameraID = self.interactable:getId()	--获取按E开启相机的ID
						sm.camera.setCameraState(2)
						
						self.network:sendToServer("server_ActiveOn", true)
						
						sm.gui.displayAlertText("相机视角开启 Camera On!", 2)
						sm.audio.play("Retrowildblip", self.shape:getWorldPosition())
					else
						self.cameraID = nil
						sm.camera.setCameraState(1)
						
						self.network:sendToServer("server_ActiveOff", false)
					end
				end
			else
				self.first = true
			end
		else
			if not state then
				sm.camera.setCameraState(1)
				self.Active = false
				self.first = true
				self.cameraID = nil
			end
		end
	else
		self.network:sendToServer("server_ActiveOff", false)
	end
	
	
	if not Parent then	--若未连接座椅则开启UI
		if state then
			if self.gui == nil then
				self.gui = sm.gui.createEngineGui()
				self.gui:setSliderCallback( "Setting", "client_onSliderChange")
				self.gui:setText("Name", "Camera 摄像头")
				self.gui:setText("Interaction", "Set Camera offset 设置视角位置偏移")		
				self.gui:setIconImage("Icon", sm.uuid.new("8002aacb-5494-11e6-beb8-9e71128cae77"))
				self.gui:setVisible("FuelContainer", false )
			end
			self.gui:setSliderData("Setting", #self.offsetTable, self.UIPosIndex-1)
			self.gui:setText("SubTitle", "offset 偏移距离: "..self.offsetTable[self.UIPosIndex].."")
			self.gui:open()
		end
	elseif Parent:getSeatCharacter() ~= char then --若连接的座椅无玩家则开启UI
		if state then
			if self.gui == nil then
				self.gui = sm.gui.createEngineGui()
				self.gui:setSliderCallback( "Setting", "client_onSliderChange")
				self.gui:setText("Name", "Camera 摄像头")
				self.gui:setText("Interaction", "Set Camera offset 设置视角位置偏移")		
				self.gui:setIconImage("Icon", sm.uuid.new("8002aacb-5494-11e6-beb8-9e71128cae77"))
				self.gui:setVisible("FuelContainer", false )
			end
			self.gui:setSliderData("Setting", #self.offsetTable, self.UIPosIndex-1)
			self.gui:setText("SubTitle", "offset 偏移距离: "..self.offsetTable[self.UIPosIndex].."")
			self.gui:open()
		end
	end
	
end

function Camera.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "offset 偏移距离: "..self.offsetTable[newIndex].."")
	end
	self.network:sendToServer("server_offsetChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function Camera.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置视角偏移值 Set Camera Offset")
	return true
end

function Camera.client_onDestroy(self)
	if self.cameraID == self.interactable:getId() then
		sm.camera.setCameraState(1)
	end
end
