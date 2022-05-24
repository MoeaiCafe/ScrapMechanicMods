----------------------------------------------
-------Original Aerodynamic Algorithms--------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------
airDensity = 1.3		--空气密度
maxAcceleration = 200	--m/(s^2)加速度上限
maxVelocity = 610		--m/s 速度上限
takeEffectTime = 2		--s 空气动力开始生效的时间

function sign(num)
	if num < 0 then
		return -1
	elseif num > 0 then
		return 1
	else
		return 0
	end
end

function KQDL( self, timeStep )
	--计算速度与速率
	local ObjectVel = self.shape.velocity
	local ObjectVelL =  ObjectVel:length()
	---------------------------------------------------------------------------------------------------------------------
	--生效时间计时--
	if ObjectVelL > 1 then
		if self.timer then
			self.timer = self.timer + 1
		else
			self.timer = 0
		end
	else
		self.timer = 0
	end
	---------------------------------------------------------------------------------------------------------------------
	--判定是否产生升力与产生升力--
	if self.timer > takeEffectTime then
		self.acceleration = ObjectVelL
		if self.lastVelocity then
			self.acceleration = (ObjectVelL - self.lastVelocity) / timeStep		--计算机翼运动加速度
		end
		self.lastVelocity = ObjectVelL		
		if ObjectVelL < maxVelocity and math.abs(self.acceleration) < maxAcceleration then	--若机翼速度小于速度上限且加速度小于加速度上限则产生升力
			--计算升力--
			local ObjectX = self.shape.right			        --获得物体的右侧 +X
			local ObjectY = -self.shape.at     					--获得物体的上方 +Y
			local ObjectZ = self.shape.up		             	--获得物体的前方 +Z
			local aSin = math.sin(math.rad(self.angle))         --机翼俯仰角的正弦值
			local aCos = math.cos(math.rad(self.angle))        	--机翼俯仰角的余弦值
			local normalUp = ObjectY * aCos + ObjectZ * aSin    --翼面的法线方向
		
			self.normalVel = ObjectVel:dot(normalUp)    --翼面法线方向的分速度（动压）
			self.PressureL = 0.5 * airDensity * self.Cy * (self.normalVel * self.normalVel * sign(self.normalVel)) * self.area	--升力数值
			self.Pressure = sm.vec3.new(self.PressureL * aSin , self.PressureL * aCos , 0)		--sm.vec3.new(f,Y,0) 升力矢量
			
			sm.physics.applyImpulse(self.shape, self.Pressure * timeStep )	--产生升力
		end
	end
end

------------------------------------------------------------
FangKuai = class( nil )
FangKuai.area = 16
FangKuai.Cy = 1.5
FangKuai.angle = 0
FangKuai.maxParentCount = 1
FangKuai.maxChildCount = -1
FangKuai.connectionInput = sm.interactable.connectionType.logic
FangKuai.connectionOutput = sm.interactable.connectionType.logic
FangKuai.colorNormal = sm.color.new(0x999999ff)
FangKuai.colorHighlight = sm.color.new(0xbbbbbbff)

function FangKuai.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
FangKuai2 = class( nil )
FangKuai2.area = 256
FangKuai2.Cy = 1.5
FangKuai2.angle = 0
FangKuai2.maxParentCount = 1
FangKuai2.maxChildCount = -1
FangKuai2.connectionInput = sm.interactable.connectionType.logic
FangKuai2.connectionOutput = sm.interactable.connectionType.logic
FangKuai2.colorNormal = sm.color.new(0x999999ff)
FangKuai2.colorHighlight = sm.color.new(0xbbbbbbff)

function FangKuai2.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
BanZhuan = class( nil )
BanZhuan.area = 16
BanZhuan.Cy = 1.5
BanZhuan.angle = 0
BanZhuan.maxParentCount = 1
BanZhuan.maxChildCount = -1
BanZhuan.connectionInput = sm.interactable.connectionType.logic
BanZhuan.connectionOutput = sm.interactable.connectionType.logic
BanZhuan.colorNormal = sm.color.new(0x999999ff)
BanZhuan.colorHighlight = sm.color.new(0xbbbbbbff)

function BanZhuan.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
Qian = class( nil )
Qian.area = 0
Qian.Cy = 0.0
Qian.angle = 0

------------------------------------------------------------
Hou2X1 = class( nil )
Hou2X1.area = 2
Hou2X1.Cy = 1.0
Hou2X1.angle = 0
Hou2X1.maxParentCount = 1
Hou2X1.maxChildCount = -1
Hou2X1.connectionInput = sm.interactable.connectionType.logic
Hou2X1.connectionOutput = sm.interactable.connectionType.logic
Hou2X1.colorNormal = sm.color.new(0x999999ff)
Hou2X1.colorHighlight = sm.color.new(0xbbbbbbff)

function Hou2X1.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
Hou2X2 = class( nil )
Hou2X2.area = 4
Hou2X2.Cy = 1.0
Hou2X2.angle = 0
Hou2X2.maxParentCount = 1
Hou2X2.maxChildCount = -1
Hou2X2.connectionInput = sm.interactable.connectionType.logic
Hou2X2.connectionOutput = sm.interactable.connectionType.logic
Hou2X2.colorNormal = sm.color.new(0x999999ff)
Hou2X2.colorHighlight = sm.color.new(0xbbbbbbff)

function Hou2X2.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
Hou2X3 = class( nil )
Hou2X3.area = 6
Hou2X3.Cy = 1.0
Hou2X3.angle = 0
Hou2X3.maxParentCount = 1
Hou2X3.maxChildCount = -1
Hou2X3.connectionInput = sm.interactable.connectionType.logic
Hou2X3.connectionOutput = sm.interactable.connectionType.logic
Hou2X3.colorNormal = sm.color.new(0x999999ff)
Hou2X3.colorHighlight = sm.color.new(0xbbbbbbff)

