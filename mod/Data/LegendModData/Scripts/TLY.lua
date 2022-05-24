----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

TLY = class( nil )
TLY.maxParentCount = 1
TLY.maxChildCount = -1
TLY.connectionInput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
TLY.connectionOutput = sm.interactable.connectionType.power + sm.interactable.connectionType.logic
TLY.colorNormal = sm.color.new(0x9c0d44ff)
TLY.colorHighlight = sm.color.new(0xc11559ff)
TLY.poseWeightCount = 1

function TLY.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 0 )
	self.boltValue = 0.0
	self.lastActive = false
end

function TLY.server_onCreate( self )
	self.interactable:setActive(false)
	self.lastActive = false
	
	WPower = 0
	SPower = 0
	APower = 0
	DPower = 0
	WActive = false
	SActive = false
	AActive = false
	DActive = false
end

function TLY.server_onFixedUpdate( self, dt )
	--self.Pos = sm.shape.getWorldPosition(self.shape)

	local ObjectX = sm.shape.getRight(self.shape)
	local ObjectY = sm.shape.getAt(self.shape)				    
	local ObjectZ = sm.shape.getUp(self.shape)
	local YRotX = sm.vec3.new(ObjectZ.x,ObjectZ.y,0)			--取物体X轴向量的x坐标和y坐标，分别作为x坐标和y坐标合成新向量（物体绕世界X轴偏转方向）
	local YRotZ = sm.vec3.new(ObjectX.x,ObjectX.y,0)			--取物体Z轴向量的x坐标和y坐标，分别作为x坐标和y坐标合成新向量（物体绕世界Z轴偏转方向）
	local YXDeg = math.deg(math.acos(sm.vec3.length(YRotX)))	--用偏转方向的向量求余弦，再求角度
	local YZDeg = math.deg(math.acos(sm.vec3.length(YRotZ)))	--用偏转方向的向量求余弦，再求角度
	
	--print("【Y轴向量】"..ObjectY.x..","..ObjectY.y..","..ObjectY.z)
	--print("【X轴旋转角度】"..YXDeg)
	--print("【Z轴旋转角度】"..YZDeg)		
	
	if YXDeg > 1 and ObjectZ.z > 0 then
		WActive = true
		WPower = 1
		--print("已激活【W】逻辑门")
	else
		WActive = false
		WPower = 0
	end
	
	if YXDeg > 1 and ObjectZ.z < 0 then
		SActive = true
		SPower = 1
		--print("已激活【S】逻辑门")
	else
		SActive = false
		SPower = 0
	end

	if YZDeg > 1 and ObjectX.z > 0 then
		AActive = true
		APower = 1
		--print("已激活【A】逻辑门")
	else
		AActive = false
		APower = 0
	end
	
	if YZDeg > 1 and ObjectX.z < 0 then
		DActive = true
		DPower = 1
		--print("已激活【D】逻辑门")
	else
		DActive = false
		DPower = 0
	end

	Parent = self.interactable:getSingleParent()
	if Parent then
		if  Parent:isActive() == true then
			self.interactable:setActive(true)
		else
			self.interactable:setActive(false)
		end
	else
		self.interactable:setActive(false)
	end
	
	--获得距离最近的玩家
	Player = server_getNearestPlayer(self.shape:getWorldPosition())
	PlayerID = Player:getId()
	if Player then
		self.network:sendToClients("client_OnOff", PlayerID )
	end
	
	local LogicW = "3008aaaf-5494-11e6-beb8-9e71128cae77"
	local LogicS = "3010aaaf-5494-11e6-beb8-9e71128cae77"
	local LogicA = "3009aaaf-5494-11e6-beb8-9e71128cae77"
	local LogicD = "3011aaaf-5494-11e6-beb8-9e71128cae77"

	if self.interactable:isActive() then
		--print("陀螺仪功能启动")
		for k,v in pairs(self.interactable:getChildren()) do
			--print("已检测到以下子连接对象")
			local UUID = sm.shape.getShapeUuid(v:getShape())
			--print(UUID)
			UUIDstring = tostring(UUID)
			if  UUIDstring == LogicW then
				v:setActive(WActive)
				v:setPower(WPower)
			end
			if UUIDstring == LogicS then
				v:setActive(SActive)
				v:setPower(SPower)
			end
			if UUIDstring == LogicA then
				v:setActive(AActive)
				v:setPower(APower)
			end
			if UUIDstring == LogicD then
				v:setActive(DActive)
				v:setPower(DPower)	
			end
		end
	else
		for k,v in pairs(self.interactable:getChildren()) do
			v:setActive(false)
			v:setPower(0)
		end
	end
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
	
	if nearestPlayer then
		return nearestPlayer
	else
		return nil
	end
end

function TLY.client_onUpdate( self, dt )	
	if self.interactable:isActive() == true then
		if self.boltValue < 1 then
			self.boltValue = self.boltValue + dt*5		
		else
			self.boltValue = 1
		end
	end
	if self.interactable:isActive() == false then
		if self.boltValue > 0 then
			self.boltValue = self.boltValue - dt*5		
		else
			self.boltValue = 0
		end
	end	
	self.interactable:setPoseWeight( 0, self.boltValue )
	--print(self.interactable:isActive())
	--print(self.boltValue)
end

function TLY.client_OnOff( self, PlayerID )
	if self.lastActive == false and self.interactable:isActive() then
		if PlayerID then
			sm.audio.play("Retrowildblip", self.shape:getWorldPosition())
			if PlayerID == sm.localPlayer.getId() then
			sm.gui.displayAlertText("陀螺仪功能已启动 Gyroscope Function Activated", 2)
			end
		end
	elseif self.lastActive == true and self.interactable:isActive() == false then
		if PlayerID then
			if PlayerID == sm.localPlayer.getId() then
				sm.gui.displayAlertText("陀螺仪已关闭 Gyroscope OFF", 1.5)
			end
		end
	end
	self.lastActive = self.interactable:isActive()
end