Utils = exports['lc_utils']:GetUtils()
local menu_active = false
local cooldown = nil
local current_fishing_location_id;
local uiOpen = false
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

function createMarkersPropertyThread()
	Citizen.CreateThreadNow(function()
		local timer = 2
		while true do
			timer = 3000
			for property_id, property_location_data in pairs(Config.available_items_store.property) do
				if not menu_active then
					local x,y,z = table.unpack(property_location_data.location)
					if Utils.Entity.isPlayerNearCoords(x,y,z,20.0) then
						timer = 2
						Utils.Markers.createMarkerInCoords(property_id,x,y,z,Utils.translate('open'),openPropertyUiCallback)
					end
				end
			end
			Citizen.Wait(timer)
		end
	end)
end

function createTargetsPropertyThread()
	Citizen.CreateThreadNow(function()
		for fishing_location_id,fishing_location_data in pairs(Config.fishing_locations) do
			local x,y,z = table.unpack(fishing_location_data.menu_location)
			Utils.Target.createTargetInCoords(fishing_location_id,x,y,z,openFishingUiCallback,Utils.translate('open_target'),"fas fa-fish-fins","#2986cc")
		end
	end)
end

function openPropertyUiCallback(property_location_id)
	TriggerServerEvent("lc_fishing_life:getDataProperty",property_location_id)
