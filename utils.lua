-- Framework init
QBCore = exports['qb-core']:GetCoreObject()

-----------------------------------------------------------------------------------------------------------------------------------------
-- Notify
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("qb_fishing_life:Notify")
AddEventHandler("qb_fishing_life:Notify", function(type,msg)
	-- You can change your notification here
	-- There are 4 notifications types: success, error, warning and info
	if msg ~= nil then
		SendNUIMessage({ 
			notification = msg,
			notification_type = type,
		})
	else
		SendNUIMessage({ 
			notification = 'Message not found',
			notification_type = type,
		})
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Draw Texts
-----------------------------------------------------------------------------------------------------------------------------------------

function DrawText3D2(x, y, z, text, scale)
	if text then
		local onScreen, _x, _y = World3dToScreen2d(x, y, z)
		local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
		SetTextScale(scale, scale) SetTextFont(4)
		SetTextProportional(1)
		SetTextEntry("STRING")
		SetTextCentre(true)
		SetTextColour(255, 255, 255, 215) AddTextComponentString(text)
		DrawText(_x, _y)
		local factor = (string.len(text)) / 700
		DrawRect(_x, _y + 0.0150, 0.095 + factor, 0.03, 41, 11, 41, 100)
	end
end

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Create Blip
-----------------------------------------------------------------------------------------------------------------------------------------

function addBlip(x,y,z,idtype,idcolor,text,scale,set_route)
	if idtype ~= 0 then
		local blip = AddBlipForCoord(x,y,z)
		SetBlipSprite(blip,idtype)
		SetBlipAsShortRange(blip,true)
		SetBlipColour(blip,idcolor)
		SetBlipScale(blip,scale)

		if text then
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(text)
			EndTextCommandSetBlipName(blip)
		end

		if set_route then
			SetBlipRoute(blip,true)
		end
		return blip
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- spawnVehicle
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- spawnVehicle
-----------------------------------------------------------------------------------------------------------------------------------------

function spawnVehicle(name,x,y,z,h,veh_health,veh_fuel,blip_sprite,blip_color,blip_name,properties)
	local mhash = GetHashKey(name)
	while not HasModelLoaded(mhash) do
		print(name)
		RequestModel(mhash)
		Citizen.Wait(10)
	end

	if HasModelLoaded(mhash) then
		print("3")
		local veh = CreateVehicle(mhash,x,y,z+0.5,h,true,false)
		local netid = NetworkGetNetworkIdFromEntity(veh)
		SetVehicleHasBeenOwnedByPlayer(veh, true)
		SetNetworkIdCanMigrate(netid, true)
		SetVehicleNeedsToBeHotwired(veh, false)
		SetVehRadioStation(veh, 'OFF')
		SetModelAsNoLongerNeeded(model)

        SetVehicleNumberPlateText(veh, Lang[Config.lang]['vehicle_plate']..tostring(math.random(1000000, 9999999)))

		print("4")
		SetVehicleFuelLevel(veh,100.0)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
		DecorSetFloat(veh, "_FUEL_LEVEL", GetVehicleFuelLevel(veh))

		if properties then
			SetVehicleProperties(veh, json.decode(properties))
		end

		TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))

		print("5")
		SetVehicleEngineHealth(veh,veh_health+0.0)
		SetVehicleBodyHealth(veh,veh_health+0.0)
	
		local blip = addBlipForVehicle(veh,blip_sprite,blip_color,blip_name)

		print("6")
		return veh,blip
	end
end

