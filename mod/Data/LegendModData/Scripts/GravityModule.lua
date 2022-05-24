----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

GravityModule = class( nil )
GravityModule.maxParentCount = 1
GravityModule.maxChildCount = 0
GravityModule.connectionInput = sm.interactable.connectionType.logic
GravityModule.connectionOutput = sm.interactable.connectionType.none
GravityModule.colorNormal = sm.color.new(0x303030ff)
GravityModule.colorHighlight = sm.color.new(0x454545ff)
GravityModule.poseWeightCount = 1

function GravityModule.server_onCreate( self ) 
	self.lastActive = false	
	self.Gravity = 9.8
end

function GravityModule.server_onFixedUpdate( self, Data )

	Parent = self.interactable:getSingleParent()
	if Parent then
		Parent:getShape()
		if  Parent:isActive() == true then
			self.interactable:setActive(true)
		else
			self.interactable:setActive(false)
		end
	else
		self.interactable:setActive(false)
	end
		
	--print("g="..self.Gravity)
	if self.lastActive == false and self.interactable:isActive() then
		sm.physics.setGravity(self.Gravity)
		
	elseif self.lastActive == true and self.interactable:isActive() == false then
		sm.physics.setGravity(9.8)
	end
	--[[
	if self.interactable:isActive() then
		self.network:sendToClients("client_Display", self.Gravity )
	end
	]]--
	self.lastActive = self.interactable:isActive()
end

function GravityModule.server_onDestroy( self )
	self.lastActive = false
end

function GravityModule.server_changemode(self, crouch)
	if self.Gravity == 9.8 then
		self.Gravity = 0
		self.Gravity = (self.Gravity + (crouch and -1 or 1))
	else
		self.Gravity = (self.Gravity + (crouch and -1 or 1))
	end
end

-- Client
function GravityModule.client_onInteract(self,character, state )
	if state == true then
		local crouching = sm.localPlayer.getPlayer().character:isCrouching()
		playerID = sm.localPlayer.getId()
		if playerID == 1 then	
			self.network:sendToServer("server_changemode", crouching)
			gravityString = tostring(self.Gravity-1)
			sm.gui.displayAlertText("当前重力为Gravity=  "..gravityString.."  N/kg (m/s^2)", 1)
		else
			sm.gui.displayAlertText("抱歉!您不是房主，无权使用! Sorry! You're NOT the HOST PLAYER!", 2)
		end
	end
end

function GravityModule.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "增大重力值 Increase the Gravity")
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "减小重力值 Decrease the Gravity")
	return true
end

