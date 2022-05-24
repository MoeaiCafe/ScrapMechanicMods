----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

ChineseCharacterBlock = class( nil )
ChineseCharacterBlock.maxParentCount = 1
ChineseCharacterBlock.maxChildCount = -1
ChineseCharacterBlock.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
ChineseCharacterBlock.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
ChineseCharacterBlock.colorNormal = sm.color.new( 0x999999ff )
ChineseCharacterBlock.colorHighlight = sm.color.new( 0xbbbbbbff )
ChineseCharacterBlock.poseWeightCount = 1

function ChineseCharacterBlock.server_onCreate( self )

	self.loadPower = self.storage:load()
	--print("self.loadPower"..self.loadPower)
	if self.loadPower then
		self.currentPower = self.loadPower
	else
		self.currentPower = 0
	end

	--有效值保护
	if self.currentPower == nil or self.currentPower < 0 or self.currentPower > 4095 then
		self.currentPower = 0
	end
	
end

function ChineseCharacterBlock.server_onFixedUpdate( self, dt )
	self.parent = self.interactable:getSingleParent()
    if self.parent then
		self.parentPower = self.parent:getPower()	--获取父级对象的power
		self.currentPower = self.parentPower
    end
	
	self.interactable:setPower(self.currentPower)
	self.network:sendToClients( "client_powerChanged",self.currentPower)
	
	if self.lastPower then
		if self.lastPower ~= self.currentPower then
			self.storage:save(self.currentPower)
			--print("已存档")
		end
	end
	self.lastPower = self.currentPower
end

function ChineseCharacterBlock.client_powerChanged( self, power )
	self.UVIndex = power
end

function ChineseCharacterBlock.client_onUpdate( self, dt )
	self.interactable:setUvFrameIndex(self.UVIndex)
end