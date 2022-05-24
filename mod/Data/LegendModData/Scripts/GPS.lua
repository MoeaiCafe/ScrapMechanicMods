----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

GPS = class( nil )
GPS.maxParentCount = 1
GPS.maxChildCount = -1
GPS.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.power
GPS.connectionOutput = sm.interactable.connectionType.logic + sm.interactable.connectionType.power
GPS.colorNormal = sm.color.new(0x9c0d44ff)
GPS.colorHighlight = sm.color.new(0xc11559ff)
GPS.poseWeightCount = 1

GPS.activeHeightTable = {-20, -10, 0, 10, 20, 30, 40, 60, 80, 100, 120, 160, 200, 300, 400, 500, 600, 700, 800, 900, 1000}

function GPS.server_onCreate( self )
	
	self.heightIndex = self.storage:load()
	if self.heightIndex == nil then
		self.heightIndex = 3
		self.activeHeight = self.activeHeightTable[self.heightIndex]
		self.storage:save(self.heightIndex)
	else
		self.activeHeight = self.activeHeightTable[self.heightIndex]
	end
	
	self.network:sendToClients("client_getUIData", self.heightIndex)
end

function GPS.server_request( self )
	self.network:sendToClients("client_getUIData", self.heightIndex)
end

function GPS.server_heightChange( self, heightIndex )
	self.heightIndex = heightIndex
	self.activeHeight = self.activeHeightTable[self.heightIndex]
	self.storage:save(self.heightIndex)
	self.network:sendToClients("client_getUIData", self.heightIndex)
end

function GPS.server_onFixedUpdate( self, timeStep )
	self.currentPos = sm.shape.getWorldPosition(self.shape)
	Player = server_getNearestPlayer( self.currentPos )
	self.getID = Player:getId()

	self.input = self.interactable:getSingleParent()
	
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.display = true
			self.network:sendToClients("client_Display", { playerID = self.getID, display = self.display })
		else
			self.display = false
		end
	else
		self.display = false
	end
	
	if self.currentPos.z >= self.activeHeight then
		self.interactable:setActive(true)
		self.interactable:setPower(1)
	else
		self.interactable:setActive(false)
		self.interactable:setPower(0)
	end

end

function server_getNearestPlayer( position )
	local nearestPlayer = nil
	local nearestDistance = nil
	for id,Player in pairs(sm.player.getAllPlayers()) do
		local length2 = sm.vec3.length2(position - Player.character:getWorldPosition())
		if nearestDistance == nil or length2 < nearestDistance then
			nearestDistance = length2
			nearestPlayer = Player
		end
	end
	return nearestPlayer
end


function GPS.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 0 )

	self.UIPosIndex = 1
	self.network:sendToServer("server_request")
end

function GPS.client_onUpdate( self, dt )
	if self.interactable:isActive() == true then
		self.interactable:setPoseWeight( 0, 1 )
	else
		self.interactable:setPoseWeight( 0, 0 )
	end
end

function GPS.client_Display( self, Data )
	if Data.display == true and Data.playerID == sm.localPlayer.getId() then
		self.Pos = sm.shape.getWorldPosition(self.shape)
		self.PosX = string.format("%.2f",self.Pos.x)
		self.PosY = string.format("%.2f",self.Pos.y)
		self.PosZ = string.format("%.2f",self.Pos.z)
		sm.gui.displayAlertText( "X坐标: "..self.PosX.."        Y坐标: "..self.PosY.."        高度Height: "..self.PosZ.." m米", 1)
	end
end

function GPS.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function GPS.client_onInteract(self,character, state )
	if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "GPS")
		self.gui:setText("Interaction", "Set Active Height 设置激活高度")		
		self.gui:setIconImage("Icon", sm.uuid.new("8001aabe-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.activeHeightTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Height高度: "..self.activeHeightTable[self.UIPosIndex].."米meters")
	self.gui:open()

	if state == true then
		self.Pos = sm.shape.getWorldPosition(self.shape)
		self.PosX = string.format("%.2f",self.Pos.x)
		self.PosY = string.format("%.2f",self.Pos.y)
		self.PosZ = string.format("%.2f",self.Pos.z)
		sm.audio.play("Retrowildblip", self.shape:getWorldPosition())
		sm.gui.displayAlertText("X坐标: "..self.PosX.."        Y坐标: "..self.PosY.."        高度Height: "..self.PosZ.." m米", 4)
	end
	
	
end

function GPS.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Height高度: "..self.activeHeightTable[newIndex].."米meters")
	end
	self.network:sendToServer("server_heightChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function GPS.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "Set Active Height 设置激活高度")
	return true
end
