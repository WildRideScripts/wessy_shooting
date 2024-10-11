local VORPcore = {}
local shootingItems = {}
local blips = {}
local gameIsRunning = false
local starttimer = 0
local timerIsRunning = false
local location = nil
local isDisplayScore = false

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

AddEventHandler("onResourceStop",function(resourceName)
    if resourceName == GetCurrentResourceName() then
        cleanupBlips()
        cleanupItems()
    end
end)

function cleanupBlips()
    for i,v in pairs(blips) do
        if DoesBlipExist(i) then
            RemoveBlip(i)
        end
    end
end

function cleanupItems()
    for i,v in pairs(shootingItems) do
        if DoesEntityExist(i) then
            DeleteEntity(i)
        end
    end   
end

for i,v in pairs(Config.shootingLocations) do
    if v.showBlip then
        blipg = N_0x554d9d53f696d002(1664425300, v.startCoord.x, v.startCoord.y, v.startCoord.z)
        SetBlipSprite(blipg, v.blipSprite, 1)
        SetBlipScale(blipg, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blipg, v.blipLabel)
        blips[blipg] = true
    end
end

RegisterNetEvent('wessy_shooting:timer')
AddEventHandler('wessy_shooting:timer',function()
    timerIsRunning = true
    starttimer = 0.0
    Citizen.CreateThread(function()
        while timerIsRunning do
            starttimer = starttimer + GetFrameTime()
            Citizen.Wait(0)
        end
    end)
end)

RegisterNetEvent('wessy_shooting:showScore')
AddEventHandler('wessy_shooting:showScore',function(location, text, text2)
    isDisplayScore = false
    Wait(500)
    local _location = location
    local data = Config.shootingLocations[location]
    local tempTimer = 15 * 1000
    Citizen.CreateThread(function()
        isDisplayScore = true
        while tempTimer > 1 and isDisplayScore do
            tempTimer = tempTimer - 10
            DrawText3D(data.scoreBoard.x, data.scoreBoard.y, data.scoreBoard.z, text.."\n".."~e~Bestzeit:~q~ "..text2)
            Citizen.Wait(0)
        end
    end)

end)

local is_frontend_sound_playing = false
local frontend_soundset_ref = "RDRO_Spectate_Sounds"
local frontend_soundset_name =  "right_bumper"

