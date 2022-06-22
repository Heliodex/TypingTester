local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local DataStore2 = require(game:GetService("ServerScriptService").Server.DataStore2)

local DataService = Knit.CreateService({
	Name = "DataService",
})

function DataService.Client:GetData()
	return "bruh"
end

return DataService
