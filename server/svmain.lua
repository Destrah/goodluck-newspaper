QBCore = exports['qb-core']:GetCoreObject()
local connectedPlayers = {}
local debugprint, arrester1, arrester2, arrester3 = false, true, false, false
local weazelNewsAccount = ""
local weazelNewsIdentifier = ""
local secretCodes = {}
local claimedCodes = {}
local secretCodeLastChanged = 0
local currentSecretCodePos = 1
local currentSecretDigitPos = 1
local digitsDisplayed = {}
local playersClaimed = {}
local newspaperaccessed = {}
local luckyNumberTries = {}
local liveInfo = {
	isLive = false,
	liveID = ""
}

local articles = {}
local globalMotd = ""
local globalArrests = {}
local globalWarrants = {}

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	while QBCore == nil do QBCore = exports['qb-core']:GetCoreObject() Citizen.Wait(10); end; 
	
	exports.oxmysql:single('SELECT `name` FROM player_business_accounts WHERE label = "Weazel News";', {}, function(result)
		weazelNewsAccount = result.name
	end)
	exports.oxmysql:single('SELECT `uniqueid` FROM player_business WHERE business = "Weazel News";', {}, function(result)
		weazelNewsIdentifier = result.uniqueid
		for k, v in pairs(QBCore.Functions.GetPlayers()) do
			TriggerClientEvent("newspaper-cl:PlayerLoaded", v, weazelNewsIdentifier)
		end
	end)
	secretCodeLastChanged = os.time()
	for i = 1, 6, 1 do 
		table.insert(secretCodes, tostring(QBCore.Shared.RandomInt(4)))
	end
	exports.oxmysql:query("SELECT * FROM newspaper", {}, function(result)
		exports.oxmysql:single("SELECT * FROM newspaper_motd WHERE id = 1", {}, function(motd)
			exports.oxmysql:query("SELECT * FROM mdw_pd_incidents i RIGHT JOIN mdw_pd_convictions c ON i.id = c.linkedincident JOIN players p ON c.cid = p.citizenid LEFT JOIN mdw_policemdwdata dat ON c.cid = dat.cid WHERE c.guilty = 1 AND c.sentence > 0 AND isCite = 0 ORDER BY i.id DESC LIMIT 5;", {}, function(arrests)
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
					table.insert(arrestData, {linkedincident = arrests[i].linkedincident, cid = arrests[i].citizenid, charges = charges, name = name, date = date, issuedjail = issuedjail, author = arrests[i].author, picture = arrests[i].picture})
				end
				exports.oxmysql:query('SELECT * FROM mdw_pd_convictions c JOIN players p ON c.cid = p.citizenid LEFT JOIN mdw_policemdwdata dat ON c.cid = dat.cid WHERE c.processed = "0" AND c.guilty = "0" AND c.warrant = "1" AND c.warrantpublic = 1 ORDER BY c.id DESC LIMIT 5;', {}, function(warrants)
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
						table.insert(warrantData, {linkedincident = warrants[i].linkedincident, cid = warrants[i].citizenid, charges = charges, name = name, date = date, picture = warrants[i].picture})
					end
					if (os.time() - secretCodeLastChanged) >= 900 then
						local addition = math.floor((os.time() - secretCodeLastChanged) / 900)
						for i = 1, addition, 1 do
							if currentSecretDigitPos == #secretCodes[currentSecretCodePos] then
								if currentSecretCodePos == #secretCodes then
									currentSecretCodePos = 1
								else
									currentSecretCodePos += 1
								end
								currentSecretDigitPos = 1
							else
								currentSecretDigitPos += 1
							end
						end
						secretCodeLastChanged = os.time() + ((os.time() - secretCodeLastChanged) % 900)
					end
					globalArrests = arrestData
					globalWarrants = warrantData
					globalMotd = motd.message
					articles = result
				end)
			end)
		end)
	end)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
	TriggerClientEvent("newspaper-cl:PlayerLoaded", Player.PlayerData.source, weazelNewsIdentifier)
end)

RegisterNetEvent("newspaper-sv:openArticleManager", function()
	local _source = source
	MySQL.Async.fetchAll("SELECT * FROM newspaper", {}, function(result)
		TriggerClientEvent("newspaper-cl:openArticleManager", _source, result)
	end)
end)

RegisterNetEvent("newspaper-sv:updateArticles", function(article)
	articles[article.article] = {title = article.title, subtitle = article.subtitle, body = article.body}
	exports.oxmysql:update('UPDATE newspaper SET title = ?, subtitle = ?, body = ? WHERE id = ?', {
		article.title, article.subtitle, article.body, article.article
	}, function(affectedRows)
	end)
end)

