----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

CYSensor = class( nil )
CYSensor.maxChildCount = -1
CYSensor.maxParentCount = 0
CYSensor.connectionInput = sm.interactable.connectionType.none
CYSensor.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
CYSensor.colorNormal = sm.color.new(0x9c0d44ff)
CYSensor.colorHighlight = sm.color.new(0xc11559ff)
CYSensor.poseWeightCount = 1

CYSensor.activeDistance = {20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 160, 180, 200, 220, 240, 260, 280, 300}

--Server
function CYSensor.server_onCreate( self )
	self.distanceIndex = self.storage:load()
	if self.distanceIndex == nil then
		self.distanceIndex = 1
		self.activeDis = self.activeDistance[self.distanceIndex]
		self.storage:save(self.distanceIndex)
	else
		self.activeDis = self.activeDistance[self.distanceIndex]
	end
	
	self.network:sendToClients("client_getUIData", self.distanceIndex)
end

function CYSensor.server_request( self )
	self.network:sendToClients("client_getUIData", self.distanceIndex)
end

function CYSensor.server_distanceChange( self, distanceIndex )
	self.distanceIndex = distanceIndex
	self.activeDis = self.activeDistance[self.distanceIndex]
	self.storage:save(self.distanceIndex)
	self.network:sendToClients("client_getUIData", self.distanceIndex)
end

function CYSensor.server_onFixedUpdate(self, dt)
	
	raycastDir = self.shape.up
	raycastDistance = sm.vec3.new(raycastDir.x/4 * self.activeDis, raycastDir.y/4 * self.activeDis, raycastDir.z/4 * self.activeDis)
	
    local hit, fraction = sm.physics.distanceRaycast(self.shape.worldPosition , raycastDistance )
	--print(self.shape.right)
    if hit then
		self.interactable:setActive(true)
		self.interactable:setPower(1)
	else
		self.interactable:setActive(false)
		self.interactable:setPower(0)
	end
	
end


--Client--
function CYSensor.client_onCreate( self )
	self.UIPosIndex = 1
	self.network:sendToServer("server_request")
end

function CYSensor.client_onUpdate( self, dt )	
	if self.interactable:isActive() == true then
		self.interactable:setPoseWeight( 0, 1 )
	else
		self.interactable:setPoseWeight( 0, 0 )
	end
end

function CYSensor.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
	--print("self.UIPosIndex"..self.UIPosIndex)
end

function CYSensor.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Sensor超远感应器")
		self.gui:setText("Interaction", "Set Active Distance 设置触发距离")		
		self.gui:setIconImage("Icon", sm.uuid.new("8002aace-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.activeDistance, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Distance距离: "..self.activeDistance[self.UIPosIndex].."格Blocks")
	self.gui:open()
end

function CYSensor.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Distance距离: "..self.activeDistance[newIndex].."格Blocks")
	end
	self.network:sendToServer("server_distanceChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function CYSensor.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置激活距离 Set Active Distance")
	return true
end