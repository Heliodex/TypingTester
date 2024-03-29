--[[
How syncing works
	When any data is updated, the client will also send a call to this module to update the data stored on the server.
	There will be latency, this does not really matter.
	All functions here will be ratelimited so even if the client is exploited, not much damage can be done.
	This means that the true data should be stored on the server for data saving.
]]

local ReplicatedStorage = game:GetService "ReplicatedStorage"
local Knit = require(ReplicatedStorage.Packages.Knit)
local ShopItems = require(ReplicatedStorage.Shared.ShopItems)
local Words = require(ReplicatedStorage.Shared.Words)
local Ranks = require(ReplicatedStorage.Shared.Ranks)
local Badge = require(script.Parent.Parent.Badge)
local seed = math.random()
local rand = Random.new(seed)

local DataService
local SyncService = Knit.CreateService {
	Name = "SyncService",
}

local wordlist = 1
local streak = 0
local streakLevel = 0

function SyncService:KnitStart()
	DataService = Knit.GetService "DataService"
end

function SyncService.Client:GetSeed()
	return seed
end

function SyncService.Client:WordTyped(player)
	local currentWordlist = Words[wordlist]
	local expToAdd = rand:NextInteger(currentWordlist.Exp[1], currentWordlist.Exp[2])
	local bonusExp = streakLevel

	DataService:IncrementData(player, "WordsTyped", 1)
	DataService:IncrementData(player, { "Stats", "Words", currentWordlist.Name }, 1)

	local exp = DataService:GetData(player, "Experience")
	local lvl = DataService:GetData(player, "Level")

	local levelUp = false
	-- Current streak level is added to experience as a bonus
	-- Might not seem like much, but adds up over a long streak
	if exp + expToAdd + bonusExp > lvl * 100 then
		while exp + expToAdd + bonusExp > lvl * 100 do -- why no while else (also probably redundant until soemone actually gets this much exp)
			exp += expToAdd + bonusExp - lvl * 100
			lvl += 1
			levelUp = true
		end
	else
		exp += expToAdd + bonusExp
	end

	streak += 1
	streakLevel += if streak % 20 == 0 then 1 else 0

	if streakLevel == 1 then
		Badge:AwardBadge(player, 2128814965) -- On Fire
	elseif streakLevel == 5 then
		Badge:AwardBadge(player, 2128873285) -- Ablaze
	elseif streakLevel == 20 then
		Badge:AwardBadge(player, 2128873287) -- Inferno
	end

	DataService:SetData(player, "Experience", exp)
	if levelUp then
		DataService:SetData(player, "Level", lvl)
		if Ranks(lvl).Badge then
			Badge:AwardBadge(player, Ranks(lvl).Badge)
		end
	end

	DataService:IncrementData(player, "Currency", currentWordlist.Currency)
	DataService:IncrementData(player, { "Stats", "TotalCurrency" }, currentWordlist.Currency)
end

function SyncService.Client:EndStreak(player)
	if (DataService:GetData(player, { "Stats", "LongestStreak" }) or 0) < streak then
		DataService:SetData(player, { "Stats", "LongestStreak" }, streak)
	end

	streak = 0
	streakLevel = 0
end

function SyncService.Client:ChangeSetting(player, setting)
	DataService:SetData(player, { "Settings", setting }, not DataService:GetSetting(player, setting))
	-- currently settings are all checkboxes stored as booleans, fine for now
end

function SyncService.Client:ChangeWordlist(player)
	SyncService:ChangeWordlist(player)
end
function SyncService:ChangeWordlist(player)
	repeat
		wordlist = wordlist % 4 + 1
		if wordlist == 1 then
			break
		end
	until DataService:ItemOwned(player, "Wordlists", Words[wordlist].Name)
end

function SyncService.Client:PurchaseItem(player, category, item)
	local categoryName = ShopItems[category].Name
	local shopItem = ShopItems[category].Items[item]
	if shopItem then
		if shopItem.Ownable and DataService:GetData(player, "ShopPurchases")[categoryName][item] then
			return
		end

		if DataService:GetData(player, "Currency") < shopItem.Price then
			return
		end
		DataService:IncrementData(player, "Currency", -shopItem.Price)
		DataService:IncrementData(player, { "Stats", "CurrencySpent" }, shopItem.Price)

		if shopItem.Ownable then
			DataService:SetData(player, { "ShopPurchases", categoryName, item }, true)
		end
		return true
	end
end

return SyncService
