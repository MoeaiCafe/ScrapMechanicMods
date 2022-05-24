----------------------------------------------
-------Original Aerodynamic Algorithms--------
-------Copyright (c) 2022 David Sirius--------
----------------------------------------------
airDensity = 1.3		--空气密度
maxAcceleration = 300	--m/(s^2)加速度上限
maxVelocity = 1000		--m/s 速度上限
maxAngularVelocity = 150 --rad/s 角速度上限
takeEffectTime = 2	--s 空气动力开始生效的时间

function sign(num)
	if num < 0 then
		return -1
	elseif num > 0 then
		return 1
	else
		return 0
	end
end

function LuoXuanJiangKQDL( self, timeStep )
	--计算速度与速率
	local ObjectVel = self.shape.velocity
	local ObjectVelL =  ObjectVel:length()
	--获取角速率
	self.angularVelocity = self.shape:getBody():getAngularVelocity()
	--print(self.angularVelocity)
	self.angularVelocityL = self.angularVelocity:length()
	--print("self.angularVelocityL"..self.angularVelocityL)
	
	---------------------------------------------------------------------------------------------------------------------
	--生效时间计时--
	if self.angularVelocityL > 0.1 then
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
		--计算升力--
		local ObjectZ = self.shape.up		             	--获得物体的前方 +Z
		local angVel = self.angularVelocity:dot(ObjectZ)	--物体绕Z轴旋转的角速度
		--print(angVel)
		if ObjectVelL < maxVelocity and math.abs(self.acceleration) < maxAcceleration and self.angularVelocityL < maxAngularVelocity then	--若速度小于速度上限且加速度小于加速度上限则产生升力
			
			self.PressureL = 0.5 * airDensity * self.Cy * (angVel * angVel * sign(angVel)) * self.area	--螺旋桨产生升力的数值
			self.Pressure = sm.vec3.new( 0, 0, self.rotationDirection*self.PressureL)		--螺旋桨产生的升力
	
			sm.physics.applyImpulse( self.shape,self.Pressure * timeStep )		--产生升力
			
			if self.resistance == true then
				--螺旋桨受到的阻力--
				self.Torque = sm.vec3.new( 0.1*-self.angularVelocity.x*math.abs(self.angularVelocity.x), 0.1*-self.angularVelocity.y*math.abs(self.angularVelocity.y), 0.1*self.angularVelocity.z*math.abs(self.angularVelocity.z))
				--print(self.Torque)
				sm.physics.applyTorque( self.shape:getBody(), self.Torque * timeStep, true ) 	--产生阻力
			end
		end
	end
	
end