RegisterNetEvent('wessy_shooting:start')
AddEventHandler('wessy_shooting:start',function(index)

    if not gameIsRunning then
        gameIsRunning = true

        location = index
        isDisplayScore = false

        local data = Config.shootingLocations[location]
        local startWaitTime = Config.StartWaitTime + 1

        for i = 1, Config.StartWaitTime do 
            if not is_frontend_sound_playing then
                if frontend_soundset_ref ~= 0 then
                Citizen.InvokeNative(0x0F2A2175734926D8,frontend_soundset_name, frontend_soundset_ref);   -- load sound frontend
                end
                Citizen.InvokeNative(0x67C540AA08E4A6F5,frontend_soundset_name, frontend_soundset_ref, true, 0);  -- play sound frontend
                is_frontend_sound_playing = true
            end
            startWaitTime = startWaitTime - 1
            VORPcore.NotifyTip(startWaitTime,500)
            Wait(1000)
            Citizen.InvokeNative(0x9D746964E0CF2C5F,frontend_soundset_name, frontend_soundset_ref)  -- stop audio
            is_frontend_sound_playing = false
        end
        
        local spawnItems = {}

        for i = 1, data.itemSpawnAmount do 
            randomItem = math.random(1,#data.items)
            table.insert(spawnItems, data.items[randomItem])
        end
        
        local firstItemSpawn = true
        for i,v in pairs(spawnItems) do
            if gameIsRunning then
                RequestModel(v.hash)
                while not HasModelLoaded(v.hash) do
                    Citizen.Wait(1)
                end

                if firstItemSpawn then
                    TriggerEvent("wessy_shooting:timer")
                    firstItemSpawn = false
                end

                local newShootingItem = CreateObjectNoOffset(v.hash, v.x, v.y, v.z, true, false, false)
                shootingItems[newShootingItem] = true
                while DoesEntityExist(newShootingItem) do
                    Citizen.Wait(500)
                end
            end
        end 
        if gameIsRunning then
            timerIsRunning = false
            
            local frontend_soundset_ref = "RDRO_Out_Of_Bounds_Sounds"
            local frontend_soundset_name =  "OOB_return"
            Citizen.InvokeNative(0x0F2A2175734926D8, "RDRO_Poker_Sounds", "player_turn_countdown_start");
            if not is_frontend_sound_playing then
                if frontend_soundset_ref ~= 0 then
                Citizen.InvokeNative(0x0F2A2175734926D8,frontend_soundset_name, frontend_soundset_ref);   -- load sound frontend
                end
                Citizen.InvokeNative(0x67C540AA08E4A6F5,frontend_soundset_name, frontend_soundset_ref, true, 0);  -- play sound frontend
                is_frontend_sound_playing = true
            end

            local itemAmount = #spawnItems
            local finalTime = round(starttimer, 2)
            VORPcore.NotifyLeft(Config.Language.scoreTitle,Config.Language.scoreDesc..finalTime..Config.Language.scoreDesc2..itemAmount..Config.Language.scoreDesc3,"toast_log_blips","blip_region_hunting",6000,"COLOR_WHITE")

            local closestDistance = Config.ShowResultPlayerRange
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed, true, true)
            local closestPlayers = {}
            for _, player in pairs(GetActivePlayers()) do
                local target = GetPlayerPed(player)

                if target ~= playerPed then
                    local targetCoords = GetEntityCoords(target, true, true)
                    local distance = #(targetCoords - coords)

                    if distance < closestDistance then
                        local txadminid = GetPlayerServerId(player)
                        closestPlayers[txadminid] = distance
                    end
                end
            end

            TriggerServerEvent("wessy_shooting:save", finalTime, itemAmount, location, closestPlayers)
            gameIsRunning = false
            timerIsRunning = false
            
            Wait(2500)
            Citizen.InvokeNative(0x9D746964E0CF2C5F,frontend_soundset_name, frontend_soundset_ref)  -- stop audio
            is_frontend_sound_playing = false
        end
    else
        gameIsRunning = false
        timerIsRunning = false
        cleanupItems()
    end
    
end)

Citizen.CreateThread(function()
    while true do

        local sleep = true
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        
        if gameIsRunning then
            for i,v in pairs(shootingItems) do
                if DoesEntityExist(i) then
                    if HasEntityBeenDamagedByAnyPed(i) then
                        if HasEntityBeenDamagedByEntity(i, player) then
                            cleanupItems()
                        else
                            gameIsRunning = false
                            timerIsRunning = false
                            cleanupItems()
                            VORPcore.NotifyLeft(Config.Language.cheaterTitle,Config.Language.cheaterDesc,"toast_log_blips","blip_region_hunting",4000,"COLOR_WHITE")
                        end
                    end
                end
                if IsPedDeadOrDying(player) then
                    gameIsRunning = false
                    timerIsRunning = false
                    cleanupItems()
                end
                if location then
                    if GetDistanceBetweenCoords(coords, Config.shootingLocations[location].startCoord.x, Config.shootingLocations[location].startCoord.y, Config.shootingLocations[location].startCoord.z, true) > 1.5 then
                        gameIsRunning = false
                        timerIsRunning = false
                        cleanupItems()                       
                        VORPcore.NotifyLeft(Config.Language.areaTitle,Config.Language.areaDesc,"toast_log_blips","blip_region_hunting",4000,"COLOR_WHITE")
                    end
                end
            end
            sleep = false
        end

        for k, v in pairs(Config.shootingLocations) do
            if GetDistanceBetweenCoords(coords, v.startCoord.x, v.startCoord.y, v.startCoord.z, true) < Config.DrawCircleDistance then
                DrawCircle3(v.startCoord.x, v.startCoord.y, v.startCoord.z)
                if GetDistanceBetweenCoords(coords, v.startCoord.x, v.startCoord.y, v.startCoord.z, true) < 1.5 and not gameIsRunning then
                    DrawText(Config.Language.startprompt, 0.50, 0.90, 0.6, 0.6, true, 255, 255, 255, 255, true, 10000)
                    if IsControlJustReleased(0, 0xD9D0E1C0) then
                        TriggerEvent("wessy_shooting:start", k)
                    end
                end
                sleep = false
            end
        end
       
        if sleep then
            Citizen.Wait(1500)
        else
            Citizen.Wait(0)
        end
        
    end
end)
