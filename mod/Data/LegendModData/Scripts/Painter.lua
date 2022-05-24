----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

Painter = class( nil )
Painter.maxChildCount = 1
Painter.maxParentCount = 1
Painter.connectionInput = sm.interactable.connectionType.logic
Painter.connectionOutput = sm.interactable.connectionType.logic
Painter.colorNormal = sm.color.new(0xff00b4ff)
Painter.colorHighlight = sm.color.new(0xff33c2ff)
Painter.poseWeightCount = 1
Painter.PainterUUID = "3012aaad-5494-11e6-beb8-9e71128cae77"

function Painter.server_onFixedUpdate( self, dt )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.Active = self.input:isActive()
		if self.Active then
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
	
	if self.lastActive == false and self.interactable:isActive() then
		self:server_paintMode1(self)
	end
	self.lastActive = self.interactable:isActive()
end

function Painter.server_paintMode1(self)
	local color = self.shape:getColor()
	
	local downDir = -sm.shape.getAt(self.shape)
	--print(downDir)
	local hit,raycastResult = sm.physics.raycast(self.shape.worldPosition, self.shape.worldPosition + downDir)
    if hit and raycastResult.type == "body" then
        local shape = raycastResult:getShape()
		self.aimColor = shape.color
		--print(self.aimColor)
    end
	
	for i,shape in pairs(self.shape.body:getCreationShapes()) do
		self.shapeUUID = sm.shape.getShapeUuid(shape)
		self.shapeUUIDstring = tostring(self.shapeUUID)
		self.shapeColor = sm.shape.getColor(shape)
		
		if self.shapeUUIDstring ~= self.PainterUUID and self.shapeColor == self.aimColor then
			shape:setColor(color)
		end
	end
end

function Painter.server_paintMode2(self)
	local color = self.shape:getColor()
	
	for i,shape in pairs(self.shape.body:getCreationShapes()) do
		self.shapeUUID = sm.shape.getShapeUuid(shape)
		self.shapeUUIDstring = tostring(self.shapeUUID)
		
		if self.shapeUUIDstring ~= self.PainterUUID then
			shape:setColor(color)
		end
	end
end

function Painter.client_onInteract(self,character, state )
	local crouching = sm.localPlayer.getPlayer().character:isCrouching()
	if state == true and crouching == false then
		self.network:sendToServer("server_paintMode1")
		sm.audio.play("PaintTool - Paint", self.shape:getWorldPosition())
		sm.gui.displayAlertText("喷漆已完成 Painting has been completed", 2)
	elseif state == true and crouching == true then
		self.network:sendToServer("server_paintMode2")
		sm.audio.play("PaintTool - Paint", self.shape:getWorldPosition())
		sm.gui.displayAlertText("喷漆已完成 Painting has been completed", 2)
	end
end

function Painter.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "同色部分喷漆! Paint parts of the same color!")
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "#ff3333全部喷漆 Paint All!")
	return true
end