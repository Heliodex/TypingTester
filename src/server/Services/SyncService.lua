--[[
How syncing works
	When any data is updated, the client will also send a call to this module to update the data stored on the server.
	There will be latency, this does not really matter.
	All functions here are ratelimited so even if the client is exploited, not much damage can be done.
	This means that the true data should be stored on the server for data saving.
]]

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local seed = math.random()
local rand = Random.new(seed)

local currency = 0
local experience = 0
local wordsTyped = 0

local SyncService = Knit.CreateService({
	Name = "SyncService",
})

function SyncService.Client:GetSeed()
	return self.Server:GetSeed()
end
function SyncService:GetSeed()
	return seed
end

function SyncService.Client:WordTyped()
	wordsTyped += 1
	currency += 1
	experience += 5
	print(wordsTyped .. " words, " .. currency .. " currency, " .. experience .. " experience")
end

return SyncService