function Hou2X3.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
Hou2X4 = class( nil )
Hou2X4.area = 8
Hou2X4.Cy = 1.0
Hou2X4.angle = 0
Hou2X4.maxParentCount = 1
Hou2X4.maxChildCount = -1
Hou2X4.connectionInput = sm.interactable.connectionType.logic
Hou2X4.connectionOutput = sm.interactable.connectionType.logic
Hou2X4.colorNormal = sm.color.new(0x999999ff)
Hou2X4.colorHighlight = sm.color.new(0xbbbbbbff)

function Hou2X4.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYi1X1 = class( nil )
JinYi1X1.area = 1
JinYi1X1.Cy = 2.0
JinYi1X1.angle = 0
JinYi1X1.maxParentCount = 1
JinYi1X1.maxChildCount = -1
JinYi1X1.connectionInput = sm.interactable.connectionType.logic
JinYi1X1.connectionOutput = sm.interactable.connectionType.logic
JinYi1X1.colorNormal = sm.color.new(0x999999ff)
JinYi1X1.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYi1X1.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYi1X2 = class( nil )
JinYi1X2.area = 2
JinYi1X2.Cy = 2.0
JinYi1X2.angle = 0
JinYi1X2.maxParentCount = 1
JinYi1X2.maxChildCount = -1
JinYi1X2.connectionInput = sm.interactable.connectionType.logic
JinYi1X2.connectionOutput = sm.interactable.connectionType.logic
JinYi1X2.colorNormal = sm.color.new(0x999999ff)
JinYi1X2.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYi1X2.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYi1X3 = class( nil )
JinYi1X3.area = 3
JinYi1X3.Cy = 2.0
JinYi1X3.angle = 0
JinYi1X3.maxParentCount = 1
JinYi1X3.maxChildCount = -1
JinYi1X3.connectionInput = sm.interactable.connectionType.logic
JinYi1X3.connectionOutput = sm.interactable.connectionType.logic
JinYi1X3.colorNormal = sm.color.new(0x999999ff)
JinYi1X3.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYi1X3.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYi1X4 = class( nil )
JinYi1X4.area = 4
JinYi1X4.Cy = 2.0
JinYi1X4.angle = 0
JinYi1X4.maxParentCount = 1
JinYi1X4.maxChildCount = -1
JinYi1X4.connectionInput = sm.interactable.connectionType.logic
JinYi1X4.connectionOutput = sm.interactable.connectionType.logic
JinYi1X4.colorNormal = sm.color.new(0x999999ff)
JinYi1X4.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYi1X4.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYiSJ1X1 = class( nil )
JinYiSJ1X1.area = 0.5
JinYiSJ1X1.Cy = 2.0
JinYiSJ1X1.angle = 0
JinYiSJ1X1.maxParentCount = 1
JinYiSJ1X1.maxChildCount = -1
JinYiSJ1X1.connectionInput = sm.interactable.connectionType.logic
JinYiSJ1X1.connectionOutput = sm.interactable.connectionType.logic
JinYiSJ1X1.colorNormal = sm.color.new(0x999999ff)
JinYiSJ1X1.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYiSJ1X1.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYiSJ1X2 = class( nil )
JinYiSJ1X2.area = 1
JinYiSJ1X2.Cy = 2.0
JinYiSJ1X2.angle = 0
JinYiSJ1X2.maxParentCount = 1
JinYiSJ1X2.maxChildCount = -1
JinYiSJ1X2.connectionInput = sm.interactable.connectionType.logic
JinYiSJ1X2.connectionOutput = sm.interactable.connectionType.logic
JinYiSJ1X2.colorNormal = sm.color.new(0x999999ff)
JinYiSJ1X2.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYiSJ1X2.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYiSJ1X3 = class( nil )
JinYiSJ1X3.area = 1.5
JinYiSJ1X3.Cy = 2.0
JinYiSJ1X3.angle = 0
JinYiSJ1X3.maxParentCount = 1
JinYiSJ1X3.maxChildCount = -1
JinYiSJ1X3.connectionInput = sm.interactable.connectionType.logic
JinYiSJ1X3.connectionOutput = sm.interactable.connectionType.logic
JinYiSJ1X3.colorNormal = sm.color.new(0x999999ff)
JinYiSJ1X3.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYiSJ1X3.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYiSJ1X4 = class( nil )
JinYiSJ1X4.area = 2
JinYiSJ1X4.Cy = 2.0
JinYiSJ1X4.angle = 0
JinYiSJ1X4.maxParentCount = 1
JinYiSJ1X4.maxChildCount = -1
JinYiSJ1X4.connectionInput = sm.interactable.connectionType.logic
JinYiSJ1X4.connectionOutput = sm.interactable.connectionType.logic
JinYiSJ1X4.colorNormal = sm.color.new(0x999999ff)
JinYiSJ1X4.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYiSJ1X4.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end

------------------------------------------------------------
JinYiXie1X1 = class( nil )
JinYiXie1X1.area = 1
JinYiXie1X1.Cy = 2.0
JinYiXie1X1.angle = -25
JinYiXie1X1.maxParentCount = 1
JinYiXie1X1.maxChildCount = -1
JinYiXie1X1.connectionInput = sm.interactable.connectionType.logic
JinYiXie1X1.connectionOutput = sm.interactable.connectionType.logic
JinYiXie1X1.colorNormal = sm.color.new(0x999999ff)
JinYiXie1X1.colorHighlight = sm.color.new(0xbbbbbbff)

function JinYiXie1X1.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			KQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		KQDL(self, timeStep)
	end
end