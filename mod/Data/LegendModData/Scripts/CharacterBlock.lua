----------------------------------------------
-------Copyright (c) 2022 David Sirius--------
----------------------------------------------

CharacterBlock = class( nil )
CharacterBlock.maxParentCount = 1
CharacterBlock.maxChildCount = -1
CharacterBlock.connectionInput = sm.interactable.connectionType.logic
CharacterBlock.connectionOutput = sm.interactable.connectionType.logic
CharacterBlock.colorNormal = sm.color.new(0x999999ff)
CharacterBlock.colorHighlight = sm.color.new(0xbbbbbbff)
CharacterBlock.poseWeightCount = 0

--Server--

function CharacterBlock.server_onCreate( self )
	self.colorModeLoad = self.storage:load()
	--有效值保护
	if self.colorModeLoad == nil then
		self.colorMode = 1
		self.storage:save(self.colorMode)
		--print("否")
	else
		self.colorMode = self.colorModeLoad
		--print("是")
	end
	
	self.Active = true
	print(self.Active)
	
	self.network:sendToClients("client_getData", {colorMode = self.colorMode, Active = self.Active} )
end

function CharacterBlock.server_request( self )
	self.colorModeLoad = self.storage:load()
	--有效值保护
	if self.colorModeLoad == nil then
		self.colorMode = 1
		self.storage:save(self.colorMode)
		--print("否")
	else
		self.colorMode = self.colorModeLoad
		--print("是")
	end
	
	self.network:sendToClients("client_getData", {colorMode = self.colorMode, Active = self.Active} )
end

function CharacterBlock.server_modeChange( self, colorMode )
	self.colorMode = colorMode
	self.storage:save(self.colorMode)
	
	self.network:sendToClients("client_getData", {colorMode = self.colorMode, Active = self.Active} )
end

function CharacterBlock.server_onFixedUpdate( self, dt )
	Parent = self.interactable:getSingleParent()
	if Parent then
		if  Parent:isActive() == true then
			self.interactable:setActive(true)
			self.Active = true
		else
			self.interactable:setActive(false)
			self.Active = false
		end
	else
		self.interactable:setActive(true)
		self.Active = true
	end
	
	if self.Active ~= self.lastActive then
		self.network:sendToClients("client_getData", {colorMode = self.colorMode, Active = self.Active} )
	end
	
	self.lastActive = self.Active
end

--Client--

function CharacterBlock.client_onCreate( self )
	self.network:sendToServer("server_request")
end

function CharacterBlock.client_onInteract(self, character, state)
	local crouching = sm.localPlayer.getPlayer().character:isCrouching()

	if state then
		if not crouching then
			self.colorMode = self.colorMode +1
		else
			self.colorMode = self.colorMode -1
		end
			
		--让色彩模式在1到3间循环
		if self.colorMode > 4 then
			self.colorMode = 1
		end
		if self.colorMode < 1 then
			self.colorMode = 4
		end
		
		sm.gui.displayAlertText("颜色模式 Color Mode: "..self.colorMode, 2)
		self.network:sendToServer("server_modeChange", self.colorMode)
	end
end

function CharacterBlock.client_getData( self, Data )
	self.colorMode = Data.colorMode
	self.Active = Data.Active
	if self.colorMode == 1 then		--颜色模式1
		if self.Active == true then
			self.interactable:setUvFrameIndex(0)
			print("Mode 1开")
		else
			self.interactable:setUvFrameIndex(1)
			print("Mode 1关")
		end	
	elseif self.colorMode == 2 then	--颜色模式2
		if self.Active == true then
			self.interactable:setUvFrameIndex(2)
			print("Mode 2开")
		else
			self.interactable:setUvFrameIndex(3)
			print("Mode 2关")
		end
	elseif self.colorMode == 3 then	--颜色模式3
		if self.Active == true then
			self.interactable:setUvFrameIndex(4)
			print("Mode 3开")
		else
			self.interactable:setUvFrameIndex(5)
			print("Mode 3关")
		end
	elseif self.colorMode == 4 then	--颜色模式4
		if self.Active == true then
			self.interactable:setUvFrameIndex(6)
			print("Mode 4开")
		else
			self.interactable:setUvFrameIndex(7)
			print("Mode 4关")
		end
	end	
end

function CharacterBlock.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "下一个颜色模式 Next Color Mode")
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "上一个颜色模式 Previous Color Mode")
	return true
end


