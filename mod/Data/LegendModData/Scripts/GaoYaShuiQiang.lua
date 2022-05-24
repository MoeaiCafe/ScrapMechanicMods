----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

GaoYaShuiQiang = class( nil )
GaoYaShuiQiang.maxParentCount = 1
GaoYaShuiQiang.maxChildCount = 0
GaoYaShuiQiang.connectionInput = sm.interactable.connectionType.logic
GaoYaShuiQiang.connectionOutput = sm.interactable.connectionType.none
GaoYaShuiQiang.colorNormal = sm.color.new(0xcb0a00ff)
GaoYaShuiQiang.colorHighlight = sm.color.new(0xee0a00ff)
GaoYaShuiQiang.poseWeightCount = 1

function GaoYaShuiQiang.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 1 )
end

function GaoYaShuiQiang.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		if self.input:isActive() then
			self.interactable:setActive(true)
		else
			self.interactable:setActive(false)
		end
	else
		self.interactable:setActive(false)
	end
end

function GaoYaShuiQiang.client_onCreate(self)

	self.waterEffect = sm.effect.createEffect( "Water - Waterleak01", self.interactable)
	self.waterEffect:setOffsetPosition( sm.vec3.new( 0, 0, 0.45 ) )
	
end

function GaoYaShuiQiang.client_onFixedUpdate( self, dt )
	waterEffect = self.waterEffect
	if self.interactable:isActive() == true then
		self.interactable:setPoseWeight( 0, 1 )
		if not waterEffect:isPlaying() then
			waterEffect:start()
		end
	else
		self.interactable:setPoseWeight( 0, 0 )
		if waterEffect:isPlaying() then
			waterEffect:stop()
		end
	end
end

function GaoYaShuiQiang.client_onDestroy(self )
	--销毁粒子效果
	waterEffect:stop()
	waterEffect:destroy()
			
end

