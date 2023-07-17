-- Framework init
QBCore = exports['qb-core']:GetCoreObject()

-- Framework functions
function getPlayers()
	return QBCore.Functions.GetPlayers()
end

function getPlayerId(source)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer then
		return xPlayer.PlayerData.citizenid
	end
	return nil
end

function getPlayerSource(user_id)
	local xPlayer = QBCore.Functions.GetPlayerByCitizenId(user_id)
	if xPlayer then
		return xPlayer.PlayerData.source
	end
	return nil
end

function giveAccountMoney(source,amount,account)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	xPlayer.Functions.AddMoney(account, amount)
end

function tryRemoveAccountMoney(source,amount,account)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local money = xPlayer.PlayerData.money[account]
	if money >= amount then
		xPlayer.Functions.RemoveMoney(account, amount)
		return true
	else
		return false
	end
end

function getPlayerAccountMoney(source,account)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local money = xPlayer.PlayerData.money[account]
	return money
end

function givePlayerItem(source,item,amount)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	return xPlayer.Functions.AddItem(item, amount)
end

function getPlayerItem(source,item,amount)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
		xPlayer.Functions.RemoveItem(item,amount)
		return true
	else
		return false
	end
end

function playerHasItem(source,item,amount)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
		return true
	else
		return false
	end
end

function hasJob(source,job)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local PlayerJob = xPlayer.PlayerData.job
	if Config.debugJob then
		print("Job name: "..PlayerJob.name)
		print(PlayerJob.onduty)
	end
	if PlayerJob.onduty and PlayerJob.name == job then
		return true
	else
		return false
	end
end