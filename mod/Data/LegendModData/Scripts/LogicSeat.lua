----------------------------------------------
-------Copyright (c) 2019 David Sirius--------
----------------------------------------------

LogicSeat = class( nil )
LogicSeat.maxParentCount = 1
LogicSeat.maxChildCount = -1
LogicSeat.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
LogicSeat.connectionOutput = sm.interactable.connectionType.logic
LogicSeat.colorNormal = sm.color.new( 0x549900ff )
LogicSeat.colorHighlight = sm.color.new( 0x69a61eff )
LogicSeat.poseWeightCount = 1

function LogicSeat.server_onFixedUpdate( self, dt )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.seatedCharacter = self.input:isActive()
		if self.seatedCharacter then
			self.interactable:setActive(true)
			self.interactable:setPower(1)
		else
			self.interactable:setActive(false)
			self.interactable:setPower(0)
		end
	else
		self.interactable:setActive(false)
		self.interactable:setPower(0)
	end
end

function LogicSeat.client_onUpdate( self, dt )
	if self.interactable:isActive() then
        self.interactable:setUvFrameIndex(10)
		self.interactable:setPoseWeight(0,1)
	else
        self.interactable:setUvFrameIndex(4)
		self.interactable:setPoseWeight(0,0)
    end
end
