local DataStoreService = game:GetService "DataStoreService"
local HttpService = game:GetService "HttpService"
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local Knit = require(ReplicatedStorage.Packages.Knit)
local Colours = require(ReplicatedStorage.Shared.Colours)
local Settings = require(ReplicatedStorage.Shared.Settings)
local ShopItems = require(ReplicatedStorage.Shared.ShopItems)
local ProfileService = require(game:GetService("ServerScriptService").Server.ProfileService)
local Badge = require(script.Parent.Parent.Badge)

-- *daft punk - get lucky plays*
-- This game has ProfileService.
-- Brought to you by Mad Studio.

local DefaultProfileTemplate = {
	WordsTyped = 0,
	Experience = 0,
	Level = 0,
	Currency = 0,

	Stats = {
		PlayTime = 0,
		Logins = 0,
		LongestStreak = 0,
		Words = {
			Easy = 0,
			Medium = 0,
			Hard = 0,
			Insane = 0,
		},
		TotalCurrency = 0,
		CurrencySpent = 0,
	},

	Theme = (function()
		local returns = {}
		for i, v in pairs(Colours) do
			returns[i] = { v.R, v.G, v.B } -- can't store Color3 (userdata) in DataStore
		end
		return returns
	end)(),

	Verified = false,

	ShopPurchases = {
		Wordlists = (function()
			local returns = {}
			for i, _ in pairs(ShopItems[1].Items) do
				returns[i] = false
			end
			return returns
		end)(),
	},
	Settings = Settings,
}

local DefaultUserTemplate = {
	DefaultProfileTemplate,
	DefaultProfileTemplate,
	DefaultProfileTemplate,
	DefaultProfileTemplate,
	DefaultProfileTemplate,
}

local ProfileStore = ProfileService.GetProfileStore("PlayerData_testing124", DefaultUserTemplate)
local LevelLeaderboard = DataStoreService:GetOrderedDataStore "LevelLeaderboard_testing124"
local WordsLeaderboard = DataStoreService:GetOrderedDataStore "WordsLeaderboard_testing124"

local Profiles = {}
local CurrentSaveSlot = {}
local ProfileViews = {}
local counter

local DataService = Knit.CreateService {
	Name = "DataService",
}

function UpdateLeaderboard(player)
	local saveSlot = CurrentSaveSlot[player]
	local data = Profiles[player].Data[saveSlot]

	LevelLeaderboard:SetAsync(player.UserId .. "_" .. saveSlot, data.Level)
	WordsLeaderboard:SetAsync(player.UserId .. "_" .. saveSlot, data.WordsTyped)
end

function DataService.Client:LevelLeaderboard(player)
	local topTen = LevelLeaderboard:GetSortedAsync(false, 10):GetCurrentPage()
	local returns = {}

	for _, data in ipairs(topTen) do
		if
			tonumber(data.key:split("_")[1]) == player.UserId
			and tonumber(data.key:split("_")[2]) == CurrentSaveSlot[player]
		then
			table.insert(returns, { Player = "You" })
			Badge:AwardBadge(player, 2128814962) -- Top 10 Level
			continue
		end
		table.insert(returns, {
			Player = data.key:split("_")[1],
			Profile = data.key:split("_")[2],
			Level = data.value,
			Words = WordsLeaderboard:GetAsync(data.key),
		})
	end

	return returns
end
function DataService.Client:WordsLeaderboard(player)
	local topTen = WordsLeaderboard:GetSortedAsync(false, 10):GetCurrentPage()
	local returns = {}

	for _, data in ipairs(topTen) do
		if
			tonumber(data.key:split("_")[1]) == player.UserId
			and tonumber(data.key:split("_")[2]) == CurrentSaveSlot[player]
		then
			table.insert(returns, { Player = "You" })
			Badge:AwardBadge(player, 2128814964) -- Top 10 Words
			continue
		end
		table.insert(returns, {
			Player = data.key:split("_")[1],
			Profile = data.key:split("_")[2],
			Level = LevelLeaderboard:GetAsync(data.key),
			Words = data.value,
		})
	end

	return returns
end

