-- Main UI-buliding script

local ReplicatedStorage = game:GetService "ReplicatedStorage"
local LocalPlayer = game:GetService("Players").LocalPlayer
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Words = require(ReplicatedStorage.Shared.Words)

Knit.Start()
	:andThen(function()
		print "[Knit] Client started"
	end)
	:catch(warn)

local SyncService = Knit.GetService "SyncService"
local DataService = Knit.GetService "DataService"
local randomGenerator

SyncService:GetSeed():andThen(function(seed)
	randomGenerator = Random.new(seed)
end)

local Ranks = require(script.Parent.Ranks)
local Sounds = ReplicatedStorage.Sounds
local ShopItems = require(ReplicatedStorage.Shared.ShopItems)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Spring = Fusion.Spring
local State = Fusion.State
local Computed = Fusion.Computed
local Compat = Fusion.Compat

local White = Color3.new(1, 1, 1)
local Grey5 = Color3.fromRGB(178, 178, 178)
local Grey3 = Color3.fromRGB(102, 102, 102)
local Grey2 = Color3.fromRGB(84, 84, 84)
local Grey1 = Color3.fromRGB(60, 60, 60)
local Grey0 = Color3.fromRGB(42, 42, 42)
local Black2 = Color3.fromRGB(16, 14, 12)
local Black1 = Color3.fromRGB(10, 9, 8)
local Black0 = Color3.new() -- hehehuehehuehe

local Green = Color3.fromRGB(0, 255, 0)
local Red = Color3.fromRGB(255, 0, 0)

local playerFontThin = Enum.Font.Gotham
local playerFont = Enum.Font.GothamMedium -- selene: "iT'S dePreCaTEd!!!!1!!!!11"
local playerFontBold = Enum.Font.GothamBold

local codeFont = Enum.Font.RobotoMono

local PlayScreen
local MainUI
local TypingBox

local MainFrameSize = State(UDim2.fromScale(0.8, 0.8))
local DarkTintTransparency = State(1)
local DarkTintTransparencyGoal = 0.5

local loadingData = false
local dataPrepared = State()
local dataPreparedChanged = Compat(dataPrepared)
local dataLoaded = State()
local dataLoadedChanged = Compat(dataLoaded)

DataService:PrepareData():andThen(function()
	dataPrepared:set(true)
end)

local displayedWords = {}
local wordCorrect = State(Green)

local currency = State(0)
local experience = State(0)
local level = State(0)
local wordsTyped = State(0)
local ownedWordlists = {}
local wordlist = State()

local Settings = {}

for _, v in pairs(Words) do
	ownedWordlists[v.Name] = false
end
ownedWordlists["Easy"] = true

local wordlistName = State "Easy"
local wordlistChanged = Compat(wordlist)

local function RandomString(length) -- thanks, mysterious4579		https://gist.github.com/haggen/2fd643ea9a261fea2094#gistcomment-2640881
	local res = ""
	for _ = 1, length do
		res = res .. string.char(math.random(97, 122)) -- needs more random
	end
	return res
end

