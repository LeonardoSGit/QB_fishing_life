Utils = exports['lc_utils']:GetUtils()
local menu_active = false
local cooldown = nil
local current_fishing_location_id;
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
-----------------------------------------------------------------------------------------------------------------------------------------	

-- Main menu locations
function createMarkersThread()
	Citizen.CreateThreadNow(function()
		local timer = 2
		while true do
			timer = 3000
			for fishing_location_id,fishing_location_data in pairs(Config.fishing_locations) do
				if not menu_active then
					local x,y,z = table.unpack(fishing_location_data.menu_location)
					if Utils.Entity.isPlayerNearCoords(x,y,z,20.0) then
						timer = 2
						Utils.Markers.createMarkerInCoords(fishing_location_id,x,y,z,Utils.translate('open'),openFishingUiCallback)
					end
				end
			end
			Citizen.Wait(timer)
		end
	end)
end

function createTargetsThread()
	Citizen.CreateThreadNow(function()
		for fishing_location_id,fishing_location_data in pairs(Config.fishing_locations) do
			local x,y,z = table.unpack(fishing_location_data.menu_location)
			Utils.Target.createTargetInCoords(fishing_location_id,x,y,z,openFishingUiCallback,Utils.translate('open_target'),"fas fa-fish-fins","#2986cc")
		end
	end)
end

function openFishingUiCallback(fishing_location_id)
	current_fishing_location_id = fishing_location_id
	TriggerServerEvent("lc_fishing_life:getData",current_fishing_location_id)
end

-- Properties locations
RegisterNetEvent('lc_fishing_life:setPropertiesBlips')
AddEventHandler('lc_fishing_life:setPropertiesBlips', function(data)
	local user_id = data.user_id
	-- TODO: move isso pra funcao createMarkersThread e checa se o cara é dono ao chamar o evento TriggerServerEvent("lc_fishing_life:getDataProperty",fishing_property_id) inves de fazer verificacao no client (o certo é toda verificacao importante ser no server)
	Citizen.CreateThread(function()
		local timer = 2
		while true do
			timer = 3000
			for k,property in pairs(data) do
				if(property.user_id == property.original_user_id) then
					local x,y,z = table.unpack(Config.available_items_store.property[property.property].location)
					local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
					if not menu_active and distance <= 20.0 then
						timer = 2
						Utils.Markers.drawMarker(21,x,y,z,0.5)
						if distance <= 2.0 then
							Utils.Markers.drawText3D(x,y,z-0.6,Utils.translate('open'))
							if IsControlJustPressed(0,38) then
								fishing_property_id = property.property
								TriggerServerEvent("lc_fishing_life:getDataProperty",fishing_property_id)
							end
						end
					end
				end
			end
			Citizen.Wait(timer)
		end
	end)
end)

RegisterNetEvent('lc_fishing_life:open')
AddEventHandler('lc_fishing_life:open', function(data,isUpdate)
	TriggerScreenblurFadeIn(1000)
	SendNUIMessage({ 
		openOwnerUI = true,
		isUpdate = isUpdate,
		data = data,
		utils = { config = Utils.Config, lang = Utils.Lang },
		resourceName = GetCurrentResourceName()
	})
	if isUpdate == false then
		menu_active = true
		SetNuiFocus(true,true)
	end
end)


