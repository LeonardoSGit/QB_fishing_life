Utils = exports['lc_utils']:GetUtils()
local cooldown = {}
local is_open = {}
local started = {}
local startedDive = {}

local vehicle_spawned = {}
function sendInternalWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

local version = '1.0.0'
local utils_required_version = '1.0.2'
local subversion = ''
local script = 3
local connected = false
local testserver = false
local cont = 0
local vrp_ready = true
Citizen.CreateThread(function()
	Wait(5000)
	if Config.create_table then
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_available_contracts` (
				`id` INT(11) NOT NULL AUTO_INCREMENT,
				`name` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`description` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`image` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`required_items` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`money_reward` INT(11) NULL DEFAULT NULL,
				`item_reward` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
				`delivery_location` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_general_ci',
				`progress` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
				`timestamp` INT(11) NOT NULL,
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_loans` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`loan` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`remaining_amount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`day_cost` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`taxes_on_day` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`timer` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_users` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`stock_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`boats_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`vehicles_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`properties_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`sea_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`lake_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`swan_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`windlass_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`rod_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`bait_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`gimp_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`money` INT(11) NOT NULL DEFAULT '0',
				`exp` INT(11) NOT NULL DEFAULT '0',
				`skill_points` INT(11) NOT NULL DEFAULT '0',
				`dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				PRIMARY KEY (`user_id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_vehicles` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`properties` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
				`traveled_distance` INT(11) UNSIGNED NOT NULL DEFAULT '0',
				`health` INT(11) UNSIGNED NOT NULL DEFAULT '1000',
				`fuel` INT(11) UNSIGNED NOT NULL DEFAULT '100',
				`type` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `fishing_life_vehicle` (`user_id`, `vehicle`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])		
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_properties` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`property` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`properties` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
				`stock` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
				`property_condition`  INT(11) UNSIGNED NOT NULL DEFAULT '100',
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `fishing_life_vehicle` (`user_id`, `property`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
	end
	local sql = "UPDATE `fishing_available_contracts` SET progress = NULL";
	Utils.Database.execute(sql, {});
	local sql = "UPDATE `fishing_available_dives` SET progress = NULL";
	Utils.Database.execute(sql, {});
	-- Wait(2000)
	-- print("^2["..GetCurrentResourceName().."] "..dec("QXV0aGVudGljYXRlZCEgU3VwcG9ydCBkaXNjb3JkOiBodHRwczovL2Rpc2NvcmQuZ2cvVTVZRGdiaF43").." ^3[v"..version..subversion.."]^7")
	-- while not connected do
	-- 	cont = cont + 1
	-- 	PerformHttpRequest(dec("aHR0cDovL3Byb2pldG9jaGFybW9zby5jb206MzAwMC9hcGkvY2hlY2stdmVyc2lvbj8=").."script="..script.."&version="..version, function(err, ip, headers)
	-- 		if err == 200 and ip then
	-- 			connected = true
	-- 			local arr_ip = json.decode(ip)
	-- 			if arr_ip[1] == true then
	-- 				if arr_ip[3] and Config.receive_update_messages ~= false then
	-- 					print("^4["..GetCurrentResourceName().."] "..dec("QW4gdXBkYXRlIGlzIGF2YWlsYWJsZSwgZG93bmxvYWQgaXQgaW4geW91ciBrZXltYXN0ZXJeNw==").." ^3[v"..arr_ip[4].."]^7")
	-- 					print("^4"..arr_ip[3].."^7")
	-- 				end
	-- 			end
	-- 		end

	-- 	end, "GET", "", {})
	-- 	if connected == false and cont > 5 then
	-- 		break
	-- 	end
	-- 	Wait(10000)
	-- end
end)

AddEventHandler('playerDropped', function(reason)
	local source = source
	if started[source] then
		local sql = "UPDATE `fishing_available_contracts` SET progress = NULL WHERE id = @id;";
		Utils.Database.execute(sql, {['@id'] = started[source].id});
		local sql = "UPDATE `fishing_available_dives` SET progress = NULL WHERE id = @id;";
		Utils.Database.execute(sql, {['@id'] = startedDive[source].id});
		started[source] = nil
	end
	is_open[source] = nil
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENT CALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------

ServerCallbacks           = {}
RegisterServerEvent('lc_fishing_life:triggerServerCallback')
AddEventHandler('lc_fishing_life:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('lc_fishing_life:serverCallback', playerId, requestId, ...)
	end, ...)
end)

RegisterServerCallback = function(name, cb)
	ServerCallbacks[name] = cb
end

TriggerServerCallback = function(name, requestId, source, cb, ...)
	if ServerCallbacks[name] then
		ServerCallbacks[name](source, cb, ...)
	else
		print(('['..GetCurrentResourceName()..'] [^3WARNING^7] Server callback "%s" does not exist. Make sure that the server sided file really is loading, an error in that file might cause it to not load.'):format(name))
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	Citizen.Wait(10000)
	while vrp_ready == nil do Wait(100) end

	while true do
		local contract_id = math.random(1,#Config.available_contracts.contracts)
		local contract = Config.available_contracts.contracts[contract_id]

		local money_reward = nil
		local item_reward = nil
		if contract.reward.money_min then
			money_reward = math.random(contract.reward.money_min,contract.reward.money_max)
		else
			item_reward = json.encode(contract.reward)
		end

		local sql = "SELECT COUNT(id) as qtd FROM fishing_available_contracts";
		local count = Utils.Database.fetchAll(sql, {})[1].qtd;
		
		if tonumber(count) >= Config.available_contracts.definitions.max_contracts then
			local sql = "SELECT MIN(id) as min FROM fishing_available_contracts WHERE progress IS NULL";
			local min = Utils.Database.fetchAll(sql, {})[1].min;
			
			local sql = "DELETE FROM `fishing_available_contracts` WHERE id = @id;";
			Utils.Database.execute(sql, {['@id'] = min});
		end

		local location = Config.delivery_locations[math.random(#Config.delivery_locations)]
		local sql = "INSERT INTO `fishing_available_contracts` (name, description, image, required_items, money_reward, item_reward, delivery_location, timestamp) VALUE (@name, @description, @image, @required_items, @money_reward, @item_reward, @delivery_location, @timestamp)";
		Utils.Database.execute(sql, {['@name'] = contract.name, ['@description'] = contract.description, ['@image'] = contract.image, ['@required_items'] = json.encode(contract.required_items), ['@money_reward'] = money_reward, ['@item_reward'] = item_reward, ['@delivery_location'] = json.encode(location), ['@timestamp'] = os.time()});

		Wait(1000*60*Config.available_contracts.definitions.time_to_new_contracts)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(10000)
	while vrp_ready == nil do Wait(100) end

	while true do
		local dive_id = math.random(1,#Config.available_dives['dives'])
		local dive = Config.available_dives.dives[dive_id]

		local money_reward = nil
		local item_reward = nil
		if dive.reward.money_min then
			money_reward = math.random(dive.reward.money_min,dive.reward.money_max)
		else
			item_reward = json.encode(dive.reward)
		end

		local sql = "SELECT COUNT(id) as qtd FROM fishing_available_dives";
		local count = Utils.Database.fetchAll(sql, {})[1].qtd;
		
		if tonumber(count) >= Config.available_dives.definitions.max_dives then
			local sql = "SELECT MIN(id) as min FROM fishing_available_dives WHERE progress IS NULL";
			local min = Utils.Database.fetchAll(sql, {})[1].min;
			
			local sql = "DELETE FROM `fishing_available_dives` WHERE id = @id;";
			Utils.Database.execute(sql, {['@id'] = min});
		end

		local location = dive.location
		local sql = "INSERT INTO `fishing_available_dives` (name, description, image, money_reward, item_reward, dive_location, timestamp) VALUE (@name, @description, @image, @money_reward, @item_reward, @dive_location, @timestamp)";
		Utils.Database.execute(sql, {['@name'] = dive.name, ['@description'] = dive.description, ['@image'] = dive.image,  ['@money_reward'] = money_reward, ['@item_reward'] = item_reward, ['@dive_location'] = json.encode(location), ['@timestamp'] = os.time()});

		Wait(1000*60*Config.available_dives.definitions.time_to_new_dives)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(10000)
	while vrp_ready == nil do Wait(100) end

	while true do
		local sql = "SELECT * FROM `fishing_life_properties`";
		local query = Utils.Database.fetchAll(sql)
		for k,v in pairs(query) do
				if v.property_condition < 1 then
					local sql = "DELETE from `fishing_life_properties` where user_id=@user_id and property = @property "
					Utils.Database.execute(sql, {['@user_id'] = v.user_id, ['@property'] = v.property});
				elseif v.property_condition < 10 then
					local source = Utils.Framework.getPlayerSource(v.user_id)
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('will_lose_property'):format(v.property))
					local sql = " UPDATE `fishing_life_properties` SET property_condition = property_condition - 1 where user_id=@user_id and property = @property"
					Utils.Database.execute(sql,{['@user_id'] = v.user_id, ['@property'] = v.property})
				else
					local sql = " UPDATE `fishing_life_properties` SET property_condition = property_condition - 1 where user_id=@user_id and property = @property"
					Utils.Database.execute(sql,{['@user_id'] = v.user_id, ['@property'] = v.property})
				end
		end
		Wait(1000*60*Config.time_degradate_property)
	end
end)

RegisterServerEvent("lc_fishing_life:getData")
AddEventHandler("lc_fishing_life:getData",function(key)
	if vrp_ready then
		local source = source
		Wrapper(source,function(user_id)
			openUI(source,key,false)
		end)
	end
end)

RegisterServerEvent("lc_fishing_life:getDataProperty")
AddEventHandler("lc_fishing_life:getDataProperty",function(property)
	if vrp_ready then
		local source = source
		Wrapper(source,function(user_id)
			openPropertyUI(source,property,user_id)
		end)
	end
end)

RegisterServerEvent("lc_fishing_life:startContract")
AddEventHandler("lc_fishing_life:startContract",function(key,data)
	local source = source
	Wrapper(source,function(user_id)
		local sql = "SELECT * FROM `fishing_available_contracts` WHERE id = @id";
		local query_contract = Utils.Database.fetchAll(sql,{['@id'] = data.contract_id})[1];
		if not query_contract then
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('contract_invalid'))
			return
		end

		if query_contract.progress ~= nil then
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('contract_someone_already_started'))
			return
		end

		if started[source] then
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('contract_already_started'))
			return
		end

		started[source] = query_contract
		local sql = "UPDATE `fishing_available_contracts` SET progress = @user_id WHERE id = @id";
		Utils.Database.execute(sql, {['@user_id'] = user_id, ['@id'] = started[source].id});
		TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('contract_started'))
		TriggerClientEvent("lc_fishing_life:startContract",source,query_contract)
	end)
end)

RegisterServerEvent("lc_fishing_life:finishContract")
AddEventHandler("lc_fishing_life:finishContract",function()
	local source = source
	Wrapper(source,function(user_id)
		if not started[source] then
			return
		end

		local required_items = json.decode(started[source].required_items)
		local missing_items = ""
		local is_missing = false
		for k,v in pairs(required_items) do
			if not Utils.Framework.playerHasItem(source,v.name,v.amount) then
				is_missing = true
				if missing_items == "" then
					missing_items = v.amount .. "x " .. v.display_name
				else
					missing_items = missing_items .. ", " .. v.amount .. "x " .. v.display_name
				end
			end
		end
		
		if is_missing then
			TriggerClientEvent('lc_fishing_life:Notify', source, "error", Utils.translate('contract_not_enough_items'):format(missing_items))
			return
		end
		
		if started[source].money_reward then
			giveFisherMoney(user_id,started[source].money_reward)
			TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('contract_received_money'):format(started[source].money_reward))
		else
			local item_reward = json.decode(started[source].item_reward)
			if Utils.Framework.givePlayerItem(source,item_reward.item,item_reward.amount) then
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('contract_received_item'):format(item_reward.amount,item_reward.display_name))
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('contract_received_item_error'):format(item_reward.amount,item_reward.display_name))
				return
			end
		end

		local sql = "DELETE FROM `fishing_available_contracts` WHERE id = @id";
		Utils.Database.execute(sql, {['@id'] = started[source].id});
		TriggerClientEvent("lc_fishing_life:cancelContract",source)
		started[source] = nil
	end)
end)

RegisterServerEvent("lc_fishing_life:cancelContract")
AddEventHandler("lc_fishing_life:cancelContract",function()
	local source = source
	Wrapper(source,function(user_id)
		if not started[source] then
			return
		end

		local sql = "UPDATE `fishing_available_contracts` SET progress = NULL WHERE id = @id";
		Utils.Database.execute(sql, {['@id'] = started[source].id});
		TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('contract_cancel'))
		TriggerClientEvent("lc_fishing_life:cancelContract",source)
		started[source] = nil
		openUI(source,nil,true)
	end)
end)



RegisterServerEvent("lc_fishing_life:startDive")
AddEventHandler("lc_fishing_life:startDive",function(key,data)
	local source = source
	Wrapper(source,function(user_id)
		local sql = "SELECT * FROM `fishing_available_dives` WHERE id = @id";
		local query_dive = Utils.Database.fetchAll(sql,{['@id'] = data.dive_id})[1];
		if not query_dive then
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('dive_invalid'))
			return
		end

		if query_dive.progress ~= nil then
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('dive_someone_already_started'))
			return
		end

		if startedDive[source] then
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('dive_already_started'))
			return
		end

		startedDive[source] = query_dive
		local sql = "UPDATE `fishing_available_dives` SET progress = @user_id WHERE id = @id";
		Utils.Database.execute(sql, {['@user_id'] = user_id, ['@id'] = startedDive[source].id});
		TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('dive_started'))
		TriggerClientEvent("lc_fishing_life:startDive",source,query_dive)
	end)
end)

RegisterServerEvent("lc_fishing_life:finishDive")
AddEventHandler("lc_fishing_life:finishDive",function()
	local source = source
	Wrapper(source,function(user_id)
		if not startedDive[source] then
			return
		end
		
		if startedDive[source].money_reward then
			giveFisherMoney(user_id,startedDive[source].money_reward)
			TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('dive_received_money'):format(startedDive[source].money_reward))
		else
			local item_reward = json.decode(startedDive[source].item_reward)
			if Utils.Framework.givePlayerItem(source,item_reward.item,item_reward.amount) then
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('dive_received_item'):format(item_reward.amount,item_reward.display_name))
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('dive_received_item_error'):format(item_reward.amount,item_reward.display_name))
				return
			end
		end

		local sql = "DELETE FROM `fishing_available_dives` WHERE id = @id";
		Utils.Database.execute(sql, {['@id'] = startedDive[source].id});
		TriggerClientEvent("lc_fishing_life:cancelDive",source)
		started[source] = nil
	end)
end)

RegisterServerEvent("lc_fishing_life:cancelDive")
AddEventHandler("lc_fishing_life:cancelDive",function()
	local source = source
	Wrapper(source,function(user_id)
		Utils.Debug.printTable(startedDive)
		if not startedDive[source] then
			return
		end

		local sql = "UPDATE `fishing_available_dives` SET progress = NULL WHERE id = @id";
		Utils.Database.execute(sql, {['@id'] = startedDive[source].id});
		TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('dive_cancel'))
		TriggerClientEvent("lc_fishing_life:cancelDive",source)
		started[source] = nil
		openUI(source,nil,true)
	end)
end)

RegisterServerEvent("lc_fishing_life:buyUpgrade")
AddEventHandler("lc_fishing_life:buyUpgrade",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local level = tonumber(data.level) or 0
		local upgrade = Config.upgrades[data.upgrade_type]
		local sql = "SELECT * FROM `fishing_life_users` WHERE user_id = @user_id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});
		if upgrade and level and level > 0 and query and query[1] and tonumber(query[1][data.upgrade_type..'_upgrade']) == (level - 1) then
			if query[1].skill_points >= upgrade[level].points_required then
				local sql = "UPDATE `fishing_life_users` SET " ..data.upgrade_type.. "_upgrade = @level , skill_points = skill_points - 1  WHERE user_id = @user_id";
				Utils.Database.execute(sql, {['@user_id'] = user_id, ['@level'] = level});
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('upgrade_purchased'))
				openUI(source,key,true)
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_skill_points'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('invalid_value'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:buyEquipment")
AddEventHandler("lc_fishing_life:buyEquipment",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local level = tonumber(data.level) or 0
		local equipment = Config.equipments_upgrades[data.equipment_type]
		local sql = "SELECT * FROM `fishing_life_users` WHERE user_id = @user_id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});
		if equipment and level and level > 0 and query and query[1] and tonumber(query[1][data.equipment_type..'_upgrade']) == (level - 1) then
			if tryGetFisherMoney(user_id,data.price) then
				local sql = "UPDATE `fishing_life_users` SET " ..data.equipment_type.. "_upgrade = @level  WHERE user_id = @user_id";
				Utils.Database.execute(sql, {['@user_id'] = user_id, ['@level'] = level});
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('upgrade_purchased'))
				openUI(source,key,true)
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_money'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('invalid_value'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:viewLocation")
AddEventHandler("lc_fishing_life:viewLocation",function(key,data)
	local source = source
	Wrapper(source,function(user_id)
		local sql = "SELECT delivery_location FROM `fishing_available_contracts` WHERE id = @id";
		local query_contract = Utils.Database.fetchAll(sql,{['@id'] = data.contract_id})[1];
		if query_contract then
			TriggerClientEvent("lc_fishing_life:viewLocation",source,json.decode(query_contract.delivery_location))
			TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('contract_waypoint_set'))
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('contract_invalid'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:viewPropertyLocation")
AddEventHandler("lc_fishing_life:viewPropertyLocation",function(key,data)
	local source = source
	Wrapper(source,function(user_id)
		local property_location = Config.available_items_store.property[data.property_id].location
		if property_location then
			TriggerClientEvent("lc_fishing_life:viewLocation",source,json.decode(json.decode(property_location)))
			TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('contract_waypoint_set'))
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('contract_invalid'))
		end
	end)
end)


RegisterServerEvent("lc_fishing_life:buyVehicle")
AddEventHandler("lc_fishing_life:buyVehicle",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local price = Config.available_items_store[data.type][data.vehicle_id].price
		local sql = "SELECT * FROM `fishing_life_vehicles` WHERE user_id = @user_id and type = @type";		
		local owned_vehicles = Utils.Database.fetchAll(sql,{['@user_id'] = user_id, ['@type'] = data.type});
		local sql = "SELECT " ..data.type.. "s_upgrade FROM `fishing_life_users` WHERE user_id = @user_id";		
		local level = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
		if Config.upgrades[data.type .. 's'][level[data.type.. "s_upgrade"]].level_reward > Utils.Table.tableLength(owned_vehicles) then
			if beforeBuyVehicle(source,data.vehicle_id,price,user_id) then
				if tryGetFisherMoney(user_id,price) then
					local sql = "INSERT INTO `fishing_life_vehicles` (user_id, vehicle, properties, type) VALUES (@user_id, @vehicle, @properties, @type);";
					Utils.Database.execute(sql, {['@user_id'] = user_id, ['@vehicle'] = data.vehicle_id, ['@properties'] = json.encode({}),['@type'] = data.type});
					TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('item_purchased'):format(data.type))
					Utils.Webhook.sendWebhookMessage(WebhookURL,Utils.translate('logs_buy_vehicle'):format(user_id,data.vehicle_id,price,Utils.Framework.getPlayerIdLog(source)..os.date("\n["..Utils.translate('logs_date').."]: %d/%m/%Y ["..Utils.translate('logs_hour').."]: %H:%M:%S")))
					openUI(source,key,true)
				else
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_money'))
				end
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('garage_full'))
		end
	end)
end)


RegisterServerEvent("lc_fishing_life:repairVehicle")
AddEventHandler("lc_fishing_life:repairVehicle",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local sql = "SELECT health, vehicle, type FROM `fishing_life_vehicles` WHERE user_id = @user_id AND id = @id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id, ['@id'] = data.vehicle_id});
		if query and query[1] then
			if query[1].health < 900 then
				if query[1].health < 0 then query[1].health = 0 end
				local remaining_health = math.floor((1000 - query[1].health)/10)
				local vehicle = Config.available_items_store[query[1].type][query[1].vehicle]
				if vehicle then
					local total_repair_price = vehicle.repair_price*remaining_health
					if tryGetFisherMoney(user_id,total_repair_price) then
						local sql = "UPDATE `fishing_life_vehicles` SET health = 1000 WHERE user_id = @user_id AND id = @id";
						Utils.Database.execute(sql, {['@user_id'] = user_id, ['@id'] = data.vehicle_id});
						TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('vehicle_repaired'))
						openUI(source,key,true)
					else
						TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_funds'))
					end
				else
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
				end
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_already_repaired'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:refuelVehicle")
AddEventHandler("lc_fishing_life:refuelVehicle",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local sql = "SELECT fuel, vehicle, type  FROM `fishing_life_vehicles` WHERE user_id = @user_id AND id = @id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id, ['@id'] = data.vehicle_id});
		if query and query[1] then
			if query[1].fuel < 90 then
				if query[1].fuel < 0 then query[1].fuel = 0 end
				local remaining_fuel = math.floor(100 - query[1].fuel)
				local vehicle = Config.available_items_store[query[1].type][query[1].vehicle]
				if vehicle then
					local total_refuel_price = vehicle.refuel_price*remaining_fuel
					if tryGetFisherMoney(user_id,total_refuel_price) then
						local sql = "UPDATE `fishing_life_vehicles` SET fuel = 100 WHERE user_id = @user_id AND id = @id";
						Utils.Database.execute(sql, {['@user_id'] = user_id, ['@id'] = data.vehicle_id});
						TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('vehicle_refueled'))
						openUI(source,key,true)
					else
						TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_funds'))
					end
				else
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
				end
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_already_refueled'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:spawnVehicle")
AddEventHandler("lc_fishing_life:spawnVehicle",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local sql = "SELECT * FROM `fishing_life_vehicles` WHERE user_id = @user_id AND id = @id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id, ['@id'] = data.vehicle_id});
		if query and query[1] then
			if not vehicle_spawned[data.vehicle_id] then
				if query[1].health > 200 then
					local vehicle = Config.available_items_store[query[1].type][query[1].vehicle]
					if vehicle then
						if query[1].type == 'vehicle' then
							TriggerClientEvent("lc_fishing_life:spawnVehicle",source,query[1],Config.fishing_locations[key].garage_locations)
						else
							TriggerClientEvent("lc_fishing_life:spawnVehicle",source,query[1],Config.fishing_locations[key].boat_garage_locations)
						end
					else
						TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
					end
				else
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_damaged'))
				end
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_already_spawned'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:setVehicleSpawned")
AddEventHandler("lc_fishing_life:setVehicleSpawned",function(vehicle_id,despawn)
	if despawn then
		vehicle_spawned[vehicle_id] = nil
	else
		vehicle_spawned[vehicle_id] = true
	end
end)

RegisterServerEvent("lc_fishing_life:updateVehicleStatus")
AddEventHandler("lc_fishing_life:updateVehicleStatus",function(vehicle_data,vehicle_engine,vehicle_body,vehicle_fuel,properties)
	local source = source
	if vehicle_data.id then
		if properties then
			local sql = "UPDATE `fishing_life_vehicles` SET traveled_distance = @traveled_distance, health = @health, fuel = @fuel, properties = @properties WHERE id = @id";
			Utils.Database.execute(sql, {['@traveled_distance'] = vehicle_data.traveled_distance,['@health'] = math.floor((vehicle_engine + vehicle_body)/2), ['@fuel'] = vehicle_fuel, ['@properties'] = json.encode(properties), ['@id'] = vehicle_data.id});
		else
			local sql = "UPDATE `fishing_life_vehicles` SET traveled_distance = @traveled_distance, health = @health, fuel = @fuel WHERE id = @id";
			Utils.Database.execute(sql, {['@traveled_distance'] = vehicle_data.traveled_distance,['@health'] = math.floor((vehicle_engine + vehicle_body)/2), ['@fuel'] = vehicle_fuel, ['@id'] = vehicle_data.id});
		end
	end
end)

RegisterServerEvent("lc_fishing_life:sellVehicle")
AddEventHandler("lc_fishing_life:sellVehicle",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local sql = "SELECT health, vehicle, type FROM `fishing_life_vehicles` WHERE user_id = @user_id AND id = @id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id, ['@id'] = data.vehicle_id});
		if query and query[1] then
			if query[1].health > 900 then
				local vehicle = Config.available_items_store[query[1].type][query[1].vehicle]
				if vehicle then
					local sell_price = math.floor(vehicle.price*Config.vehicle_sell_price_multiplier)
					giveFisherMoney(user_id,sell_price)
					local sql = "DELETE FROM `fishing_life_vehicles` WHERE user_id = @user_id AND id = @id";
					Utils.Database.execute(sql, {['@user_id'] = user_id, ['@id'] = data.vehicle_id});
					TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('vehicle_sold'):format(sell_price))
					openUI(source,key,true)
				else
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
				end
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_damaged'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('vehicle_not_found'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:buyProperty")
AddEventHandler("lc_fishing_life:buyProperty",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local price = Config.available_items_store[data.type][data.property_id].price
		local sql = "SELECT * FROM `fishing_life_properties` WHERE user_id = @user_id";
		if beforeBuyVehicle(source,data.vehicle_id,price,user_id) then
			if tryGetFisherMoney(user_id,price) then
				local sql = "INSERT INTO `fishing_life_properties` (user_id, property, properties) VALUES (@user_id, @property, @properties);";
				Utils.Database.execute(sql, {['@user_id'] = user_id, ['@property'] = data.property_id, ['@properties'] = json.encode({})});
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('item_purchased'):format(data.type))
				Utils.Webhook.sendWebhookMessage(WebhookURL,Utils.translate('logs_buy_property'):format(user_id,data.property_id,price,Utils.Framework.getPlayerIdLog(source)..os.date("\n["..Utils.translate('logs_date').."]: %d/%m/%Y ["..Utils.translate('logs_hour').."]: %H:%M:%S")))
				openUI(source,key,true)
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_money'))
			end
		end
	end)
end)


RegisterServerEvent("lc_fishing_life:withdrawMoney")
AddEventHandler("lc_fishing_life:withdrawMoney",function(key, data)
	local source = source
	Wrapper(source,function(user_id)
		local sql = "SELECT * FROM `fishing_life_loans` WHERE user_id = @user_id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
		if not query or not query.remaining_amount or query.remaining_amount <= 0 then
			local sql = "SELECT money FROM `fishing_life_users` WHERE user_id = @user_id";
			local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
			local amount = math.floor(tonumber(data.amount) or 0)
			local money = tonumber(query.money) or 0
			if amount and amount > 0 and amount <= money then
				local sql = "UPDATE `fishing_life_users` SET money = money - @amount WHERE user_id = @user_id";
				Utils.Database.execute(sql, {['@user_id'] = user_id, ['@amount'] = amount});
				Utils.Framework.giveAccountMoney(source,amount,getAccount())
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('money_withdrawn'))
				Utils.Webhook.sendWebhookMessage(WebhookURL,Utils.translate('logs_withdraw'):format(amount,Utils.Framework.getPlayerIdLog(source)..os.date("\n["..Utils.translate('logs_date').."]: %d/%m/%Y ["..Utils.translate('logs_hour').."]: %H:%M:%S")))
				openUI(source,key,true)
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_money'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('pay_loans'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:depositMoney")
AddEventHandler("lc_fishing_life:depositMoney",function(key, data)
	local source = source
	Wrapper(source,function(user_id)
		local amount = math.floor(tonumber(data.amount) or 0)
		if amount and amount > 0 then
			if Utils.Framework.tryRemoveAccountMoney(source,amount,getAccount()) then
				giveFisherMoney(user_id,amount)
				TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('money_deposited'))
				Utils.Webhook.sendWebhookMessage(WebhookURL,Utils.translate('logs_deposit'):format(amount,Utils.Framework.getPlayerIdLog(source)..os.date("\n["..Utils.translate('logs_date').."]: %d/%m/%Y ["..Utils.translate('logs_hour').."]: %H:%M:%S")))
				openUI(source,key,true)
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficient_money'))
			end
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('invalid_value'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:loan")
AddEventHandler("lc_fishing_life:loan",function(key, data)
	local source = source
	Wrapper(source,function(user_id)
		local sql = "SELECT * FROM `fishing_life_loans` WHERE user_id = @user_id";
		local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});
		local amount_loans = 0;
		for k,v in pairs(query) do
			amount_loans = amount_loans + tonumber(v.loan)
		end
		
		data.loan_id = tonumber(data.loan_id) or 0
		if amount_loans + Config.loans.amount[data.loan_id][1] <= getMaxLoan(user_id) then
			local sql = "INSERT INTO `fishing_life_loans` (user_id,loan,remaining_amount,day_cost,taxes_on_day) VALUES (@user_id,@loan,@remaining_amount,@day_cost,@taxes_on_day);";
			Utils.Database.execute(sql, {['@user_id'] = user_id, ['@loan'] = Config.loans.amount[data.loan_id][1], ['@remaining_amount'] = Config.loans.amount[data.loan_id][1], ['@day_cost'] = Config.loans.amount[data.loan_id][2], ['@taxes_on_day'] = Config.loans.amount[data.loan_id][3]});
			giveFisherMoney(user_id,Config.loans.amount[data.loan_id][1])
			TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('loan'))
			openUI(source,key,true)
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('no_loan'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:payLoan")
AddEventHandler("lc_fishing_life:payLoan",function(key, data)
	local source = source
	Wrapper(source,function(user_id)
		local sql = "SELECT * FROM `fishing_life_loans` WHERE id = @id";
		local query = Utils.Database.fetchAll(sql,{['@id'] = data.loan_id})[1];
		if tryGetFisherMoney(user_id,query.remaining_amount) then
			local sql = "DELETE FROM `fishing_life_loans` WHERE id = @id;";
			Utils.Database.execute(sql, {['@id'] = data.loan_id});
			TriggerClientEvent("lc_fishing_life:Notify",source,"success",Utils.translate('loan_paid'))
			openUI(source,key,data)
		else
			TriggerClientEvent("lc_fishing_life:Notify",source,"error",Utils.translate('insufficiente_funds'))
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:withdrawItem")
AddEventHandler("lc_fishing_life:withdrawItem",function(key,data)
	local source = source
	Wrapper(source, function(user_id)
		local sql = "SELECT stock FROM `fishing_life_properties` WHERE property = @property and user_id = @user_id";
		local query =  Utils.Database.fetchAll(sql,{['@property'] = data.property, ['@user_id'] = user_id});
		if query and query[1] then
			local config_item = nil
			if  string.find(data.item,'fish') then
				config_item = Config.fishs_available[data.item]
			end
			if config_item then
				data.amount = math.floor(tonumber(data.amount) or 0)
				local arr_stock = json.decode(query[1].stock)
				if data.amount > 0 and arr_stock[data.item] and (arr_stock[data.item] - data.amount) >= 0 then
					local success = false
					success = Utils.Framework.givePlayerItem(source,data.item,data.amount)
					if success then
						TriggerClientEvent("lc_fishing_life:Notify",source,"success",Lang[Config.lang]['stock_item_withdrawn'])
					end
					if success then
						arr_stock[data.item] = arr_stock[data.item] - data.amount
						if arr_stock[data.item] == 0 then arr_stock[data.item] = nil end
						local sql = "UPDATE `fishing_life_properties` SET stock = @stock WHERE property = @property and user_id = @user_id";
						Utils.Database.execute(sql, {['@stock'] = json.encode(arr_stock), ['@property'] = data.property, ['@user_id'] = user_id});
						openPropertyUI(source,data.property,user_id)
					else
						TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['cant_carry_item'])
					end
				else
					TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['invalid_value'])
				end
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['stock_cannot_withdraw'])
			end
		end
	end)
end)

RegisterServerEvent("lc_fishing_life:depositItem")
AddEventHandler("lc_fishing_life:depositItem",function(key,data)
	local source = source
	Utils.Debug.printTable(data)
	Wrapper(source, function(user_id)
		local sql = "SELECT stock FROM `fishing_life_properties` WHERE property = @property and user_id = @user_id";
		local query =  Utils.Database.fetchAll(sql,{['@property'] = data.property, ['@user_id'] = user_id});
		if query and query[1] then
			data.amount = math.floor(tonumber(data.amount) or 0)
			local arr_stock = json.decode(query[1].stock)
			if data.amount > 0 then
				local stock_amount = getStockWeight(arr_stock)
				local max_stock = getMaxStock(data.property)
				local config_item = nil
				if  string.find(data.item,'fish') then
					config_item = Config.fishs_available[data.item]
				end
				if config_item then
					if stock_amount + (data.amount * config_item.weight) <= max_stock then
						Utils.Debug.printTable(data.item)
						Utils.Debug.printTable(data.amount)
						success = Utils.Framework.getPlayerItem(source,data.item,data.amount)
						if success then
							TriggerClientEvent("lc_fishing_life:Notify",source,"success",Lang[Config.lang]['stock_item_deposited'])
						end
						if success then
							if not arr_stock[data.item] then arr_stock[data.item] = 0 end
							arr_stock[data.item] = arr_stock[data.item] + data.amount
							local sql = "UPDATE `fishing_life_properties` SET stock = @stock , property = @property , user_id = @user_id";
							Utils.Database.execute(sql, {['@property'] = data.property, ['@user_id'] = user_id,  ['@stock'] = json.encode(arr_stock)});
							openPropertyUI(source,data.property,user_id)
						else
							TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['dont_have_item']:format(data.amount,config_item.name))
						end
					else
						TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['stock_property_full'])
					end
				end
			else
				TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['invalid_value'])
			end
		end
	end)
end)

function giveFisherMoney(user_id,amount)
	if amount > 0 then
		local sql = "UPDATE `fishing_life_users` SET money = money + @amount WHERE user_id = @user_id";
		Utils.Database.execute(sql, {['@amount'] = amount, ['@user_id'] = user_id});
	end
end

function tryGetFisherMoney(user_id,amount)
	local sql = "SELECT money FROM `fishing_life_users` WHERE user_id = @user_id";
	local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
	if query and tonumber(query.money) >= amount then
		local sql = "UPDATE `fishing_life_users` SET money = @amount WHERE user_id = @user_id";
		Utils.Database.execute(sql, {['@amount'] = (tonumber(query.money) - amount), ['@user_id'] = user_id});
		return true
	else
		return false
	end
end

function Wrapper(source,cb)
	assert(source, "Source is nil at Wrapper")

	if cooldown[source] == nil then
		cooldown[source] = true
		local user_id = Utils.Framework.getPlayerId(source)
		if user_id then
			cb(user_id)
		else
			print("^8["..GetCurrentResourceName().."] ^3User not found: ^1"..(source or "nil").."^7")
		end
		SetTimeout(100,function()
			cooldown[source] = nil
		end)
	end
end

function getAccount()
	if Config.account then
		return Config.account.fisher
	else
		return nil
	end
end


function getStockWeight(arr_stock)
	local weight = 0
	for k,v in pairs(arr_stock) do
		local item = nil
		if string.find(k,'fish') then
			item = Config.fishs_available[k]
		end
		if item then
			weight = weight + item.weight * v
		else
			print("^8["..GetCurrentResourceName().."]^3 item ^1"..k.."^3 is in a property stock but it is not configured in config, please add it in the config.^7")
		end
	end
	return weight
end

function getMaxStock(property)
	return Config.available_items_store.property[property].warehouse_capacity
end

function getMaxLoan(user_id)
	local max_loan = 0;
	local level = getPlayerLevel(user_id)
	for k,v in pairs(Config.max_loan_per_level) do
		if k <= level then
			max_loan = v
		end
	end
	return max_loan
end

function getPlayerLevel(user_id)
	local sql = "SELECT exp FROM `fishing_life_users` WHERE user_id = @user_id";
	local query = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
	local level = 0
	if query then
		for k,v in pairs(Config.required_xp_to_levelup) do
			if tonumber(query.exp) >= v then
				level = k
			else
				return level
			end
		end
	end
	return level
end

function openUI(source,key,isUpdate)
	local query = {}
	local user_id = Utils.Framework.getPlayerId(source)
	if Config.job == false or Config.job == "false" or Utils.Framework.hasJobs(source,{Config.job}) then

		-- Busca os dados do usuário
		local sql = "SELECT * FROM `fishing_life_users` WHERE user_id = @user_id";
		query.fishing_life_users = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
		if query.fishing_life_users == nil then
			if beforeBuyLocation(source,user_id) then
				local sql = "INSERT INTO `fishing_life_users` (user_id) VALUES (@user_id);";
				Utils.Database.execute(sql, {['@user_id'] = user_id});
				local sql = "SELECT * FROM `fishing_life_users` WHERE user_id = @user_id";
				query.fishing_life_users = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
			else
				return
			end
		end

		--Busca todos os items disponiveis para compra de acordo com o level do usuario
		query.available_vehicles = Utils.Table.deepCopy(Config.vehicles[query.fishing_life_users.vehicles_upgrade])
		query.available_boats = Utils.Table.deepCopy(Config.vehicles[query.fishing_life_users.boats_upgrade])
		query.available_properties = Utils.Table.deepCopy(Config.vehicles[query.fishing_life_users.properties_upgrade])

		-- Busca os contratos ativos
		local sql = "SELECT * FROM `fishing_available_contracts` WHERE progress IS NULL OR progress = @user_id";
		query.fishing_available_contracts = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});

		-- Busca os dives ativos
		local sql = "SELECT * FROM `fishing_available_dives` WHERE progress IS NULL OR progress = @user_id";
		query.fishing_available_dives = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});

		-- Busca os emprestimos
		local sql = "SELECT * FROM `fishing_life_loans` WHERE user_id = @user_id";
		query.fishing_life_loans = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});

		-- Dinheiro do personagem
		query.available_money = Utils.Framework.getPlayerAccountMoney(source,getAccount())

		-- Busca os veiculos
		local sql = "SELECT * FROM `fishing_life_vehicles` WHERE user_id = @user_id";		
		local owned_vehicles = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});
		query.owned_vehicles = {}
		local owned_cars = {}
		local owned_boats = {}
		for k,v in pairs(owned_vehicles) do
			if v.type == 'vehicle' then
				table.insert(owned_cars,v)
			elseif v.type == 'boat' then
				table.insert(owned_boats,v)
			end
		end 
		query.owned_vehicles.vehicles = owned_cars
		query.owned_vehicles.boats = owned_boats

		-- Busca as propriedades
		local sql = "SELECT * FROM `fishing_life_properties` WHERE user_id = @user_id";		
		query.owned_properties = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});

		-- Busca as configs necessárias
		query.config = {}
		query.config.lang =  Utils.Table.deepCopy(Config.lang)
		query.config.format =  Utils.Table.deepCopy(Config.format)
		query.config.required_xp_to_levelup =  Utils.Table.deepCopy(Config.required_xp_to_levelup)
		query.config.max_loan_per_level =  Utils.Table.deepCopy(Config.max_loan_per_level)
		query.config.loans =  Utils.Table.deepCopy(Config.loans.amount)
		query.config.contracts =  Utils.Table.deepCopy(Config.available_contracts.definitions)
		query.config.dives =  Utils.Table.deepCopy(Config.available_dives.definitions)
		query.config.available_items_store =  Utils.Table.deepCopy(Config.available_items_store)
		query.config.upgrades =  Utils.Table.deepCopy(Config.upgrades)
		query.config.equipments_upgrades =  Utils.Table.deepCopy(Config.equipments_upgrades)
		query.config.fishs_available =  Utils.Table.deepCopy(Config.fishs_available)
		query.config.lake = Utils.Table.deepCopy(Config.lake)
		query.config.sea = Utils.Table.deepCopy(Config.sea)
		query.config.swan = Utils.Table.deepCopy(Config.swan)
		-- query.config.dealership = Utils.Table.deepCopy(Config.dealership)

		-- Busca outras variaveis
		query.config.max_loan = getMaxLoan(user_id)
		query.config.player_level = getPlayerLevel(user_id)

		-- Envia pro front-end
		TriggerClientEvent("lc_fishing_life:open",source, query, isUpdate)
	end
end

function openPropertyUI(source,property_id,user_id)
	-- Busca o stock
	local data = {}
	local sql = "SELECT * FROM `fishing_life_properties` WHERE property = @property and user_id = @user_id";		
	local property = Utils.Database.fetchAll(sql,{['@property'] = property_id ,['@user_id'] = user_id})[1];
	if property then
		data.config = {}
		data.config.lang = Utils.Table.deepCopy(Config.lang)
		data.config.format = Utils.Table.deepCopy(Config.format)
		data.config.player_level = getPlayerLevel(user_id)
		data.config.available_items_store =  Utils.Table.deepCopy(Config.available_items_store)
		data.config.fishs_available =  Utils.Table.deepCopy(Config.fishs_available)

		-- Busca os dados do usuário
		local sql = "SELECT * FROM `fishing_life_users` WHERE user_id = @user_id";
		data.fishing_life_users = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
		if data.fishing_life_users == nil then
			if beforeBuyLocation(source,user_id) then
				local sql = "INSERT INTO `fishing_life_users` (user_id) VALUES (@user_id);";
				Utils.Database.execute(sql, {['@user_id'] = user_id});
				local sql = "SELECT * FROM `fishing_life_users` WHERE user_id = @user_id";
				data.fishing_life_users = Utils.Database.fetchAll(sql,{['@user_id'] = user_id})[1];
			else
				return
			end
		end
		local player_items = Utils.Framework.getPlayerInventory(source)
		data.players_items_fishing = {}
		for k,v in pairs(player_items) do
			if string.find(v.name, "fish")	 then
				table.insert(data.players_items_fishing,v)
			end
		end
		property.stock =  json.decode(property.stock)
		property.stock_amount = getStockAmount(property.stock)
		property.name = Config.available_items_store.property[property.property].name
		-- Envia pro front-end
		TriggerClientEvent("lc_fishing_life:openProperty",source, data, property)
	else
		TriggerClientEvent("lc_fishing_life:Notify",source,"error",Lang[Config.lang]['you_dont_own_this_property'])
	end
end

function getStockAmount(arr_stock)
	local count = 0
	for k,v in pairs(arr_stock) do
		count = count + v
	end
	return count
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

Citizen.CreateThread(function()
	Wait(1000)
	-- Config checker
	assert(Config, "^3You have errors in your config file, consider fixing it or redownload the original config.^7")

	-- Check lc_utils dependency
	assert(GetResourceState('lc_utils') == 'started', "^3The '^1lc_utils^3' file is missing. Please refer to the documentation for installation instructions: ^7https://lixeirocharmoso.com/owned_stores/installation^7")
	assert(not Utils.Math.checkIfCurrentVersionisOutdated(utils_required_version, Utils.Version), "^3The script requires 'lc_utils' in version ^1"..utils_required_version.."^3, but you currently have version ^1"..Utils.Version.."^3. Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7")

	Wait(1000)
	-- Load langs
	Utils.loadLanguageFile(Lang)
	-- Statup queries
	while not vrp_ready do Wait(100) end
	runCreateTableQueries()
	local sql = "UPDATE `fishing_available_contracts` SET progress = NULL";
	Utils.Database.execute(sql, {});

	Wait(1000)
	-- Check if all the columns exist in database
	local tables = {
		-- ['store_business'] = {
		-- 	"market_id",
		-- 	"user_id",
		-- 	"stock",
		-- 	"stock_prices",
		-- 	"stock_upgrade",
		-- 	"truck_upgrade",
		-- 	"relationship_upgrade",
		-- 	"money",
		-- 	"total_money_earned",
		-- 	"total_money_spent",
		-- 	"goods_bought",
		-- 	"distance_traveled",
		-- 	"total_visits",
		-- 	"customers",
		-- 	"market_name",
		-- 	"market_color",
		-- 	"market_blip",
		-- 	"timer"
		-- },
		-- ['store_balance'] = {
		-- 	"id",
		-- 	"market_id",
		-- 	"income",
		-- 	"title",
		-- 	"amount",
		-- 	"date",
		-- 	"hidden"
		-- },
		-- ['store_jobs'] = {
		-- 	"id",
		-- 	"market_id",
		-- 	"name",
		-- 	"reward",
		-- 	"product",
		-- 	"amount",
		-- 	"progress",
		-- 	"trucker_contract_id"
		-- },
		-- ['store_employees'] = {
		-- 	"market_id",
		-- 	"user_id",
		-- 	"jobs_done",
		-- 	"role",
		-- 	"timer",
		-- },
		-- ['store_categories'] = {
		-- 	"id",
		-- 	"market_id",
		-- 	"category"
		-- },
		-- ['store_users_theme'] = {
		-- 	"user_id",
		-- 	"dark_theme"
		-- }
	}
	Utils.Database.validateTableColumns(tables)
end)

function runCreateTableQueries()
	if Config.create_table ~= false then
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_available_contracts` (
				`id` INT(11) NOT NULL AUTO_INCREMENT,
				`name` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`description` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`image` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`required_items` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`money_reward` INT(11) NULL DEFAULT NULL,
				`item_reward` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
				`delivery_location` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_general_ci',
				`progress` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
				`timestamp` INT(11) NOT NULL,
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_available_dives` (
				`id` INT(11) NOT NULL AUTO_INCREMENT,
				`name` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`description` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`image` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
				`money_reward` INT(11) NULL DEFAULT NULL,
				`item_reward` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
				`dive_location` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_general_ci',
				`progress` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
				`timestamp` INT(11) NOT NULL,
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_loans` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`loan` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`remaining_amount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`day_cost` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`taxes_on_day` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`timer` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_users` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`boats_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`vehicles_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`properties_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`sea_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`lake_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`swan_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`windlass_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`rod_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`bait_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`gimp_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				`money` INT(11) NOT NULL DEFAULT '0',
				`exp` INT(11) NOT NULL DEFAULT '0',
				`skill_points` INT(11) NOT NULL DEFAULT '0',
				`dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				PRIMARY KEY (`user_id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
		
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_vehicles` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`vehicle` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`properties` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
				`traveled_distance` INT(11) UNSIGNED NOT NULL DEFAULT '0',
				`health` INT(11) UNSIGNED NOT NULL DEFAULT '1000',
				`fuel` INT(11) UNSIGNED NOT NULL DEFAULT '100',
				`type` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `fishing_life_vehicle` (`user_id`, `vehicle`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])		
		Utils.Database.execute([[
			CREATE TABLE IF NOT EXISTS `fishing_life_properties` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`property` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`properties` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
				`stock` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
				`property_condition`  INT(11) UNSIGNED NOT NULL DEFAULT '100',
				PRIMARY KEY (`id`) USING BTREE,
				INDEX `fishing_life_vehicle` (`user_id`, `property`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]])
	end
end