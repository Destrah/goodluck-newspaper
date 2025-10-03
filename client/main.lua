local display, toggleDisplay, paperon, param = false, true, true, ""
local PaperStandModels = { [3108197479] = true,[1211559620] = true,[3917076173] = true,[720581693] = true,[261193082] = true,[2911910593] = true, [1375076930] = true, [917457845] = true, [3538814340] = true, [3456106952] = true, [-756152956] = true}
local businessIdentifier = ""
local lastAccess = 0

local NewsPaperProps = {
    [1] = "prop_news_disp_02a_s",
    [2] = "prop_news_disp_02c",
    [3] = "prop_news_disp_05a",
    [4] = "prop_news_disp_02e",
    [5] = "prop_news_disp_03c",
    [6] = "prop_news_disp_06a",
    [7] = "prop_news_disp_02a",
    [8] = "prop_news_disp_02d",
    [9] = "prop_news_disp_02b",
    [10] = "prop_news_disp_01a",
    [11] = "prop_news_disp_03a",
}

Citizen.CreateThread(function()
    QBCore = exports['qb-core']:GetCoreObject()
    PlayerData = {}
    while QBCore == nil do 
        QBCore = exports['qb-core']:GetCoreObject()
            Citizen.Wait(0)
    end
    while QBCore.Functions.GetPlayerData().job == nil do 
        Citizen.Wait(10)
    end
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerEvent("newspaper:off")
end)

RegisterNetEvent("newspaper-cl:PlayerLoaded", function(bizIdentifier)
    businessIdentifier = bizIdentifier
end)

RegisterNetEvent("news:OpenNewspaper")
AddEventHandler("news:OpenNewspaper", function()
    if Config.useNewsStands then
        if CanGrabPaper then
            if toggleDisplay then
                TriggerEvent("newspaper:on")
            else
                TriggerEvent("newspaper:off")
            end
        else
            TriggerEvent("newspaper:off")
        end
    else
        if toggleDisplay then
            TriggerEvent("newspaper:on")
        else
            TriggerEvent("newspaper:off")
        end
    end
end)

-- Citizen.CreateThread(function()
--     if Config.useNewsStands then
--         Citizen.CreateThread(function()
--             while true do
--                 Citizen.Wait(1000)
--                 local paperObject, paperDistance = Stand()
--                 if paperDistance < 3 then
--                     CanGrabPaper = true
--                 else
--                     CanGrabPaper = false
--                     if paperon then
--                         TriggerEvent("newspaper:off")
--                     end
--                 end
--             end
--         end)
--     end
-- end)

function Stand() 
    local coords, paperStands = GetEntityCoords(PlayerPedId()), {}
    local handle, object = FindFirstObject()
    local success
    repeat
        if PaperStandModels[GetEntityModel(object)] then
            table.insert(paperStands, object)
        end
        success, object = FindNextObject(handle, object)
    until not success
    EndFindObject(handle)
    local paperObject, paperDistance = 0, 1000
    for k,v in pairs(paperStands) do
        local dstcheck = GetDistanceBetweenCoords(coords, GetEntityCoords(v))
        if dstcheck < paperDistance then 
            paperDistance = dstcheck
            paperObject = v
        end
    end
    return paperObject, paperDistance
end

RegisterNetEvent("newspaper:off")
AddEventHandler("newspaper:off", function(value)
    ExecuteCommand("e c")
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'ui',
        display = false
    })
    toggleDisplay = true
    managinArticles = false
    paperon = false
end)

RegisterNUICallback("close", function(data, cb)
    ExecuteCommand("e c")
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'ui',
        display = false
    })
    toggleDisplay = true
    managinArticles = false
    paperon = false
end)

RegisterNetEvent("newspaper:on")
AddEventHandler("newspaper:on", function(value)
    if GetNetworkTime() - lastAccess >= 500 then
        lastAccess = GetNetworkTime()
        TriggerServerEvent("newspaper:open", false)
    end
end)

RegisterNetEvent('newspaper-cl:updateLiveInfo', function(liveInfo)
    if not toggleDisplay then
        SendNUIMessage({
            type = 'updateLive',
            liveInfo = liveInfo
        })
    end
end)

