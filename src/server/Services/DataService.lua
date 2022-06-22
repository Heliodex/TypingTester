local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(game:GetService("ServerScriptService").Server.ProfileService)

local ProfileTemplate = {
	WordsTyped = 0,
	Experience = 0,
	Currency = 0,

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

local DataService = Knit.CreateService({
	Name = "DataService",
})

function DataService.Client:LoadData()
	return "bruh"
end

function DataService.Client:UpdateData() end

return DataService
