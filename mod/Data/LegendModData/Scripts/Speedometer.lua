----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

Speedometer = class( nil )
Speedometer.maxParentCount = 1
Speedometer.maxChildCount = -1
Speedometer.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
Speedometer.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
Speedometer.colorNormal = sm.color.new(0x9c0d44ff)
Speedometer.colorHighlight = sm.color.new(0xc11559ff)
Speedometer.poseWeightCount = 2

Speedometer.activeSpeed = {0.5, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400}

--Server--
function Speedometer.server_onCreate( self )
	self.speedIndex = self.storage:load()
	if self.speedIndex == nil then
		self.speedIndex = 1
		self.activeVel = self.activeSpeed[self.speedIndex]
		self.storage:save(self.speedIndex)
	else
		self.activeVel = self.activeSpeed[self.speedIndex]
	end
	
	self.network:sendToClients("client_getUIData", self.speedIndex)
end

function Speedometer.server_request( self )
	self.network:sendToClients("client_getUIData", self.speedIndex)
end

function Speedometer.server_speedChange( self, speedIndex )
	self.speedIndex = speedIndex
	self.activeVel = self.activeSpeed[self.speedIndex]
	self.storage:save(self.speedIndex)
	self.network:sendToClients("client_getUIData", self.speedIndex)
end

function Speedometer.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.display = true
		else
			self.display = false
		end
	else
		self.display = false
	end

	self.currentPos = sm.shape.getWorldPosition(self.shape)
	Player = server_getNearestPlayer( self.currentPos )
	self.getID = Player:getId()

	ObjectVel = self.shape.velocity		--速度		
	ObjectVelL =  ObjectVel:length()	--速率
	self.ObjectVelLkmh = ObjectVelL * 3.6
	self.Speedstring = string.format("%.2f",self.ObjectVelLkmh)
	--[[
	print(self.currentPos)
	print(ObjectVelL.."m/s")
	print(self.ObjectVelLkmh.."km/h")
	]]--
	self.network:sendToClients("client_setPoseWeight", { Speed = self.Speedstring, playerID = self.getID, display = self.display })
	self.network:sendToClients("client_Display", { Speed = self.Speedstring, playerID = self.getID, display = self.display })
	
	if self.ObjectVelLkmh >= self.activeVel then
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

--Client--
function Speedometer.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 1 )
	self.interactable:setPoseWeight( 1, 0 )
	self.ObjectVelLkmh = 0
	self.UIPosIndex = 1
	self.network:sendToServer("server_request")
end

function Speedometer.client_setPoseWeight( self, Data )
	self.boltValue = Data.Speed / 250
	self.interactable:setPoseWeight( 0, -self.boltValue*2+1 )
	self.interactable:setPoseWeight( 1, self.boltValue*2-1 )
end

function Speedometer.client_Display( self, Data )
	if Data.display == true and Data.playerID == sm.localPlayer.getId() then
		sm.gui.displayAlertText( Data.Speed.." km/h" , 1)
	end
end

function Speedometer.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function Speedometer.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Speedometer迈速表")
		self.gui:setText("Interaction", "Set Active Speed 设置激活速度")		
		self.gui:setIconImage("Icon", sm.uuid.new("3007aaaf-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.activeSpeed, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Speed速度: "..self.activeSpeed[self.UIPosIndex].."km/h")
	self.gui:open()
end

function Speedometer.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Speed速度: "..self.activeSpeed[newIndex].."km/h")
	end
	self.network:sendToServer("server_speedChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function Speedometer.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置激活速度 Set Active Speed")
	return true
end