-------------------------------
LuoXuanJiangSL = class( nil )
LuoXuanJiangSL.area = 5
LuoXuanJiangSL.Cy = 0.5
LuoXuanJiangSL.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangSL.resistance = true		--是否产生阻力
LuoXuanJiangSL.maxParentCount = 1
LuoXuanJiangSL.maxChildCount = -1
LuoXuanJiangSL.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangSL.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangSL.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangSL.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangSL.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangSR = class( nil )
LuoXuanJiangSR.area = 5
LuoXuanJiangSR.Cy = 0.5
LuoXuanJiangSR.rotationDirection = -1	--	1顺时针 -1逆时针
LuoXuanJiangSR.resistance = true		--是否产生阻力
LuoXuanJiangSR.maxParentCount = 1
LuoXuanJiangSR.maxChildCount = -1
LuoXuanJiangSR.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangSR.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangSR.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangSR.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangSR.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangML = class( nil )
LuoXuanJiangML.area = 20
LuoXuanJiangML.Cy = 0.5
LuoXuanJiangML.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangML.resistance = true		--是否产生阻力
LuoXuanJiangML.maxParentCount = 1
LuoXuanJiangML.maxChildCount = -1
LuoXuanJiangML.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangML.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangML.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangML.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangML.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangMR = class( nil )
LuoXuanJiangMR.area = 20
LuoXuanJiangMR.Cy = 0.5
LuoXuanJiangMR.rotationDirection = -1	--	1顺时针 -1逆时针
LuoXuanJiangMR.resistance = true		--是否产生阻力
LuoXuanJiangMR.maxParentCount = 1
LuoXuanJiangMR.maxChildCount = -1
LuoXuanJiangMR.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangMR.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangMR.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangMR.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangMR.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangBL = class( nil )
LuoXuanJiangBL.area = 35
LuoXuanJiangBL.Cy = 0.4
LuoXuanJiangBL.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangBL.resistance = true		--是否产生阻力
LuoXuanJiangBL.maxParentCount = 1
LuoXuanJiangBL.maxChildCount = -1
LuoXuanJiangBL.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangBL.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangBL.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangBL.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangBL.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangBR = class( nil )
LuoXuanJiangBR.area = 35
LuoXuanJiangBR.Cy = 0.4
LuoXuanJiangBR.rotationDirection = -1	--	1顺时针 -1逆时针
LuoXuanJiangBR.resistance = true		--是否产生阻力
LuoXuanJiangBR.maxParentCount = 1
LuoXuanJiangBR.maxChildCount = -1
LuoXuanJiangBR.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangBR.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangBR.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangBR.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangBR.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangLL = class( nil )
LuoXuanJiangLL.area = 50
LuoXuanJiangLL.Cy = 0.3
LuoXuanJiangLL.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangLL.resistance = true		--是否产生阻力
LuoXuanJiangLL.maxParentCount = 1
LuoXuanJiangLL.maxChildCount = -1
LuoXuanJiangLL.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangLL.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangLL.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangLL.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangLL.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangLR = class( nil )
LuoXuanJiangLR.area = 50
LuoXuanJiangLR.Cy = 0.3
LuoXuanJiangLR.rotationDirection = -1	--	1顺时针 -1逆时针
LuoXuanJiangLR.resistance = true		--是否产生阻力
LuoXuanJiangLR.maxParentCount = 1
LuoXuanJiangLR.maxChildCount = -1
LuoXuanJiangLR.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangLR.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangLR.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangLR.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangLR.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangSanYeS = class( nil )
LuoXuanJiangSanYeS.area = 6
LuoXuanJiangSanYeS.Cy = 0.5
LuoXuanJiangSanYeS.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangSanYeS.resistance = false		--是否产生阻力
LuoXuanJiangSanYeS.maxParentCount = 1
LuoXuanJiangSanYeS.maxChildCount = -1
LuoXuanJiangSanYeS.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangSanYeS.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangSanYeS.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangSanYeS.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangSanYeS.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangSanYeM = class( nil )
LuoXuanJiangSanYeM.area = 9
LuoXuanJiangSanYeM.Cy = 0.5
LuoXuanJiangSanYeM.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangSanYeM.resistance = false		--是否产生阻力
LuoXuanJiangSanYeM.maxParentCount = 1
LuoXuanJiangSanYeM.maxChildCount = -1
LuoXuanJiangSanYeM.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangSanYeM.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangSanYeM.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangSanYeM.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangSanYeM.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangSanYeB = class( nil )
LuoXuanJiangSanYeB.area = 15
LuoXuanJiangSanYeB.Cy = 0.5
LuoXuanJiangSanYeB.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangSanYeB.resistance = false		--是否产生阻力
LuoXuanJiangSanYeB.maxParentCount = 1
LuoXuanJiangSanYeB.maxChildCount = -1
LuoXuanJiangSanYeB.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangSanYeB.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangSanYeB.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangSanYeB.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangSanYeB.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
LuoXuanJiangWJ = class( nil )
LuoXuanJiangWJ.area = 12
LuoXuanJiangWJ.Cy = 0.01
LuoXuanJiangWJ.rotationDirection = 1	--	1顺时针 -1逆时针
LuoXuanJiangWJ.resistance = false		--是否产生阻力
LuoXuanJiangWJ.maxParentCount = 1
LuoXuanJiangWJ.maxChildCount = -1
LuoXuanJiangWJ.connectionInput = sm.interactable.connectionType.logic
LuoXuanJiangWJ.connectionOutput = sm.interactable.connectionType.logic
LuoXuanJiangWJ.colorNormal = sm.color.new(0x999999ff)
LuoXuanJiangWJ.colorHighlight = sm.color.new(0xbbbbbbff)

function LuoXuanJiangWJ.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WRJL = class( nil )
WRJL.area = 9
WRJL.Cy = 0.25
WRJL.rotationDirection = 1	--	1顺时针 -1逆时针
WRJL.resistance = true		--是否产生阻力
WRJL.maxParentCount = 1
WRJL.maxChildCount = -1
WRJL.connectionInput = sm.interactable.connectionType.logic
WRJL.connectionOutput = sm.interactable.connectionType.logic
WRJL.colorNormal = sm.color.new(0x999999ff)
WRJL.colorHighlight = sm.color.new(0xbbbbbbff)

