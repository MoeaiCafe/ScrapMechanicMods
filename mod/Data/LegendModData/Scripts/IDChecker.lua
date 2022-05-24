----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------
IDChecker = class()

DavidName = "David Sirius"

function IDChecker.client_onInteract(self,character, state )
	local playerID = sm.localPlayer.getId()
	local playerName = sm.localPlayer.getPlayer():getName()
	local playerNameString = tostring( playerName )
	--print(playerID)
	--print(playerNameString)
	if state == true then
		if playerID == 1 or playerNameString == DavidName then
			sm.gui.chatMessage("#ff0000地图内的全部玩家 All players in this world:")
			
			players = sm.player.getAllPlayers()
			for i, v in pairs(players) do
				IDString = tostring( v:getId() )
				nameString = tostring( v.name )
				sm.gui.chatMessage(IDString..": "..nameString)
			end
			sm.audio.play("ConnectTool - Released", self.shape:getWorldPosition())
		else
			sm.gui.displayAlertText("抱歉!您不是房主，无权查看! Sorry! You're NOT the HOST PLAYER!", 2)
		end
	end
end

function IDChecker.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "查看地图内所有玩家的ID值 Check all Players' ID")
	return true
end
