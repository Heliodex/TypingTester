local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(game:GetService("ServerScriptService").Server.ProfileService)

local DefaultProfileTemplate = {
	WordsTyped = 0,
	Experience = 0,
	Currency = 0,
	Stats = {
		PlayTime = 0,
		LoginTimes = 0,
	},

	ShopPurchases = {
		NormalMode = false,
		HardMode = false,
		InsaneMode = false,
	},
	Settings = {
		KeySounds = false,
		BlindMode = false,
		MemoryMode = false,
		PlainBG = false,
	},
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerData",
	DefaultProfileTemplate
)
local Profiles = {}

local DataService = Knit.CreateService({
	Name = "DataService",
})

local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile
			-- A profile has been successfully loaded:
			-- DoSomethingWithALoadedProfile(player, profile)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick()
	end
end

function DataService.Client:LoadData()
	return "bruh"
end

function DataService:UpdateData(variable)
end

return DataService
