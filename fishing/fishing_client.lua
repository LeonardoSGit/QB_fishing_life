local QBCore = Fishing_Config.Core
local uiOpen = false
local pedd = nil
local hasalreadyentered = false
local CurrentBait = 'none'
local currentDiff = nil
local startingDiff = nil
local password = ""
local currentpedarea = nil
Utils = exports['lc_utils']:GetUtils()

Citizen.CreateThread(function()
    Citizen.Wait(1000)

    SendNUIMessage({
        type = "setLocale", 
        hook =  Fishing_Config.locale["hook"],
        success =  Fishing_Config.locale["success"],
        fail = Fishing_Config.locale["fail"],
        gotaway = Fishing_Config.locale["got_away2"],
        fishon = Fishing_Config.locale["fish_on"],
        toosoon = Fishing_Config.locale["too_soon"],
    })

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

local IsFishing = false
local rodHandle = nil
local StartFish = false
local area = nil

function InitFishing()
    if StartFish == false then
        StartFish = true
        rodHandle = FishingRod()
        if IsPedSwimming(PlayerPedId()) or IsPedInAnyVehicle(PlayerPedId()) then 
            StartFish = false
            TriggerEvent("lc_fishing_life:Notify", Fishing_Config.locale["cant_now"])
            DeleteEntity(trackingFish)
            return
        end
        area = fishingSpot()
        local waterValidated, castLocation = IsInWater()
        if area then
            if waterValidated then
                if not IsFishing then
                    SendBait(castLocation, cont)
                    StartFish = false
                end
            else
                TriggerEvent("lc_fishing_life:Notify", Fishing_Config.locale["aim_to_water"])
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
            TriggerEvent("lc_fishing_life:Notify", Fishing_Config.locale["cant_fish"])
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

function SendBait(castLocation, cont)
    IsFishing = true

    local startedBaiting = GetGameTimer()
    local randomBait = math.random(1, 1)
	
    local interrupted = false
    
    Citizen.Wait(1000)

    while GetGameTimer() - startedBaiting < randomBait do
        Citizen.Wait(1)
        if not IsEntityPlayingAnim(PlayerPedId(), "amb@world_human_stand_fishing@idle_a", "idle_c", 3) or IsControlJustReleased(0, 177) then
            interrupted = true
            break
        end
    end

    if interrupted then
        ClearPedTasks(PlayerPedId())
        DeleteEntity(rodHandle)
        DeleteEntity(FishRod)
        rodHandle = nil
        RemoveLoadingPrompt()
        IsFishing = false
        return
    else
        TryToCatchFish()
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

function TryToCatchFish()
    math.randomseed(GetGameTimer())
    local foundFish = false
    local fishNumber = 0
    repeat
        Wait(10)
        local rnd = 1
        rnd = math.random(1, #Fishing_Config.FishTable[area][CurrentBait])
        if Fishing_Config.debug then
            print("before area is "..tostring(area))
            print("before bait used is "..tostring(CurrentBait))
            print("before fish number is "..tostring(fishNumber))
        end
        if math.random(100) <= Fishing_Config.FishTable[area][CurrentBait][rnd].chance then
            foundFish = true
            fishNumber = rnd
        end
    until foundFish
    startingDiff = Fishing_Config.FishTable[area][CurrentBait][fishNumber]["diff"]
    currentDiff = startingDiff
    SendNUIMessage({type = "updateDifficulty",
        tensionIncrease =  math.random(Fishing_Config.difficulty[currentDiff].tensionIncrease.min, Fishing_Config.difficulty[currentDiff].tensionIncrease.max),
        tensionDecrease =  math.random(Fishing_Config.difficulty[currentDiff].tensionDecrease.min, Fishing_Config.difficulty[currentDiff].tensionDecrease.max),
        progressIncrease = math.random(Fishing_Config.difficulty[currentDiff].progressIncrease.min, Fishing_Config.difficulty[currentDiff].progressIncrease.max),
        progressDecrease = math.random(Fishing_Config.difficulty[currentDiff].progressDecrease.min, Fishing_Config.difficulty[currentDiff].progressDecrease.max),
    })
    local rewardtype = Fishing_Config.FishTable[area][CurrentBait][fishNumber]
    if Fishing_Config.debug then
        print("after area is "..tostring(area))
        print("after bait used is "..tostring(CurrentBait))
        print("after fish number is "..tostring(fishNumber))
        print("after reward type is "..json.encode(rewardtype))
    end
    local finished = false
        finished = fishingGameStart()
        onFishingEnd(finished)
        if not finished then
            TriggerEvent("lc_fishing_life:Notify", Fishing_Config.locale["got_away"])
            ClearPedTasks(PlayerPedId())
            DeleteEntity(rodHandle)
            DeleteEntity(FishRod)
            rodHandle = nil
            IsFishing = false
            if math.random(100) > 90 and Fishing_Config.canBreakRod then
                TriggerServerEvent('lc_fishing_life:RemoveItem', 'fishingrod', 1, password)
            end
        return
    end
    ClearPedTasks(PlayerPedId())
    local forwardVector = GetEntityForwardVector(PlayerPedId())
    local forwardPos = vector3(GetEntityCoords(PlayerPedId())["x"] + forwardVector["x"] * 5, GetEntityCoords(PlayerPedId())["y"] + forwardVector["y"] * 5, GetEntityCoords(PlayerPedId())["z"])
    local model = GetHashKey(rewardtype.prop)
    LoadModel(model)
    local waterHeight = GetWaterHeight(forwardPos["x"], forwardPos["y"], forwardPos["z"])
    local fishHandle = nil
    if rewardtype.ped == true then
        fishHandle = CreatePed(28, model, forwardPos, 0.0, true, true)
    else
        fishHandle = CreateObject(model, forwardPos, true, false)
    end
    while not DoesEntityExist(fishHandle) do
        Citizen.Wait(10)
    end
    if rewardtype.ped == true then
        SetEntityHealth(fishHandle, 0.0)
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
                DeleteEntity(fishHandle)
                if rewardtype.name == 'cash' then
                    TriggerServerEvent('lc_fishing_life:cashbag', password)
                else
                    TriggerServerEvent('lc_fishing_life:ReceiveItem', rewardtype.name, 1, password)
                end
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


RegisterNetEvent("lc_fishing_life:StartFish", function()
    if IsPedInAnyVehicle(PlayerPedId(), true) then return end
	InitFishing()
end)

RegisterCommand("fish", function()
    InitFishing()
end)

local isCrafting = false
RegisterNetEvent("lc_fishing_life:cutBait", function(returnBait, takeItem, amount)
    if not isCrafting and not IsPedInAnyVehicle(PlayerPedId(), true) then
        isCrafting = true
        loadAnimDict( "amb@world_human_clipboard@male@idle_a" ) 
        TaskPlayAnim( PlayerPedId(), "amb@world_human_clipboard@male@idle_a", "idle_c", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        QBCore.Functions.Progressbar("reful_boat", Fishing_Config.locale["cutting_bait"], 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            ClearPedTasksImmediately(PlayerPedId())
            Player(GetPlayerServerId(PlayerId())).state:set("CanGetBait", true, true)

            TriggerServerEvent('lc_fishing_life:getBait', password, returnBait, takeItem, amount)
            Citizen.Wait(300)
            isCrafting = false
        end, function() -- Cancel
            QBCore.Functions.Notify(Fishing_Config.locale["cancel_bait"], 'error')
            isCrafting = false
        end)
    end
end)

local blips = {}

Citizen.CreateThread(function()
   for _, info in pairs(Fishing_Config.PedLocs) do
    if info.blip.show then
        local x,y,z = table.unpack(info.position)
        blips[_]  = Utils.Blips.createBlipForCoords(x,y,z,z,info.blip.color,info.blip.name,info.blip.scale)
    /* = AddBlipForCoord(info.position.x, info.position.y, info.position.z)
     SetBlipSprite(blips[_], info.blip.sprite)
     SetBlipDisplay(blips[_], 4)
     SetBlipScale(blips[_], info.blip.scale)
     SetBlipColour(blips[_], info.blip.color)
     SetBlipAsShortRange(blips[_], true)
     BeginTextCommandSetBlipName("STRING")
     AddTextComponentString(info.blip.name)*/
     EndTextCommandSetBlipName(blips[_])
    end
   end
end)

local last_x, last_y, lasttext, isDrawing
function Draw3dNUI(coords)
    if not coords then return end
	local paused = false
	if IsPauseMenuActive() then paused = true end
	local onScreen,_x,_y = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
		if paused then
            SendNUIMessage ({type = "hide"}) 
        else 
            SendNUIMessage ({type = "show"}) 
        end
            SendNUIMessage({type = "updatePos", x = _x, y = _y})
		    last_x, last_y = _x, _y
end

local reelingProgress = 0
local isItOver = false
function fishingGameStart()
    Citizen.Wait(250)
    reelingProgress = 0
    uiOpen = true
    isItOver = false
    SetNuiFocus(true, false)
    local ply = PlayerPedId()
    local plyCords = GetEntityCoords(ply)
    local fishcoords = GetEntityCoords(trackingFish)
    local onScreen,_x,_y = GetScreenCoordFromWorldCoord(fishcoords.x,fishcoords.y,fishcoords.z)
    local dist = #(plyCords - fishcoords)
    local savedcord = nil
    local baitlabel = "None"
    if QBCore.Shared.Items[CurrentBait] then
        baitlabel = QBCore.Shared.Items[CurrentBait].label
    end
    SendNUIMessage({
        type = "start",
        bait = baitlabel,
        x = _x, 
        y = _y,
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

RegisterNUICallback("updateTrackingFish", function(data)
    if data.progress >= 100 or data.isitover ~= nil then
        isItOver = true
        Citizen.Wait(100)
    end
    reelingProgress = data.progress
end)

RegisterNetEvent('nuifalse', function()
    cancelGame()
end)

function cancelGame()
    SendNUIMessage({
        type = "close",
    })
    SetNuiFocus(false, false)
    DeleteEntity(trackingFish)
    SetModelAsNoLongerNeeded(trackingFish)
    trackingFish = nil
    uiOpen = false
    value = nil
end

function DiffChanger()
    Citizen.CreateThread(function()
        while IsFishing do
            Citizen.Wait(math.random(12000,15000))
            if currentDiff == "easy" and startingDiff == "easy" then
                    currentDiff = "medium"
            elseif currentDiff == "medium" and startingDiff == "easy" then
                    currentDiff = "easy"
            elseif currentDiff == "medium" and startingDiff == "medium" then
                if math.random(1, 2) == 1 then
                    currentDiff = "hard"
                else
                    currentDiff = "easy"
                end
            elseif currentDiff == "easy" and startingDiff == "medium" then
                if math.random(1, 2) == 1 then
                    currentDiff = "hard"
                else
                    currentDiff = "medium"
                end
            elseif currentDiff == "hard" and startingDiff == "medium" then
                if math.random(1, 2) == 1 then
                    currentDiff = "easy"
                else
                    currentDiff = "medium"
                end
            elseif currentDiff == "medium" and startingDiff == "hard" then
                currentDiff = "hard"
            elseif currentDiff == "hard" and startingDiff == "hard" then
                currentDiff = "medium"
            end
            SendNUIMessage({type = "updateDifficulty", 
                tensionIncrease =  math.random(Fishing_Config.difficulty[currentDiff].tensionIncrease.min, Fishing_Config.difficulty[currentDiff].tensionIncrease.max),
                tensionDecrease =  math.random(Fishing_Config.difficulty[currentDiff].tensionDecrease.min, Fishing_Config.difficulty[currentDiff].tensionDecrease.max),
                progressIncrease = math.random(Fishing_Config.difficulty[currentDiff].progressIncrease.min, Fishing_Config.difficulty[currentDiff].progressIncrease.max),
                progressDecrease = math.random(Fishing_Config.difficulty[currentDiff].progressDecrease.min, Fishing_Config.difficulty[currentDiff].progressDecrease.max),
            })
        end
    end)
end

RegisterNUICallback("isReeling", function(data)
    isReeling = data.isReeling
    if isReeling == true then
        DiffChanger()
    end
end)

RegisterNUICallback("close", function(data)
    SetNuiFocus(false, false)
    DeleteEntity(trackingFish)
    SetModelAsNoLongerNeeded(trackingFish)
    trackingFish = nil
    SendNUIMessage({
        type = "close",
    })
    uiOpen = false
    value = data.success
    Citizen.Wait(100)
    value = nil
    SendNUIMessage({
        type = "close",
    })
end)

Citizen.CreateThread(function()
    if Fishing_Config.UseTarget then
        for i,v in pairs(Fishing_Config.PedLocs) do
            if v.legal then
                exports[Fishing_Config.qbtargetScriptName]:AddTargetModel(v.pedmodel, {
                    options = {
                        {
                            type = "client",
                            event = "lc_fishing_life:sellFish",
        	    			legal = true,
        	    			icon = "fas fa-dollar-sign",
        	    			label = Fishing_Config.locale['sell_fish_legal'],
                            canInteract = function(entity)
                                if #(GetEntityCoords(entity) - v.position) <= 1 and not IsPedAPlayer(entity) then 
                                      return true
                                else 
                                      return false
                                end 
                            end,
                        },
                    },
                    distance = 2.5
                })
            else
                exports[Fishing_Config.qbtargetScriptName]:AddTargetModel(v.pedmodel, {
                    options = {
                        {
                            type = "client",
                            event = "lc_fishing_life:sellFish",
        	    			legal = false,
        	    			icon = "fas fa-dollar-sign",
        	    			label = Fishing_Config.locale['sell_fish_illegal'],
                            canInteract = function(entity)
                                if #(GetEntityCoords(entity) - v.position) <= 1 and not IsPedAPlayer(entity) then 
                                      return true
                                else 
                                      return false
                                end 
                            end,
                        },
                    },
                    distance = 2.5
                })
            end
        end
    elseif Fishing_Config.UseQBMenu then
        local shownHeader = false
        while true do
            local headerMenu = {}
            if pedd ~= nil then
                if #(GetEntityCoords(pedd) - GetEntityCoords(PlayerPedId())) < 2 then
                    if currentpedarea.legal then
                        headerMenu[#headerMenu+1] = {
                            header = "Sell Fish",
                            params = {
                                event = 'lc_fishing_life:sellFish',
                                args = {legal = true}
                            }
                        }
                    else
                        headerMenu[#headerMenu+1] = {
                            header = "Sell Illegal Fish",
                            params = {
                                event = 'lc_fishing_life:sellFish',
                                args = {legal = false}
                            }
                        }
                    end
                    if not shownHeader then
                        shownHeader = true
                        exports['qb-menu']:showHeader(headerMenu)
                    end
                else
                    if shownHeader then
                        shownHeader = false
                        exports['qb-menu']:closeMenu()
                    end
                end
            end
            Citizen.Wait(250)
        end
    elseif Fishing_Config.useDrawText then
        local wait = 100
        while true do
            if pedd ~= nil then
                if #(GetEntityCoords(pedd) - GetEntityCoords(PlayerPedId())) < 2 then
                    wait = 0
                    DrawText3Ds(GetEntityCoords(pedd), Fishing_Config.locale['draw_text_sell'])
                    if IsControlJustReleased(0, 38) then
                        if currentpedarea.legal then
                            TriggerEvent("lc_fishing_life:sellFish", {legal = true})
                        else
                            TriggerEvent("lc_fishing_life:sellFish", {legal = false})
                        end
                    end
                else
                    wait = 100
                end
            else
                wait = 100
            end
            Citizen.Wait(wait)
        end
    end
end)

Citizen.CreateThread(function() while true do Citizen.Wait(30000) collectgarbage() end end)-- Prevents RAM LEAKS :)