local Shared = game:GetService("ReplicatedStorage").Shared
local Settings = require(Shared.Settings)
local Words = require(Shared.Words)
local Colours = require(Shared.Colours)

local Fusion = require(script.Parent.Fusion)
local Value = Fusion.Value

return {
	MainUI = Value(), -- why r these values
	PlayScreen = Value(),

	MainFrameSize = Value(UDim2.fromScale(0.8, 0.8)),
	DarkTintTransparency = Value(1),

	dataLoaded = Value(),

	Colours = (function()
		local returns = {}
		for _, v in pairs(Colours) do
			returns[v[1]] = Value(v[2])
		end
		return returns
	end)(),

	playerFontThin = Value(Font.fromName("GothamSSm", Enum.FontWeight.Thin)), -- selene: "`FOnT` iS Not dEfinEd!!!!1!!!!11"
	playerFont = Value(Font.fromName("GothamSSm", Enum.FontWeight.Medium)),
	playerFontBold = Value(Font.fromName("GothamSSm", Enum.FontWeight.Bold)),

	currency = Value(0),
	experience = Value(0),
	level = Value(0),
	wordsTyped = Value(0),
	streak = Value(0),
	streakLevel = Value(0),
	ownedWordlists = (function()
		local t = {}
		for _, v in pairs(Words) do
			t[v.Name] = Value(false)
		end
		t["Easy words"]:set(true)
		return t
	end)(),

	currentShopItem = Value(),
	Settings = (function()
		local returns = {}
		for _, v in pairs(Settings) do
			returns[v[1]] = Value()
		end
		return returns
	end)(),
}
