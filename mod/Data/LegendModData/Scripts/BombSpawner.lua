----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

BombSpawner = class()

BombSpawner.maxParentCount = 1
BombSpawner.maxChildCount = 0
BombSpawner.connectionInput = sm.interactable.connectionType.logic
BombSpawner.connectionOutput = sm.interactable.connectionType.none
BombSpawner.colorNormal = sm.color.new( 0xcb0a00ff )
BombSpawner.colorHighlight = sm.color.new( 0xee0a00ff )

BombSpawner.spawnedObjectNameTable = {
	{Object_name = "Small Propanetank 小燃气罐" },
	{Object_name = "Large Propanetank 大燃气罐" },
	{Object_name = "Smoke Bomb 烟雾弹" },
	{Object_name = "Grenade 手雷" },
	{Object_name = "Missile1 导弹1" },
	{Object_name = "Missile2 导弹2" },
	{Object_name = "Bmob 炸弹" },
	{Object_name = "Air Bomb 航爆弹" },
	{Object_name = "APHE 高爆穿甲弹" },
	{Object_name = "Land Mine 地雷" },
	{Object_name = "Water Mine 水雷" }
}

BombSpawner.spawnedObjectUUIDTable = {
	{Object_UUID = "8d3b98de-c981-4f05-abfe-d22ee4781d33" },
	{Object_UUID = "24001201-40dd-4950-b99f-17d878a9e07b" },
	{Object_UUID = "5004aacd-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5002aaad-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5001aaba-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5002aaba-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5003aaba-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5004aaba-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5005aaba-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5001aabf-5494-11e6-beb8-9e71128cae77" },
	{Object_UUID = "5001aace-5494-11e6-beb8-9e71128cae77" }
}

--[[ Server ]]

function BombSpawner.server_onCreate( self )
	self.interactable.active = false
	self.spawnedObject = nil
    self.spawnTimer = 0
    self.indestructibleTimer = 0
	
	--读取储存的索引
	self.spawnedObjectIndex = self.storage:load()
	
	if self.spawnedObjectIndex == nil then
		self.spawnedObjectIndex = 1
		self.storage:save(self.spawnedObjectIndex)
	end
	
	--广播索引至客户端
	self.network:sendToClients("client_getUIData", self.spawnedObjectIndex)
end

function BombSpawner.server_request( self )
	--广播索引至客户端
	self.network:sendToClients("client_getUIData", self.spawnedObjectIndex)
end

function BombSpawner.server_spawnObjectChange( self, spawnedObjectIndex )
	--接收客户端改变后的索引
	self.spawnedObjectIndex = spawnedObjectIndex
	
	--储存改变后的索引
	self.storage:save(self.spawnedObjectIndex)
	
	self.spawnedObjectName = self.spawnedObjectNameTable[self.spawnedObjectIndex].Object_name
	self.spawnedObjectUUID = sm.uuid.new(self.spawnedObjectUUIDTable[self.spawnedObjectIndex].Object_UUID)
	--广播改变后的索引至全部客户端
	self.network:sendToClients("client_getUIData", self.spawnedObjectIndex)
end

function BombSpawner.server_onFixedUpdate( self, timeStep )
		
	local parent = self.interactable:getSingleParent()
	if parent then
		self.interactable.active = parent.active
		
		if self.interactable.active == true and self.lastActive == false then
		
			if self.spawnedObject == nil or not sm.exists( self.spawnedObject ) then -- No tank or tank was destroyed
				
				local spawnPos = self.shape:getWorldPosition() + ( self.shape.at * 0.125 ) - (self.shape.right * 0.375 + self.shape.up * 0.375) 
					
				--生成物品
				self.spawnedObject = sm.shape.createPart( self.spawnedObjectUUID, spawnPos, self.shape.worldRotation, true, true )
				--self.spawnedObject.color = self.shape.color
                    
				self.spawnedObject.body.destructable = false
				self.spawnedObject.body.buildable = true
				self.spawnedObject.body.paintable = true
				self.spawnedObject.body.connectable = false 
				self.spawnedObject.body.liftable = true
				self.spawnedObject.body.erasable = true
                    
				self.network:sendToClients( "client_onTankSpawned" )
					
				self.spawnedObject.body.destructable = true
				self.spawnedObject = nil
				
			elseif self.spawnedObject ~= nil and sm.exists( self.spawnedObject ) then
				if self.indestructibleTimer > 0 then
					self.indestructibleTimer = self.indestructibleTimer-1
					if self.indestructibleTimer <= 0 then
						-- Tank can now explode
						self.spawnedObject.body.destructable = true
					end
				end
			end	
		end
		
		self.lastActive = self.interactable.active
	end
end

--[[ Client ]]

function BombSpawner.client_onCreate( self )
	self.activationEffect = sm.effect.createEffect( "Ballspawner - Activate", self.interactable )
	
	--初始化索引并在创建时请求服务端
	self.UIPosIndex = 1
	self.network:sendToServer("server_request")
end

-- (Event) Called upon through the network when creating a new ball
function BombSpawner.client_onTankSpawned( self )
	self.activationEffect:start()
end

function BombSpawner.client_getUIData(self, UIPosIndex )

	--接收服务端的广播并刷新索引
	self.UIPosIndex = UIPosIndex
	
	self.spawnedObjectName = self.spawnedObjectNameTable[self.UIPosIndex].Object_name
	self.spawnedObjectUUID = sm.uuid.new(self.spawnedObjectUUIDTable[self.UIPosIndex].Object_UUID)
	self.gui:setIconImage("Icon", sm.uuid.new(self.spawnedObjectUUIDTable[self.UIPosIndex].Object_UUID))
end

function BombSpawner.client_onInteract(self, character, state)
    if not state then return end
	if self.gui == nil then
		--创建UI
		self.gui = sm.gui.createEngineGui()
		self.gui:setSliderCallback( "Setting", "client_onSliderChange")
		self.gui:setText("Name", "Bomb Spawner")
		self.gui:setText("Interaction", "Choose Bomb 选择要生成的炸弹")		
		self.gui:setIconImage("Icon", self.spawnedObjectUUID)
		self.gui:setVisible("FuelContainer", false )
	end
	self.gui:setSliderData("Setting", #self.spawnedObjectNameTable, self.UIPosIndex-1)
	self.gui:setText("SubTitle", self.spawnedObjectName.."")
	self.gui:open()
end

function BombSpawner.client_onSliderChange( self, sliderName, sliderPos )
	local newIndex = sliderPos + 1
	self.UIPosIndex = newIndex
	if self.gui ~= nil then
		--刷新选择的物品名和预览图标
		self.gui:setIconImage("Icon", sm.uuid.new(self.spawnedObjectUUIDTable[self.UIPosIndex].Object_UUID))
		self.gui:setText("SubTitle", self.spawnedObjectNameTable[self.UIPosIndex].Object_name)
	end
	self.network:sendToServer("server_spawnObjectChange", newIndex)
	--sm.audio.play("Button on", self.shape.worldPosition)
end

function BombSpawner.client_canInteract(self)
	sm.gui.setInteractionText( "", sm.gui.getKeyBinding( "Use" ), "Choose Bomb 选择要生成的炸弹")
	return true
end