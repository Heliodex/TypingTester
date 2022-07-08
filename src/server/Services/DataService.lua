local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(game:GetService("ServerScriptService").Server.ProfileService)

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
		Words = {
			Easy = 0,
			Normal = 0,
			Hard = 0,
			Insane = 0,
		},
	},

	ShopPurchases = {
		MediumDifficulty = false,
		HardDifficulty = false,
		InsaneDifficulty = false,
	},
	Settings = {
		KeySounds = false,
		BlindMode = false,
		MemoryMode = false,
		PlainBG = false,
	},
}

local DefaultUserTemplate = {
	DefaultProfileTemplate,
	DefaultProfileTemplate,
	DefaultProfileTemplate,
	DefaultProfileTemplate,
	DefaultProfileTemplate,
}

local ProfileStore = ProfileService.GetProfileStore("PlayerData_testing123", DefaultUserTemplate)
local Profiles = {}
local CurrentSaveSlot = {}
local ProfileViews = {}

local DataService = Knit.CreateService({
	Name = "DataService",
})

function DataService.Client:LoadData(player, SaveSlot)
	CurrentSaveSlot[player] = SaveSlot
	return Profiles[player].Data[SaveSlot]
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
			player:Kick()
		end)
		if player:IsDescendantOf(Players) then
			-- A profile has been successfully loaded:
			Profiles[player] = profile
			ProfileViews[player] = profile.Data
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		-- Roblox servers trying to load this profile at the same time:
		player:Kick("\n\nYour data could not be loaded. Please rejoin and try again.\n")
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

function DataService.Client:ItemOwned(player, item)
	return DataService:GetData(player, "ShopPurchases")[item]
end

function DataService.Client:GetSetting(player, setting)
	return DataService:GetData(player, "Settings")[setting]
end

function DataService:GetData(player, variable)
	return Profiles[player].Data[CurrentSaveSlot[player]][variable]
end

function DataService:SetData(player, variable, value)
	local slot = Profiles[player].Data[CurrentSaveSlot[player]]

	-- Variable could be a list of values denoting a path to access:
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
	Profiles[player].Data[CurrentSaveSlot[player]][variable] += value
end

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:Release()
	end
end)

return DataService
