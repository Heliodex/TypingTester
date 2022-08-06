--[[
How syncing works
	When any data is updated, the client will also send a call to this module to update the data stored on the server.
	There will be latency, this does not really matter.
	All functions here will be ratelimited so even if the client is exploited, not much damage can be done.
	This means that the true data should be stored on the server for data saving.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ShopItems = require(ReplicatedStorage.Shared.ShopItems)
local Words = require(ReplicatedStorage.Shared.Words)
local seed = math.random()
local rand = Random.new(seed)

local DataService
local SyncService = Knit.CreateService({
	Name = "SyncService",
})

local experience
local level
local wordlist = 1

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

	local currentWordlist = Words[wordlist]
	local expToAdd = rand:NextInteger(currentWordlist.Exp[1], currentWordlist.Exp[2])

	if experience + expToAdd > level * 100 then
		experience += expToAdd - level * 100
		DataService:IncrementData(player, "Experience", expToAdd - level * 100)
		level += 1
		DataService:IncrementData(player, "Level", 1)
	else
		experience += expToAdd
		DataService:IncrementData(player, "Experience", expToAdd)
	end

	DataService:IncrementData(player, "Currency", currentWordlist.Currency)
end

function SyncService.Client:ChangeSetting(player, setting)
	DataService:SetData(player, {"Settings", setting}, not DataService:GetSetting(player, setting))
	-- currently settings are all checkboxes stored as booleans, fine for now
end

function SyncService.Client:ChangeWordlist()
	wordlist = wordlist % 4 + 1
end

function SyncService.Client:PurchaseItem(player, category, item)
	-- if DataService:GetData(player, "ShopPurchases")[item] then
	-- 	return
	-- end
	local itemPrice = ShopItems[category][item].Price
	if DataService:GetData(player, "Currency") < itemPrice then
		return
	end
	DataService:IncrementData(player, "Currency", -itemPrice)
	DataService:SetData(player, {"ShopPurchases", category, item}, true)
	return true
end

return SyncService