end

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
AddEventHandler('lc_fishing_life:openProperty', function(data, property)
	TriggerScreenblurFadeIn(1000)
	SendNUIMessage({ 
		openPropertyUI = true,
		property = property,
		data = data,
		utils = { config = Utils.Config, lang = Utils.Lang },
		resourceName = GetCurrentResourceName()
	})
	SetNuiFocus(true,true)
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

RegisterNetEvent('lc_fishing_life:closeFishingUi')
AddEventHandler('lc_fishing_life:closeFishingUi', function(success)
    SetNuiFocus(false, false)
    DeleteEntity(trackingFish)
    SetModelAsNoLongerNeeded(trackingFish)
    trackingFish = nil
    uiOpen = false
    value = success
    Citizen.Wait(100)
    value = nil
    SendNUIMessage({
        type = "close",
        resourceName = GetCurrentResourceName()
    })
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
	Utils.Blips.removeBlip(route_blip)
end)

RegisterNetEvent('lc_fishing_life:viewLocation')
AddEventHandler('lc_fishing_life:viewLocation', function(location)
	closeUI()
	SetNewWaypoint(location[1],location[2])
end)

local route_blip_dive
RegisterNetEvent('lc_fishing_life:startDive')
AddEventHandler('lc_fishing_life:startDive', function(dive_data)
	closeUI()
	
	dive_data.dive_location = json.decode(dive_data.dive_location)
	local x,y,z = table.unpack(dive_data.dive_location)
	route_blip_dive = Utils.Blips.createBlipForCoords(x,y,z,1,5,Utils.translate('contract_destination_blip'),10.0,true)

	local timer
	while DoesBlipExist(route_blip_dive) do
		timer = 3000
		local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
		if distance <= 20.0 then
			timer = 2
			Utils.Markers.drawMarker(21,x,y,z,0.5)
			if distance <= 2.0 then
				Utils.Markers.drawText3D(x,y,z-0.6,Utils.translate('dive_finish'))
				if IsControlJustPressed(0,38) then
					TriggerServerEvent("lc_fishing_life:finishDive")
				end
			end
		end
		Citizen.Wait(timer)
	end
end)

RegisterNetEvent('lc_fishing_life:cancelDive')
AddEventHandler('lc_fishing_life:cancelDive', function()
	Utils.Blips.removeBlip(route_blip_dive)
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
						Utils.Markers.drawMarker(36,x,y,z,1.0) -- TODO: Id 36 se for carro, id 35 se for barco
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

Citizen.CreateThread(function()
	for _,fishing_location_data in pairs(Config.fishing_locations) do
		local x,y,z = table.unpack(fishing_location_data.menu_location)
		local blips = fishing_location_data.blips
		Utils.Blips.createBlipForCoords(x,y,z,blips.id,blips.color,blips.name,blips.scale,false)
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
	createMarkersThread()
	-- if Utils.Config.custom_scripts_compatibility.target == "disabled" then
	-- else
	-- 	createTargetsThread()
	-- end
end)

Citizen.CreateThread(function()
	Wait(1000)
	SetNuiFocus(false,false)

	Utils.loadLanguageFile(Lang)


	createMarkersPropertyThread()
	-- if Utils.Config.custom_scripts_compatibility.target == "disabled" then
	-- else
	-- 	createTargetsPropertyThread()
	-- end
end)



local QBCore = Fishing_Config.Core
local currentDiff = nil
local startingDiff = nil
Utils = exports['lc_utils']:GetUtils()

Citizen.CreateThread(function()
    Citizen.Wait(10)
    TriggerServerCallback('lc_fishing_life:getDataFishing', function(player)
        SendNUIMessage({
            type = "setLocale", 
            hook =  Utils.translate("hook"),
            success =  Utils.translate("success"),
            fail = Utils.translate("fail"),
            gotaway = Utils.translate("got_away2"),
            toosoon = Utils.translate("too_soon"),
            fishBite = Utils.translate("fish_bite"),
            resourceName = GetCurrentResourceName(),
            utils = { config = Utils.Config, lang = Utils.Lang },
            player = player
        })
    end)

end)


function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(5)
    end
end

function LoadModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end
end


-----------------------------------------------------------------------------------------------------------------------------------------
-- Fishing Area
-----------------------------------------------------------------------------------------------------------------------------------------


local IsFishing = false
local rodHandle = nil
local StartFish = false
local area = nil

Citizen.CreateThread(function()
    while true do
        local timer = 1500
        if isNearFishingSpot() and not uiOpen then
            ShowHelpNotification("press ~INPUT_SPECIAL_ABILITY_SECONDARY~ to start fishing", true)
            timer = 2            
            if IsControlJustPressed(0,29) then
                TriggerServerCallback('lc_fishing_life:getDataFishing', function(player)
                    InitFishing(player)
                end)
            end
        end
        Citizen.Wait(timer)
    end
end)

function ShowHelpNotification(msg, thisFrame, beep, duration)
    AddTextEntry('esxHelpNotification', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('esxHelpNotification', false)
    else
        if beep == nil then
            beep = true
        end
        BeginTextCommandDisplayHelp('esxHelpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

function InitFishing(player)
    if StartFish == false then
        StartFish = true
        rodHandle = FishingRod()
        if IsPedSwimming(PlayerPedId()) or IsPedInAnyVehicle(PlayerPedId()) then 
            StartFish = false
            exports['lc_utils']:notify("error", Utils.translate("cant_now"))
            DeleteEntity(trackingFish)
            return
        end
        area = fishingSpot()
        local waterValidated, castLocation = IsInWater()
        if area then
            if waterValidated then
                if not IsFishing then
                    IsFishing = true
                    TryToCatchFish(player)
                    StartFish = false
                end
            else
                exports['lc_utils']:notify("error", Utils.translate("aim_to_water"))
                StartFish = false
                ClearPedTasks(PlayerPedId())
                DeleteEntity(rodHandle)
                DeleteEntity(FishRod)
                DeleteEntity(trackingFish)
                rodHandle = nil
                RemoveLoadingPrompt()
                IsFishing = false
            end
        else
            exports['lc_utils']:notify("error", Utils.translate("cant_fish"))
            StartFish = false
            ClearPedTasks(PlayerPedId())
            DeleteEntity(rodHandle)
            DeleteEntity(FishRod)
            DeleteEntity(trackingFish)
            rodHandle = nil
            RemoveLoadingPrompt()
            IsFishing = false
        end
    end
end

function FishingRod()
    local fishingRodHash = GetHashKey("prop_fishing_rod_01")

    LoadModel(fishingRodHash)

    rodHandle = CreateObject(fishingRodHash, GetEntityCoords(PlayerPedId()), true)

    AttachEntityToEntity(rodHandle, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 18905), 0.1, 0.05, 0, 80.0, 120.0, 160.0, true, true, false, true, 1, true)

    SetModelAsNoLongerNeeded(fishingRodHash)
    
    Anim("mini@tennis", "forehand_ts_md_far", {
        ["flag"] = 48
    })

    while IsEntityPlayingAnim(PlayerPedId(), "mini@tennis", "forehand_ts_md_far", 3) do
        Citizen.Wait(0)
    end

    Anim("amb@world_human_stand_fishing@idle_a", "idle_c", {
        ["flag"] = 11
    })

    return rodHandle
end

function removeFishingRod()
    local fishingRodHash = GetHashKey("prop_fishing_rod_01")

    LoadModel(fishingRodHash)
    DeleteObject(fishingRodHash, GetEntityCoords(PlayerPedId()), true)
end

function Anim(dict, anim, settings)
	if dict then
        Citizen.CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(PlayerPedId(), dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(PlayerPedId(), dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end

            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(PlayerPedId(), anim, 0, true)
	end
end
function DrawText3Ds(coords, text, size)
    local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z+0.5)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropShadow()
    SetTextProportional(1.2)
    SetTextColour(255, 255, 255, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
end

function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

function TryToCatchFish(player)
    math.randomseed(GetGameTimer())
    fish = calculateAndGetFish(player)
    startingDiff = CalculateDiffStartOnTension(player)
    currentDiff = startingDiff
    SendNUIMessage({type = "updateDifficulty", 
        tensionIncrease =  math.random(Config.difficulty[currentDiff].tensionIncrease.min, Config.difficulty[currentDiff].tensionIncrease.max),
        tensionDecrease =  math.random(Config.difficulty[currentDiff].tensionDecrease.min, Config.difficulty[currentDiff].tensionDecrease.max),
        progressIncrease = math.random(Config.difficulty[currentDiff].progressIncrease.min, Config.difficulty[currentDiff].progressIncrease.max),
        progressDecrease = math.random(Config.difficulty[currentDiff].progressDecrease.min, Config.difficulty[currentDiff].progressDecrease.max),
    })
    local finished = false
    finished = fishingGameStart(player)
    onFishingEnd(finished)
    if not finished then
        Wait(1000)
        exports['lc_utils']:notify("error", Utils.translate("got_away"))
        StartFish = false
        ClearPedTasks(PlayerPedId())
        DeleteEntity(rodHandle)
        DeleteEntity(FishRod)
        DeleteEntity(trackingFish)
        rodHandle = nil
        RemoveLoadingPrompt()
        IsFishing = false
        return
    end
    ClearPedTasks(PlayerPedId())
    local forwardVector = GetEntityForwardVector(PlayerPedId())
    local forwardPos = vector3(GetEntityCoords(PlayerPedId())["x"] + forwardVector["x"] * 5, GetEntityCoords(PlayerPedId())["y"] + forwardVector["y"] * 5, GetEntityCoords(PlayerPedId())["z"])
    local model = GetHashKey(fish.prop)
    LoadModel(model)
    local fishHandle = CreatePed(28, model, forwardPos, 0.0, true, true)
    while not DoesEntityExist(fishHandle) do
        Citizen.Wait(10)
    end
    Citizen.CreateThread(function() 
        while true do
            Citizen.Wait(100)
            local asd = GetEntityCoords(fishHandle, false)
            if Vdist(GetEntityCoords(fishHandle, false), forwardPos) <= 1.5 then
                local plypos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -25.0, 0.4)
                
                local x = plypos.x - asd.x
                local y = plypos.y - asd.y
                local z = plypos.z - asd.z
                ApplyForceToEntity(fishHandle, 3, x, y, z+1, 0.0, 0.0, 0.0, 1, false, false, true, false, false)
                Citizen.Wait(1500)
                SetEntityCoords(fishHandle, plypos)
                loadAnimDict( "random@domestic" ) 
                TaskPlayAnim( PlayerPedId(), "random@domestic", "pickup_low", 100.0, 1.0, 1000, 0, 0, 0, 0, 0 )
                Citizen.Wait(500)
                AttachEntityToEntity(fishHandle, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                Citizen.Wait(1000)
                local attempt = 0

                while not NetworkHasControlOfEntity(fishHandle) and attempt < 100 and DoesEntityExist(fishHandle) do
                    Citizen.Wait(100)
                    NetworkRequestControlOfEntity(fishHandle)
                    attempt = attempt + 1
                end
                Wait(1000)
                DeleteEntity(fishHandle)
                ClearPedTasks(PlayerPedId())
                DeleteEntity(rodHandle)
                DeleteEntity(FishRod)
                rodHandle = nil
                RemoveLoadingPrompt()
                IsFishing = false
           
            else
                break
            end
        end
    end)
    Anim("mini@tennis", "forehand_ts_md_far", {
        ["flag"] = 48
    })
    while IsEntityPlayingAnim(PlayerPedId(), "mini@tennis", "forehand_ts_md_far", 3) do
        Citizen.Wait(0)
    end
    Citizen.Wait(1500)
    ClearPedTasks(PlayerPedId())
    DeleteEntity(rodHandle)
    DeleteEntity(FishRod)
    rodHandle = nil
    IsFishing = false
end


local trackingFish = nil
function IsInWater()

    local startedCheck = GetGameTimer()
    local forwardVector = GetEntityForwardVector(PlayerPedId())
    local forwardPos = vector3(GetEntityCoords(PlayerPedId())["x"] + forwardVector["x"] * 10, GetEntityCoords(PlayerPedId())["y"] + forwardVector["y"] * 10, GetEntityCoords(PlayerPedId())["z"])
    local fishHash = "a_c_fish"

    LoadModel(fishHash)

    local waterHeight = GetWaterHeight(forwardPos["x"], forwardPos["y"], forwardPos["z"])
          trackingFish = CreatePed(1, fishHash, forwardPos.x, forwardPos.y, forwardPos.z, 0.0, false, true)

    SetEntityAlpha(trackingFish, 1, true) -- makes the fish invisible.

    local timeout = 5
    while not IsEntityInWater(trackingFish) and timeout > 0 do
        Citizen.Wait(1000)
        timeout = timeout - 1
    end

    local fishInWater = IsEntityInWater(trackingFish)

    if area == 'sewer' then
        waterHeight = forwardPos.z - 1
    end
    if waterHeight then
        return fishInWater, fishInWater and vector3(forwardPos["x"], forwardPos["y"], waterHeight) or false
    else
        DeleteEntity(trackingFish)
        return false
    end
end

RegisterCommand("fish", function()
    InitFishing()
end)
local blips = {}

local last_x, last_y, lasttext, isDrawing
function Draw3dNUI(coords)
    if not coords then return end
	local paused = false
	if IsPauseMenuActive() then paused = true end
	local onScreen,_x,_y = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
		if paused then
            SendNUIMessage ({
                type = "hide",
                resourceName = GetCurrentResourceName()
            }) 
        else 
            SendNUIMessage ({
                type = "show",
                resourceName = GetCurrentResourceName()
            }) 
        end
            SendNUIMessage({
                type = "updatePos",
                resourceName = GetCurrentResourceName(), 
                x = _x,
                y = _y
            })
		    last_x, last_y = _x, _y
end

local reelingProgress = 0
local isItOver = false
function fishingGameStart(player)
    Citizen.Wait(250)
    reelingProgress = 0
    uiOpen = true
    isItOver = false
    SetNuiFocus(true, false)
    local ply = PlayerPedId()
    local plyCords = GetEntityCoords(ply)
    local fishcoords = GetEntityCoords(trackingFish)
    local _x,_y = GetScreenCoordFromWorldCoord(fishcoords.x,fishcoords.y,fishcoords.z)
    local dist = #(plyCords - fishcoords)
    local savedcord = nil
    SendNUIMessage({
        type = "start",
        x = _x, 
        y = _y,
        resourceName = GetCurrentResourceName(),
        utils = { config = Utils.Config, lang = Utils.Lang },
        player = player
    });
    while uiOpen do
        Citizen.Wait(10)
        local progresscords = GetOffsetFromEntityInWorldCoords(ply, 0, (dist - (dist * (reelingProgress/100))) + 1, 0)
        if not isItOver then
            savedcord = progresscords
            Draw3dNUI(progresscords)
        else
            Draw3dNUI(savedcord)
        end
        DisableControlAction(0, 24, active) -- Attack
        DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
        DisableControlAction(0, 142, active) -- MeleeAttackAlternate
        DisableControlAction(0, 106, active) -- VehicleMouseControlOverride
    end
    Citizen.CreateThread(function()
        local time = GetGameTimer()
        while GetGameTimer() - time < 500 do
            DisableControlAction(0, 24, active) -- Attack
            DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
            DisableControlAction(0, 142, active) -- MeleeAttackAlternate
            DisableControlAction(0, 106, active) -- VehicleMouseControlOverride
            Citizen.Wait(0)
        end 
    end)
    return value
end
RegisterNetEvent('nuifalse', function()
    cancelGame()
end)

function cancelGame()
    SendNUIMessage({
        type = "close",
        resourceName = GetCurrentResourceName()
    })
    SetNuiFocus(false, false)
    DeleteEntity(trackingFish)
    SetModelAsNoLongerNeeded(trackingFish)
    trackingFish = nil
    uiOpen = false
    value = nil
end

RegisterNUICallback('updateTrackingFish', function(data)
    Citizen.Wait(100)
    if data.data.progress >= 100 or data.data.isitover ~= nil then
        isItOver = true
        Citizen.Wait(100)
    end
    reelingProgress = data.data.progress
end)

function onFishingEnd(pass) -- this client function will run after minigame
    if pass then
        TriggerServerEvent('lc_fishing_life:receiveFish', fish)
    else
        exports['lc_utils']:notify("error", Utils.translate("caught_nothing"))
    end

  end
  
Citizen.CreateThread(function() while true do Citizen.Wait(30000) collectgarbage() end end)

ServerCallbacks = {}
CurrentRequestId = 0
RegisterNetEvent('lc_fishing_life:serverCallback')
AddEventHandler('lc_fishing_life:serverCallback', function(requestId, ...)
    ServerCallbacks[requestId](...)
    ServerCallbacks[requestId] = nil
end)
TriggerServerCallback = function(name, cb, ...)
    ServerCallbacks[CurrentRequestId] = cb

    TriggerServerEvent('lc_fishing_life:triggerServerCallback', name, CurrentRequestId, ...)

    if CurrentRequestId < 65535 then
        CurrentRequestId = CurrentRequestId + 1
    else
        CurrentRequestId = 0
    end
end

function CalculateDiffStartOnTension(player)
    local playerLevel = player.gimp_upgrade
    local rand = math.random(1, 100)
    rand = rand + addCountForUpgrades(playerLevel)
    if playerLevel == 1 then
        return "hard"
    elseif playerLevel == 2 then
        if rand <= 70 then
            return "hard"
        else
            return "medium"
        end
    elseif playerLevel == 3 then
        if rand <= 35 then
            return "hard"
        elseif rand <= 95 then
            return "medium"
        else
            return "easy"
        end
    elseif playerLevel == 4 then
        if rand <= 70 then
            return "medium"
        else
            return "easy"
        end
    elseif playerLevel == 5 then
        return "easy"
    else
        return nil 
    end
end

function calculateAndGetFish(player)
    if area == 'sea' then
        return selectTable(player.sea_upgrade, player.rod_upgrade)
    elseif  area == 'swan' then
        return selectTable(player.swan_upgrade, player.rod_upgrade)
    elseif area == 'lake' then
        return selectTable(player.lake_upgrade, player.rod_upgrade)
    end
end

function randomSelect(tbl)
    return tbl[1][math.random(1, #tbl[1])]
end

function selectTable(playerLevel,rodlevel)
    local rand = math.random(1, 100)
    rand = rand + addCountForUpgrades(rodlevel)
    if playerLevel == 1 then
        return randomSelect({Fishing_Config.FishTable[area][1]})
    elseif playerLevel == 2 then
        if rand <= 70 then
            return randomSelect({Fishing_Config.FishTable[area][1]})
        elseif rand <= 95 then
            return randomSelect({Fishing_Config.FishTable[area][2]})
        else
            return randomSelect({Fishing_Config.FishTable[area][3]})
        end
    elseif playerLevel == 3 then
        if rand <= 35 then
            return randomSelect({Fishing_Config.FishTable[area][1]})
        elseif rand <= 70 then
            return randomSelect({Fishing_Config.FishTable[area][2]})
        elseif rand <= 95 then
            return randomSelect({Fishing_Config.FishTable[area][3]})
        else
            return randomSelect({Fishing_Config.FishTable[area][4]})
        end
    elseif playerLevel == 4 then
        if rand <= 15 then
            return randomSelect({Fishing_Config.FishTable[area][1]})
        elseif rand <= 35 then
            return randomSelect({Fishing_Config.FishTable[area][2]})
        elseif rand <= 70 then
            return randomSelect({Fishing_Config.FishTable[area][3]})
        elseif rand <= 94 then
            return randomSelect({Fishing_Config.FishTable[area][4]})
        else
            return randomSelect({Fishing_Config.FishTable[area][5]})
        end
    elseif playerLevel == 5 then
        if rand <= 10 then
            return randomSelect({Fishing_Config.FishTable[area][1]})
        elseif rand <= 25 then
            return randomSelect({Fishing_Config.FishTable[area][2]})
        elseif rand <= 55 then
            return randomSelect({Fishing_Config.FishTable[area][3]})
        elseif rand <= 85 then
            return randomSelect({Fishing_Config.FishTable[area][4]})
        else
            return randomSelect({Fishing_Config.FishTable[area][5]})
        end
    else
        return nil 
    end
end

function addCountForUpgrades(rodlevel)
    if rodlevel == 1 then
        return 0
    elseif rodlevel == 2 then
        return 5
    elseif rodlevel == 3 then
        return 10
    elseif rodlevel == 4 then
        return 15
    elseif rodlevel == 5 then
        return 20
    end
end
