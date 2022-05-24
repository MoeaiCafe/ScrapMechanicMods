----------------------------------------------
-------Copyright (c) 2020 David Sirius--------
----------------------------------------------

ChinaFlag = class( nil )
ChinaFlag.poseWeightCount = 3
ChinaFlag.animSpeed = 1.2

function ChinaFlag.client_onCreate( self )
	self.boltValue = 0.001
	self.lastValue = 0
end

function ChinaFlag.client_onUpdate( self, dt )

	if self.lastValue < 1 then
		self.boltValue = self.lastValue + dt*self.animSpeed	
	else 
		self.boltValue = 0
	end
	self.lastValue = self.boltValue

	if self.boltValue then
		if self.boltValue < 1/3 then					
			PW0 = self.boltValue*3 
			PW1 = 0
			PW2 = -self.boltValue*3 +1
		elseif self.boltValue < 2/3 then
			PW0 = -self.boltValue*3 +2
			PW1 = self.boltValue*3 -1
			PW2 = 0
		else
			PW0 = 0
			PW1 = -self.boltValue*3 +3
			PW2 = self.boltValue*3 -2
		end
			
		--print("【PW0】"..PW0)
		--print("【PW1】"..PW1)
		--print("【PW2】"..PW2)
			
		self.interactable:setPoseWeight( 0, PW0 )
		self.interactable:setPoseWeight( 1, PW1 )
		self.interactable:setPoseWeight( 2, PW2 )
	end
end
