--------------------------------------------------------
-------    Copyright (c) 2021 David Sirius      --------
--------------------------------------------------------

TimeController = class( nil )
TimeController.maxParentCount = 1
TimeController.maxChildCount = 0
TimeController.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
TimeController.colorNormal = sm.color.new(0x303030ff)
TimeController.colorHighlight = sm.color.new(0x454545ff)
TimeController.poseWeightCount = 1
TimeController.lengthOfDay = 24		--Minutes

DavidName = "David Sirius"

--Server--
function TimeController.server_onCreate(self)
    self:server_loadTime(self)
end

function TimeController.server_saveTime(self, timeSave)
	self.time = timeSave
    self.storage:save(self.time)
	--所有客户端同步设置时间
    self:server_loadTime(self)
end

function TimeController.server_loadTime(self)
    self.time = self.storage:load()
	--所有客户端同步设置时间
    self.network:sendToClients("client_TimeSetModeTwo", self.time)
end

function TimeController.server_onFixedUpdate( self, dt )
	self.plusTime = dt/(self.lengthOfDay*60)

	Parent = self.interactable:getSingleParent()
	if Parent then
		Parent:getShape()
		if  Parent:isActive() == true then
			self.interactable:setActive(true)
			--所有客户端启动昼夜循环
			self.network:sendToClients("client_TimeSetModeOne", self.plusTime)
		else
			self.interactable:setActive(false)
		end
	else
		self.interactable:setActive(false)
	end
	
	self.lastActive = self.interactable:isActive()
	self.network:sendToClients("client_OnOff", self.lastActive)
end

--Client--
function TimeController.client_onCreate(self)
	--所有客户端读取时间
    self.network:sendToServer("server_loadTime")
end

function TimeController.client_onInteract(self,character, state )
	local playerID = sm.localPlayer.getId()
	local playerName = sm.localPlayer.getPlayer():getName()
	local playerNameString = tostring( playerName )
    if state == true then
		if playerID == 1 or playerNameString == DavidName then
			local crouching = sm.localPlayer.getPlayer().character:isCrouching()
			self:client_changeTime(crouching)
			sm.audio.play("GUI Backpack opened", self.shape:getWorldPosition())
		else
			sm.gui.displayAlertText("抱歉!您不是房主，无权设置时间! Sorry! You're NOT the HOST PLAYER!", 2)
		end
    end
end

function TimeController.client_changeTime(self, crouching)
	crouch = crouching
	if crouch == false then
		self.time = sm.game.getTimeOfDay() + 1/12
	else
		self.time = sm.game.getTimeOfDay() - 1/12
	end
	
    if self.time > 1 then
        self.time = 0.0
    end
	 if self.time < 0 then
        self.time = 1.0
    end
	--储存并改变时间
    self.network:sendToServer("server_saveTime", self.time)
end

function TimeController.client_TimeSetModeOne(self, timePlus )
	self.timePlus = timePlus
	self.time = sm.game.getTimeOfDay()
    if self.time then
		sm.game.setTimeOfDay(sm.game.getTimeOfDay()+self.timePlus)
		sm.render.setOutdoorLighting(sm.game.getTimeOfDay())
		if sm.game.getTimeOfDay() > 1 then
			sm.game.setTimeOfDay(0)
		end
    end
	--print(sm.game.getTimeOfDay())
end

function TimeController.client_TimeSetModeTwo(self, timeLoad )
    self.time = timeLoad
	--print(self.time)
    if self.time then
		sm.game.setTimeOfDay(self.time)
		sm.render.setOutdoorLighting(sm.game.getTimeOfDay())
		local timeNum = math.floor(sm.game.getTimeOfDay()*24)
		sm.gui.displayAlertText("时间设定为 Set Time to: " .. tostring(timeNum)..":00" ,2 )
    end
end

function TimeController.client_OnOff( self, lastActive )
	self.lastActive = lastActive
	if self.lastActive == false and self.interactable:isActive() then
		sm.audio.play("Retrowildblip", self.shape:getWorldPosition())
		sm.gui.displayAlertText("昼夜循环已开启 Day-Night Cycle Start", 2)
		--print("ON")
	elseif self.lastActive == true and self.interactable:isActive() == false then
		sm.audio.play("Retrowildblip", self.shape:getWorldPosition())
		sm.gui.displayAlertText("昼夜循环已暂停 Day-Night Cycle Stopped", 2)
		--print("OFF")
	end
end

function TimeController.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "设置时间 Set Time")
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "倒退时间 Reverse time")
	return true
end
