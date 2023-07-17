WebhookURL = "WEBHOOK" -- Webhook to send logs to discord

function beforeBuyLocation(source,user_id)
	-- Here you can do any verification when a player is opening the trucker UI for the first time, like if player has the permission or money to that or anything else you want to check. return true or false
	return true
end

function beforeBuyVehicle(source,user_id,vehicle_name,price,user_id)
	-- Here you can do any verification when a player is buying a vehicle, like if player has driver license or anything else you want to check before buy the vehicle. return true or false
	return true
end

function MySQL_Sync_execute(sql,params)
	MySQL.Sync.execute(sql, params)
end

function MySQL_Sync_fetchAll(sql,params)
	return MySQL.Sync.fetchAll(sql, params)
end

-- Player ID that will appear on the logs
function getPlayerIdLog(source)
	local user_id = getPlayerId(source)
	local player_name = GetPlayerName(source)
	return user_id.." ("..player_name..")"
end