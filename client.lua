local menu_active = false
local cooldown = nil
local fishing_location_id;
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
-----------------------------------------------------------------------------------------------------------------------------------------	

-- Main menu locations
Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	local timer = 2
	while true do
		timer = 3000
		for k,mark in pairs(Config.fishing_locations) do
			local x,y,z = table.unpack(mark.menu_location)
			local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
			if not menu_active and distance <= 20.0 then
				timer = 2
				DrawMarker(21,x,y,z-0.6,0,0,0,0.0,0,0,0.5,0.5,0.4,255,0,0,50,0,0,0,1)
				if distance <= 2.0 then
					DrawText3D2(x,y,z-0.6, Lang[Config.lang]['open'], 0.40)
					if IsControlJustPressed(0,38) then
						fishing_location_id = k
						TriggerServerEvent("qb_fishing_life:getData",fishing_location_id)
					end
				end
			end
		end
		Citizen.Wait(timer)
	end
end)

-- Properties locations
RegisterNetEvent('qb_fishing_life:setPropertiesBlips')
AddEventHandler('qb_fishing_life:setPropertiesBlips', function(data)
	local user_id = data.user_id
	Citizen.CreateThread(function()
		SetNuiFocus(false,false)
		local timer = 2
		while true do
			timer = 3000
			for k,property in pairs(data) do
				if(property.user_id == property.original_user_id) then
					local x,y,z = table.unpack(Config.available_items_store.property[property.property].location)
					print_table(Config.available_items_store.property[property.property].location)
					local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
					if not menu_active and distance <= 20.0 then
						timer = 2
						DrawMarker(21,x,y,z-0.6,0,0,0,0.0,0,0,0.5,0.5,0.4,255,0,0,50,0,0,0,1)
						if distance <= 2.0 then
							DrawText3D2(x,y,z-0.6, Lang[Config.lang]['open'], 0.40)
							if IsControlJustPressed(0,38) then
								fishing_property_id = property.property
								TriggerServerEvent("qb_fishing_life:getDataProperty",fishing_property_id)
							end
						end
					end
				end
			end
			Citizen.Wait(timer)
		end
	end)
end)

RegisterNetEvent('qb_fishing_life:open')
AddEventHandler('qb_fishing_life:open', function(data,isUpdate)
	SendNUIMessage({ 
		openOwnerUI = true,
		isUpdate = isUpdate,
		data = data,
		resourceName = GetCurrentResourceName()
	})
	if isUpdate == false then
		menu_active = true
		SetNuiFocus(true,true)
	end
end)


