----------------------------------------------
-------Copyright (c) 2020 David Sirius--------
----------------------------------------------
HuaSa = class( nil )
HuaSa.colorNormal = sm.color.new(0x87580cff)
HuaSa.colorHighlight = sm.color.new(0x9e6f24ff)
HuaSa.poseWeightCount = 1

function HuaSa.client_onCreate( self )
	self.toggle = false
end

function HuaSa.server_onCreate( self )
	self.toggle = false
end

function HuaSa.client_onFixedUpdate(self,dt)
	if self.toggle then
		self:Particles()
		self.Active = true
		self.client_OnOff( self, Data )
		self.interactable:setPoseWeight( 0, 1 )
	else
		self.Active = false
		self.client_OnOff( self, Data )
		self.interactable:setPoseWeight( 0, 0 )
	end
end

function HuaSa.client_OnOff( self, Data )
	if self.lastActive == false and self.Active then
		sm.audio.play("Button on", self.shape:getWorldPosition())
		--print("ON")
	elseif self.lastActive == true and self.Active == false then
		sm.audio.play("Button off", self.shape:getWorldPosition())
		--print("OFF")
	end
	self.lastActive = self.Active
end

function HuaSa.Particles(self)
	local shapePos = sm.shape.getWorldPosition(self.shape)
	local pos = (self.shape.right * 0) + (self.shape.up * 0.35) + (self.shape.at * 0.36)
	local pos1 = shapePos + pos
	local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, -1 ), self.shape.at )
	sm.particle.createParticle("p_watercanon_muzzelflash", pos1, rot )
end

function HuaSa.client_onInteract(self,character, state )
	if state == true then
		self.network:sendToServer("server_toggle")
	end
end

function HuaSa.client_onToggle_test(self,toggleValue)
	self.toggle = toggleValue
end

function HuaSa.server_toggle(self)
	self.toggle = not self.toggle
	self.network:sendToClients("client_onToggle_test",self.toggle)
end

function HuaSa.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "打开 Turn On")
	return true
end
