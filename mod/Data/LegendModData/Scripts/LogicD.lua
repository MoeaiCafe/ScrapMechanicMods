----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

LogicD = class( nil )
LogicD.maxParentCount = 1
LogicD.maxChildCount = -1
LogicD.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.power
LogicD.connectionOutput = sm.interactable.connectionType.logic
LogicD.colorNormal = sm.color.new( 0x549900ff )
LogicD.colorHighlight = sm.color.new( 0x69a61eff )
LogicD.poseWeightCount = 1

local TLYUUID = "8001aabc-5494-11e6-beb8-9e71128cae77"
local SJCKUUID = "8002aabc-5494-11e6-beb8-9e71128cae77"
local FXQUUID = "8003aabc-5494-11e6-beb8-9e71128cae77"
local JXQUUID = "8004aabc-5494-11e6-beb8-9e71128cae77"
local LogicWUUID = "3008aaaf-5494-11e6-beb8-9e71128cae77"
local LogicSUUID = "3010aaaf-5494-11e6-beb8-9e71128cae77"
local LogicDUUID = "3009aaaf-5494-11e6-beb8-9e71128cae77"
local LogicDUUID = "3011aaaf-5494-11e6-beb8-9e71128cae77"

function LogicD.client_onCreate( self )
    self.lastPW = 0.5
end

function LogicD.server_onFixedUpdate( self, dt )
	self.input = self.interactable:getSingleParent()
    if self.input then
		self.inputPower = self.input:getPower()
		self.inputUUID = sm.shape.getShapeUuid(self.input:getShape())
		self.inputUUIDstring = tostring( self.inputUUID )
	
		if self.inputUUIDstring == FXQUUID
		or self.inputUUIDstring == JXQUUID
		or self.inputUUIDstring == LogicWUUID
		or self.inputUUIDstring == LogicDUUID
		or self.inputUUIDstring == LogicSUUID
		or self.inputUUIDstring == LogicDUUID
		then
			if self.inputPower == 1 then
				self:server_setActiveOn1()
			elseif self.inputPower == -1 then
				self:server_setActiveOn2()
			else
				self:server_setActiveOff()
			end
			
		elseif self.inputUUIDstring == TLYUUID
		or self.inputUUIDstring == SJCKUUID	then
			--[[
			if self.inputPower ~= 0 then
				self:server_TLYandSJCK()
			else
				self:server_setActiveOff()
			end
			]]--
			
		else
			if sm.version:sub(1, 3) == "0.3" then	--0.3版本启用此检测方法
				self.network:sendToClient("client_oldSeatConverter")
			else	--0.4及以上版本启用此检测方法
				self.seatAngle = self.interactable.getSteeringAngle(self.input)
				if self.seatAngle > 0 then
					self:server_setActiveOn1()
				else
					self:server_setActiveOff()
				end
			end
		end
	end
end

function LogicD.client_oldSeatConverter( self )
	self.curPW = self.input:getPoseWeight(0)			
	if self.curPW > 0.5 and self.curPW >= self.lastPW then
		if not self.interactable:isActive() then
			self.network:sendToServer("server_receiveSteer", true)
		end
	else
		self.network:sendToServer("server_setActiveOff")
	end
	self.lastPW = self.curPW
end

function LogicD.client_onUpdate( self, dt )
    if self.interactable:isActive() then
        self.interactable:setUvFrameIndex(9)
		self.interactable:setPoseWeight(0,1)
	else
        self.interactable:setUvFrameIndex(3)
		self.interactable:setPoseWeight(0,0)
    end 
end
--[[
function LogicW.server_TLYandSJCK( self )
	self.interactable:setActive(true)
	self.interactable:setPower(self.inputPower)
end
]]--
function LogicD.server_setActiveOn1( self )
	self.interactable:setActive(true)
    self.interactable:setPower(1)
end

function LogicD.server_setActiveOn2( self )
	self.interactable:setActive(true)
    self.interactable:setPower(-1)
end

function LogicD.server_setActiveOff( self )
	self.interactable:setActive(false)
    self.interactable:setPower(0)	
end

function LogicD.server_receiveSteer( self, steer )
    if steer ~= self.interactable:isActive() then
        self.interactable:setActive( steer )
        if steer then
			self.interactable:setPower(1)
		else
			self.interactable:setPower(0)
		end
    end
end