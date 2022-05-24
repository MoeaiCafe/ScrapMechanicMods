--------------------------------------------------------
---This script contains open source code from MJM Mod---
---------------Modified by David Sirius-----------------
--------------------------------------------------------

LogicMouseRight = class()
LogicMouseRight.maxChildCount = -1
LogicMouseRight.maxParentCount = 1
LogicMouseRight.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.power
LogicMouseRight.connectionOutput = sm.interactable.connectionType.logic
LogicMouseRight.colorNormal = sm.color.new( 0x549900ff )
LogicMouseRight.colorHighlight = sm.color.new( 0x69a61eff )
LogicMouseRight.poseWeightCount = 1

function LogicMouseRight.server_onFixedUpdate( self, dt )
	local active = false
	local rightClick = false

	-- check for seat signals
	parent = self.interactable:getSingleParent()
	if parent then
		if parent:hasOutputType(sm.interactable.connectionType.seated) and parent:isActive() then
			seated = true -- seated
			--print("是")
			local parentID = parent.id
			if _G[parentID.."rightClick"] then
				rightClick = true
			end
		end
	end
	
	if seated then -- a player is seated in a connected seat
		if rightClick then
			self.interactable:setActive(true)
			self.interactable:setPower(1)
		else
			self.interactable:setActive(false)
			self.interactable:setPower(0)
		end
	end
end

-- ____________________________________ Client ____________________________________

function LogicMouseRight.client_onDestroy( self )
	if self.cl_ID then
		_G[self.cl_ID.."rightClick"] = nil
	end
end

function LogicMouseRight.client_onFixedUpdate( self, dt )
	if self.cl_ID == null and self.interactable then
		self.cl_ID = self.interactable.id
		self:cl_setMode()
	end

	if self.interactable:isActive() then
        self.interactable:setUvFrameIndex(9)
		self.interactable:setPoseWeight(0,1)
	else
        self.interactable:setUvFrameIndex(3)
		self.interactable:setPoseWeight(0,0)
    end 
end

function LogicMouseRight.cl_setMode( self, modeIndex )
	if self.cl_ID then
			_G[self.cl_ID.."rightClick"] = true
	end
end

