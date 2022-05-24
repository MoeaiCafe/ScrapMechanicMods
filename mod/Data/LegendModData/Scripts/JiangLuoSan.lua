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
			self.acceleration = (ObjectVelL - self.lastVelocity) / timeStep		--计算运动加速度
		end
		self.lastVelocity = ObjectVelL		
		if ObjectVelL < maxVelocity and math.abs(self.acceleration) < maxAcceleration then	--若速度小于速度上限且加速度小于加速度上限则产生阻力
			--计算阻力--
			local ObjectY = self.shape.at     					--获得物体的上方 +Y
		
			self.normalVel = ObjectVel:dot(ObjectY)    --竖直方向的速度（动压）
			self.PressureL = 0.5 * airDensity * self.Cy * (self.normalVel * self.normalVel * sign(self.normalVel)) * self.area	--计算阻力数值
			self.Pressure = sm.vec3.new(0 , -self.PressureL , 0 )		--sm.vec3.new(f,Y,0) 阻力矢量
			
			self.posOffSet = sm.vec3.new(0 , 40 , 0)
			
			sm.physics.applyImpulse(self.shape, self.Pressure * timeStep, nil, self.posOffSet )	--产生阻力
		end
	end
end

------------------------------------------------------------
JiangLuoSan = class( nil )
JiangLuoSan.area = 40
JiangLuoSan.Cy = 1.3
JiangLuoSan.angle = 0
JiangLuoSan.maxParentCount = 1
JiangLuoSan.maxChildCount = -1
JiangLuoSan.connectionInput = sm.interactable.connectionType.logic
JiangLuoSan.connectionOutput = sm.interactable.connectionType.logic
JiangLuoSan.colorNormal = sm.color.new(0x999999ff)
JiangLuoSan.colorHighlight = sm.color.new(0xbbbbbbff)
JiangLuoSan.poseWeightCount = 1

function JiangLuoSan.client_onCreate( self )
	self.interactable:setPoseWeight( 0, 0 )
	self.boltValue = 0.0
end

function JiangLuoSan.server_onFixedUpdate( self, timeStep )
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
		self.inputActive = false
		self.interactable:setActive(false)
	end
end

function JiangLuoSan.client_onUpdate( self, dt )	
	if self.interactable:isActive() == true then
		if self.boltValue < 1 then
			self.boltValue = self.boltValue + dt*3		
		else
			self.boltValue = 1
		end
	end
	if self.interactable:isActive() == false then
		if self.boltValue > 0 then
			self.boltValue = self.boltValue - dt*3		
		else
			self.boltValue = 0
		end
	end	
	self.interactable:setPoseWeight( 0, self.boltValue )
	--print(self.interactable:isActive())
	--print(self.boltValue)
end