local function getWord()
	local list = Words[wordlist:get()]
	wordlistName:set(list.Name)
	return list[math.random(1, #list)]
end

wordlistChanged:onChange(function()
	if TypingBox then
		TypingBox.Text = ""
	end

	for i = 1, 5 do
		if not displayedWords[i] then
			displayedWords[i] = State(getWord())
		else
			displayedWords[i]:set(getWord())
		end
	end
end)
wordlist:set(1)

local function UICorner(corner)
	return New "UICorner" {
		CornerRadius = UDim.new(corner or 0.2, 0),
	}
end

local function UIPadding(props)
	if props then
		props.Padding = props.Padding or 0.075
		props.PaddingV = props.PaddingV or props.Padding
		props.PaddingH = props.PaddingH or props.Padding
	else
		props = {
			Padding = 0.075,
			PaddingV = 0.075,
			PaddingH = 0.075,
		}
	end

	return New "UIPadding" {
		PaddingBottom = UDim.new(props.PaddingV, 0),
		PaddingTop = UDim.new(props.PaddingV, 0),
		PaddingLeft = UDim.new(props.PaddingH, 0),
		PaddingRight = UDim.new(props.PaddingH, 0),
	}
end

local function NextWords(props)
	return New "TextLabel" {
		Name = "Label" .. props.Number,

		Size = UDim2.fromScale(0.4, 0.06),
		Position = UDim2.fromScale(0.5, props.Position),

		Font = playerFont,
		TextColor3 = Grey5,
		Text = displayedWords[props.Number],
	}
end

local function BackgroundDesign()
	local returns = {}

	for i = 1, 11 do
		local temp = (i - 3.5) / 5

		local box = New "TextLabel" {
			Name = "BackgroundDesign" .. tostring(i),

			Size = UDim2.fromScale(2.41, 0.1),
			Position = UDim2.fromScale(0.5, temp),

			Font = codeFont,
			TextColor3 = Grey0,
			TextTransparency = 0.65,
			Text = RandomString(215),
		}
		table.insert(returns, box)
	end
	return returns
end

local function Button(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.ImageSize = props.ImageSize or 0.3
	props.SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeXY

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale) -- i hate
	local clickable = true

	return New "TextButton" {
		Name = props.Name,

		Size = props.Size,

		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = Grey3,
		AutoButtonColor = true,

		SizeConstraint = props.SizeConstraint,

		[OnEvent "Activated"] = function()
			if clickable or not props.Ratelimit then
				clickable = false
				props.Activated() -- shouldn't yield
				task.wait(0.1)
				clickable = true
			end
		end,

		[Children] = {
			UICorner(props.Corner),
			UIPadding { PaddingH = 0.075 / ratio }, -- at least it works well

			New "TextLabel" {
				Text = props.Text,

				Size = UDim2.fromScale(props.LabelWidth, 1),
				Position = UDim2.fromScale(0.9, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),

				Font = playerFont,
			},

			New "ImageLabel" {
				Size = UDim2.fromScale(props.ImageSize, props.ImageSize),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),

				Image = "rbxassetid://" .. tostring(props.Image),
				[Children] = New "UIAspectRatioConstraint" {
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Width,
				},
			},
		},
	}
end

local function SaveSlot(props)
	local text = State("Save slot " .. props.SaveSlot)
	local previewText = State "Loading info..."

	local disconnect = dataPreparedChanged:onChange(function()
		DataService:PreviewData(props.SaveSlot):andThen(function(data)
			previewText:set(
				"Level: " .. data.Level .. "\nWords: " .. data.WordsTyped .. "\nTyping Tokens: " .. data.Currency
			)
		end)
	end)

	return New "TextButton" {
		Name = "SaveSlot",

		Size = UDim2.fromScale(1, 0.15),

		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = Grey3,
		AutoButtonColor = true,

		[OnEvent "Activated"] = function()
			if not loadingData then
				loadingData = true
				print "Loading data..."
				text:set "Loading..."
				disconnect()

				DataService:LoadData(props.SaveSlot):andThen(function(data)
					currency:set(data.Currency)
					experience:set(data.Experience)
					level:set(data.Level)
					wordsTyped:set(data.WordsTyped)

					dataLoaded:set(true)
					print "Data loaded!"

					PlayScreen.Frame.Visible = false
					Sounds.music:Play()
					MainFrameSize:set(UDim2.fromScale(1, 1))
				end)
			end
		end,

		[Children] = {
			UICorner(),

			New "TextLabel" {
				Name = "SaveSlotName",
				Text = text,

				Size = UDim2.fromScale(0.3, 0.8),
				Position = UDim2.fromScale(0.02, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,

				Font = playerFont,
			},

			New "TextLabel" {
				Name = "SaveSlotPreview",
				Text = previewText,

				Size = UDim2.fromScale(0.3, 0.8),
				Position = UDim2.fromScale(0.98, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				TextXAlignment = Enum.TextXAlignment.Right,

				Font = playerFont,
			},
		},
	}
end

local function Label(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.LabelPosition = props.LabelPosition or 0.9

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale)

	return New "TextLabel" {
		Name = props.Name,

		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		BackgroundColor3 = props.BackgroundColor3 or Grey0,
		BackgroundTransparency = 0,

		[Children] = {
			UICorner(),
			UIPadding { PaddingH = 0.075 / ratio }, -- ratio
			props.Children,

			New "TextLabel" {
				Text = props.Text,

				Size = UDim2.fromScale(props.LabelWidth, 1),
				Position = UDim2.fromScale(props.LabelPosition, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),

				Font = playerFont,
			},

			New "ImageLabel" {
				Size = UDim2.fromScale(0.3, 0.3),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),

				Image = "rbxassetid://" .. tostring(props.Image),
				[Children] = New "UIAspectRatioConstraint" {
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Width,
				},
			},
		},
	}
end

local function Popup(props)
	if typeof(props.Children) == "table" then
		for i = 1, #props.Children do
			if props.Children[i]:IsA "GuiObject" then
				props.Children[i].LayoutOrder = i
			end
		end
	end

	local popup
	popup = New "Frame" {
		Name = props.Name,

		Size = props.Size or UDim2.fromScale(0.8, 0.8),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Grey2,
		Visible = false,
		ZIndex = props.ZIndex or 120, -- bruh darktint moment

		[Children] = {
			UICorner(props.Corner),

			New "ScrollingFrame" {
				Active = true,
				Position = UDim2.fromScale(0.5, 0.556), -- perfect values
				Size = UDim2.fromScale(1, 0.888),
				CanvasSize = UDim2.fromScale(1, 2.5),

				[Children] = New "Frame" {
					Size = UDim2.fromScale(0.96, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,

					[Children] = {
						UIPadding { PaddingV = 0.01, PaddingH = 0 },
						props.Children,
					},
				},
			},

			New "TextLabel" {
				Name = "Label",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Grey1,
				BackgroundTransparency = 0,

				Position = UDim2.fromScale(0.5, 0.03),
				Size = UDim2.fromScale(1, 0.08), -- I don't like it. 0.08 barely works okay enough.
				Font = playerFontBold,
				Text = string.upper(props.Name),

				[Children] = New "TextButton" {
					Name = "CloseButton",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = Black2,

					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromScale(1, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Font = Enum.Font.SourceSans,

					Text = "X",
					AutoButtonColor = true,

					[OnEvent "Activated"] = function()
						popup.Visible = false
						DarkTintTransparency:set(1)
					end,
				},
			},
		},
	}
	return popup
end

local function Setting(props)
	local clickable = true
	Settings[props.Name] = State()

	dataLoadedChanged:onChange(function()
		DataService:GetSetting(props.Name):andThen(function(value)
			Settings[props.Name]:set(value)
		end)
	end)

	return New "TextButton" {
		Name = props.Name,

		AnchorPoint = if props.Right then Vector2.new(1, 0) else Vector2.new(0, 0),
		BackgroundTransparency = 1,

		[OnEvent "Activated"] = function()
			if clickable then
				clickable = false

				Settings[props.Name]:set(not Settings[props.Name]:get())

				SyncService:ChangeSetting(props.Name)
				task.wait(0.1) -- ratelimiting, don't click so fast
				clickable = true
			end
		end,

		[Children] = {
			New "ImageLabel" {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = Computed(function()
					return if Settings[props.Name]:get() then "rbxassetid://7523095951" else "rbxassetid://7523096047"
				end),
			},
			New "TextLabel" {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.18, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				Font = playerFont,
				Text = props.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
		},
	}
end

local function ShopOption(props)
	local buttonText = State(ShopItems[props.Category][props.Name].Price)
	local clickable

	dataLoadedChanged:onChange(function()
		DataService:ItemOwned(props.Category, props.Name):andThen(function(owned)
			if owned then
				buttonText:set "Owned"
				ownedWordlists[props.Name] = true
				clickable = false
			else
				clickable = true
			end
		end)
	end)

	return New "Frame" {
		Name = props.Name,

		AnchorPoint = if props.Right then Vector2.new(1, 0) else Vector2.new(0, 0),
		BackgroundTransparency = 1,

		[Children] = {
			New "TextLabel" {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(0.7, 0.8),
				Font = playerFont,
				Text = props.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			},

			New "TextButton" {
				Name = "Price",

				BackgroundColor3 = Grey3,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.25, 1),
				Font = playerFont,
				Text = buttonText,
				AutoButtonColor = true,

				[OnEvent "Activated"] = function()
					if clickable then
						local price = buttonText:get()
						clickable = false
						SyncService:PurchaseItem(props.Category, props.Name):andThen(function(success)
							if success then
								currency:set(currency:get() - price)
								buttonText:set "Purchase successful!"
								task.wait(1)
								buttonText:set "Owned"
							else
								buttonText:set "Purchase failed!"
								task.wait(1)
								buttonText:set(price)
								clickable = true
							end
						end)
					end
				end,

				[Children] = {
					UIPadding(),
					UICorner(),
				},
			},
		},
	}
end

TypingBox = New "TextBox" {
	Name = "TypingBox",
	Position = UDim2.fromScale(0.5, 0.7),
	Size = UDim2.fromScale(0.5, 0.05),
	BackgroundColor3 = Grey0,
	TextColor3 = wordCorrect,

	Font = playerFont,
	PlaceholderText = "Type here (spacebar to complete word)",
	PlaceholderColor3 = Grey3,

	[OnChange "Text"] = function()
		TypingBox.Text = TypingBox.Text:sub(1, 33) -- Does not allow words longer than 32 characters + space, no word in any list is longer than 31 characters.

		local rand = math.random(1, 3)
		local rand2 = (math.random(90, 110) / 100) -- randomize sound pitch

		Sounds["click" .. rand].PlaybackSpeed = rand2
		Sounds["click" .. rand]:Play()

		local text = TypingBox.Text

		if string.match("!" .. displayedWords[1]:get() .. " ", ("!" .. text)) then
			wordCorrect:set(Green)
			if text == displayedWords[1]:get() .. " " then
				TypingBox.Text = ""

				SyncService:WordTyped()
				wordsTyped:set(wordsTyped:get() + 1)

				local currentWordlist = Words[wordlist:get()]
				local expToAdd = randomGenerator:NextInteger(currentWordlist.Exp[1], currentWordlist.Exp[2])

				local exp = experience:get()
				if exp + expToAdd > level:get() * 100 then
					while exp + expToAdd > level:get() * 100 do -- why no while else (also probably redundant until soemone actually gets this much exp)
						exp += expToAdd - level:get() * 100
						level:set(level:get() + 1)
					end
				else
					exp += expToAdd
				end
				experience:set(exp)

				currency:set(currency:get() + currentWordlist.Currency)

				local tempWords = displayedWords

				for i = 1, 4 do
					tempWords[i]:set(tempWords[i + 1]:get()) -- Move each word up by one place
				end
				tempWords[5]:set(getWord()) -- Add a new word to the bottom

				displayedWords = tempWords
			end
		else
			wordCorrect:set(Red)
		end
	end,

	[Children] = {
		UICorner(),
		UIPadding(),
	},
}

PlayScreen = New "ScreenGui" {
	Name = "PlayScreen",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = 10,
	IgnoreGuiInset = true,

	[Children] = New "Frame" {

		BackgroundColor3 = Black2,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			New "Frame" {
				Name = "SaveSlots",
				BackgroundColor3 = Black1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 0.5),
				Visible = false,

				[Children] = {
					UICorner(0.05),
					UIPadding { Padding = 0.025 },

					New "TextLabel" {
						Size = UDim2.fromScale(1, 0.1),
						Position = UDim2.fromScale(0.5, -0.1),
						Text = "Select a save slot to load",
						Font = playerFontBold,
					},

					SaveSlot {
						SaveSlot = 1,
						Position = UDim2.fromScale(0.5, 0.1),
					},
					SaveSlot {
						SaveSlot = 2,
						Position = UDim2.fromScale(0.5, 0.3),
					},
					SaveSlot {
						SaveSlot = 3,
						Position = UDim2.fromScale(0.5, 0.5),
					},
					SaveSlot {
						SaveSlot = 4,
						Position = UDim2.fromScale(0.5, 0.7),
					},
					SaveSlot {
						SaveSlot = 5,
						Position = UDim2.fromScale(0.5, 0.9),
					},
				},
			},

			New "Frame" {
				Name = "Play",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				[Children] = {
					Button {
						Name = "Play",
						Size = UDim2.fromScale(0.17, 0.075),
						Position = UDim2.fromScale(0.5, 0.5),
						Text = "Play",
						Image = 8156398059,

						Activated = function() -- o this is how you do functions
							PlayScreen.Frame.Play.Visible = false
							PlayScreen.Frame.SaveSlots.Visible = true
						end,
					},

					New "TextLabel" { -- Title
						Name = "Title",
						Position = UDim2.fromScale(0.5, 0.35),
						Size = UDim2.fromScale(0.3, 0.175),
						Font = playerFontBold,
						RichText = true,
						Text = "typing simulator but better",

						[Children] = UIPadding { Padding = 0.1 },
					},

					New "Frame" { -- Credits
						Name = "Credits",
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.9, 0.65),
						Size = UDim2.fromScale(0.1, 0.1),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,

						[Children] = New "ImageLabel" {
							Name = "HeliodexLogo",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							ZIndex = 6,
							Image = "rbxassetid://7501730261",

							[Children] = {
								New "TextLabel" {
									Name = "a Heliodex game",
									Position = UDim2.fromScale(0.5, 1.1),
									Size = UDim2.fromScale(1.8, 0.2),
									Font = playerFontThin,
									RichText = true,
									Text = "a <i>HELIODEX</i> game",
								},
								New "TextLabel" {
									Name = "pjstarr12",
									Position = UDim2.fromScale(0.5, 1.4),
									Size = UDim2.fromScale(1.5, 0.175),
									Font = playerFontThin,
									Text = "pjstarr12",

									[Children] = UIPadding(),
								},
								New "TextLabel" {
									Name = "TheWhaleCloud",
									Position = UDim2.fromScale(0.5, 1.6),
									Size = UDim2.fromScale(1.5, 0.175),
									Font = playerFontThin,
									Text = "TheWhaleCloud",

									[Children] = UIPadding(),
								},
								New "TextLabel" {
									Name = "Lewin4",
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 1.8),
									Size = UDim2.fromScale(1.5, 0.175),
									Font = playerFontThin,
									Text = "Lewin4",

									[Children] = UIPadding(),
								},
							},
						},
					},
				},
			},
		},
	},
}

