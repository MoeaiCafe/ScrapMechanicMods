----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

FenLiQi = class( nil )
FenLiQi.maxChildCount = 0
FenLiQi.maxParentCount = 1
FenLiQi.connectionInput = sm.interactable.connectionType.logic
FenLiQi.connectionOutput = sm.interactable.connectionType.none
FenLiQi.colorNormal = sm.color.new( 0x303030ff )
FenLiQi.colorHighlight = sm.color.new( 0x454545ff )

function FenLiQi.server_onFixedUpdate(self, dt)
	local parent = self.interactable:getSingleParent()
	if parent and parent:isActive() then
		sm.shape.destroyPart(self.shape) 
	end
end