RegisterNetEvent("newspaper-sv:changeMOTD", function(...)
	local args = ...
	globalMotd = table.concat(args, " ")
	exports.oxmysql:update('UPDATE newspaper_motd SET message = ? WHERE id = ?', {
		globalMotd, 1
	}, function(affectedRows)
	end)
end)

RegisterNetEvent("newspaper:open")
AddEventHandler("newspaper:open", function(isItem)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	if (os.time() - secretCodeLastChanged) >= 900 then
		local addition = math.floor((os.time() - secretCodeLastChanged) / 900)
		for i = 1, addition, 1 do
			if currentSecretDigitPos == #secretCodes[currentSecretCodePos] then
				if currentSecretCodePos == #secretCodes then
					currentSecretCodePos = 1
				else
					currentSecretCodePos += 1
				end
				currentSecretDigitPos = 1
			else
				currentSecretDigitPos += 1
			end
			Citizen.Wait(0)
		end
		secretCodeLastChanged = os.time() + ((os.time() - secretCodeLastChanged) % 900)
	end
	TriggerClientEvent("newspaper:open", _source, articles, globalArrests, globalWarrants, globalMotd, {digit = string.sub(secretCodes[currentSecretCodePos], currentSecretDigitPos, currentSecretDigitPos), digitNumber = currentSecretDigitPos, codeNumber = currentSecretCodePos}, liveInfo)
	if (newspaperaccessed[xPlayer.PlayerData.citizenid] == nil or (os.time() - newspaperaccessed[xPlayer.PlayerData.citizenid]) > 300) and not isItem then
		exports['brazzers-banking']:calculateBusinessFund(_source, weazelNewsAccount, 100, 99, "services", "Used Newspaper Stand")
		newspaperaccessed[xPlayer.PlayerData.citizenid] = os.time()
	end
end)

RegisterNetEvent("newspaper-sv:buyPaper", function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local money = { cash = Player.PlayerData.money.cash, bank = Player.PlayerData.money.bank }
	if money.cash >= 500 then
		Player.Functions.RemoveMoney('cash', 500, 'newspaper')
		exports.ox_inventory:AddItem(src, "newspaper", 1)
		exports['brazzers-banking']:calculateBusinessFund(_source, weazelNewsAccount, 500, 99, "services", "Used Newspaper Stand")
	elseif money.bank >= 500 then
		Player.Functions.RemoveMoney('bank', 500, 'newspaper')
		exports.ox_inventory:AddItem(src, "newspaper", 1)
		exports['brazzers-banking']:calculateBusinessFund(_source, weazelNewsAccount, 500, 99, "services", "Used Newspaper Stand")
	end
end)

local updateQueue = nil
local handlingQueue = false

RegisterNetEvent("newspaper-sv:UpdateArrestAndWarrantData", function(arrestInfo, incidentid, time, isArrest)
    List.pushright(updateQueue, {arrestInfo, incidentid, time, isArrest})
	handledQueue()
end)

function handledQueue()
	if not handlingQueue then
		handlingQueue = true
		Citizen.CreateThread(function()
			while handlingQueue do
				if updateQueue.last >= updateQueue.first then
					local info = updateQueue[updateQueue.first]
					if info[4] then
						globalArrests = UpdateArrestAndWarrants(info[1], info[2], info[3], globalArrests, info[4])
					else
						globalWarrants = UpdateArrestAndWarrants(info[1], info[2], info[3], globalWarrants, info[4])
					end
                    List.popleft(updateQueue)
				else
					handlingQueue = false
				end
			end
		end)
	end
end

Citizen.CreateThread(function()
	updateQueue = List.new()
	while updateQueue == nil do
		Citizen.Wait(100)
		updateQueue = List.new()
	end
end)

