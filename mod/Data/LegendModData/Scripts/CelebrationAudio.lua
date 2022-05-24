----------------------------------------------
-------Copyright (c) 2020 David Sirius--------
----------------------------------------------

CelebrationAudio = class()

CelebrationAudio.maxParentCount = 1
CelebrationAudio.maxChildCount = 0
CelebrationAudio.connectionInput = sm.interactable.connectionType.logic
CelebrationAudio.connectionOutput = sm.interactable.connectionType.none
CelebrationAudio.colorNormal = sm.color.new( 0x9c9c9cff )
CelebrationAudio.colorHighlight = sm.color.new( 0xb5b5b5ff )

--Server
function CelebrationAudio.server_onFixedUpdate( self, timeStep )
	local parent = self.interactable:getSingleParent()
	if parent then
		self.interactable.active = parent.active
	else
		self.interactable.active = false
	end
end

--Client
function CelebrationAudio.client_onCreate( self )
	self:client_init()
end

function CelebrationAudio.client_onRefresh( self )
	self:client_init()
end

function CelebrationAudio.client_init( self )
	self.audioEffect = sm.effect.createEffect( "CelebrationBot - Audio", self.interactable )
end

function CelebrationAudio.client_onUpdate( self, dt )
	if self.audioEffect then
		if self.interactable.active and self.lastActive== false then
			self.audioEffect:start()
		end
		if not self.interactable.active then
			self.audioEffect:stop()
		end
	end
	self.lastActive = self.interactable.active
end