RegisterNetEvent("newspaper:open")
AddEventHandler("newspaper:open", function(columns, arrests, warrants, motd, secretInfo, liveInfo)
    ExecuteCommand("e newspaper3")
	local ems, police, avocat, mechanic, cardealer, estate, towtruck, pizza, burgershot, tuner, reporter, uwu, players = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	local citizenid = QBCore.Functions.GetPlayerData().citizenid
	-- for k,v in pairs(connectedPlayers) do
	-- 	if num == 1 then
	-- 		table.insert(formattedPlayerList, ('<tr><td>%s</td><td>%s</td><td>%s</td>'):format(v.name, v.id, v.ping))
	-- 		num = 2
	-- 	elseif num == 2 then
	-- 		table.insert(formattedPlayerList, ('<td>%s</td><td>%s</td><td>%s</td></tr>'):format(v.name, v.id, v.ping))
	-- 		num = 1
	-- 	end

	-- 	players = players + 1

	-- 	if v.job.name == 'ems' and v.job.onduty then
	-- 		ems = ems + 1
	-- 	elseif v.job.type == 'leo' and v.job.onduty then
	-- 		police = police + 1
	-- 	elseif v.job.name == 'doj' or v.job.name == 'da' and v.job.onduty then
	-- 		avocat = avocat + 1
	-- 	elseif v.job.name == 'mechanic' and v.job.onduty then
	-- 		mechanic = mechanic + 1
	-- 	elseif v.job.name == 'cardealer' and v.job.onduty then
	-- 		cardealer = cardealer + 1
	-- 	elseif v.job.name == 'realestate' and v.job.onduty then
	-- 		estate = estate + 1
	-- 	elseif v.job.name == 'towtruck' and v.job.onduty then
	-- 		towtruck = towtruck + 1
	-- 	elseif v.job.name == 'pizza' and v.job.onduty then
	-- 		pizza = pizza + 1
	-- 	elseif v.job.name == 'burgershot' and v.job.onduty then
	-- 		burgershot = burgershot + 1
	-- 	elseif v.job.name == 'reporter' and v.job.onduty then
	-- 		reporter = reporter + 1
	-- 	elseif v.job.name == 'uwu' and v.job.onduty then
	-- 		uwu = uwu + 1
	-- 	end
	-- end
    -- if police > 3 then
    --     police = "3+"
    -- end
    -- population = {
    --     total = players, 
    --     ems = ems, 
    --     police = police, 
    --     avocat= avocat, 
    --     mechanic = mechanic, 
    --     cardealer = cardealer, 
    --     estate = estate, 
    --     towtruck = towtruck, 
    --     pizza = pizza, 
    --     burgershot = burgershot,
    --     reporter = reporter,
    --     uwu = uwu
    -- }
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'ui',
        display = true,
        columns = columns,
        arrests = arrests,
        warrants = warrants,
        motd = motd,
        secretInfo = secretInfo,
        liveInfo = liveInfo

    })
    toggleDisplay = false
    paperon = true
end)

RegisterNetEvent("newspaper-cl:openArticleManager", function(columns)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'article',
        display = true,
        columns = columns
    })
end)

RegisterCommand("articlemanager", function()
    local permission = exports['brazzers-businesses']:inBusiness(businessIdentifier)
    if not permission then return QBCore.Functions.Notify("You don't have permission to do this", "error") end
    if not managinArticles then
        managinArticles = true
        TriggerServerEvent("newspaper-sv:openArticleManager")
    end
end)

RegisterCommand("newspaperLive", function(target, args, rawCommand)
    local permission = exports['brazzers-businesses']:inBusiness(businessIdentifier)
    if not permission then return QBCore.Functions.Notify("You don't have permission to do this", "error") end
    TriggerServerEvent("newspaper-sv:setLive", args[1])
end)

RegisterCommand("newspapermotd", function(target, args, rawCommand)
    local permission = exports['brazzers-businesses']:inBusiness(businessIdentifier)
    if not permission then return QBCore.Functions.Notify("You don't have permission to do this", "error") end
    TriggerServerEvent("newspaper-sv:changeMOTD", args)
end)

RegisterNUICallback("updateArticles", function(data, cb)
    TriggerServerEvent("newspaper-sv:updateArticles", data.article)
end)

RegisterNetEvent("newspaper-cl:TryLuckyNumber", function()
    local input = lib.inputDialog('Try The Lucky Code', {
        {type = "input", label = "Code", required = true, min = 4}
    })
    if input ~= nil then
        local code = input[1]
        TriggerServerEvent("newspaper-sv:CheckLuckyNumber",code)
    end
end)

CreateThread(function()
    for index, value in ipairs(NewsPaperProps) do
        exports['qb-target']:AddTargetModel(value, {
            options = {
                {
                    action = function()
                        if GetNetworkTime() - lastAccess >= 500 then
                            lastAccess = GetNetworkTime()
                            TriggerServerEvent("newspaper:open", false)
                        end
                    end,
                    icon = "fas fa-newspaper",
                    label = "View Paper",
                },
            },
            distance = 2.5
        })
        exports['qb-target']:AddTargetModel(value, {
            options = {
                {
                    action = function()
                        TriggerServerEvent("newspaper-sv:buyPaper")
                    end,
                    icon = "fas fa-newspaper",
                    label = "Buy Paper ($500)",
                },
            },
            distance = 2.5
        })
    end
end)

function viewpaper()
    if GetNetworkTime() - lastAccess >= 500 then
        lastAccess = GetNetworkTime()
	    TriggerServerEvent("newspaper:open", true)
    end
end

exports("viewpaper", viewpaper)