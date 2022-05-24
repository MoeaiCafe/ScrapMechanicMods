--------------------------------------------------------
---This script contains open source code from MJM Mod---
---------------Modified by David Sirius-----------------
--------------------------------------------------------

LogicMouseLeft = class()
LogicMouseLeft.maxChildCount = -1
LogicMouseLeft.maxParentCount = 1
LogicMouseLeft.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.power
LogicMouseLeft.connectionOutput = sm.interactable.connectionType.logic
LogicMouseLeft.colorNormal = sm.color.new( 0x549900ff )
LogicMouseLeft.colorHighlight = sm.color.new( 0x69a61eff )
LogicMouseLeft.poseWeightCount = 1

function LogicMouseLeft.server_onFixedUpdate( self, dt )
	local active = false
	local leftClick = false

	-- check for seat signals
	parent = self.interactable:getSingleParent()
	if parent then
		if parent:hasOutputType(sm.interactable.connectionType.seated) and parent:isActive() then
			seated = true -- seated
			--print("是")
			local parentID = parent.id
			if _G[parentID.."leftClick"] then
				leftClick = true
			end
		end
	end
	
	if seated then -- a player is seated in a connected seat
		if leftClick then
			self.interactable:setActive(true)
			self.interactable:setPower(1)
		else
			self.interactable:setActive(false)
			self.interactable:setPower(0)
		end
	end
end

-- ____________________________________ Client ____________________________________

function LogicMouseLeft.client_onDestroy( self )
	if self.cl_ID then
		_G[self.cl_ID.."leftClick"] = nil
	end
end

function LogicMouseLeft.client_onFixedUpdate( self, dt )
	if self.cl_ID == null and self.interactable then
		self.cl_ID = self.interactable.id
		self:cl_setMode()
	end

	if self.interactable:isActive() then
        self.interactable:setUvFrameIndex(8)
		self.interactable:setPoseWeight(0,1)
	else
        self.interactable:setUvFrameIndex(2)
		self.interactable:setPoseWeight(0,0)
    end 
end

function LogicMouseLeft.cl_setMode( self, modeIndex )
	if self.cl_ID then
			_G[self.cl_ID.."leftClick"] = true
	end
end

