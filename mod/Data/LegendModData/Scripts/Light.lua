----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

Light = class( nil )
Light.maxParentCount = 1
Light.maxChildCount = -1
Light.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
Light.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
Light.colorNormal = sm.color.new(0xffeb6dff)
Light.colorHighlight = sm.color.new(0xfff29dff)
Light.poseWeightCount = 1

function Light.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 1 )
end

function Light.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		if self.input:isActive() then
			self.interactable:setActive(true)
			self.interactable:setPower(1)
		else
			self.interactable:setActive(false)
			self.interactable:setPower(0)
		end
	else
		self.interactable:setActive(true)
		self.interactable:setPower(1)
	end
end

function Light.client_onUpdate( self, dt )
	if self.interactable:isActive() == true then
		self.interactable:setPoseWeight( 0, 1 )
	else
		self.interactable:setPoseWeight( 0, 0 )
	end
end
