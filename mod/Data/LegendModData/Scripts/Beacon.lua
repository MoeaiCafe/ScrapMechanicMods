----------------------------------------------
-------Copyright (c) 2021 David Sirius--------
----------------------------------------------

dofile( "$SURVIVAL_DATA/Scripts/game/managers/BeaconManager.lua" )

Beacon = class( nil )
Beacon.poseWeightCount = 1
Beacon.animSpeed = 0.8

function Beacon.server_onCreate( self )
	self.loaded = true

	self.saved = self.storage:load()
	if self.saved == nil then
		self.saved = {}
	end
	if self.saved.iconData == nil then
		self.saved.iconData = {}
	end
	if self.saved.iconData.iconIndex == nil then
		self.saved.iconData.iconIndex = 0
	end
	if self.saved.iconData.colorIndex == nil then
		self.saved.iconData.colorIndex = 1
	end

	self.storage:save( self.saved )
	self.network:setClientData( { iconIndex = self.saved.iconData.iconIndex, colorIndex = self.saved.iconData.colorIndex } )

	if g_beaconManager then
		g_beaconManager:sv_createBeacon( self.shape, self.saved.iconData )
	end
end

function Beacon.server_onDestroy( self )
	if self.loaded then
		if g_beaconManager then
			g_beaconManager:sv_destroyBeacon( self.shape )
		end
		self.loaded = false
	end
end

function Beacon.server_onUnload( self )
	if self.loaded then
		if g_beaconManager then
			g_beaconManager:sv_unloadBeacon( self.shape )
		end
		self.loaded = false
	end
end

function Beacon.sv_updateIcon( self, params )
	if params.iconIndex then
		self.saved.iconData.iconIndex = params.iconIndex
	end
	if params.colorIndex then
		self.saved.iconData.colorIndex = params.colorIndex
	end
	self.storage:save( self.saved )
	self.network:setClientData( { iconIndex = self.saved.iconData.iconIndex, colorIndex = self.saved.iconData.colorIndex } )
	if g_beaconManager then
		g_beaconManager:sv_createBeacon( self.shape, self.saved.iconData )
	end
end

function Beacon.client_onCreate( self )

	self.boltValue = 0.001
	self.lastValue = 0
	sm.audio.play("Blueprint - Share", self.shape:getWorldPosition())
	sm.gui.displayAlertText("信标已部署 Beacon Deployed", 3)
	self.deployedEffect = sm.effect.createEffect( "ModLightPoint", self.interactable )
	self.deployedEffect:start()
	
	--游戏原版
	self.cl = {}
	self.cl.loopingIndex = 0
	self.cl.unfoldWeight = 0

	if self.cl.selectedIconButton == nil then
		self.cl.selectedIconButton = "IconButton0"
	end
	if self.cl.selectedColorButton == nil then
		self.cl.selectedColorButton = "ColorButton0"
	end

	self.cl.idleSound = sm.effect.createEffect( "Beacon - Idle", self.shape.interactable )
	self.cl.idleSound:start()
	
end

function Beacon.client_onDestroy(self)
	self.deployedEffect:stop()
	
	--游戏原版
	self.cl.idleSound:stop()
	self.cl.idleSound:destroy()
	self.cl.idleSound = nil

	if self.cl.beaconIconGui then
		self.cl.beaconIconGui:close()
		self.cl.beaconIconGui:destroy()
	end
end

