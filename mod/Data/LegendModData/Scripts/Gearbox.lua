----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

Gearbox = class( nil )
Gearbox.maxParentCount = -1
Gearbox.maxChildCount = -1
Gearbox.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
Gearbox.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
Gearbox.colorNormal = sm.color.new(0xffbf00ff)
Gearbox.colorHighlight = sm.color.new(0xffcc33ff)
Gearbox.poseWeightCount = 1

--Server
function Gearbox.server_onCreate( self )
	--若没有油门输入则油门power默认为0.5，刹车power值默认为1	
	self.ShaChePower = 1
	self.otherInputActive = false
	self.otherInputPower = 0
	
	self.loadPower = self.storage:load()
	--print("self.loadPower"..self.loadPower)
	if self.loadPower then
		self.YouMenPower = self.loadPower
	else
		self.YouMenPower = 0.5
	end

	--有效值保护
	if self.YouMenPower == nil or self.YouMenPower < 0 or self.YouMenPower > 1 then
		self.YouMenPower = 0.5
	end
end

function Gearbox.server_onFixedUpdate( self, dt )
	local ModZuoYiUUID1 = "3014aaad-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID2 = "3002aaaf-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID3 = "3001aabc-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID4 = "3002aabc-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID5 = "2487aaaa-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID6 = "2488aaaa-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID7 = "2489aaaa-5494-11e6-beb8-9e71128cae77"
	local ModZuoYiUUID8 = "3016aaaf-5494-11e6-beb8-9e71128cae77"
	
	local YuanBanZuoYiUUID1 = "77c2687c-2e13-4df8-996a-96fb26d75ee0"
	local YuanBanZuoYiUUID2 = "efbf45f8-62ec-4541-9eb1-d529966f6a29"
	local YuanBanZuoYiUUID3 = "c3ef3008-9367-4ab7-813a-24195d63e5a3"
	local YuanBanZuoYiUUID4 = "d30dcd12-ec39-43b9-a115-44c08e1b9091"
	local YuanBanZuoYiUUID5 = "ffa3a47e-fc0d-4977-802f-bd15683bbe5c"
	
	local YuanBanZuoYiUUID6 = "7d601a5a-796d-4cae-be88-b47479d38d11"
	local YuanBanZuoYiUUID7 = "bb2ed406-f0d3-4fd6-b3f9-7caadfa8e4e4"
	local YuanBanZuoYiUUID8 = "6953b17e-0a38-4107-8c56-5ee97e68bee3"
	local YuanBanZuoYiUUID9 = "41960868-6245-47b5-97c4-f446e199812f"
	local YuanBanZuoYiUUID10 = "9dd1ccea-1e44-430d-b706-3ff45416583e"
	
	
	
	local ShaCheUUID = "3015aaaf-5494-11e6-beb8-9e71128cae77"
	local whiteColor = sm.color.new(0xeeeeeeff)
	local blackColor = sm.color.new(0x222222ff)
	local rightUpColor = sm.color.new(0xeeaf5cff)
	local rightDownColor = sm.color.new(0x472800ff)

	Player = server_getNearestPlayer(self.shape:getWorldPosition())

	parents = self.interactable:getParents()
	if parents then
		for k,v in pairs(parents) do
			self.parentShape = v:getShape()
			self.parentUUID = sm.shape.getShapeUuid(self.parentShape)
			self.parentColor = sm.shape.getColor(self.parentShape)
			self.parentUUIDstring = tostring(self.parentUUID)
		
			--如果连接对象不是油门或刹车（座椅）
			if self.parentColor ~= whiteColor 
			and self.parentColor ~= blackColor 
			and self.parentColor ~= rightUpColor 
			and self.parentColor ~= rightDownColor 
			and self.parentUUIDstring ~= ShaCheUUID
			
			or self.parentUUIDstring == ModZuoYiUUID1
			or self.parentUUIDstring == ModZuoYiUUID2
			or self.parentUUIDstring == ModZuoYiUUID3  
			or self.parentUUIDstring == ModZuoYiUUID4  
			or self.parentUUIDstring == ModZuoYiUUID5  
			or self.parentUUIDstring == YuanBanZuoYiUUID1  
			or self.parentUUIDstring == YuanBanZuoYiUUID2  
			or self.parentUUIDstring == YuanBanZuoYiUUID3  
			or self.parentUUIDstring == YuanBanZuoYiUUID4  
			or self.parentUUIDstring == YuanBanZuoYiUUID5  
			or self.parentUUIDstring == YuanBanZuoYiUUID6  
			or self.parentUUIDstring == YuanBanZuoYiUUID7  
			or self.parentUUIDstring == YuanBanZuoYiUUID8  
			or self.parentUUIDstring == YuanBanZuoYiUUID9  
			or self.parentUUIDstring == YuanBanZuoYiUUID10
			
			then
				self.otherInputActive = v:isActive()
				self.otherInputPower = v:getPower()	
			end
			
			--如果连接对象不是座椅
			if self.parentUUIDstring ~= ModZuoYiUUID1
			and self.parentUUIDstring ~= ModZuoYiUUID2
			and self.parentUUIDstring ~= ModZuoYiUUID3  
			and self.parentUUIDstring ~= ModZuoYiUUID4  
			and self.parentUUIDstring ~= ModZuoYiUUID5  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID1  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID2  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID3  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID4  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID5  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID6  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID7  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID8  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID9  
			and self.parentUUIDstring ~= YuanBanZuoYiUUID10
			then
				--排除第一次运行此段代码
				if self.lastYouMenPower then
				
					--如果油门为白色
					if self.parentColor == whiteColor then	
						self.YouMenWhiteActive = v:isActive()
						--如果油门被按下一次
						if self.lastYouMenWhiteActive == false and v:isActive() then
							self.YouMenPower = self.lastYouMenPower + 0.1	--油门power值+0.1
						else
							--油门一直按下油门power值不变
							self.YouMenPower = self.lastYouMenPower
						end
						self.lastYouMenWhiteActive = v:isActive()
					end
					
					--如果油门为黑色
					if self.parentColor == blackColor then	
						self.YouMenBlackActive = v:isActive()
						--如果油门被按下一次
						if self.lastYouMenBlackActive == false and v:isActive() then
							self.YouMenPower = self.lastYouMenPower - 0.1	--油门power值-0.1
						else
							--油门一直按下油门power值不变
							self.YouMenPower = self.lastYouMenPower
						end
						self.lastYouMenBlackActive = v:isActive()
					end
					
					--如果油门为右上角颜色
					if self.parentColor == rightUpColor then	
						self.YouMenRightUpActive = v:isActive()
						--如果油门被按下
						if self.lastYouMenRightUpActive == false and v:isActive() then
							self.YouMenPower = self.lastYouMenPower + 0.15	--油门power值+0.1
						--如果油门关闭
						elseif self.lastYouMenRightUpActive == true and not v:isActive() then
							if self.lastYouMenPower ~= 1.0 then
								self.YouMenPower = self.lastYouMenPower - 0.15
							end
						else
							--油门一直按下油门power值不变
							self.YouMenPower = self.lastYouMenPower
						end
						self.lastYouMenRightUpActive = v:isActive()
					end
					
					--如果油门为右下角颜色
					if self.parentColor == rightDownColor then	
						self.YouMenRightDownActive = v:isActive()
						--如果油门被按下
						if self.lastYouMenRightDownActive == false and v:isActive() then
							self.YouMenPower = self.lastYouMenPower - 0.15	--油门power值+0.1
						--如果油门关闭
						elseif self.lastYouMenRightDownActive == true and not v:isActive() then
							if self.lastYouMenPower ~= 0.0 then
								self.YouMenPower = self.lastYouMenPower + 0.15
							end
						else
							--油门一直按下油门power值不变
							self.YouMenPower = self.lastYouMenPower
						end
						self.lastYouMenRightDownActive = v:isActive()
					end
				end
				
				--保持油门power值最大为1最小为0
				if self.YouMenPower > 1 then
					self.YouMenPower = 1
				elseif self.YouMenPower < 0 then
					self.YouMenPower = 0
				end
				
				--广播油门power值到客户端
				self.network:sendToClients("client_sendPower", self.YouMenPower)
				
				if self.lastYouMenPower then
					if self.lastYouMenPower ~= self.YouMenPower then
						self.storage:save(self.YouMenPower)	--储存改变后的油门power值
						--print("已存档")
						if Player then
							--显示油门power值
							self.network:sendToClients("client_powerChangedDisplay", Player:getId())
						end
					end
				end
				self.lastYouMenPower = self.YouMenPower
 			end
			
			--如果连接对象为刹车
			if self.parentUUIDstring == ShaCheUUID then	
				self.ShaCheActive = v:isActive()
				--如果刹车被按下则刹车power值为0
				if self.ShaCheActive == true then
					self.ShaChePower = 0
					self.otherInputActive = false
				else
					self.ShaChePower = 1
				end
				
			end
		end
		
		--如果有座椅输入
		if self.otherInputPower then
			--计算最终输出结果
			self.outputActive = self.otherInputActive
			self.outputPower = 	self.otherInputPower * self.YouMenPower * self.ShaChePower
				
			--print("座椅"..self.otherInputPower)
			--print("油门"..self.YouMenPower)
			--print("刹车"..self.ShaChePower)
		else
			--无座椅输入
			self.outputActive = false
			self.outputPower = 	0
		end
	else
		--无输入的输出结果
		self.outputActive = false
		self.outputPower = 0
	end
	
	--向子对象输出最终结果
	self.interactable:setActive(self.outputActive)
	self.interactable:setPower(self.outputPower)
	
	
	
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

--Client
function Gearbox.client_powerChangedDisplay( self, PlayerID )
	if PlayerID then
		sm.audio.play("ConnectTool - Selected", self.shape:getWorldPosition())
		if PlayerID == sm.localPlayer.getId() then
			local YouMenPowerString = string.format("%.0f",self.YouMenPower*100)
			sm.gui.displayAlertText("输出动力 Output Power ="..YouMenPowerString.."%", 2)
		end
	end
end

function Gearbox.client_sendPower( self, Data )
	self.YouMenPower = Data
end

function Gearbox.client_canInteract(self) 
	local YouMenPowerString = string.format("%.0f",self.YouMenPower*100)
	sm.gui.displayAlertText("输出动力 Output Power ="..YouMenPowerString.."%", 2)
end