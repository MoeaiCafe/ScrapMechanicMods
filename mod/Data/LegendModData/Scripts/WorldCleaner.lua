----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------
WorldCleaner = class()

DavidName = "David Sirius"

function WorldCleaner.server_ClearWorld(self,playerNameString)
	local allBodys = sm.body.getAllBodies()	--获取所有Body
	
	for k,v in pairs(allBodys) do
		local allShapes = sm.body.getShapes(v)	--获取所有Shape	
		for k,v in pairs(allShapes) do
			sm.shape.destroyShape(v,0) -- 参数为0将摧毁所有零件
		end		
    end

	self.network:sendToClients("client_displayAndSound",playerNameString)
	
	sm.shape.destroyPart(self.shape)
end

function WorldCleaner.client_onInteract(self,character, state )
	local playerID = sm.localPlayer.getId()
	local playerName = sm.localPlayer.getPlayer():getName()
	local playerNameString = tostring( playerName )
	--print(playerID)
	--print(playerNameString)
	if playerID == 1 or playerNameString == DavidName and state == true then		
		self.network:sendToServer("server_ClearWorld", playerNameString)	
	else
		sm.gui.displayAlertText("抱歉!您不是房主，无权清图! Sorry! You're NOT the HOST PLAYER!", 2)
	end
end

function WorldCleaner.client_displayAndSound(self, playerNameString)
	if playerNameString == DavidName then
		sm.gui.displayAlertText("地图已被管理员戴维Sirius清空 World has been cleared by administrator David Sirius", 4)
		sm.audio.play("Blueprint - Share", nil)
	else
		sm.gui.displayAlertText("地图已被房主清空 World has been Cleared", 2)
		sm.audio.play("Retrowildblip", nil)
	end
end

function WorldCleaner.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "#ff3333清除世界所有物品! Clear the World!")
	return true
end
