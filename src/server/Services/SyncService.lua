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

local DataService
local SyncService = Knit.CreateService({
	Name = "SyncService",
})

local experience
local level

function SyncService:KnitStart()
	DataService = Knit.GetService("DataService")
end

function SyncService.Client:GetSeed()
	return seed
end

function SyncService.Client:WordTyped(player)
	experience = DataService:GetData(player, "Experience")
	level = DataService:GetData(player, "Level")

	DataService:IncrementData(player, "WordsTyped", 1)

	local expToAdd = rand:NextInteger(3, 10)
	if experience + expToAdd > level * 100 then
		experience += expToAdd - level * 100
		DataService:IncrementData(player, "Experience", expToAdd - level * 100)
		level += 1
		DataService:IncrementData(player, "Level", 1)
	else
		experience += expToAdd
		DataService:IncrementData(player, "Experience", expToAdd)
	end

	DataService:IncrementData(player, "Currency", 1)
end

return SyncService
