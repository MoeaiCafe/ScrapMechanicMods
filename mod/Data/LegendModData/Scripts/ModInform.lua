----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

ModInform = class( nil )

function ModInform.client_onInteract(self, character, state )
	if state then
		sm.audio.play("Blueprint - Share", self.shape:getWorldPosition())
		--sm.gui.displayAlertText("传奇模组 New Legend Mod 2.9.4     更新于 Updated at 2021/3/14", 4)
		
		self.gui = sm.gui.createGuiFromLayout('$MOD_DATA/Gui/Layouts/ModInform.layout')
		self.gui:open()
		
		
	end
end

function ModInform.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "查看更多信息 More Information")
	return true
end