function addBlipForVehicle(veh,blip_sprite,blip_color,blip_name)
	local blip = AddBlipForEntity(veh)
	SetBlipSprite(blip,blip_sprite)
	SetBlipColour(blip,blip_color)
	SetBlipAsShortRange(blip,false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(blip_name)
	EndTextCommandSetBlipName(blip)
	return blip
end


-----------------------------------------------------------------------------------------------------------------------------------------
-- Vehicle Tuning
-----------------------------------------------------------------------------------------------------------------------------------------

Trim = function(value)
	if not value then return nil end
	return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end
Round = function(value, numDecimalPlaces)
	if not numDecimalPlaces then return math.floor(value + 0.5) end
	local power = 10 ^ numDecimalPlaces
	return math.floor((value * power) + 0.5) / (power)
end

function GetPlate(vehicle)
	if vehicle == 0 then return end
	return Trim(GetVehicleNumberPlateText(vehicle))
end

function GetVehicleProperties(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}

		if GetIsVehiclePrimaryColourCustom(vehicle) then
			r, g, b = GetVehicleCustomPrimaryColour(vehicle)
			colorPrimary = { r, g, b }
		end

		if GetIsVehicleSecondaryColourCustom(vehicle) then
			r, g, b = GetVehicleCustomSecondaryColour(vehicle)
			colorSecondary = { r, g, b }
		end

		for extraId = 0, 12 do
			if DoesExtraExist(vehicle, extraId) then
				local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
				extras[tostring(extraId)] = state
			end
		end

		if GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) ~= -1 then
			modLivery = GetVehicleLivery(vehicle)
		else
			modLivery = GetVehicleMod(vehicle, 48)
		end

		return {
			model = GetEntityModel(vehicle),
			plate = GetPlate(vehicle),
			plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
			bodyHealth = Round(GetVehicleBodyHealth(vehicle)),
			engineHealth = Round(GetVehicleEngineHealth(vehicle)),
			tankHealth = Round(GetVehiclePetrolTankHealth(vehicle)),
			fuelLevel = Round(GetVehicleFuelLevel(vehicle)),
			dirtLevel = Round(GetVehicleDirtLevel(vehicle)),
			color1 = colorPrimary,
			color2 = colorSecondary,
			pearlescentColor = pearlescentColor,
			interiorColor = GetVehicleInteriorColor(vehicle),
			dashboardColor = GetVehicleDashboardColour(vehicle),
			wheelColor = wheelColor,
			wheels = GetVehicleWheelType(vehicle),
			windowTint = GetVehicleWindowTint(vehicle),
			xenonColor = GetVehicleXenonLightsColour(vehicle),
			neonEnabled = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},
			neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras = extras,
			tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
			modSpoilers = GetVehicleMod(vehicle, 0),
			modFrontBumper = GetVehicleMod(vehicle, 1),
			modRearBumper = GetVehicleMod(vehicle, 2),
			modSideSkirt = GetVehicleMod(vehicle, 3),
			modExhaust = GetVehicleMod(vehicle, 4),
			modFrame = GetVehicleMod(vehicle, 5),
			modGrille = GetVehicleMod(vehicle, 6),
			modHood = GetVehicleMod(vehicle, 7),
			modFender = GetVehicleMod(vehicle, 8),
			modRightFender = GetVehicleMod(vehicle, 9),
			modRoof = GetVehicleMod(vehicle, 10),
			modEngine = GetVehicleMod(vehicle, 11),
			modBrakes = GetVehicleMod(vehicle, 12),
			modTransmission = GetVehicleMod(vehicle, 13),
			modHorns = GetVehicleMod(vehicle, 14),
			modSuspension = GetVehicleMod(vehicle, 15),
			modArmor = GetVehicleMod(vehicle, 16),
			modTurbo = IsToggleModOn(vehicle, 18),
			modSmokeEnabled = IsToggleModOn(vehicle, 20),
			modXenon = IsToggleModOn(vehicle, 22),
			modFrontWheels = GetVehicleMod(vehicle, 23),
			modBackWheels = GetVehicleMod(vehicle, 24),
			modCustomTiresF = GetVehicleModVariation(vehicle, 23),
			modCustomTiresR = GetVehicleModVariation(vehicle, 24),
			modPlateHolder = GetVehicleMod(vehicle, 25),
			modVanityPlate = GetVehicleMod(vehicle, 26),
			modTrimA = GetVehicleMod(vehicle, 27),
			modOrnaments = GetVehicleMod(vehicle, 28),
			modDashboard = GetVehicleMod(vehicle, 29),
			modDial = GetVehicleMod(vehicle, 30),
			modDoorSpeaker = GetVehicleMod(vehicle, 31),
			modSeats = GetVehicleMod(vehicle, 32),
			modSteeringWheel = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate = GetVehicleMod(vehicle, 35),
			modSpeakers = GetVehicleMod(vehicle, 36),
			modTrunk = GetVehicleMod(vehicle, 37),
			modHydrolic = GetVehicleMod(vehicle, 38),
			modEngineBlock = GetVehicleMod(vehicle, 39),
			modAirFilter = GetVehicleMod(vehicle, 40),
			modStruts = GetVehicleMod(vehicle, 41),
			modArchCover = GetVehicleMod(vehicle, 42),
			modAerials = GetVehicleMod(vehicle, 43),
			modTrimB = GetVehicleMod(vehicle, 44),
			modTank = GetVehicleMod(vehicle, 45),
			modWindows = GetVehicleMod(vehicle, 46),
			modLivery = modLivery,
		}
	else
		return
	end
end

