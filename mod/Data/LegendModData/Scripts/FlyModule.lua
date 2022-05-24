----------------------------------------------
-------Copyright (c) 2022 David Sirius--------
----------------------------------------------

FlyModule = class(nil)
FlyModule.maxParentCount = 0
FlyModule.maxChildCount = 0
FlyModule.connectionInput = sm.interactable.connectionType.none
FlyModule.connectionOutput = sm.interactable.connectionType.none

DavidName = "David Sirius"

function FlyModule.server_onCreate( self )
	self.Active = false
end

function FlyModule.server_request( self )
	self:server_Fly(self.Active)
end


function FlyModule.server_Fly( self, Active )
	self.Active = Active
	if self.Active == true then
		self.playerSpeed = 3
	else
		self.playerSpeed = 1
	end
	
	for id, player in pairs(sm.player.getAllPlayers()) do
		local character = player:getCharacter()
		character:setSwimming(self.Active)
		character:setMovementSpeedFraction(self.playerSpeed)
	end
	
	self.network:sendToClients("client_displayAndSound", self.Active)
end

function FlyModule.server_onDestroy(self)
	for id, player in pairs(sm.player.getAllPlayers()) do
		local character = player:getCharacter()
		character:setSwimming(false)
		character:setMovementSpeedFraction(1)
	end
end

function FlyModule.client_onCreate( self )
	self.network:sendToServer("server_request")
end

function FlyModule.client_onInteract( self, character, state )
	local playerID = sm.localPlayer.getId()
	local playerName = sm.localPlayer.getPlayer():getName()
	local playerNameString = tostring( playerName )
	--print(playerID)
	--print(playerNameString)
	if playerID == 1 or playerNameString == DavidName then
		if state == true then
			self.Active = not self.Active
			self.network:sendToServer("server_Fly", self.Active)
		end
	else
		sm.gui.displayAlertText("抱歉!您不是房主，无权启用飞行! Sorry! You're NOT the HOST PLAYER!", 2)
	end
	print(self.Active)
end

function FlyModule.client_displayAndSound(self, Active)
	self.Active = Active
	if self.lastActive == false and self.Active == true then
		sm.gui.displayAlertText("房主已开启飞行模式 Fly Mode On!", 2)
		sm.audio.play("Retrowildblip", nil)
	elseif self.lastActive == true and self.Active == false then
		sm.gui.displayAlertText("房主关闭飞行模式 Fly Mode Off!", 2)
		sm.audio.play("Retrowildblip", nil)
	end
	self.lastActive = self.Active
end

