----------------------------------------------
-------Copyright (c) 2020 David Sirius--------
----------------------------------------------
JiXianQi = class( nil )
JiXianQi.maxParentCount = 20
JiXianQi.maxChildCount = -1
JiXianQi.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
JiXianQi.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
JiXianQi.colorNormal = sm.color.new( 0x007fffff )
JiXianQi.colorHighlight = sm.color.new( 0x80bdffff )
JiXianQi.poseWeightCount = 1

function JiXianQi.server_onFixedUpdate( self, dt )
    local Parents = self.interactable:getParents()
    local outputPower = 0
    for k,v in pairs(Parents) do
        outputPower = v:getPower() + outputPower
    end
    self.interactable:setPower(outputPower)
	
    if outputPower ~= 0 and not self.interactable:isActive() then
        self.interactable:setActive(true)
    end
    if outputPower == 0 and self.interactable:isActive() then
        self.interactable:setActive(false)
    end
end

function JiXianQi.client_onUpdate( self, dt )
    if self.interactable:isActive() then 
		self.interactable:setUvFrameIndex(7)
		self.interactable:setPoseWeight(0,1)
    else
		self.interactable:setUvFrameIndex(1)
		self.interactable:setPoseWeight(0,0)
	end
end