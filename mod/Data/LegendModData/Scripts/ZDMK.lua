--------------------------------------------------
---------Copyright (c) 2021 David Sirius----------
--------------------------------------------------

ZDMK = class( nil )
ZDMK.maxParentCount = -1
ZDMK.connectionInput = sm.interactable.connectionType.logic
ZDMK.connectionOutput = sm.interactable.connectionType.logic
ZDMK.colorNormal = sm.color.new( 0x9000ffff )
ZDMK.colorHighlight = sm.color.new( 0xa733ffff )
ZDMK.poseWeightCount = 1

function ZDMK.server_onCreate( self )
	self.targetPlayerID = 1
end

function ZDMK.server_onFixedUpdate( self, dt )
	self.playerList = sm.player.getAllPlayers()
	--print(self.playerList)
	
	local whiteColor = sm.color.new(0xeeeeeeff)
	local blackColor = sm.color.new(0x222222ff)
	
	parents = self.interactable:getParents()
	if parents then
		for k,v in pairs(parents) do
			
			self.parentShape = v:getShape()
			self.parentColor = sm.shape.getColor(self.parentShape)
			
			nearestPlayer = server_getNearestPlayer(self.parentShape:getWorldPosition())
			
			--其他父级输入控制开关
			if self.parentColor ~= whiteColor and self.parentColor ~=blackColor then
				self.otherInput = true
				self.parentActive = v:isActive()
			end
			
			--如果输入为白色
			if self.parentColor == whiteColor then
				--如果白色按钮被按下一次
				if self.lastWhiteActive == false and v:isActive() then
					self.targetPlayerID = self.targetPlayerID +1	--目标玩家ID值+1
					
					--使目标ID值在有效范围内
					local maxIndex = table.maxn(self.playerList)
					if self.targetPlayerID > maxIndex then
						self.targetPlayerID = 1
					elseif self.targetPlayerID < 1 then
						self.targetPlayerID = maxIndex
					end
					
					--离操作对象最近的玩家显示目标ID值变化
					if nearestPlayer then
						self.network:sendToClients("client_targetChangedDisplay", { nearestPlayerID = nearestPlayer:getId(), TargetPlayerID = self.targetPlayerID, playerList = self.playerList })
					end
				end
				self.lastWhiteActive = v:isActive()
			end
			
			--如果输入为黑色
			if self.parentColor == blackColor then
				--如果黑色按钮被按下一次
				if self.lastBlackActive == false and v:isActive() then
					self.targetPlayerID = self.targetPlayerID -1	--目标玩家ID值-1
					
					--使目标ID值在有效范围内
					local maxIndex = table.maxn(self.playerList)
					if self.targetPlayerID > maxIndex then
						self.targetPlayerID = 1
					elseif self.targetPlayerID < 1 then
						self.targetPlayerID = maxIndex
					end
					
					--离操作对象最近的玩家显示目标ID值变化
					if nearestPlayer then
						self.network:sendToClients("client_targetChangedDisplay", { nearestPlayerID = nearestPlayer:getId(), TargetPlayerID = self.targetPlayerID, playerList = self.playerList })
					end
				end
				self.lastBlackActive = v:isActive()
			end
			
			if self.otherInput == true then
				self.inputActive = self.parentActive
			else
				self.inputActive = false
			end
		end
	else
		self.inputActive = false
	end
	
	--控制开关
	if self.inputActive == true then
		self.interactable:setActive(true)
		self:server_track( dt )
	else
		self.interactable:setActive(false)
	end
end

function ZDMK.server_track( self, dt )
	--获得目标玩家的位置
	self.targetCharacter = self.playerList[self.targetPlayerID]:getCharacter()
	self.targetPosition = self.targetCharacter:getWorldPosition()
	--print(self.targetPosition)
	--开始追踪
	local localX = sm.shape.getRight(self.shape)
  	local localY = sm.shape.getAt(self.shape)
	local localZ = sm.shape.getUp(self.shape)
	self.totalMass = 0
	for k,v in pairs(sm.body.getShapes(self.shape:getBody())) do
		self.totalMass = self.totalMass + sm.shape.getMass(v)
	end
	self.targetVec = sm.vec3.normalize(sm.shape.getWorldPosition(self.shape) - self.targetPosition) * -0.5 * self.totalMass
	sm.physics.applyImpulse(self.shape, sm.vec3.new(self.targetVec:dot(localX), self.targetVec:dot(localY), self.targetVec:dot(localZ)))
end

function ZDMK.server_onChangeEffectRequest(self,reverse)
	self.playerList = sm.player.getAllPlayers()
	
	local indexID = (self.targetPlayerID + (reverse and -1 or 1))
	print("indexID"..indexID)
	--使目标ID值在有效范围内
	local maxIndex = table.maxn(self.playerList)
	if indexID > maxIndex then
		indexID = 1
	elseif indexID < 1 then
		indexID = maxIndex
	end
	self.targetPlayerID = indexID
	
	self.network:sendToClients("client_targetChanged",{ TargetPlayerID = self.targetPlayerID, playerList = self.playerList })
end

function server_getNearestPlayer( position )
	local nearestPlayer = nil
	local nearestDistance = nil
	for id,Player in pairs(sm.player.getAllPlayers()) do
		if Player.character then
			local length2 = sm.vec3.length2(position - Player.character:getWorldPosition())
			if nearestDistance == nil or length2 < nearestDistance then
				nearestDistance = length2
				nearestPlayer = Player
			end
			--print(nearestPlayer)
		end
	end
	return nearestPlayer
end

--Client--

function ZDMK.client_onCreate( self )
	self.targetPlayerID = 1
end

function ZDMK.client_onInteract(self,char,state)
	if state then
		local crouching = sm.localPlayer.getPlayer().character:isCrouching()
		local reverse = crouching
		
		--请求服务端更改效果索引
		self.network:sendToServer("server_onChangeEffectRequest",reverse)
		sm.audio.play("Button on", self.shape:getWorldPosition())
		
	end
end

function ZDMK.client_targetChangedDisplay( self, Data )
	self.playerList = Data.playerList
	self.targetPlayerID = Data.TargetPlayerID
	print("targetChangedDisplay"..self.targetPlayerID)
	if Data.nearestPlayerID then
		sm.audio.play("ConnectTool - Selected", self.shape:getWorldPosition())
		if Data.nearestPlayerID == sm.localPlayer.getId() then
			self.targetPlayerName = self.playerList[Data.TargetPlayerID].name
			--print(self.targetPlayerName)
			sm.gui.displayAlertText("当前追踪玩家为Current Target Player: ".."#ff0000"..self.targetPlayerName,2.0)
		end
	end
end

function ZDMK.client_targetChanged(self, Data)
	self.playerList = Data.playerList
	self.targetPlayerID = Data.TargetPlayerID
end

function ZDMK.client_canInteract(self)
	displayTargetPlayerID = self.targetPlayerID
	--有效值保护
	
	if displayTargetPlayerID == nil or displayTargetPlayerID == 0 or displayTargetPlayerID > table.maxn(self.playerList) then
		displayTargetPlayerID = 1
	end
	
	--刷新提示文本
	self.targetPlayerName = self.playerList[displayTargetPlayerID].name
	--print(self.targetPlayerName)
	sm.gui.displayAlertText("当前追踪玩家为Current Target Player: ".."#ff0000"..self.targetPlayerName,2.0)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "切换到追踪下一个玩家 Target next player")
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Crawl").." + "..sm.gui.getKeyBinding( "Use" ), "切换到追踪上一个玩家 Target previous player")

	return true
end


