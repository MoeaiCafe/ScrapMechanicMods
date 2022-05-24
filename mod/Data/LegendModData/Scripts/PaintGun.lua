----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

PaintGun = class( nil )
PaintGun.maxParentCount = 1
PaintGun.maxChildCount = 1
PaintGun.connectionInput =  sm.interactable.connectionType.logic
PaintGun.connectionOutput = sm.interactable.connectionType.logic
PaintGun.colorNormal = sm.color.new(0xff00b4ff)
PaintGun.colorHighlight = sm.color.new(0xff33c2ff)
PaintGun.poseWeightCount = 1


function PaintGun.server_onFixedUpdate( self, dt )
	local parent = self.interactable:getSingleParent()
	
	if parent then
		--print(parent)
		local parentColor = parent:getShape():getColor()
		self.shape:setColor(parentColor)
		if parent:isActive() then
			self:server_paint()
			self.interactable:setActive(true)
			self.interactable:setPower(1)
		else
			self.interactable:setActive(false)
			self.interactable:setPower(0)
		end
	end
end

function PaintGun.server_paint(self)
	local color = self.shape:getColor()
	local back = -sm.shape.getUp(self.shape)
	local hit,raycastResult = sm.physics.raycast(self.shape.worldPosition, self.shape.worldPosition + back*50)
	if hit and raycastResult.type == "body" then
		local aimShape = raycastResult:getShape()
		aimShape:setColor(color)
		aimShapePos = sm.shape.getWorldPosition( aimShape )
		aimShapeArgs = {color, aimShapePos}
		self.network:sendToClients("client_paintParticle", aimShapeArgs )
		
	end
end

function PaintGun.client_onCreate( self )
	self.boltValue = 0.0
end

function PaintGun.client_onFixedUpdate( self, dt )

	if self.boltValue > 0.0 then
		self.boltValue = self.boltValue - dt * 5
	end
	if self.boltValue ~= self.prevBoltValue then
		self.interactable:setPoseWeight( 0, self.boltValue ) --Clamping inside
		self.prevBoltValue = self.boltValue
	end
	
end

function PaintGun.client_paintParticle(self)
	self.boltValue = 1.0
	sm.particle.createParticle("paint_smoke", aimShapeArgs[2], nil, aimShapeArgs[1])
end

function PaintGun.client_onInteract(self,character, state )
	if state == true then
		self.network:sendToServer("server_paint")
		sm.audio.play("PaintTool - Paint", self.shape:getWorldPosition())
		sm.gui.displayAlertText("喷漆已完成 Painting has been completed", 2)
	end
end

function PaintGun.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "#ff3333喷漆! Paint!")
	return true
end
