-- Main UI-buliding script

game.StarterGui:SetCoreGuiEnabled("All", false)
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local Players = game:GetService "Players"
local LocalPlayer = Players.LocalPlayer
local Fusion = require(ReplicatedStorage.Shared.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Words = require(ReplicatedStorage.Shared.Words)
local Images = require(script.Parent.Images)
local Ranks = require(script.Parent.Ranks)

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

local Sounds = ReplicatedStorage.Sounds
local ShopItems = require(ReplicatedStorage.Shared.ShopItems)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Spring = Fusion.Spring
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer

local White = Color3.new(1, 1, 1)
local Grey4 = Color3.fromRGB(178, 178, 178)
local Grey3 = Color3.fromRGB(102, 102, 102)
local Grey2 = Color3.fromRGB(84, 84, 84)
local Grey1 = Color3.fromRGB(60, 60, 60)
local Grey0 = Color3.fromRGB(42, 42, 42)
local Black3 = Color3.fromRGB(32, 30, 28)
local Black2 = Color3.fromRGB(16, 14, 12)
local Black1 = Color3.fromRGB(10, 9, 8)
local Black0 = Color3.new() -- hehehuehehuehe

local Green = Color3.fromRGB(0, 255, 0)
local Red = Color3.fromRGB(255, 0, 0)

local playerFontThin = Enum.Font.Gotham
local playerFont = Enum.Font.GothamMedium -- selene: "iT'S dePreCaTEd!!!!1!!!!11"
local playerFontBold = Enum.Font.GothamBold

local PlayScreen
local MainUI
local TypingBox

local MainFrameSize = Value(UDim2.fromScale(0.8, 0.8))
local DarkTintTransparency = Value(1)
local DarkTintTransparencyGoal = 0.5

local loadingData = false
local dataPrepared = Value()
local dataLoaded = Value()
local dataLoadedChanged = Observer(dataLoaded)

DataService:PrepareData():andThen(function()
	dataPrepared:set(true)
end)

local displayedWords = {}
local wordCorrect = Value(Green)

local backgroundRotation = { Value(90), Value(90), Value(90) }
local currency = Value(0)
local experience = Value(0)
local level = Value(0)
local wordsTyped = Value(0)
local streak = Value(0)
local streakLevel = Value(0)
local ownedWordlists = {}
local wordlist = Value()

local adderTransparency = Value(1)
local adderTransparencySpring = Spring(adderTransparency, 6, 1)
local currencyAdded = Value(0) -- For the adder popup animation beside currency and experience
local experienceAdded = Value(0)
local streakLevelUpTransparency = Value(1)
local streakLevelUpTransparencySpring = Spring(streakLevelUpTransparency, 3, 1)

local Settings = {
	KeySounds = Value(),
	BlindMode = Value(),
	MemoryMode = Value(),
	PlainBG = Value(),
}

for _, v in pairs(Words) do
	ownedWordlists[v.Name] = false
end
ownedWordlists["Easy"] = true

local wordlistName = Value "Easy"

local function getWord()
	local list = Words[wordlist:get()]
	wordlistName:set(list.Name)
	return list[math.random(1, #list)]
end

Observer(wordlist):onChange(function()
	if TypingBox then
		TypingBox.Text = ""
	end

	for i = 1, 5 do
		if not displayedWords[i] then
			displayedWords[i] = Value(getWord())
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

-- Was quite the trip to get working
local function populateLeaderboard(leaderboard, page)
	for _, v in ipairs(leaderboard) do
		local you = v == "You"

		-- Load users on leaderboard
		-- very slow, so it would make the game load slowly if it was done at creation of the leaderboard popup
		task.spawn(function()
			New "Frame" {
				Name = "LeaderboardPerson",
				Parent = page,

				Size = UDim2.fromScale(1, 0.04),
				BackgroundTransparency = 1,

				[Children] = {
					UIPadding {
						PaddingH = 0.03,
					},

					New "Frame" {
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = White,

						[Children] = {
							UICorner(),
							New "UIGradient" {
								Color = if you
									then Computed(function()
										return Ranks(level:get()).Colour
									end)
									else Ranks(v.Level).Colour,
							},

							New "ImageLabel" {
								Name = "ProfilePic",

								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromScale(0, 0.5),
								Size = UDim2.fromScale(1, 0.8),
								SizeConstraint = Enum.SizeConstraint.RelativeYY,
								Image = (function()
									local img
									pcall(function()
										img = Players:GetUserThumbnailAsync(
											if you then LocalPlayer.UserId else v.Player,
											Enum.ThumbnailType.HeadShot,
											Enum.ThumbnailSize.Size48x48
										)
									end)
									return img or 0
								end)(),

								[Children] = UICorner(1),
							},
							New "TextLabel" {
								Name = "Username",
								Text = if you
									then LocalPlayer.Name
									else (function()
										local name
										pcall(function()
											name = Players:GetNameFromUserIdAsync(v.Player)
										end)
										return name or "[Unknown]"
									end)(),

								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromScale(0.1, 0.5),
								Size = UDim2.fromScale(0.25, 0.8),
								Font = playerFont,
							},
							New "TextLabel" {
								Name = "Level",
								Text = if you then level else v.Level,

								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.6, 0.5),
								Size = UDim2.fromScale(0.2, 0.8),
								Font = playerFont,
							},
							New "TextLabel" {
								Name = "Words",
								Text = if you then wordsTyped else v.Words,

								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.fromScale(1, 0.5),
								Size = UDim2.fromScale(0.2, 0.8),
								Font = playerFont,
							},
						},
					},
				},
			}
		end)
	end
end

local function NextWords(props)
	return New "TextLabel" {
		Name = "Label" .. props.Number,

		Size = UDim2.fromScale(0.4, 0.06),
		Position = UDim2.fromScale(0.5, props.Position),

		Font = playerFont,
		TextTransparency = 0.6,
		Text = displayedWords[props.Number],
		Visible = Computed(function()
			return not Settings.BlindMode:get()
		end),
	}
end

local function ImageButton(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.ImageSize = props.ImageSize or 0.3
	props.Size = props.Size or UDim2.fromScale(0.17, 0.075)
	props.SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeXY

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale) -- i hate
	local clickable = true

	return New "TextButton" {
		Name = props.Name,

		Size = props.Size,
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = props.BackgroundColor3 or Grey3,

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
			UIPadding {
				PaddingH = 0.075 / ratio,
			}, -- at least it works well

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

local function Button(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.ImageSize = props.ImageSize or 0.3
	props.Size = props.Size or UDim2.fromScale(0.17, 0.075)
	props.SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeXY

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale) -- i hate
	local clickable = true

	return New "TextButton" {
		Name = props.Name,

		Size = props.Size,
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = props.BackgroundColor3 or Grey3,

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
			UIPadding {
				PaddingH = 0.075 / ratio,
			}, -- at least it works well

			New "TextLabel" {
				Text = props.Text,

				Size = UDim2.fromScale(props.LabelWidth, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),

				Font = playerFont,
			},
		},
	}
end

local function SaveSlot(props)
	local text = Value("Save slot " .. props.SaveSlot)
	local previewText = Value "Loading info..."

	local disconnect = Observer(dataPrepared):onChange(function()
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

					DataService:LevelLeaderboard():andThen(function(leaderboard)
						populateLeaderboard(
							leaderboard,
							MainUI.MainFrame.Leaderboard.ScrollingFrame.Frame.Pages.LevelLeaderboard
						)
					end)
					DataService:WordsLeaderboard():andThen(function(leaderboard)
						populateLeaderboard(
							leaderboard,
							MainUI.MainFrame.Leaderboard.ScrollingFrame.Frame.Pages.WordsLeaderboard
						)
					end)
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
			UIPadding {
				PaddingH = 0.075 / ratio,
			}, -- ratio
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
	local function checkChildren(table)
		for i = 1, #table do
			if typeof(table[i]) ~= "table" then
				if table[i]:IsA "GuiObject" then
					table[i].LayoutOrder = i
				end
			else
				checkChildren(table[i])
			end
		end
	end
	if typeof(props.Children) == "table" then
		checkChildren(props.Children)
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
			UICorner(props.Corner or 0.04),

			New "ScrollingFrame" {
				Active = true,
				Position = UDim2.fromScale(0.5, 0.556), -- perfect values
				Size = UDim2.fromScale(1, 0.888),
				CanvasSize = UDim2.fromScale(1, props.Length or 2.5),

				[Children] = New "Frame" {
					Size = UDim2.fromScale(0.96, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,

					[Children] = {
						UIPadding {
							PaddingV = 0.01,
							PaddingH = 0,
						},
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

						if not props.NoBG then
							DarkTintTransparency:set(1)
						end
					end,
				},
			},
		},
	}
	return popup
end

local function Setting(props)
	local clickable = true

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
					return if Settings[props.Name]:get() then Images.Checked else Images.Unchecked
				end),
			},
			New "TextLabel" {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.7, 0.8),
				Font = playerFont,
				Text = props.Text,
				TextXAlignment = Enum.TextXAlignment.Right,
			},
		},
	}