function UpdateArrestAndWarrants(arrestInfo, incidentid, time, sentTable, isArrest)
	local dataTable = sentTable
	local lowestIncNumber = 999999999
	local attemptToAddOrUpdate = false
	if isArrest then
		if arrestInfo["recsentence"] == nil or arrestInfo["recsentence"] == "" then
			arrestInfo["recsentence"] = 0
		else
			arrestInfo['recsentence'] = tonumber(arrestInfo['recsentence'])
		end
		if arrestInfo['Guilty'] and tonumber(arrestInfo["recsentence"]) > 0 and table.type(arrestInfo['Charges']) ~= "empty" then
			attemptToAddOrUpdate = true
		end
	else
		if arrestInfo['WarrantPublic'] and table.type(arrestInfo['Charges']) ~= "empty" then
			attemptToAddOrUpdate = true
		end
	end
	if attemptToAddOrUpdate then
		local charges = {}
		for j = 1, #arrestInfo['Charges'], 1 do
			if charges[arrestInfo['Charges'][j]] == nil then
				charges[arrestInfo['Charges'][j]] = 1
			else
				charges[arrestInfo['Charges'][j]] += 1
			end
		end
		local needToUpdate = -1
		for i = 1, #dataTable, 1 do
			if tonumber(dataTable[i].linkedincident) < lowestIncNumber then lowestIncNumber = tonumber(dataTable[i].linkedincident) end
			if tonumber(dataTable[i].linkedincident) == tonumber(incidentid) and tonumber(dataTable[i].cid) == tonumber(arrestInfo["Cid"]) then
				dataTable[i].charges = charges
				dataTable[i].issuedjail = arrestInfo['recsentence']
				needToUpdate = i
				break
			end
		end
		if (tonumber(incidentid) >= lowestIncNumber or #dataTable < 5) and needToUpdate == -1 then
			for i = #dataTable + 1, 1, -1 do
				if i < 6 then
					dataTable[i] = dataTable[i - 1]
				end
			end
			local date = os.date('%Y-%m-%d %H:%M:%S', QBCore.Shared.Round(time / 1000))
			local authorResult = exports.oxmysql:single_async('SELECT author FROM mdw_pd_incidents WHERE id = ?', {
				incidentid
			})
			local nameResult = exports.oxmysql:single_async('SELECT charinfo FROM players WHERE citizenid = ?', {
				arrestInfo["Cid"]
			})
			local pictureResult = exports.oxmysql:single_async('SELECT picture FROM mdw_policemdwdata WHERE cid = ?', {
				arrestInfo["Cid"]
			})
			local picture = "img/male.png"
			if pictureResult then
				picture = pictureResult.picture
			end
			local charinfo = json.decode(nameResult.charinfo)
			dataTable[1] = {linkedincident = incidentid, cid = arrestInfo["Cid"], charges = charges, name = charinfo.firstname .. ' ' .. charinfo.lastname, date = date, issuedjail = arrestInfo['recsentence'], author = authorResult.author, picture = picture}
		elseif needToUpdate ~= -1 then
			local date = os.date('%Y-%m-%d %H:%M:%S', QBCore.Shared.Round(time / 1000))
			local authorResult = exports.oxmysql:single_async('SELECT author FROM mdw_pd_incidents WHERE id = ?', {
				incidentid
			})
			local nameResult = exports.oxmysql:single_async('SELECT charinfo FROM players WHERE citizenid = ?', {
				arrestInfo["Cid"]
			})
			local pictureResult = exports.oxmysql:single_async('SELECT picture FROM mdw_policemdwdata WHERE cid = ?', {
				arrestInfo["Cid"]
			})
			local picture = "img/male.png"
			if pictureResult then
				picture = pictureResult.picture
			end
			local charinfo = json.decode(nameResult.charinfo)
			dataTable[needToUpdate] = {linkedincident = incidentid, cid = arrestInfo["Cid"], charges = charges, name = charinfo.firstname .. ' ' .. charinfo.lastname, date = date, issuedjail = arrestInfo['recsentence'], author = authorResult.author, picture = picture}
		end
	else
		local arrestToRemove = -1
		local lowestIncidentNumber = -1
		local lowestCID = ""
		for i = 1, #dataTable, 1 do
			if lowestIncidentNumber == -1 or tonumber(dataTable[i].linkedincident) < lowestIncidentNumber then
				lowestIncidentNumber = tonumber(dataTable[i].linkedincident)
			end
			if tonumber(dataTable[i].linkedincident) == tonumber(incidentid) and tonumber(dataTable[i].cid) == tonumber(arrestInfo["Cid"]) then
				arrestToRemove = i
			end
		end
		if arrestToRemove ~= -1 then
			for i = 1, #dataTable, 1 do
				if lowestIncidentNumber == tonumber(dataTable[i].linkedincident) then
					lowestCID = lowestCID .. tostring(dataTable[i].cid) .. ', '
				end
			end
			lowestCID = lowestCID:gsub("(.*), ", "%1")
			if lowestIncidentNumber ~= -1 then
				for i = arrestToRemove, (#dataTable - 1), 1 do
					dataTable[i] = dataTable[i + 1]
				end
				local searchQuery = 'SELECT * FROM mdw_pd_convictions WHERE processed = "0" AND guilty = "0" AND warrant = "1" AND warrantpublic = 1 AND ((linkedincident = ? AND cid NOT IN (' .. lowestCID .. ')) OR linkedincident < ?) ORDER BY id DESC LIMIT 1;'
				if isArrest then
					searchQuery = 'SELECT * FROM mdw_pd_convictions WHERE guilty = "1" AND sentence > 0 AND ((linkedincident = ? AND cid NOT IN (' .. lowestCID .. ')) OR linkedincident < ?) ORDER BY id DESC LIMIT 1;'
				end
				exports.oxmysql:single(searchQuery, {lowestIncidentNumber, lowestIncidentNumber}, function(arrestData)
					if arrestData then
						local date = os.date('%Y-%m-%d %H:%M:%S', QBCore.Shared.Round(arrestData.time / 1000))
						local authorResult = exports.oxmysql:single_async('SELECT author FROM mdw_pd_incidents WHERE id = ?', {
							arrestData.linkedincident
						})
						local nameResult = exports.oxmysql:single_async('SELECT charinfo FROM players WHERE citizenid = ?', {
							arrestData.cid
						})
						local pictureResult = exports.oxmysql:single_async('SELECT picture FROM mdw_policemdwdata WHERE cid = ?', {
							arrestData.cid
						})
						local picture = "img/male.png"
						if pictureResult then
							picture = pictureResult.picture
						end
						local charges = {}
						local parsedCharges = json.decode(arrestData.charges)
						for j = 1, #parsedCharges, 1 do
							if charges[parsedCharges[j]] == nil then
								charges[parsedCharges[j]] = 1
							else
								charges[parsedCharges[j]] += 1
							end
						end
						local charinfo = json.decode(nameResult.charinfo)
						dataTable[#dataTable] = {linkedincident = arrestData.linkedincident, cid = arrestData.cid, charges = charges, name = charinfo.firstname .. ' ' .. charinfo.lastname, date = date, issuedjail = issuedjail, author = authorResult.author, picture = picture}
					else
						table.remove(dataTable, #dataTable)
					end
				end)
			end
		end
	end
	return dataTable
end

RegisterNetEvent("newspaper-sv:TryLuckyNumber", function()
	local _source = source
	TriggerClientEvent("newspaper-cl:TryLuckyNumber", _source)
end)

local lootTable = {
    ["fishingrod"] = {300, {[1] = 50, [2] = 40, [3] = 30}},
    ["lawnmower"] = {200, {[1] = 1}},
    ["miningdrill"] = {300, {[1] = 50, [2] = 40, [3] = 30}},
    ["radio"] = {200, {[1] = 50, [2] = 40, [3] = 30}},
    ["nvg"] = {100, {[1] = 50, [2] = 15}},
}

RegisterNetEvent("newspaper-sv:CheckLuckyNumber", function(luckyNumber)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	if luckyNumberTries[xPlayer.PlayerData.citizenid] == nil or (os.time() - luckyNumberTries[xPlayer.PlayerData.citizenid]) > 300 then
		if playersClaimed[xPlayer.PlayerData.citizenid] == nil then
			luckyNumberTries[xPlayer.PlayerData.citizenid] = os.time()
			local codeFound = false
			for i = 1, #secretCodes, 1 do
				if luckyNumber == secretCodes[i] then
					if claimedCodes[secretCodes[i]] == nil then
						local weight = 0
						for _, data in pairs(lootTable) do
							weight += data[1]
						end
						local choice = math.random(1, weight)
						for item, data in pairs(lootTable) do
							weight -= data[1]
							if choice > weight then
								local weightAmount = 0
								for _, dataAmount in pairs(lootTable[item][2]) do
									weightAmount += dataAmount
								end
								local choiceAmount = math.random(1, weightAmount)
								for amount, dataAmount in pairs(lootTable[item][2]) do
									weightAmount -= dataAmount
									if choiceAmount > weightAmount then
										exports.ox_inventory:AddItem(_source, item, amount)
										break
									end
								end
								break
							end
						end
						playersClaimed[xPlayer.PlayerData.citizenid] = os.time()
						claimedCodes[secretCodes[i]] = true
						codeFound = true
						QBCore.Functions.Notify(_source, "Code redeemed", "success")
						break
					else
						QBCore.Functions.Notify(_source, "Code already claimed", "error")
					end
				end
			end
		else
			QBCore.Functions.Notify(_source, "You can only claim one code per tsunamic", "error")
		end
		if not codeFound then
			QBCore.Functions.Notify(_source, "Code not correct", "error")
		end
	else
		--Let them know they can only try once every 5 minutes
		QBCore.Functions.Notify(_source, "You can only attempt once every 5 minutes", "error")
	end
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

RegisterNetEvent("newspaper-sv:setLive", function(liveID)
	if liveID then
		liveInfo.isLive = true
		liveInfo.liveID = liveID
	else
		liveInfo.isLive = false
		liveInfo.liveID = ""
	end
	TriggerClientEvent("newspaper-cl:updateLiveInfo", -1, liveInfo)
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

List = {}
function List.new()
    return {first = 0, last = -1}
end

function List.pushleft (list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end
  
function List.pushright (list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end

function List.popleft (list)
    local first = list.first
    if first > list.last then error("list is empty") end
    local value = list[first]
    list[first] = nil        -- to allow garbage collection
    list.first = first + 1
    return value
end

function List.popright (list)
    local last = list.last
    if list.first > last then error("list is empty") end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
    return value
end