function DataService.Client:LoadData(player, SaveSlot)
	if Profiles[player] and not CurrentSaveSlot[player] then
		CurrentSaveSlot[player] = SaveSlot
		local slot = Profiles[player].Data[SaveSlot]
		UpdateLeaderboard(player)
		slot.Stats.Logins += 1

		counter = task.spawn(function()
			while task.wait(1) do
				Profiles[player].Data[SaveSlot].Stats.PlayTime += 1
			end
		end)
		-- Award badges for time spent in game
		task.spawn(function()
			Badge:AwardBadge(player, 2128696002) -- Welcome!

			if slot.Stats.PlayTime > 3600 * 8 then
				Badge:AwardBadge(player, 2128888555) -- Fan
			end
			if slot.Stats.PlayTime > 3600 * 30 then
				Badge:AwardBadge(player, 2128888557) -- Expert
			end
			if slot.Stats.PlayTime > 3600 * 100 then
				Badge:AwardBadge(player, 2128888558) -- Veteran
			end
			if slot.Stats.PlayTime > 3600 * 300 then
				Badge:AwardBadge(player, 2128888559) -- Champion
			end

			task.wait(3600)
			Badge:AwardBadge(player, 2128873301) -- Enthusiast
			task.wait(3600 * 2)
			Badge:AwardBadge(player, 2128873302) -- Dedicated
			task.wait(3600 * 2)
			Badge:AwardBadge(player, 2128873304) -- Aficionado
			task.wait(3600 * 3)
			Badge:AwardBadge(player, 2128888554) -- Devotee
		end)

		return slot
	end
end
function DataService.Client:GetStats(player)
	return Profiles[player].Data[CurrentSaveSlot[player]].Stats
end

function DataService.Client:PrepareData(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			ProfileViews[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick "\n\nYour data may have been loaded on another server. Please rejoin and try again.\n"
		end)
		if player:IsDescendantOf(Players) then
			-- A profile has been successfully loaded:
			print "Data prepared"
			Profiles[player] = profile
			ProfileViews[player] = profile.Data
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		-- Roblox servers trying to load this profile at the same time:
		player:Kick "\n\nYour data could not be loaded. Please rejoin and try again.\n"
	end
end

function DataService.Client:PreviewData(player, SaveSlot)
	local view = ProfileViews[player]
	if view ~= nil and view[SaveSlot] ~= nil then
		if player:IsDescendantOf(Players) == true then
			return view[SaveSlot]
		end
	else
		return DefaultProfileTemplate
	end
end

function DataService.Client:ItemOwned(player, categoryName, item)
	return DataService:ItemOwned(player, categoryName, item)
end
function DataService:ItemOwned(player, categoryName, item)
	return DataService:GetData(player, "ShopPurchases")[categoryName][item]
end

function DataService.Client:GetSetting(player, setting)
	return DataService:GetSetting(player, setting)
end
function DataService:GetSetting(player, setting)
	return DataService:GetData(player, "Settings")[setting]
end

function DataService:GetData(player, variable)
	local slot = Profiles[player].Data[CurrentSaveSlot[player]]

	-- Variable could be a list of values denoting a path to access:
	-- todo make this a function
	if typeof(variable) == "table" then
		for i = 1, #variable - 1 do
			slot = slot[variable[i]]
		end
		return slot[variable[#variable]]
	else
		return slot[variable]
	end
end

function DataService:SetData(player, variable, value)
	local slot = Profiles[player].Data[CurrentSaveSlot[player]]

	if typeof(variable) == "table" then
		for i = 1, #variable - 1 do
			slot = slot[variable[i]]
		end
		slot[variable[#variable]] = value
	else
		slot[variable] = value
	end
end
function DataService:IncrementData(player, variable, value)
	local slot = Profiles[player].Data[CurrentSaveSlot[player]]

	if typeof(variable) == "table" then
		for i = 1, #variable - 1 do
			slot = slot[variable[i]]
		end

		local var = slot[variable[#variable]]
		if var then
			slot[variable[#variable]] += value
		else
			slot[variable[#variable]] = value
		end
	else
		slot[variable] += value
	end
end

function DataService.Client:Verify(player, code)
	local response = HttpService:RequestAsync {
		Url = "http://echat.ddns.net:7777",
		-- was using this domain for echat
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
		},
		Body = HttpService:JSONEncode {
			code = code,
			player = player.Name,
			userId = player.UserId,
		},
	}

	if response.Body == "success" then
		Profiles[player].Data[CurrentSaveSlot[player]].Verified = true
		Badge:AwardBadge(player, 2129375774) -- Verified
		return true
	else
		return false
	end
end

function DataService.Client:SaveTheme(player, colourName, colour)
	local slot = Profiles[player].Data[CurrentSaveSlot[player]]
	if not slot.Theme then
		slot.Theme = {}
	end
	if typeof(colourName) == "string" then
		slot.Theme[colourName] = { colour.R, colour.G, colour.B }
	else
		return false
	end
end

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if counter then
		task.cancel(counter)
	end
	if profile ~= nil then
		profile:Release()
	end
end)

return DataService
