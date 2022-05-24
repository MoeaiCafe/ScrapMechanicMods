----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

ZiXingCheLun = class( nil )
ZiXingCheLun.poseWeightCount = 1

function ZiXingCheLun.server_onCreate( self )
	self.activeLoad = self.storage:load()
	if self.activeLoad == nil then
		self.active = false
		self.storage:save(self.active)
		print("否")
	else
		self.active = self.activeLoad
		print("是")
	end
	
	self.network:sendToClients("client_getData", self.active)
end

function ZiXingCheLun.server_request( self )
	self.activeLoad = self.storage:load()
	if self.activeLoad == nil then
		self.active = false
		self.storage:save(self.active)
		print("否")
	else
		self.active = self.activeLoad
		print("是")
	end
	
	self.network:sendToClients("client_getData", self.active)
end

function ZiXingCheLun.server_activeChange( self, Active )
	self.active = Active
	self.storage:save(self.active)
	
	self.network:sendToClients("client_getData", self.active)
end

function ZiXingCheLun.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 0 )
	self.boltValue = 0.0
	self.network:sendToServer("server_request")
end

function ZiXingCheLun.client_onInteract(self, character, state)
	if state then
		self.active = not self.active	--下一次按E的时候反转按E的效果
		self.network:sendToServer("server_activeChange", self.active)
	end
end

function ZiXingCheLun.client_getData( self, data )	
	self.active = data
end

function ZiXingCheLun.client_onUpdate( self, dt )	
	if self.active == true then
		if self.boltValue < 1 then
			self.boltValue = self.boltValue + dt*2		
		else
			self.boltValue = 1
		end
	end
	if self.active == false then
		if self.boltValue > 0 then
			self.boltValue = self.boltValue - dt*2		
		else
			self.boltValue = 0
		end
	end	
	self.interactable:setPoseWeight( 0, self.boltValue )
	--print(self.interactable:isActive())
	--print(self.boltValue)
end

function ZiXingCheLun.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "切换轮胎造型 Change Wheel Styling")
	return true
end


