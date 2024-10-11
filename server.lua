local VorpCore = {}
local TopScore = {}


TriggerEvent("getCore",function(core)
    VorpCore = core
end)

Inventory = exports.vorp_inventory:vorp_inventoryApi()

AddEventHandler('onResourceStart', function(resourceName)
    local _source = source
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end   

    -- cleanup weekly
    local today = os.date('%A', realtimestamp)
    if today == "Sunday" then
        exports.ghmattimysql:execute("SELECT * FROM shooting_areas WHERE DATEDIFF(NOW(),date) > 0 AND DATEDIFF(NOW(),date) < 8", { }, function(result)
            if result[1] ~= nil then
                local cleanupItems = #result
                exports.ghmattimysql:execute("DELETE FROM shooting_areas WHERE DATEDIFF(NOW(),date) > 0 AND DATEDIFF(NOW(),date) < 8", { })

                print("Shooting Area | Cleanup SUCCESS | "..cleanupItems.." deleted.")
                Wait(5000)
                print("Shooting Area | Checking Data ...")
                exports.ghmattimysql:execute("SELECT * FROM shooting_areas", { }, function(result)
                    TopScore = result
                    local sumResult = #TopScore
                    print("Shooting Area | Got "..sumResult.." results")
                end) 
            else
                Wait(5000)
                exports.ghmattimysql:execute("SELECT * FROM shooting_areas", { }, function(result)
                    TopScore = result
                    local sumResult = #TopScore
                    print("Shooting Area | Got "..sumResult.." results")
                end) 
            end
        end) 
    end


	
end)

AddEventHandler('playerDropped', function()

    local _source = source
    local User = VorpCore.getUser(_source)
    if User ~= nil then
        local Character = User.getUsedCharacter
        local charidentifier = Character.charIdentifier
        local firstname = Character.firstname or ""
        local lastname = Character.lastname or ""
        local name = firstname .. ' ' .. lastname
        local now = os.date('%Y-%m-%d', realtimestamp)

        for i,v in pairs(TopScore) do
            if v.name == name then
                exports.ghmattimysql:execute('SELECT * FROM shooting_areas WHERE location=@location AND name=@name AND date=@date', { ['location'] = v.location, ['name'] = v.name, ['date'] = now }, function(result)
                    if result[1] ~= nil then
                        local Parameters = { ['name'] = v.name, ['time'] = v.time, ['targets'] = v.targets, ['location'] = v.location, ["name"] = v.name, ['date'] = now }
                        exports.ghmattimysql:execute("UPDATE shooting_areas Set name=@name, time=@time, targets=@targets, date=@date WHERE location=@location AND name=@name AND date=@date", Parameters)
                    else
                        local Parameters = { ['name'] = v.name, ['time'] = v.time, ['targets'] = v.targets, ['location'] = v.location, ["name"] = v.name, ['date'] = now }
                        exports.ghmattimysql:execute("INSERT INTO shooting_areas ( `name`, `time`, `targets`, `location`, `date` ) VALUES ( @name, @time, @targets, @location, @date )", Parameters)
                    end
                end)  
            end
        end  
    end
end)

RegisterServerEvent('wessy_shooting:save')
AddEventHandler('wessy_shooting:save',function(time, targets, location, closestPlayers)

    local _time = time
    local _closestPlayers = closestPlayers
    local _targets = targets
    local _location = location
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local charidentifier = Character.charIdentifier
    local firstname = Character.firstname or ""
    local lastname = Character.lastname or ""
    local name = firstname .. ' ' .. lastname
    
    if not TopScore[charidentifier] then
        TopScore[charidentifier] = { name = name, time = _time, targets = _targets, location = _location}
    else
        if tonumber(TopScore[charidentifier].time) > tonumber(_time) then
            TopScore[charidentifier] = { name = name, time = _time, targets = _targets, location = _location}
        end
    end

    local besttext
    local bestTime = nil

    for i,v in pairs(TopScore) do
        if v.location == _location then

            -- initial erster eintrag als bestzeit
            if bestTime == nil then
                bestTime = tonumber(v.time)
                besttext = "~q~" ..v.name .. "~q~ - ~e~" .. v.time .. "s~q~ (" .. v.targets .. " Ziele)" 
            end 

            -- weitere einträge prüfen ob bessere zeit
            if bestTime > tonumber(v.time) then
                bestTime = v.time
                besttext = "~q~" ..v.name .. "~q~ - ~e~" .. v.time .. "s~q~ (" .. v.targets .. " Ziele)"                 
            end

        end
    end

    local text = "~q~" ..name .. "~q~ - ~e~" .. _time .. "s~q~ (" .. _targets .. " Ziele)"
    TriggerClientEvent("wessy_shooting:showScore", _source, _location, text, besttext)

    for i, v in pairs(_closestPlayers) do
        TriggerClientEvent("wessy_shooting:showScore", i, _location, text, besttext)
    end

    --print_table(TopScore)
end)