RegisterNetEvent('qb_fishing_life:openProperty')
AddEventHandler('qb_fishing_life:openProperty', function(data,property)
	SendNUIMessage({ 
		openPropertyUI = true,
		property = property,
		data = data,
		resourceName = GetCurrentResourceName()
	})
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
ServerCallbacks = {}
CurrentRequestId = 0
RegisterNetEvent('qb_fishing_life:serverCallback')
AddEventHandler('qb_fishing_life:serverCallback', function(requestId, ...)
	ServerCallbacks[requestId](...)
	ServerCallbacks[requestId] = nil
end)
TriggerServerCallback = function(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb

	TriggerServerEvent('qb_fishing_life:triggerServerCallback', name, CurrentRequestId, ...)

	if CurrentRequestId < 65535 then
		CurrentRequestId = CurrentRequestId + 1
	else
		CurrentRequestId = 0
	end
end

RegisterNUICallback('post', function(data, cb)
	if cooldown == nil then
		cooldown = true
		
		if data.event == "close" then
			closeUI()
		else
			TriggerServerEvent('qb_fishing_life:'..data.event,fishing_location_id,data.data)
		end
		cb()

		SetTimeout(500,function()
			cooldown = nil
		end)
	end
end)

function closeUI()
	fishing_id = nil
	menu_active = false
	SetNuiFocus(false,false)
	SendNUIMessage({ hidemenu = true })
end

RegisterNetEvent('qb_fishing_life:closeUI')
AddEventHandler('qb_fishing_life:closeUI', function()
	closeUI()
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- addBlipProperty
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    Wait(5000)
    TriggerServerEvent("qb_fishing_life:getProperties")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local route_blip
RegisterNetEvent('qb_fishing_life:startContract')
AddEventHandler('qb_fishing_life:startContract', function(contract_data)
	closeUI()
	
	contract_data.delivery_location = json.decode(contract_data.delivery_location)
	local x,y,z = table.unpack(contract_data.delivery_location)

	route_blip = addBlip(x,y,z,1,5,Lang[Config.lang]['contract_destination_blip'],1.0,true)

	local timer
	while DoesBlipExist(route_blip) do
		timer = 3000
		local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
		if distance <= 20.0 then
			timer = 2
			DrawMarker(21,x,y,z-0.6,0,0,0,0.0,0,0,0.5,0.5,0.4,255,0,0,50,0,0,0,1)
			if distance <= 2.0 then
				DrawText3D2(x,y,z-0.6, Lang[Config.lang]['contract_finish_delivery'], 0.40)
				if IsControlJustPressed(0,38) then
					TriggerServerEvent("qb_fishing_life:finishContract")
				end
			end
		end
		Citizen.Wait(timer)
	end
end)

RegisterNetEvent('qb_fishing_life:cancelContract')
AddEventHandler('qb_fishing_life:cancelContract', function()
	RemoveBlip(route_blip)
end)

RegisterNetEvent('qb_fishing_life:viewLocation')
AddEventHandler('qb_fishing_life:viewLocation', function(location)
	closeUI()
	SetNewWaypoint(location[1],location[2])
end)

local update_vehicle_status = 0
RegisterNetEvent('qb_fishing_life:spawnVehicle')
AddEventHandler('qb_fishing_life:spawnVehicle', function(vehicle_data,garage_to_spawn)
	if IsEntityAVehicle(vehicle) then
		TriggerEvent("qb_fishing_life:Notify","negado",Lang[Config.lang]['vehicle_already_spawned'])
		return
	end

	closeUI()

	local i = #garage_to_spawn
	local x,y,z,h
	while i > 0 do
		x,y,z,h = table.unpack(garage_to_spawn[i])
		local checkPos = IsSpawnPointClear({['x']=x,['y']=y,['z']=z},3.001)
		if checkPos == false then
			if i <= 1 then
				TriggerEvent("qb_fishing_life:Notify","negado",Lang[Config.lang]['occupied_places'])
				return
			end
		else
			break
		end
		i = i - 1
	end
	
	vehicle,vehicle_blip = spawnVehicle(vehicle_data.vehicle,x,y,z,h,vehicle_data.health,vehicle_data.fuel,Config.vehicle_blips.sprite,Config.vehicle_blips.color,Lang[Config.lang]['vehicle_blip'],vehicle_data.properties)
	TriggerEvent("qb_fishing_life:Notify","sucesso",Lang[Config.lang]['vehicle_spawned'])

	local timer = 2
	local engine_health = GetVehicleEngineHealth(vehicle)
	local vehicle_fuel = GetVehicleFuelLevel(vehicle)
	local body_health = GetVehicleBodyHealth(vehicle)
	
	while IsEntityAVehicle(vehicle) do
		timer = 2000
		local coords = GetEntityCoords(vehicle)
		if oldpos ~= nil then
			local dist = #(coords - oldpos)
			vehicle_data.traveled_distance = vehicle_data.traveled_distance + dist
			local ped = PlayerPedId()
			veh = GetVehiclePedIsIn(ped,false)
			if veh == vehicle then
				for k,mark in pairs(garage_to_spawn) do
					local x,y,z = table.unpack(mark)
					local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
					if distance <= 20.0 then
						timer = 2
						DrawMarker(21,x,y,z,0,0,0,0.0,0,0,1.0,1.0,1.0,255,0,0,50,0,0,0,1)
						if distance <= 2.0 then
							drawTxt(Lang[Config.lang]['press_e_to_store_vehicle'], 8,0.5,0.95,0.50,255,255,255,180)
							if IsControlJustPressed(0,38) and IsEntityAVehicle(vehicle) then
								TriggerServerEvent("qb_fishing_life:updateVehicleStatus",vehicle_data,GetVehicleEngineHealth(vehicle),GetVehicleBodyHealth(vehicle),GetVehicleFuelLevel(vehicle),GetVehicleProperties(vehicle))
								DeleteVehicle(vehicle)
								RemoveBlip(vehicle_blip)
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
				TriggerServerEvent("qb_fishing_life:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel,GetVehicleProperties(vehicle))
			end
		end
		oldpos = coords
		Citizen.Wait(timer)
	end
	DeleteEntity(vehicle)
	RemoveBlip(vehicle_blip)
	TriggerEvent("qb_fishing_life:Notify","negado",Lang[Config.lang]['vehicle_lost'])
	TriggerServerEvent("qb_fishing_life:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel)
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

-----------------------------------------------------------------------------------------------------------------------------------------
-- IsSpawnPointClear
-----------------------------------------------------------------------------------------------------------------------------------------

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

GetVehiclesInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(GetVehicles(), false, coords, maxDistance) end
IsSpawnPointClear = function(coords, maxDistance) return #GetVehiclesInArea(coords, maxDistance) == 0 end

-----------------------------------------------------------------------------------------------------------------------------------------
-- debug
-----------------------------------------------------------------------------------------------------------------------------------------
function print_table(node)
	if type(node) == "table" then
		-- to make output beautiful
		local function tab(amt)
			local str = ""
			for i=1,amt do
				str = str .. "\t"
			end
			return str
		end
	
		local cache, stack, output = {},{},{}
		local depth = 1
		local output_str = "{\n"
	
		while true do
			local size = 0
			for k,v in pairs(node) do
				size = size + 1
			end
	
			local cur_index = 1
			for k,v in pairs(node) do
				if (cache[node] == nil) or (cur_index >= cache[node]) then
				
					if (string.find(output_str,"}",output_str:len())) then
						output_str = output_str .. ",\n"
					elseif not (string.find(output_str,"\n",output_str:len())) then
						output_str = output_str .. "\n"
					end
	
					-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
					table.insert(output,output_str)
					output_str = ""
				
					local key
					if (type(k) == "number" or type(k) == "boolean") then
						key = "["..tostring(k).."]"
					else
						key = "['"..tostring(k).."']"
					end
	
					if (type(v) == "number" or type(v) == "boolean") then
						output_str = output_str .. tab(depth) .. key .. " = "..tostring(v)
					elseif (type(v) == "table") then
						output_str = output_str .. tab(depth) .. key .. " = {\n"
						table.insert(stack,node)
						table.insert(stack,v)
						cache[node] = cur_index+1
						break
					else
						output_str = output_str .. tab(depth) .. key .. " = '"..tostring(v).."'"
					end
	
					if (cur_index == size) then
						output_str = output_str .. "\n" .. tab(depth-1) .. "}"
					else
						output_str = output_str .. ","
					end
				else
					-- close the table
					if (cur_index == size) then
						output_str = output_str .. "\n" .. tab(depth-1) .. "}"
					end
				end
	
				cur_index = cur_index + 1
			end
	
			if (#stack > 0) then
				node = stack[#stack]
				stack[#stack] = nil
				depth = cache[node] == nil and depth + 1 or depth - 1
			else
				break
			end
		end
	
		-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
		table.insert(output,output_str)
		output_str = table.concat(output)
	
		print(output_str)
	else
		print(node)
	end
end