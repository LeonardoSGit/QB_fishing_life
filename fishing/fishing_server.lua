local QBCore = Fishing_Config.Core

RegisterNetEvent('lc_fishing_life:RemoveItem', function(item, amount, clientPass)
	if clientPass ~= password then return end
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
	xPlayer.Functions.RemoveItem(item, amount)
	TriggerClientEvent('inventory:client:ItemBox',src, QBCore.Shared.Items[item], "remove")
end)

RegisterNetEvent('lc_fishing_life:ReceiveItem', function(item, amount, clientPass)
	local src = source
	if password ~= clientPass or not Player(tonumber(src)).state.CanGetFish then return end
	Player(tonumber(src)).state:set('CanGetFish', false,  true)
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
	TriggerClientEvent('inventory:client:ItemBox',src, QBCore.Shared.Items[item], "add")
	TriggerEvent("lc_fishing_life:CatchLog", src, item)
end)