function WRJL.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WRJR = class( nil )
WRJR.area = 9
WRJR.Cy = 0.25
WRJR.rotationDirection = -1	--	1顺时针 -1逆时针
WRJR.resistance = true		--是否产生阻力
WRJR.maxParentCount = 1
WRJR.maxChildCount = -1
WRJR.connectionInput = sm.interactable.connectionType.logic
WRJR.connectionOutput = sm.interactable.connectionType.logic
WRJR.colorNormal = sm.color.new(0x999999ff)
WRJR.colorHighlight = sm.color.new(0xbbbbbbff)

function WRJR.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WoLun1X3 = class( nil )
WoLun1X3.area = 7
WoLun1X3.Cy = 0.5
WoLun1X3.rotationDirection = 1	--	1顺时针 -1逆时针
WoLun1X3.resistance = false		--是否产生阻力
WoLun1X3.maxParentCount = 1
WoLun1X3.maxChildCount = -1
WoLun1X3.connectionInput = sm.interactable.connectionType.logic
WoLun1X3.connectionOutput = sm.interactable.connectionType.logic
WoLun1X3.colorNormal = sm.color.new(0x999999ff)
WoLun1X3.colorHighlight = sm.color.new(0xbbbbbbff)

function WoLun1X3.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WoLun1X5 = class( nil )
WoLun1X5.area = 19
WoLun1X5.Cy = 0.5
WoLun1X5.rotationDirection = 1	--	1顺时针 -1逆时针
WoLun1X5.resistance = false		--是否产生阻力
WoLun1X5.maxParentCount = 1
WoLun1X5.maxChildCount = -1
WoLun1X5.connectionInput = sm.interactable.connectionType.logic
WoLun1X5.connectionOutput = sm.interactable.connectionType.logic
WoLun1X5.colorNormal = sm.color.new(0x999999ff)
WoLun1X5.colorHighlight = sm.color.new(0xbbbbbbff)

function WoLun1X5.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WoLun1X7 = class( nil )
WoLun1X7.area = 38
WoLun1X7.Cy = 0.5
WoLun1X7.rotationDirection = 1	--	1顺时针 -1逆时针
WoLun1X7.resistance = false		--是否产生阻力
WoLun1X7.maxParentCount = 1
WoLun1X7.maxChildCount = -1
WoLun1X7.connectionInput = sm.interactable.connectionType.logic
WoLun1X7.connectionOutput = sm.interactable.connectionType.logic
WoLun1X7.colorNormal = sm.color.new(0x999999ff)
WoLun1X7.colorHighlight = sm.color.new(0xbbbbbbff)

function WoLun1X7.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WoLun1X9 = class( nil )
WoLun1X9.area = 64
WoLun1X9.Cy = 0.5
WoLun1X9.rotationDirection = 1	--	1顺时针 -1逆时针
WoLun1X9.resistance = false		--是否产生阻力
WoLun1X9.maxParentCount = 1
WoLun1X9.maxChildCount = -1
WoLun1X9.connectionInput = sm.interactable.connectionType.logic
WoLun1X9.connectionOutput = sm.interactable.connectionType.logic
WoLun1X9.colorNormal = sm.color.new(0x999999ff)
WoLun1X9.colorHighlight = sm.color.new(0xbbbbbbff)

function WoLun1X9.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WoLun1X11 = class( nil )
WoLun1X11.area = 95
WoLun1X11.Cy = 0.5
WoLun1X11.rotationDirection = 1	--	1顺时针 -1逆时针
WoLun1X11.resistance = false		--是否产生阻力
WoLun1X11.maxParentCount = 1
WoLun1X11.maxChildCount = -1
WoLun1X11.connectionInput = sm.interactable.connectionType.logic
WoLun1X11.connectionOutput = sm.interactable.connectionType.logic
WoLun1X11.colorNormal = sm.color.new(0x999999ff)
WoLun1X11.colorHighlight = sm.color.new(0xbbbbbbff)

function WoLun1X11.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
WoLun1X13 = class( nil )
WoLun1X13.area = 133
WoLun1X13.Cy = 0.5
WoLun1X13.rotationDirection = 1	--	1顺时针 -1逆时针
WoLun1X13.resistance = false		--是否产生阻力
WoLun1X13.maxParentCount = 1
WoLun1X13.maxChildCount = -1
WoLun1X13.connectionInput = sm.interactable.connectionType.logic
WoLun1X13.connectionOutput = sm.interactable.connectionType.logic
WoLun1X13.colorNormal = sm.color.new(0x999999ff)
WoLun1X13.colorHighlight = sm.color.new(0xbbbbbbff)

