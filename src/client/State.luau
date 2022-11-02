local ReplicatedStorage = game:GetService "ReplicatedStorage"
local Words = require(ReplicatedStorage.Shared.Words)

local Fusion = require(script.Parent.Fusion)
local Value = Fusion.Value

return {
	MainUI = Value(), -- why r these values
	PlayScreen = Value(),

	MainFrameSize = Value(UDim2.fromScale(0.8, 0.8)),
	DarkTintTransparency = Value(1),

	dataLoaded = Value(),

	White = Color3.new(1, 1, 1),
	Grey4 = Color3.fromRGB(178, 178, 178),
	Grey3 = Color3.fromRGB(102, 102, 102),
	Grey2 = Color3.fromRGB(84, 84, 84),
	Grey1 = Color3.fromRGB(60, 60, 60),
	Grey0 = Color3.fromRGB(42, 42, 42),
	Black3 = Color3.fromRGB(32, 30, 28),
	Black2 = Color3.fromRGB(16, 14, 12),
	Black1 = Color3.fromRGB(10, 9, 8),
	Black0 = Color3.new(), -- hehehuehehuehe

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
		t.Easy:set(true)
		return t
	end)(),

	currentShopItem = Value(),
	Settings = {
		KeySounds = Value(),
		BlindMode = Value(),
		MemoryMode = Value(),
		PlainBG = Value(),
		Fullscreen = Value(),
	},
}
