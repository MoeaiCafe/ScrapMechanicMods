
JiGuang = class( nil )
JiGuang.maxChildCount = 0
JiGuang.maxParentCount = 1
JiGuang.connectionInput = sm.interactable.connectionType.logic
JiGuang.connectionOutput = sm.interactable.connectionType.none
JiGuang.colorNormal = sm.color.new( 0xdb0a00ff )
JiGuang.colorHighlight = sm.color.new( 0xfe0a00ff )
JiGuang.poseWeightCount = 1
JiGuang.cooldownToEnable = 200
JiGuang.fireoffset = 0
JiGuang.Damage = 28


function JiGuang.server_onCreate( self ) 
	self:server_init()
	self.cooldown = 0
end

function JiGuang.server_init( self ) 
	self.fireDelayProgress = 0
end

function JiGuang.server_onRefresh( self )
	print('refresh')
	self:server_init()
end


function JiGuang.server_onFixedUpdate( self, dt )
	if self.cooldown < self.cooldownToEnable then
		self.cooldown = self.cooldown + 1
	end
	if self.cooldown >= self.cooldownToEnable then
		self:server_tryFire()
	end
end

function JiGuang.server_tryFire( self )
	local parent = self.interactable:getSingleParent()
	if parent then
		if parent:isActive() then
			self.interactable:setActive(true)
			
			local mass = 10
			local fireForce = 10
			--local impulse = sm.noise.gunSpread( sm.vec3.new( 0.0, 0.0, 1.0 ), 1.0) * -fireForce * mass
			--sm.physics.applyImpulse( self.shape, impulse )
			
			local dest = sm.shape.getWorldPosition(self.shape) + sm.shape.getUp(self.shape)*500
			local src = sm.shape.getWorldPosition(self.shape) + sm.shape.getUp(self.shape)
			local hit, result = sm.physics.raycast(src,dest)
			if hit then
				--sm.physics.explode(result.pointWorld,0.3,0.3)
				--sm.projectile.shapeFire( self.shape, "potato", sm.vec3.new(0,0, sm.vec3.length(result.pointWorld - src) - 0.25), sm.vec3.new( 0.0, 0.0, 1.0 )*300 )
				sm.projectile.shapeProjectileAttack( "potato", self.Damage, sm.vec3.new(0,0, sm.vec3.length(result.pointWorld - src) - 0.25), sm.vec3.new( 0.0, 0.0, 1.0 )*300, self.shape )
			end
			self.network:sendToClients( "client_onShoot", {hit = hit, pointWorld = result.pointWorld} )
		else
			self.interactable:setActive(false)
		end
	end
end

--client

function JiGuang.client_onCreate( self )
end

function JiGuang.client_onUpdate( self, dt )
	
	local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
	local pos = sm.shape.getWorldPosition( self.shape ) + self.shape.up * 0.625

	
	if self.interactable:isActive() then
		self.interactable:setPoseWeight( 0, 1 )
	else
		self.interactable:setPoseWeight( 0, 0 )
	end
end

function JiGuang.client_onShoot( self, ray )
	self.fireoffset = self.fireoffset + 1.25
	if self.fireoffset > 6 then
		self.fireoffset = self.fireoffset - 6
	end
	
	
	if ray.pointWorld ~= nil then
	
		local pos = sm.shape.getWorldPosition(self.shape)
		local point = sm.vec3.new(0,0,0)
		if ray.hit then
			point = ray.pointWorld
		else
			point = pos + (self.shape.up * 300)
		end
		
		local dir = pos - point
		local i = 0.25+ self.fireoffset
		local length = sm.vec3.length(dir + (self.shape.up*(i-5)) )
		while length>5 and i<100 do
			sm.particle.createParticle("jiguang",pos+(self.shape.up*i))
			i = i+4
			length = sm.vec3.length(dir + (self.shape.up*(i-5)) )
		end
		
		if self.fireoffset < 1.5 and ray.hit then
			sm.particle.createParticle("p_spudgun_impact_defualt01",ray.pointWorld)
			sm.particle.createParticle("p_spudgun_impact_defualt02",ray.pointWorld)
		end
		local j = 0
		
	end	
	--local rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), self.shape.up )
end
