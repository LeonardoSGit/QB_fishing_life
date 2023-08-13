WebhookURL = "WEBHOOK" -- Webhook to send logs to discord

function beforeBuyLocation(source,user_id)
	-- Here you can do any verification when a player is opening the trucker UI for the first time, like if player has the permission or money to that or anything else you want to check. return true or false
	return true
end

function beforeBuyVehicle(source,user_id,vehicle_name,price,user_id)
	-- Here you can do any verification when a player is buying a vehicle, like if player has driver license or anything else you want to check before buy the vehicle. return true or false
	return true
end