RegisterNetEvent('lc_fishing_life:openProperty')
AddEventHandler('lc_fishing_life:openProperty', function(property)
	SendNUIMessage({ 
		openPropertyUI = true,
		property = property,
		utils = { config = Utils.Config, lang = Utils.Lang },
		resourceName = GetCurrentResourceName()
	})
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('post', function(data, cb)
	if cooldown == nil then
		cooldown = true
		
		if data.event == "close" then
			closeUI()
		else
			TriggerServerEvent('lc_fishing_life:'..data.event,current_fishing_location_id,data.data)
		end
		cb(200)

		SetTimeout(500,function()
			cooldown = nil
		end)
	end
end)

RegisterNUICallback('close', function(data, cb)
	closeUI()
	cb(200)
end)

RegisterNetEvent('lc_fishing_life:closeUI')
AddEventHandler('lc_fishing_life:closeUI', function()
	closeUI()
end)

function closeUI()
	current_fishing_location_id = nil
	menu_active = false
	SetNuiFocus(false,false)
	SendNUIMessage({ hidemenu = true })
	TriggerScreenblurFadeOut(1000)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- addBlipProperty
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    Wait(5000)
    TriggerServerEvent("lc_fishing_life:getProperties")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local route_blip
RegisterNetEvent('lc_fishing_life:startContract')
AddEventHandler('lc_fishing_life:startContract', function(contract_data)
	closeUI()
	
	contract_data.delivery_location = json.decode(contract_data.delivery_location)
	local x,y,z = table.unpack(contract_data.delivery_location)

	route_blip = Utils.Blips.createBlipForCoords(x,y,z,1,5,Utils.translate('contract_destination_blip'),1.0,true)

	local timer
	while DoesBlipExist(route_blip) do
		timer = 3000
		local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
		if distance <= 20.0 then
			timer = 2
			Utils.Markers.drawMarker(21,x,y,z,0.5)
			if distance <= 2.0 then
				Utils.Markers.drawText3D(x,y,z-0.6,Utils.translate('contract_finish_delivery'))
				if IsControlJustPressed(0,38) then
					TriggerServerEvent("lc_fishing_life:finishContract")
				end
			end
		end
		Citizen.Wait(timer)
	end
end)

RegisterNetEvent('lc_fishing_life:cancelContract')
AddEventHandler('lc_fishing_life:cancelContract', function()
	RemoveBlip(route_blip)
end)

RegisterNetEvent('lc_fishing_life:viewLocation')
AddEventHandler('lc_fishing_life:viewLocation', function(location)
	closeUI()
	SetNewWaypoint(location[1],location[2])
end)

local vehicle,vehicle_blip
local update_vehicle_status = 0
RegisterNetEvent('lc_fishing_life:spawnVehicle')
AddEventHandler('lc_fishing_life:spawnVehicle', function(vehicle_data,garage_to_spawn)
	if IsEntityAVehicle(vehicle) then
		exports['lc_utils']:notify("error",Utils.translate('vehicle_already_spawned'))
		return
	end

	closeUI()

	local i = #garage_to_spawn
	local x,y,z,h
	while i > 0 do
		x,y,z,h = table.unpack(garage_to_spawn[i])
		if not Utils.Vehicles.isSpawnPointClear({['x']=x,['y']=y,['z']=z},5.001) then
			if i <= 1 then
				exports['lc_utils']:notify("error",Utils.translate('occupied_places'))
				return
			end
		else
			break
		end
		i = i - 1
	end

	vehicle_data.properties = json.decode(vehicle_data.properties)
	Utils.Debug.printTable(vehicle_data)
	if not vehicle_data.properties.plate then
		vehicle_data.properties.plate = Utils.translate('vehicle_plate')..tostring(math.random(1000000, 9999999))
	end
	vehicle_data.properties.bodyHealth = vehicle_data.health
	vehicle_data.properties.engineHealth = vehicle_data.health
	vehicle_data.properties.fuelLevel = vehicle_data.fuel
	local blip_data = { name = Utils.translate('vehicle_blip'), sprite = Config.vehicle_blips.sprite, color = Config.vehicle_blips.color }
	vehicle,vehicle_blip = Utils.Vehicles.spawnVehicle(vehicle_data.vehicle,x,y,z,h,blip_data,vehicle_data.properties)
	exports['lc_utils']:notify("success",Utils.translate('vehicle_spawned'))

	local timer = 2
	local engine_health = GetVehicleEngineHealth(vehicle)
	local vehicle_fuel = GetVehicleFuelLevel(vehicle)
	local body_health = GetVehicleBodyHealth(vehicle)
	
	while IsEntityAVehicle(vehicle) do
		timer = 2000
		local coords = GetEntityCoords(vehicle)
		local ped = PlayerPedId()
		if oldpos ~= nil then
			local dist = #(coords - oldpos)
			vehicle_data.traveled_distance = vehicle_data.traveled_distance + dist
			veh = GetVehiclePedIsIn(ped,false)
			if veh == vehicle then
				for k,mark in pairs(garage_to_spawn) do
					local x,y,z = table.unpack(mark)
					local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
					if distance <= 20.0 then
						timer = 2
						Utils.Markers.drawMarker(21,x,y,z,1.0)
						if distance <= 2.0 then
							Utils.Markers.drawText2D(Utils.translate('press_e_to_store_vehicle'), 8,0.5,0.95,0.50,255,255,255,180)
							if IsControlJustPressed(0,38) and IsEntityAVehicle(vehicle) then
								TriggerServerEvent("lc_fishing_life:updateVehicleStatus",vehicle_data,GetVehicleEngineHealth(vehicle),GetVehicleBodyHealth(vehicle),GetVehicleFuelLevel(vehicle),Utils.Vehicles.getVehicleProperties(vehicle))
								Utils.Vehicles.deleteVehicle(vehicle)
								Utils.Blips.removeBlip(vehicle_blip)
								return
							end
						end
					end
				end
			end

			if IsEntityAVehicle(vehicle) and update_vehicle_status == 0 and (engine_health ~= GetVehicleEngineHealth(vehicle) or vehicle_fuel ~= GetVehicleFuelLevel(vehicle)) then
				update_vehicle_status = 3
				engine_health = GetVehicleEngineHealth(vehicle)
				body_health = GetVehicleBodyHealth(vehicle)
				vehicle_fuel = GetVehicleFuelLevel(vehicle)
				TriggerServerEvent("lc_fishing_life:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel,Utils.Vehicles.getVehicleProperties(vehicle))
			end
		end

		local vehicles = { vehicle }
		local peds = { ped }
		local has_error, error_message = Utils.Entity.isThereSomethingWrongWithThoseBoys(vehicles,peds)
		if has_error then
			Utils.Framework.removeVehicleKeys(vehicle)
			Utils.Blips.removeBlip(route_blip)
			Utils.Blips.removeBlip(vehicle_blip)
			PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "HUD_AWARDS", false)
			if Utils.Table.contains({'vehicle_almost_destroyed','vehicle_undriveable','ped_is_dead'}, error_message) then
				SetVehicleEngineHealth(vehicle,-4000)
				SetVehicleUndriveable(vehicle,true)
			end
			if error_message == 'ped_is_dead' then
				exports['lc_utils']:notify("error",Utils.translate('you_died'))
			else
				exports['lc_utils']:notify("error",Utils.translate('vehicle_destroyed'))
			end
			TriggerServerEvent("lc_fishing_life:updateVehicleStatus",vehicle_data,GetVehicleEngineHealth(vehicle),GetVehicleBodyHealth(vehicle),GetVehicleFuelLevel(vehicle),Utils.Vehicles.getVehicleProperties(vehicle))
			return
		end

		oldpos = coords
		Citizen.Wait(timer)
	end
	Utils.Blips.removeBlip(vehicle_blip)
	exports['lc_utils']:notify("error",Utils.translate('vehicle_lost'))
	TriggerServerEvent("lc_fishing_life:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel)
end)

Citizen.CreateThread(function()
	while true do
		timer = 10000
		if update_vehicle_status > 0 then
			update_vehicle_status = update_vehicle_status - 1
		end
		Citizen.Wait(timer)
	end
end)

RegisterNetEvent('lc_fishing_life:Notify')
AddEventHandler('lc_fishing_life:Notify', function(type,message)
	exports['lc_utils']:notify(type,message)
end)

Citizen.CreateThread(function()
	Wait(1000)
	SetNuiFocus(false,false)

	Utils.loadLanguageFile(Lang)

	if Utils.Config.custom_scripts_compatibility.target == "disabled" then
		createMarkersThread()
	else
		createTargetsThread()
	end
end)