function SetVehicleProperties(vehicle, props)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleModKit(vehicle, 0)
		if props.plate then
			SetVehicleNumberPlateText(vehicle, props.plate)
		end
		if props.plateIndex then
			SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
		end
		if props.bodyHealth then
			SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
		end
		if props.engineHealth then
			SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
		end
		if props.fuelLevel then
			SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
		end
		if props.dirtLevel then
			SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
		end
		if props.color1 then
			if type(props.color1) == "number" then
				SetVehicleColours(vehicle, props.color1, colorSecondary)
			else
				SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
			end
		end
		if props.color2 then
			if type(props.color2) == "number" then
				if (type(props.color1) == "number") then
					SetVehicleColours(vehicle, props.color1, props.color2)
				else
					SetVehicleColours(vehicle, colorPrimary, props.color2)
				end
			else
				SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
			end
		end
		if props.pearlescentColor then
			SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
		end
		if props.interiorColor then
			SetVehicleInteriorColor(vehicle, props.interiorColor)
		end
		if props.dashboardColor then
			SetVehicleDashboardColour(vehicle, props.dashboardColor)
		end
		if props.wheelColor then
			SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
		end
		if props.wheels then
			SetVehicleWheelType(vehicle, props.wheels)
		end
		if props.windowTint then
			SetVehicleWindowTint(vehicle, props.windowTint)
		end
		if props.neonEnabled then
			SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
			SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
			SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
			SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
		end
		if props.extras then
			for id, enabled in pairs(props.extras) do
				if enabled then
					SetVehicleExtra(vehicle, tonumber(id), 0)
				else
					SetVehicleExtra(vehicle, tonumber(id), 1)
				end
			end
		end
		if props.neonColor then
			SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
		end
		if props.modSmokeEnabled then
			ToggleVehicleMod(vehicle, 20, true)
		end
		if props.tyreSmokeColor then
			SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
		end
		if props.modSpoilers then
			SetVehicleMod(vehicle, 0, props.modSpoilers, false)
		end
		if props.modFrontBumper then
			SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
		end
		if props.modRearBumper then
			SetVehicleMod(vehicle, 2, props.modRearBumper, false)
		end
		if props.modSideSkirt then
			SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
		end
		if props.modExhaust then
			SetVehicleMod(vehicle, 4, props.modExhaust, false)
		end
		if props.modFrame then
			SetVehicleMod(vehicle, 5, props.modFrame, false)
		end
		if props.modGrille then
			SetVehicleMod(vehicle, 6, props.modGrille, false)
		end
		if props.modHood then
			SetVehicleMod(vehicle, 7, props.modHood, false)
		end
		if props.modFender then
			SetVehicleMod(vehicle, 8, props.modFender, false)
		end
		if props.modRightFender then
			SetVehicleMod(vehicle, 9, props.modRightFender, false)
		end
		if props.modRoof then
			SetVehicleMod(vehicle, 10, props.modRoof, false)
		end
		if props.modEngine then
			SetVehicleMod(vehicle, 11, props.modEngine, false)
		end
		if props.modBrakes then
			SetVehicleMod(vehicle, 12, props.modBrakes, false)
		end
		if props.modTransmission then
			SetVehicleMod(vehicle, 13, props.modTransmission, false)
		end
		if props.modHorns then
			SetVehicleMod(vehicle, 14, props.modHorns, false)
		end
		if props.modSuspension then
			SetVehicleMod(vehicle, 15, props.modSuspension, false)
		end
		if props.modArmor then
			SetVehicleMod(vehicle, 16, props.modArmor, false)
		end
		if props.modTurbo then
			ToggleVehicleMod(vehicle, 18, props.modTurbo)
		end
		if props.modXenon then
			ToggleVehicleMod(vehicle, 22, props.modXenon)
		end
		if props.xenonColor then
			SetVehicleXenonLightsColor(vehicle, props.xenonColor)
		end
		if props.modFrontWheels then
			SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
		end
		if props.modBackWheels then
			SetVehicleMod(vehicle, 24, props.modBackWheels, false)
		end
		if props.modCustomTiresF then
			SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
		end
		if props.modCustomTiresR then
			SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
		end
		if props.modPlateHolder then
			SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
		end
		if props.modVanityPlate then
			SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
		end
		if props.modTrimA then
			SetVehicleMod(vehicle, 27, props.modTrimA, false)
		end
		if props.modOrnaments then
			SetVehicleMod(vehicle, 28, props.modOrnaments, false)
		end
		if props.modDashboard then
			SetVehicleMod(vehicle, 29, props.modDashboard, false)
		end
		if props.modDial then
			SetVehicleMod(vehicle, 30, props.modDial, false)
		end
		if props.modDoorSpeaker then
			SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
		end
		if props.modSeats then
			SetVehicleMod(vehicle, 32, props.modSeats, false)
		end
		if props.modSteeringWheel then
			SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
		end
		if props.modShifterLeavers then
			SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
		end
		if props.modAPlate then
			SetVehicleMod(vehicle, 35, props.modAPlate, false)
		end
		if props.modSpeakers then
			SetVehicleMod(vehicle, 36, props.modSpeakers, false)
		end
		if props.modTrunk then
			SetVehicleMod(vehicle, 37, props.modTrunk, false)
		end
		if props.modHydrolic then
			SetVehicleMod(vehicle, 38, props.modHydrolic, false)
		end
		if props.modEngineBlock then
			SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
		end
		if props.modAirFilter then
			SetVehicleMod(vehicle, 40, props.modAirFilter, false)
		end
		if props.modStruts then
			SetVehicleMod(vehicle, 41, props.modStruts, false)
		end
		if props.modArchCover then
			SetVehicleMod(vehicle, 42, props.modArchCover, false)
		end
		if props.modAerials then
			SetVehicleMod(vehicle, 43, props.modAerials, false)
		end
		if props.modTrimB then
			SetVehicleMod(vehicle, 44, props.modTrimB, false)
		end
		if props.modTank then
			SetVehicleMod(vehicle, 45, props.modTank, false)
		end
		if props.modWindows then
			SetVehicleMod(vehicle, 46, props.modWindows, false)
		end
		if props.modLivery then
			SetVehicleMod(vehicle, 48, props.modLivery, false)
			SetVehicleLivery(vehicle, props.modLivery)
		end
	end
end