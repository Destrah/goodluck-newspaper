QBCore = exports['qb-core']:GetCoreObject()
local connectedPlayers = {}
local debugprint, arrester1, arrester2, arrester3 = false, true, false, false
local weazelNewsAccount = ""
newspaperaccessed = {}
Citizen.CreateThread(function()
	while QBCore == nil do QBCore = exports['qb-core']:GetCoreObject() Citizen.Wait(10); end; 
	
	exports.oxmysql:single('SELECT `name` FROM player_business_accounts WHERE label = "Weazel News";', {}, function(result)
		weazelNewsAccount = result.name
	end)
end)

RegisterNetEvent("newspaper:jail")
AddEventHandler("newspaper:jail", function(name,jailTime,sentenceType)
local bigbootybitches = name
local timeType = "month(s)"
if sentenceType == "community service" then
	timeType = "hour(s)"
end
local args = bigbootybitches .. " was sent to " .. sentenceType.. " for " .. jailTime .. " " .. timeType .. "."
if arrester1 and not arrester2 and not arrester3 then
    TriggerClientEvent("newspaper:arrest1", -1, args)
    arrester1 = false
    arrester2 = true
    MySQL.Sync.execute("UPDATE newspaper SET arrest1=@arrest1",{["@arrest1"] = args})
elseif not arrester1 and arrester2 and not arrester3 then
    TriggerClientEvent("newspaper:arrest2", -1, args)
    arrester2 = false
    arrester3 = true
    MySQL.Sync.execute("UPDATE newspaper SET arrest2=@arrest2",{["@arrest2"] = args})
elseif not arrester1 and not arrester2 and arrester3 then
    TriggerClientEvent("newspaper:arrest3", -1, args)
    arrester3 = false
    arrester1 = true
    MySQL.Sync.execute("UPDATE newspaper SET arrest3=@arrest3",{["@arrest3"] = args})
  end
end)

RegisterNetEvent("newspaper-sv:openArticleManager", function()
	local _source = source
	MySQL.Async.fetchAll("SELECT * FROM newspaper", {}, function(result)
		TriggerClientEvent("newspaper-cl:openArticleManager", _source, result)
	end)
end)

RegisterNetEvent("newspaper-sv:updateArticles", function(article)
	exports.oxmysql:update('UPDATE newspaper SET title = ?, subtitle = ?, body = ? WHERE id = ?', {
		article.title, article.subtitle, article.body, article.article
	}, function(affectedRows)
	end)
end)

RegisterNetEvent("newspaper-sv:changeMOTD", function(...)
	local args = ...
	exports.oxmysql:update('UPDATE newspaper_motd SET message = ? WHERE id = ?', {
		table.concat(args, " "), 1
	}, function(affectedRows)
	end)
end)

RegisterNetEvent("newspaper:open")
AddEventHandler("newspaper:open", function()
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	MySQL.Async.fetchAll("SELECT * FROM newspaper", {}, function(result)
		exports.oxmysql:single("SELECT * FROM newspaper_motd WHERE id = 1", {}, function(motd)
			MySQL.Async.fetchAll("SELECT * FROM mdw_pd_incidents i INNER JOIN mdw_pd_convictions c ON i.id = c.linkedincident JOIN players p ON c.cid = p.citizenid JOIN mdw_policemdwdata dat ON c.cid = dat.cid WHERE c.guilty = 1 AND c.sentence > 0 ORDER BY i.id DESC LIMIT 5;", {}, function(arrests)
				local arrestData = {}
				for i = 1, #arrests, 1 do
					local charges = {}
					local charInfo = json.decode(arrests[i].charinfo)
					local date = os.date('%Y-%m-%d %H:%M:%S', QBCore.Shared.Round(arrests[i].time / 1000))
					local name = charInfo.firstname .. " " .. charInfo.lastname
					local issuedjail = arrests[i].sentence
					arrests[i].charges = json.decode(arrests[i].charges)
					for j = 1, #arrests[i].charges, 1 do
						if charges[arrests[i].charges[j]] == nil then
							charges[arrests[i].charges[j]] = 1
						else
							charges[arrests[i].charges[j]] += 1
						end
					end
					table.insert(arrestData, {charges = charges, name = name, date = date, issuedjail = issuedjail, author = arrests[i].author, picture = arrests[i].picture})
				end
				--MySQL.Async.fetchAll("SELECT * FROM `largestblackjackwinner` WHERE `id` = '1'", {}, function(bjwinner)
				MySQL.Async.fetchAll('SELECT * FROM mdw_pd_convictions c JOIN players p ON c.cid = p.citizenid LEFT OUTER JOIN mdw_policemdwdata dat ON c.cid = dat.cid WHERE c.processed = "0" AND c.guilty = "0" AND c.warrant = "1" AND c.warrantpublic = 1 ORDER BY c.id DESC LIMIT 5;', {}, function(warrants)
					local warrantData = {}
					for i = 1, #warrants, 1 do
						local charges = {}
						local charInfo = json.decode(warrants[i].charinfo)
						local name = charInfo.firstname .. " " .. charInfo.lastname
						warrants[i].charges = json.decode(warrants[i].charges)
						for j = 1, #warrants[i].charges, 1 do
							if charges[warrants[i].charges[j]] == nil then
								charges[warrants[i].charges[j]] = 1
							else
								charges[warrants[i].charges[j]] += 1
							end
						end
						table.insert(warrantData, {charges = charges, name = name, date = date, picture = warrants[i].picture})
					end
					TriggerClientEvent("newspaper:open", _source, result, arrestData, connectedPlayers, {name = "Under Construction", amount = 0}, warrantData, motd.message)
				end)
			end)
		end)
	end)
	if newspaperaccessed[xPlayer.PlayerData.citizenid] == nil or (os.time() - newspaperaccessed[xPlayer.PlayerData.citizenid]) > 300 then
		exports['brazzers-banking']:calculateBusinessFund(_source, weazelNewsAccount, 10, 100, "services", "Used Newspaper Stand", "Used Newspaper Stand")
	end
	newspaperaccessed[xPlayer.PlayerData.citizenid] = os.time()
end)

AddEventHandler('QBCore:Server:OnJobUpdate', function(playerId, job, lastjob)
	connectedPlayers[playerId].job = job
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(xPlayer)
	AddPlayerToScoreboard(xPlayer, true)
end)

AddEventHandler("playerDropped", function()
	local playerId = source
	connectedPlayers[playerId] = nil
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		UpdatePing()
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			AddPlayersToScoreboard()
		end)
	end
end)

function AddPlayerToScoreboard(xPlayer, update)
	local playerId = xPlayer.PlayerData.source
	connectedPlayers[playerId] = {}
	connectedPlayers[playerId].ping = GetPlayerPing(playerId)
	connectedPlayers[playerId].id = playerId
	--[[local result = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE identifier = @identifier", {
        ['@identifier'] = GetPlayerIdentifiers(playerId)[1]
    })--]]
	connectedPlayers[playerId].name = xPlayer.PlayerData.citizenid
	connectedPlayers[playerId].job = xPlayer.PlayerData.job
end

function AddPlayersToScoreboard()
	while QBCore == nil do Citizen.Wait(10); end
	local players = QBCore.Functions.GetPlayers()

	for i=1, #players, 1 do
		local xPlayer = QBCore.Functions.GetPlayer(players[i])
		AddPlayerToScoreboard(xPlayer, false)
	end
end

function UpdatePing()
	for k,v in pairs(connectedPlayers) do
		v.ping = GetPlayerPing(k)
	end
end

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end