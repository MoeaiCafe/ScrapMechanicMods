----------------------------------------------
-------Copyright (c) 2020 David Sirius--------
----------------------------------------------
FanXiangQi = class( nil )
FanXiangQi.maxParentCount = 1
FanXiangQi.maxChildCount = -1
FanXiangQi.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
FanXiangQi.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
FanXiangQi.colorNormal = sm.color.new( 0x007fffff )
FanXiangQi.colorHighlight = sm.color.new( 0x80bdffff )
FanXiangQi.poseWeightCount = 1

function FanXiangQi.server_onFixedUpdate( self, dt )
    local Parent = self.interactable:getSingleParent()
    if Parent then
        local outputPower = -Parent:getPower()
        if outputPower ~= 0 then
            self.interactable:setPower(outputPower)
			self.interactable:setActive(true)
        else
			self.interactable:setPower(0)
			self.interactable:setActive(false)
		end
    else
        if self.interactable:getPower() ~= 0 then
            self.interactable:setPower(0)
			self.interactable:setActive(false)
        end
    end
end

function FanXiangQi.client_onUpdate( self, dt )
    if self.interactable:isActive() then 
		self.interactable:setUvFrameIndex(6)
		self.interactable:setPoseWeight(0,1)
    else
		self.interactable:setUvFrameIndex(0)
		self.interactable:setPoseWeight(0,0)
	end
end