function WoLun1X13.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	if self.input then
		self.inputActive = self.input:isActive()
		if self.inputActive == true then
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		else
			self.interactable:setActive(false)
		end
	else
		self.inputActive = true
		self.interactable:setActive(true)
		LuoXuanJiangKQDL(self, timeStep)
	end
end

------------------------------------------------------------
ChuanLXJ1X3 = class( nil )
ChuanLXJ1X3.area = 7
ChuanLXJ1X3.Cy = 0.8
ChuanLXJ1X3.rotationDirection = -1	--	1顺时针 -1逆时针
ChuanLXJ1X3.resistance = false		--是否产生阻力
ChuanLXJ1X3.maxParentCount = 1
ChuanLXJ1X3.maxChildCount = -1
ChuanLXJ1X3.connectionInput = sm.interactable.connectionType.logic
ChuanLXJ1X3.connectionOutput = sm.interactable.connectionType.logic
ChuanLXJ1X3.colorNormal = sm.color.new(0x999999ff)
ChuanLXJ1X3.colorHighlight = sm.color.new(0xbbbbbbff)

function ChuanLXJ1X3.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	self.Pos = sm.shape.getWorldPosition(self.shape)
	if self.Pos.z < -1.5 then	--螺旋桨的高度坐标是否在水面以下
		if self.input then
			self.inputActive = self.input:isActive()
			if self.inputActive == true then
				self.interactable:setActive(true)
				LuoXuanJiangKQDL(self, timeStep)
			else
				self.interactable:setActive(false)
			end
		else
			self.inputActive = true
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		end
	end
end

------------------------------------------------------------
ChuanLXJ1X5 = class( nil )
ChuanLXJ1X5.area = 19
ChuanLXJ1X5.Cy = 0.8
ChuanLXJ1X5.rotationDirection = -1	--	1顺时针 -1逆时针
ChuanLXJ1X5.resistance = false		--是否产生阻力
ChuanLXJ1X5.maxParentCount = 1
ChuanLXJ1X5.maxChildCount = -1
ChuanLXJ1X5.connectionInput = sm.interactable.connectionType.logic
ChuanLXJ1X5.connectionOutput = sm.interactable.connectionType.logic
ChuanLXJ1X5.colorNormal = sm.color.new(0x999999ff)
ChuanLXJ1X5.colorHighlight = sm.color.new(0xbbbbbbff)

function ChuanLXJ1X5.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	self.Pos = sm.shape.getWorldPosition(self.shape)
	if self.Pos.z < -1.5 then	--螺旋桨的高度坐标是否在水面以下
		if self.input then
			self.inputActive = self.input:isActive()
			if self.inputActive == true then
				self.interactable:setActive(true)
				LuoXuanJiangKQDL(self, timeStep)
			else
				self.interactable:setActive(false)
			end
		else
			self.inputActive = true
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		end
	end
end

------------------------------------------------------------
ChuanLXJ1X7 = class( nil )
ChuanLXJ1X7.area = 38
ChuanLXJ1X7.Cy = 0.8
ChuanLXJ1X7.rotationDirection = -1	--	1顺时针 -1逆时针
ChuanLXJ1X7.resistance = false		--是否产生阻力
ChuanLXJ1X7.maxParentCount = 1
ChuanLXJ1X7.maxChildCount = -1
ChuanLXJ1X7.connectionInput = sm.interactable.connectionType.logic
ChuanLXJ1X7.connectionOutput = sm.interactable.connectionType.logic
ChuanLXJ1X7.colorNormal = sm.color.new(0x999999ff)
ChuanLXJ1X7.colorHighlight = sm.color.new(0xbbbbbbff)

function ChuanLXJ1X7.server_onFixedUpdate( self, timeStep )
	self.input = self.interactable:getSingleParent()
	self.Pos = sm.shape.getWorldPosition(self.shape)
	if self.Pos.z < -1.5 then	--螺旋桨的高度坐标是否在水面以下
		if self.input then
			self.inputActive = self.input:isActive()
			if self.inputActive == true then
				self.interactable:setActive(true)
				LuoXuanJiangKQDL(self, timeStep)
			else
				self.interactable:setActive(false)
			end
		else
			self.inputActive = true
			self.interactable:setActive(true)
			LuoXuanJiangKQDL(self, timeStep)
		end
	end
end