-- Main ui time,,.,,.oaoeueuoueooaaeiiaaa

MainUI = New "ScreenGui" {
	Name = "Main",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = 0,
	IgnoreGuiInset = true,

	[Children] = {
		New "TextLabel" { -- could go inside MainFrame or frame
			Name = "Notification",

			Position = UDim2.fromScale(0.5, 0.15),
			Size = UDim2.fromScale(1, 1),

			Visible = false,

			TextTransparency = 1,
			Font = playerFont,

			ZIndex = 88,
		},

		New "Frame" {
			Name = "MainFrame",
			Size = UDim2.fromScale(1, 1),

			ZIndex = 5,

			[Children] = {
				New "Frame" {
					Size = Spring(MainFrameSize, 12, 1),
					BackgroundTransparency = 1,

					ZIndex = 5,

					[Children] = {
						Button {
							Name = "OpenHelp",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.01, 0.98),
							Text = "Help",
							Image = 7362810660,

							Activated = function()
								MainUI.MainFrame.Help.Visible = not MainUI.MainFrame.Help.Visible

								DarkTintTransparency:set(
									if MainUI.MainFrame.Help.Visible then DarkTintTransparencyGoal else 1
								)
							end,
						},
						Button {
							Name = "OpenShop",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.12),
							Text = "Shop",
							Image = 7362870044,

							Activated = function()
								MainUI.MainFrame.Shop.Visible = not MainUI.MainFrame.Shop.Visible

								DarkTintTransparency:set(
									if MainUI.MainFrame.Shop.Visible then DarkTintTransparencyGoal else 1
								)
							end,
						},
						Button {
							Name = "OpenSettings",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.39),
							Text = "Settings",
							Image = 7362801114,

							Activated = function()
								MainUI.MainFrame.Settings.Visible = not MainUI.MainFrame.Settings.Visible

								DarkTintTransparency:set(
									if MainUI.MainFrame.Settings.Visible then DarkTintTransparencyGoal else 1
								)
							end,
						},
						Button {
							Name = "AudioToggle",
							Size = UDim2.fromScale(0.1, 0.1),
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromScale(0.99, 0.98),
							Text = "",
							Image = 7517177224,

							Corner = 0.1,
							ImageSize = 0.9,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
						},
						Label {
							Name = "Currency",
							Size = UDim2.fromScale(0.22, 0.075),
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.02),
							Text = Computed(function()
								return currency:get() .. " typing\ntokens"
							end),
							Image = 7367251392,

							LabelWidth = 0.7,
							LabelPosition = 0.95,
						},
						Label {
							Name = "Words",
							Size = UDim2.fromScale(0.19, 0.075),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromScale(0.5, 0.02),
							Text = Computed(function()
								return wordsTyped:get() .. " Words"
							end),
							Image = 7367083297,
						},

						Button {
							Name = "wordlistButton",
							Size = UDim2.fromScale(0.22, 0.075),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.02),
							Text = Computed(function()
								return "Change word list:\n" .. wordlistName:get()
							end),
							Image = 7363005276,
							Ratelimit = true,

							Activated = function()
								local currentWordlist = wordlist:get()

								repeat
									currentWordlist = currentWordlist % 4 + 1
									if currentWordlist == 1 then
										break
									end
								until ownedWordlists[Words[currentWordlist].Name]

								wordlist:set(currentWordlist)

								SyncService:ChangeWordlist()
							end,

							LabelWidth = 0.65,
							LabelPosition = 0.95,
						},

						New "Frame" {
							Name = "LevelMenu",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.115),
							Size = UDim2.fromScale(0.17, 0.255),
							BackgroundColor3 = Grey3,

							[Children] = {
								UICorner(0.05),
								UIPadding { Padding = 0.04 },

								Label {
									Name = "Rank",
									Size = UDim2.fromScale(1, 0.32),
									AnchorPoint = Vector2.new(0.5, 1),
									Position = UDim2.fromScale(0.5, 1),
									Text = Computed(function()
										return Ranks(level:get()).Text
									end),
									Image = 7456285956,
									BackgroundColor3 = White,

									Children = {
										New "UIGradient" {
											Color = Computed(function()
												return Ranks(level:get()).Colour
											end),

											Rotation = 90,
										},
									},
								},
								Label {
									Name = "Level",
									Size = UDim2.fromScale(1, 0.25),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Text = Computed(function()
										return "Level " .. level:get()
									end),
									Image = 7367078076,
								},
								Label {
									Name = "Experience",
									Size = UDim2.fromScale(1, 0.2),
									AnchorPoint = Vector2.new(0.5, 0),
									Position = UDim2.fromScale(0.5, 0),
									Text = "Amount until level up",

									Image = 0, -- No image

									LabelWidth = 1,
									LabelPosition = 1,
								},

								New "Frame" {
									Name = "BarHolder",
									Size = UDim2.fromScale(1, 0.08),
									Position = UDim2.fromScale(0.5, 0.28),

									BackgroundColor3 = Grey0,

									[Children] = {
										UICorner(0.5),

										[Children] = New "Frame" {
											Name = "Bar",
											Size = Spring(
												Computed(function()
													local size = experience:get() / (level:get() * 100) % 1
													return UDim2.fromScale(if size == size then size else 0, 1) -- prevent NaNs from silently breaking everything
												end),
												50
											),
											AnchorPoint = Vector2.new(0, 0),
											Position = UDim2.fromScale(0, 0),

											BackgroundColor3 = Green,

											[Children] = UICorner(0.5),
										},
									},
								},
							},
						},

						TypingBox,

						New "Folder" {
							Name = "NextWordLabels",

							[Children] = {
								New "TextLabel" {
									Name = "CurrentWordLabel",

									Size = UDim2.fromScale(0.4, 0.06),
									Position = UDim2.fromScale(0.5, 0.3),

									Font = playerFont,
									Text = displayedWords[1],
								},

								NextWords {
									Position = 0.36,
									Number = 2,
								},
								NextWords {
									Position = 0.42,
									Number = 3,
								},
								NextWords {
									Position = 0.48,
									Number = 4,
								},
								NextWords {
									Position = 0.54,
									Number = 5,
								},
							},
						},
					},
				},

				New "UIGradient" {
					Color = ColorSequence.new {
						ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 30, 28)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 8)),
					},
					Rotation = 110,
				},

				New "Frame" {
					Name = "BackgroundDesign",

					Size = UDim2.fromScale(1.5, 0.75),
					BackgroundTransparency = 1,

					Rotation = -20,
					ZIndex = -50,

					[Children] = {
						New "Frame" {
							Name = "Frame1",

							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,

							[Children] = BackgroundDesign(),
						},

						New "Frame" {
							Name = "Frame2",

							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.5, 0.6),
							BackgroundTransparency = 1,

							[Children] = BackgroundDesign(),
						},
					},
				},

				-- MENU TIME
				-- OH MY GOD STOP PROCRASTINATING

				Popup {
					Name = "Help",

					Size = UDim2.fromScale(0.8, 0.8),
					Corner = 0.04,
					ZIndex = 120,

					-- Children does not require brackets here
					-- remember, this is a variable, children are applied in the Popup() function
					Children = New "TextLabel" {
						Name = "Text",
						AnchorPoint = Vector2.new(0.5, 0.9),
						Position = UDim2.fromScale(0.5, 1),
						Size = UDim2.fromScale(0.97, 1.1),
						Font = playerFont,
						-- RichText = true,
						Text = [[Welcome to game name goes here!
This is a game you can use to improve your speed, accuracy, and stamina while typing.

In the middle of the screen, a highlighted word will appear. Type it in the text box below, then press the spacebar once you finish a word.
The upcoming words are displayed below the current word.

The button in the top-right corner allows you to change the wordlist of your words.

Easy words can be between 2 and 4 letters long. They are the easiest to type.
They give 1 typing token and 12-15 exp per word.

Medium words can be between 4 and 7 letters long. Harder, but more rewarding.
They give 2 typing tokens and 20-26 exp per word.

Hard words can be between 7 and 10 letters long.
They give 3 typing tokens and 35-42 exp per word.

Insane words were added as a joke, they are some of the longest words in English.
They give 5 typing tokens and 57-65 exp per word.

Experience is used to level up. Each level requires 100 more experience to level up than the one before it.
Ranks are gained every 10 levels.

Developers:
pjstarr12
TheWhaleCloud
Lewin4

The soundtrack for the game is Click by C418.
Thanks to icons8 for providing the icons.

Inspired by:
Monkeytype by Miodec
Typing Simulator by S-GAMES]],
						TextSize = 28,
						TextScaled = false,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					},
				},

				Popup {
					Name = "Settings",

					Size = UDim2.fromScale(0.5, 0.5),
					Corner = 0.04,
					ZIndex = 130,

					Children = {
						New "UIGridLayout" {
							FillDirectionMaxCells = 2,
							CellSize = UDim2.fromScale(0.465, 0.05),
							CellPadding = UDim2.fromScale(0.05, 0.02),
						},

						Setting {
							Name = "KeySounds",
							Text = "Keypress Sounds",
						},
						Setting {
							Name = "BlindMode",
							Text = "Blind Mode",
						},
						Setting {
							Name = "MemoryMode",
							Text = "Memory Mode",
						},
						Setting {
							Name = "PlainBG",
							Text = "Plain Background",
						},
					},
				},

				Popup {
					Name = "Shop",

					Size = UDim2.fromScale(0.5, 0.5),
					Corner = 0.04,
					ZIndex = 120,

					Children = {
						New "UIGridLayout" {
							FillDirectionMaxCells = 2,
							CellSize = UDim2.fromScale(0.465, 0.05),
							CellPadding = UDim2.fromScale(0.05, 0.02),
						},

						ShopOption {
							Name = "Medium",
							Category = "Wordlists",
							Text = "Medium words",
							LayoutOrder = 1,
						},
						ShopOption {
							Name = "Hard",
							Category = "Wordlists",
							Text = "Hard words",
							LayoutOrder = 2,
						},
						ShopOption {
							Name = "Insane",
							Category = "Wordlists",
							Text = "Insane words",
							LayoutOrder = 3,
						},
					},
				},

				New "Frame" {
					Name = "DarkTint",
					BackgroundColor3 = Black0,
					BackgroundTransparency = Spring(DarkTintTransparency, 25),
					Size = UDim2.fromScale(2, 2),
					ZIndex = 100,
				},
			},
		},
	},
}