end

local function ShopOption(props)
	local buttonText = Value(ShopItems[props.Category][props.Name].Price)
	local levelRequirement = ShopItems[props.Category][props.Name].Level
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
					if clickable and level:get() >= levelRequirement then
						local price = buttonText:get()
						clickable = false
						SyncService:PurchaseItem(props.Category, props.Name):andThen(function(success)
							if success then
								ownedWordlists[props.Name] = true
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

			New "Frame" {
				Name = "LevelLock",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1.05, 1.2),
				BackgroundTransparency = 0.25,
				BackgroundColor3 = Black0,
				Visible = Computed(function()
					return level:get() < levelRequirement
				end),

				[Children] = {
					UICorner(),
					New "ImageLabel" {
						Name = "PadlockIcon",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0.03, 0.5),
						Size = UDim2.fromScale(0.8, 0.8),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Image = "rbxassetid://10970873852",
					},
					New "TextLabel" {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.6, 0.5),
						Size = UDim2.fromScale(0.7, 0.7),
						Font = playerFont,
						Text = "Level " .. levelRequirement,
					},
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

		if Settings.KeySounds:get() then
			local rand = math.random(1, 3)
			local rand2 = 0.9 + math.random() * 0.2 -- Randomize sound pitch

			Sounds["click" .. rand].PlaybackSpeed = rand2
			Sounds["click" .. rand]:Play()
		end

		local text = TypingBox.Text

		if string.match("!" .. displayedWords[1]:get() .. " ", ("!" .. text)) then
			-- Word is correct!
			wordCorrect:set(Green)
			if text == displayedWords[1]:get() .. " " then
				TypingBox.Text = ""

				SyncService:WordTyped()
				wordsTyped:set(wordsTyped:get() + 1)

				-- Manage streak
				local currentStreak = streak:get() + 1
				local currentStreakLevel = streakLevel:get()
				streak:set(currentStreak)

				if currentStreak % 20 == 0 then
					currentStreakLevel += 1
					print "Streak level up!!"
				end
				streakLevel:set(currentStreakLevel)

				print("Streak of ", currentStreak)

				-- Manage experience
				local currentWordlist = Words[wordlist:get()]
				local expToAdd = randomGenerator:NextInteger(currentWordlist.Exp[1], currentWordlist.Exp[2])
				local bonusExp = currentStreakLevel

				local exp = experience:get()
				local lvl = level:get()

				-- Current streak level is added to experience as a bonus
				-- Might not seem like much, but adds up over a long streak
				if exp + expToAdd + bonusExp > lvl * 100 then
					while exp + expToAdd + bonusExp > lvl * 100 do -- why no while else (also probably redundant until soemone actually gets this much exp)
						exp += expToAdd + bonusExp - lvl * 100
						lvl += 1
					end
				else
					exp += expToAdd + bonusExp
				end

				experience:set(exp)
				level:set(lvl)

				currency:set(currency:get() + currentWordlist.Currency)
				currencyAdded:set(currentWordlist.Currency)
				experienceAdded:set(expToAdd)

				-- Pop up adder then fade out
				adderTransparencySpring:setPosition(0)
				adderTransparency:set(1)
				if currentStreak % 20 == 0 then
					streakLevelUpTransparencySpring:setPosition(0)
					streakLevelUpTransparency:set(1)
				end

				local tempWords = displayedWords

				for i = 1, 4 do
					tempWords[i]:set(tempWords[i + 1]:get()) -- Move each word up by one place
				end
				tempWords[5]:set(getWord()) -- Add a new word to the bottom

				displayedWords = tempWords

				task.wait(wordlist:get() + 1)
				if streak:get() == currentStreak then
					SyncService:EndStreak()
					streak:set(0)
					streakLevel:set(0)
					print("Streak ended with ", currentStreak, "words!")
				end
			end
		else
			wordCorrect:set(Red)
		end
	end,

	[Children] = {
		UICorner(),
		UIPadding {
			PaddingH = 0,
		},

		New "Frame" {
			Name = "StreakProgress",
			Size = Spring(
				Computed(function()
					return UDim2.fromScale((streak:get() % 20) / 20, 0.1) -- Remember padding of parent while sizing
				end),
				20,
				1
			),
			BackgroundColor3 = Spring(
				Computed(function()
					return if streakLevel:get() > 0 then Grey4 else Grey3
				end),
				8,
				1
			),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0, 1),

			[Children] = UICorner(),
		},

		New "TextLabel" {
			Name = "StreakLevelUp",
			Size = UDim2.fromScale(0.7, 0.7),
			Position = UDim2.fromScale(1.08, 0.5),
			AnchorPoint = Vector2.new(0.5, 0),
			TextTransparency = streakLevelUpTransparencySpring,
			Rotation = -20,

			Text = Computed(function()
				local currentStreakLevel = streakLevel:get()
				local messages = { -- Upon reaching level:
					{ "NICE!", "COOL!", "WOW!", "GREAT!", "SUPER!", "SWEET!" }, -- 1-3
					{
						"AWESOME!",
						"AMAZING!",
						"EPIC!",
						"FANTASTIC!",
						"FLAWLESS!",
						"PERFECT!",
						"TERRIFIC!",
						"IMPRESSIVE!",
						"EXCEPTIONAL!",
						"BRILLIANT!",
					}, -- 4-8
					{
						"INCREDIBLE!!",
						"INSANITY!!",
						"INSANE!!",
						"IMPOSSIBLE!!",
						"CRAZY!!",
						"ASTONISHING!!",
						"PHENOMENAL!",
						"OUTSTANDING!!",
						"BREATHTAKING!!",
					}, -- 9-13
					{
						"UNSTOPPABLE!!",
						"UNBEATABLE!!",
						"UNBELIEVABLE!!",
						"UNREAL!!",
						"UNMATCHED!!",
						"UNPARALLELED!!",
						"UNTHINKABLE!!",
						"MAGNIFICENT!!",
						"SPECTACULAR!!",
						"OUTRAGEOUS!!",
					}, -- 14-18
					{
						"LEGENDARY!!!",
						"INFINITE!!!",
						"GODLIKE!!!",
						"GODLY!!!",
						"OMNIPOTENT!!!",
						"IMMORTAL!!!",
						"HACKER!!!",
						"ALMIGHTY!!!",
					}, -- 19-22
				}

				if currentStreakLevel < 4 then
					return messages[1][math.random(1, #messages[1])]
				elseif currentStreakLevel < 9 then
					return messages[2][math.random(1, #messages[2])]
				elseif currentStreakLevel < 14 then
					return messages[3][math.random(1, #messages[3])]
				elseif currentStreakLevel < 19 then
					return messages[4][math.random(1, #messages[4])]
				else
					return messages[5][math.random(1, #messages[5])]
				end
			end),
			Font = playerFont,
		},
	},
}

PlayScreen = New "ScreenGui" {
	Name = "PlayScreen",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = 10,
	IgnoreGuiInset = true,

	[Children] = New "Frame" {

		BackgroundColor3 = Black2,
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
					UIPadding {
						Padding = 0.025,
					},

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
					ImageButton {
						Name = "Play",
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

						[Children] = UIPadding {
							Padding = 0.1,
						},
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

			BackgroundColor3 = Black3,
			ZIndex = 5,

			[Children] = {
				New "Frame" {
					Size = Spring(MainFrameSize, 12, 1),
					BackgroundTransparency = 1,

					ZIndex = 5,

					[Children] = {
						Label {
							Name = "Currency",
							Size = UDim2.fromScale(0.22, 0.075),
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.02),
							Text = Computed(function()
								return currency:get() .. "\nTyping tokens"
							end),
							Image = 7367251392,

							LabelWidth = 0.7,
							LabelPosition = 0.95,

							Children = {
								New "TextLabel" {
									Name = "CurrencyAdder",
									Size = UDim2.fromScale(0.6, 0.6),
									Position = UDim2.fromScale(1.08, 0.5),
									AnchorPoint = Vector2.new(0, 0.5),
									TextTransparency = adderTransparencySpring,

									Text = Computed(function()
										return "+" .. currencyAdded:get()
									end),
									TextXAlignment = Enum.TextXAlignment.Left,
									Font = playerFont,
								},
							},
						},
						ImageButton {
							Name = "OpenShop",
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.12),
							Text = "Shop",
							Image = 7362870044,

							Activated = function()
								local shop = MainUI.MainFrame.Shop
								shop.Visible = not shop.Visible

								DarkTintTransparency:set(if shop.Visible then DarkTintTransparencyGoal else 1)
							end,
						},
						ImageButton {
							Name = "OpenLeaderboard",
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.01, 0.88),
							Text = "Leaderboard",
							Image = 10975178174,

							Activated = function()
								local leaderboard = MainUI.MainFrame.Leaderboard
								leaderboard.Visible = not leaderboard.Visible

								DarkTintTransparency:set(if leaderboard.Visible then DarkTintTransparencyGoal else 1)
							end,
						},
						ImageButton {
							Name = "OpenHelp",
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
						ImageButton {
							Name = "OpenSettings",
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
						(function()
							local button
							button = ImageButton {
								Name = "AudioToggle",
								Size = UDim2.fromScale(0.1, 0.1),
								AnchorPoint = Vector2.new(1, 1),
								Position = UDim2.fromScale(0.99, 0.98),
								Text = "",
								Image = 7517177224,

								Corner = 0.1,
								ImageSize = 0.9,
								SizeConstraint = Enum.SizeConstraint.RelativeYY,

								Activated = function()
									if Sounds.music.Playing then
										Sounds.music:Pause()
										button.ImageLabel.Image = Images.Muted
									else
										Sounds.music:Play()
										button.ImageLabel.Image = Images.Playing
									end
								end,
							}

							return button
						end)(),

						Label {
							Name = "Words",
							Size = UDim2.fromScale(0.19, 0.075),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromScale(0.5, 0.02),
							Text = Computed(function()
								return wordsTyped:get() .. "\nWords"
							end),
							Image = 7367083297,
						},

						ImageButton {
							Name = "wordlistButton",
							Size = UDim2.fromScale(0.22, 0.075),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.02),
							Text = Computed(function()
								return "Change wordlist:\n" .. wordlistName:get()
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
								UIPadding {
									Padding = 0.04,
								},

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

											Rotation = 75,
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

										New "Frame" {
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

										Children = {
											New "TextLabel" {
												Name = "ExperienceAdder",
												Size = UDim2.fromScale(1, 2),
												Position = UDim2.fromScale(-0.12, 0.5),
												AnchorPoint = Vector2.new(1, 0.5),
												TextTransparency = adderTransparencySpring,

												Text = Computed(function()
													local currentStreakLevel = streakLevel:get()
													local expAdded = experienceAdded:get()

													if currentStreakLevel > 0 then
														return "<font color='#AA0000'>+"
															.. currentStreakLevel
															.. "</font> +"
															.. expAdded
													end
													return "+" .. expAdded
												end),
												TextXAlignment = Enum.TextXAlignment.Right,
												Font = playerFont,
												RichText = true,
											},
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
									Visible = Computed(function()
										return not Settings.MemoryMode:get()
									end),
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

				(function()
					local camera = New "Camera" {
						CFrame = CFrame.new(Vector3.new(-400, 400, 400), Vector3.new(0, 0, 0)),
						FieldOfView = 1,
					}

					return New "ViewportFrame" {
						Name = "BackgroundDesign",

						Size = UDim2.fromScale(1, 1),
						ZIndex = -50,
						BackgroundColor3 = Grey0, -- Prevent white outlines for parts
						BackgroundTransparency = 1,
						LightColor = Grey3,
						LightDirection = Vector3.new(0, -0.5, -1),
						Visible = Computed(function()
							return not Settings.PlainBG:get()
						end),

						CurrentCamera = camera,
						[Children] = {
							camera,
							(function()
								local returns = {}
								for h = -9, 9 do
									for w = -16, 16 do
										local r = math.random() * 0.2
										table.insert(
											returns,
											New "Part" {
												Size = Vector3.new(1, 1, 1),
												Position = Vector3.new(h + w, h, w),
												Color = Spring(
													Computed(function()
														local currentLevel = streakLevel:get() - 1
														return if currentLevel > 0
															then Color3.new(
																math.min(r + (currentLevel / 25), 0.6),
																r,
																r
															)
															else Color3.new(r, r, r)
													end),
													0.5 + r * 5,
													1
												),
												Material = Enum.Material.Plastic,
												Rotation = Spring(
													Computed(function()
														return Vector3.new(
															backgroundRotation[1]:get(),
															backgroundRotation[2]:get(),
															backgroundRotation[3]:get()
														) -- rotation, rotation
													end),
													0.2,
													1
												),
											}
										)
									end
								end

								return returns
							end)(),
						},
					}
				end)(),

				-- MENU TIME
				-- OH MY GOD STOP ROCRASTINATING

				Popup {
					Name = "Help",
					Size = UDim2.fromScale(0.8, 0.8),
					Length = 6,

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

Insane words are some of the longest words in English.
They give 5 typing tokens and 57-65 exp per word.

Experience is used to level up. Each level needs 100 more experience to level up than the one before it.
Ranks are gained every 10 levels.

Typing enough words in quick succession will give you a streak.
The longer you can keep a streak going, the more experience you will earn per word!

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
						Button {
							Name = "Stats",
							Text = "Stats",
							BackgroundColor3 = Black3,

							Activated = function()
								local stats = MainUI.MainFrame.Stats
								stats.Visible = not stats.Visible
							end,
						},
					},
				},

				Popup {
					Name = "Stats",
					Size = UDim2.fromScale(0.5, 0.5),
					ZIndex = 140,
					NoBG = true,

					Children = {
						New "UIListLayout" {},

						(function()
							dataLoadedChanged:onChange(function()
								local _, stats = DataService:GetStats():await()
								local userStats = {
									{ "Total time played", "todo" },
									{ "Logins", stats.Logins },
									{ "Longest Streak", stats.LongestStreak },
									{ "Easy Words", stats.Words.Easy },
									{ "Medium Words", stats.Words.Medium },
									{ "Hard Words", stats.Words.Hard },
									{ "Insane Words", stats.Words.Insane },
								}

								for i in userStats do
									New "Frame" {
										BackgroundTransparency = 1,
										Size = UDim2.fromScale(0.98, 0.04),
										Parent = MainUI.MainFrame.Stats.ScrollingFrame.Frame,

										[Children] = {
											New "TextLabel" {
												Name = "StatName",
												Size = UDim2.fromScale(0.75, 1),
												Position = UDim2.fromScale(0, 0.5),
												AnchorPoint = Vector2.new(0, 0),

												Text = userStats[i][1],
												Font = playerFont,
												TextXAlignment = Enum.TextXAlignment.Left,
											},
											New "TextLabel" {
												Name = "Stat",
												Size = UDim2.fromScale(0.25, 1),
												Position = UDim2.fromScale(1, 0.5),
												AnchorPoint = Vector2.new(1, 0),

												Text = userStats[i][2],
												Font = playerFont,
												TextXAlignment = Enum.TextXAlignment.Right,
											},
										},
									}
								end
							end)
						end)(),
					},
				},

				Popup {
					Name = "Leaderboard",
					Size = UDim2.fromScale(0.5, 0.75),

					Children = {
						New "Frame" {
							Name = "Header",
							Size = UDim2.fromScale(1, 0.06),
							Position = UDim2.fromScale(0.5, 0.025),
							BackgroundTransparency = 1,

							[Children] = {
								UIPadding {
									Padding = 0.03,
								},
								Button {
									Size = UDim2.fromScale(0.49, 0.5),
									Position = UDim2.fromScale(0, 0),
									AnchorPoint = Vector2.new(0, 0),
									Text = "Level",
									BackgroundColor3 = Black3,

									Activated = function()
										local popup = MainUI.MainFrame.Leaderboard.ScrollingFrame.Frame.Pages
										popup.UIPageLayout:JumpTo(popup.LevelLeaderboard)
									end,
								},
								Button {
									Size = UDim2.fromScale(0.49, 0.5),
									Position = UDim2.fromScale(0.51, 0),
									AnchorPoint = Vector2.new(0, 0),
									Text = "Words",
									BackgroundColor3 = Black3,

									Activated = function()
										local popup = MainUI.MainFrame.Leaderboard.ScrollingFrame.Frame.Pages
										popup.UIPageLayout:JumpTo(popup.WordsLeaderboard)
									end,
								},

								New "TextLabel" {
									Name = "Username",
									Text = "Username",

									AnchorPoint = Vector2.new(0, 0),
									Position = UDim2.fromScale(0.1, 0.55),
									Size = UDim2.fromScale(0.25, 0.3),
									Font = playerFont,
								},
								New "TextLabel" {
									Name = "Level",
									Text = "Level",

									AnchorPoint = Vector2.new(0.5, 0),
									Position = UDim2.fromScale(0.6, 0.55),
									Size = UDim2.fromScale(0.2, 0.3),
									Font = playerFont,
								},
								New "TextLabel" {
									Name = "Words",
									Text = "Words",

									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0.55),
									Size = UDim2.fromScale(0.2, 0.3),
									Font = playerFont,
								},
							},
						},

						New "Frame" {
							Name = "Pages",
							Size = UDim2.fromScale(1, 0.97),
							Position = UDim2.fromScale(0.5, 0.045),
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,

							[Children] = {
								New "UIPageLayout" {
									ScrollWheelInputEnabled = false,
								},

								New "Frame" {
									Name = "LevelLeaderboard",
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 1),
									Position = UDim2.fromScale(0.5, 0.5),

									[Children] = New "UIListLayout" {},
								},
								New "Frame" {
									Name = "WordsLeaderboard",
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 1),
									Position = UDim2.fromScale(0.5, 0.5),

									[Children] = New "UIListLayout" {},
								},
							},
						},
					},
				},

				Popup {
					Name = "Shop",
					Size = UDim2.fromScale(0.5, 0.5),

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

-- Animate background cubes
while true do
	for i = 1, 3 do
		if not Settings.PlainBG:get() then
			backgroundRotation[i]:set(90 - backgroundRotation[i]:get())
		end
		task.wait(18)
	end
end