function Beacon.client_onClientDataUpdate( self, clientData )
	if self.cl == nil then
		self.cl = {}
	end
	local selectedIconButton = "IconButton" .. tostring( clientData.iconIndex )
	local selectedColorButton = "ColorButton" .. tostring( clientData.colorIndex - 1 )

	if self.cl.gui then
		self:cl_updateIconButton( selectedIconButton )
		self:cl_updateColorButton( selectedColorButton )
	else
		self.cl.selectedIconButton = selectedIconButton
		self.cl.selectedColorButton = selectedColorButton
	end

	if g_beaconManager == nil then
		if self.cl.beaconIconGui then
			self.cl.beaconIconGui:close()
		else
			self.cl.beaconIconGui = sm.gui.createBeaconIconGui()
		end
		self.cl.beaconIconGui:setItemIcon( "Icon", "BeaconIconMap", "BeaconIconMap", tostring( clientData.iconIndex ) )
		local beaconColor = BEACON_COLORS[clientData.colorIndex]
		self.cl.beaconIconGui:setColor( "Icon", beaconColor )
		self.cl.beaconIconGui:setHost( self.shape )
		self.cl.beaconIconGui:setRequireLineOfSight( false )
		self.cl.beaconIconGui:setMaxRenderDistance(10000)
		self.cl.beaconIconGui:open()
	end
end

function Beacon.client_onUpdate( self, dt )

	if self.lastValue < 1 then
		self.boltValue = self.lastValue + dt*self.animSpeed	
	else 
		self.boltValue = 1
	end
	self.lastValue = self.boltValue

	if self.boltValue then
		self.interactable:setPoseWeight( 0, self.boltValue )
	end
	
	--游戏原版
	if self.cl.idleSound and not self.cl.idleSound:isPlaying() then
		self.cl.idleSound:start()
	end
end

function Beacon.client_onInteract( self, character, state )
	print( "client_onInteract", state )
	if state == true then
		self.cl.gui = sm.gui.createGuiFromLayout( "$GAME_DATA/Gui/Layouts/Interactable/Interactable_Beacon.layout" ) --Destroy on close
		for i = 0, 23 do
			self.cl.gui:setButtonCallback( "IconButton" .. tostring( i ), "cl_onIconButtonClick" )
		end
		for i = 0, 7 do
			self.cl.gui:setButtonCallback( "ColorButton" .. tostring( i ), "cl_onColorButtonClick" )
		end

		self.cl.gui:setOnCloseCallback( "cl_onClose" )
		self.cl.gui:open()
		self:cl_updateIconButton( self.cl.selectedIconButton )
		self:cl_updateColorButton( self.cl.selectedColorButton )
	end
end

function Beacon.cl_onIconButtonClick( self, name )
	print( "cl_onButtonClick", name )
	local iconIndex = tonumber( name:match( '%d+' ) )
	self.network:sendToServer( "sv_updateIcon", { iconIndex = iconIndex } )
end

function Beacon.cl_onColorButtonClick( self, name )
	print( "cl_onButtonClick", name )
	local colorIndex = tonumber( name:match( '%d+' ) ) + 1
	self.network:sendToServer( "sv_updateIcon", { colorIndex = colorIndex } )
end

function Beacon.cl_onClose( self )
	self.cl.gui:destroy()
	self.cl.gui = nil
end

function Beacon.cl_updateIconButton( self, iconButtonName )
	if self.cl.selectedIconButton ~= iconButtonName then
		self.cl.gui:setButtonState( self.cl.selectedIconButton, false )
		self.cl.selectedIconButton = iconButtonName
	end
	self.cl.gui:setButtonState( self.cl.selectedIconButton, true )
	self:cl_updateSelectedIconColor()
end

function Beacon.cl_updateColorButton( self, colorButtonName )
	if self.cl.selectedColorButton ~= colorButtonName then
		self.cl.gui:setButtonState( self.cl.selectedColorButton, false )
		self.cl.selectedColorButton = colorButtonName
	end
	self.cl.gui:setButtonState( self.cl.selectedColorButton, true )
	self:cl_updateSelectedIconColor()
end

function Beacon.cl_updateSelectedIconColor( self )
	local defaultColor = sm.color.new( "FFFFFF4F" )
	for i = 0, 23 do
		self.cl.gui:setColor( "IconImage" .. tostring( i ), defaultColor )
	end
	local colorIndex = tonumber( self.cl.selectedColorButton:match( '%d+' ) ) + 1
	local iconColor = BEACON_COLORS[colorIndex]
	self.cl.gui:setColor( "IconImage" .. self.cl.selectedIconButton:match( '%d+' ), iconColor )
end

