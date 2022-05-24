----------------------------------------------------
---This script contains code from TechnologicNick---
-------------Modified by David Sirius---------------
----------------------------------------------------

SJCK = class( nil )
SJCK.maxParentCount = 1
SJCK.maxChildCount = -1
SJCK.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
SJCK.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
SJCK.colorNormal = sm.color.new(0x9c0d44ff)
SJCK.colorHighlight = sm.color.new(0xc11559ff)
SJCK.poseWeightCount = 1

SJCK.offsetDegreeTable = {-90, -80, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90}

--Server--
function SJCK.server_onCreate( self )
	self.interactable:setActive(false)
	WSPower = 0
	ADPower = 0
	self.lastActive = false

	self.degreeIndex = self.storage:load()
	if self.degreeIndex == nil then
		self.degreeIndex = 10
		self.offsetDegree = self.offsetDegreeTable[self.degreeIndex]
		self.storage:save(self.degreeIndex)
	else
		self.offsetDegree = self.offsetDegreeTable[self.degreeIndex]
	end
	
	self.network:sendToClients("client_getUIData", self.degreeIndex)
end

function SJCK.server_request( self )
	self.network:sendToClients("client_getUIData", self.degreeIndex)
end

function SJCK.server_degreeChange( self, degreeIndex )
	self.degreeIndex = degreeIndex
	self.offsetDegree = self.offsetDegreeTable[self.degreeIndex]
	self.storage:save(self.degreeIndex)
	self.network:sendToClients("client_getUIData", self.degreeIndex)
end

function SJCK.server_onFixedUpdate( self, dt )
	Parent = self.interactable:getSingleParent()
	if Parent then
		if  Parent:isActive() == true then
			self.interactable:setActive(true)
		else
			self.interactable:setActive(false)
		end
		--获取离父级对象最近的玩家
		Player = server_getNearestPlayer(Parent:getShape():getWorldPosition())
		PlayerID = Player:getId()
	else
		self.interactable:setActive(false)
	end
	
	if self.interactable:isActive() then
		if Player then
			ObjectZ = self.shape.up	--获得物体的前方 +Z
			PlayerDir = directionCalculation(Player.character:getDirection())	--返回玩家视角水平和竖直方向的角度
			ObjectDir = directionCalculation(ObjectZ)	--返回自身+Z水平和竖直方向的角度
			
			WSDeg = ObjectDir.WSDeg - PlayerDir.WSDeg + self.offsetDegree/90 	--竖直方向视角与物体的角度差值
			ADDeg = ObjectDir.ADDeg - PlayerDir.ADDeg 	--水平方向视角与物体的角度差值
			print(WSDeg)
			
			if math.abs(ADDeg) > 1 then	--如果水平角度差值绝对值大于1度
				if ADDeg > 0 then
					ADDeg = ObjectDir.ADDeg - PlayerDir.ADDeg -2	--水平角度差值为正时将差值减小2
				else
					ADDeg = ObjectDir.ADDeg - PlayerDir.ADDeg +2	--水平角度差值为负时将差值增大2
				end
			end
			--[[
			print("【视角WS】"..PlayerDir.WSDeg)
			print("【视角AD】"..PlayerDir.ADDeg)
			print("【控制WS】"..ObjectDir.WSDeg)
			print("【控制AD】"..ObjectDir.ADDeg)
			print("【WS】"..WSDeg)
			print("【AD】"..ADDeg)
			]]--
			
			WSPower = calculationPower(WSDeg)
			ADPower = calculationPower(ADDeg)
		
			if WSPower ~= 0 then
				WSActive = true
			else
				WSActive = false
			end
			if ADPower ~= 0 then
				ADActive = true
			else
				ADActive = false
			end
		
			local LogicW = "3008aaaf-5494-11e6-beb8-9e71128cae77"
			local LogicS = "3010aaaf-5494-11e6-beb8-9e71128cae77"
			local LogicA = "3009aaaf-5494-11e6-beb8-9e71128cae77"
			local LogicD = "3011aaaf-5494-11e6-beb8-9e71128cae77"

			for k,v in pairs(self.interactable:getChildren()) do
				--print("已检测到以下子连接对象")
				local UUID = sm.shape.getShapeUuid(v:getShape())
				--print(UUID)
				UUIDstring = tostring(UUID)
				if  UUIDstring == LogicW or UUIDstring == LogicS then
					v:setActive(WSActive)
					v:setPower(WSPower)
				end
				if UUIDstring == LogicA or UUIDstring == LogicD then
					v:setActive(ADActive)
					v:setPower(ADPower)
				end
			end
		end
	else
		for k,v in pairs(self.interactable:getChildren()) do
			v:setActive(false)
			v:setPower(0)
		end
	end
	
	if PlayerID then
		self.network:sendToClients("client_OnOff", PlayerID )
	end
	
	self.lastActive = self.interactable:isActive()
end

function server_getNearestPlayer( position )
	local nearestPlayer = nil
	local nearestDistance = nil
	for id,Player in pairs(sm.player.getAllPlayers()) do
		if Player.character then
			local length2 = sm.vec3.length2(position - Player.character:getWorldPosition())
			if nearestDistance == nil or length2 < nearestDistance then
				nearestDistance = length2
				nearestPlayer = Player
			end
			--print(nearestPlayer)
		end
	end
	
	if nearestPlayer then
		return nearestPlayer
	else
		return nil
	end
end

function directionCalculation( direction )
	local Degree = {}
	Degree.WSDeg = math.acos(direction.z)/(math.pi/2)-1
	Degree.ADDeg = math.atan2(direction.y,direction.x)/math.pi
	return Degree
end

function calculationPower(value)
	value = value *2
	if math.abs(value) < 0.0001 then
		value = 0
	end
	return value
end

--Client--
function SJCK.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 0 )
	self.boltValue = 0.0
	self.lastActive = false
	self.UIPosIndex = 10
	self.network:sendToServer("server_request")
end

function SJCK.client_onUpdate( self, dt )	
	if self.interactable:isActive() then
		self.boltValue = 1.0
	else
		self.boltValue = 0.0	
	end	
	self.interactable:setPoseWeight( 0, self.boltValue )
end

function SJCK.client_OnOff( self, PlayerID )
	if self.lastActive == false and self.interactable:isActive() then
		if PlayerID then
			sm.audio.play("Retrowildblip", self.shape:getWorldPosition())
			if PlayerID == sm.localPlayer.getId() then
			sm.gui.displayAlertText("视角操控已开启 Camera Control Activated", 2)
			end
		end
	elseif self.lastActive == true and self.interactable:isActive() == false then
		if PlayerID then
			if PlayerID == sm.localPlayer.getId() then
				sm.gui.displayAlertText("视角操控已关闭 Camera Control OFF", 1.5)
			end
		end
	end
	self.lastActive = self.interactable:isActive()
end

function SJCK.client_getUIData(self, UIPosIndex )
	self.UIPosIndex = UIPosIndex
end

function SJCK.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Camera Control视角操控")
		self.gui:setText("Interaction", "Set Offset Angle设置偏移角度")		
		self.gui:setIconImage("Icon", sm.uuid.new("8002aabc-5494-11e6-beb8-9e71128cae77"))
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.offsetDegreeTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", "Angle角度: "..self.offsetDegreeTable[self.UIPosIndex].."度degrees")
	self.gui:open()
end

function SJCK.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		self.gui:setText("SubTitle", "Offset Angle偏移角度: "..self.offsetDegreeTable[newIndex].."度degrees")
	end
	self.network:sendToServer("server_degreeChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function SJCK.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置视角偏移 Set Offset Angle")
	return true
end

