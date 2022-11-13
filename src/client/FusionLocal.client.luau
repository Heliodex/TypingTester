-- Main UI-buliding script
local version = "1.0.0"

game.StarterGui:SetCoreGuiEnabled("All", false)
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local LocalPlayer = Players.LocalPlayer
local Fusion = require(script.Parent.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Ranks = require(ReplicatedStorage.Shared.Ranks)
local StarterSettings = require(ReplicatedStorage.Shared.Settings)
local Words = require(ReplicatedStorage.Shared.Words)
local Images = require(script.Parent.Images)
local State = require(script.Parent.State)
local Components = script.Parent.components

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

local White = State.White
local Grey4 = State.Grey4
local Grey3 = State.Grey3
local Grey1 = State.Grey1
local Grey0 = State.Grey0
local Black3 = State.Black3
local Black2 = State.Black2
local Black1 = State.Black1
local Black0 = State.Black0

local Green = Color3.fromRGB(0, 255, 0)
local Red = Color3.fromRGB(255, 0, 0)

local playerFontThin = State.playerFontThin -- selene: "`FOnT` iS Not dEfinEd!!!!1!!!!11"
local playerFont = State.playerFont
local playerFontBold = State.playerFontBold

local PlayScreen
local MainUI
local TypingBox

local MainFrameSize = State.MainFrameSize
local DarkTintTransparency = State.DarkTintTransparency
local DarkTintTransparencyGoal = 0.5

local displayedWords = {}
local wordCorrect = Value(Green)

local backgroundRotation = { Value(90), Value(90), Value(90) }
local currency = State.currency
local experience = State.experience
local level = State.level
local wordsTyped = State.wordsTyped
local streak = State.streak
local streakLevel = State.streakLevel
local ownedWordlists = State.ownedWordlists
local wordlist = Value()

local adderTransparency = Value(1)
local adderTransparencySpring = Spring(adderTransparency, 6, 1)
local currencyAdded = Value(0) -- For the adder popup animation beside currency and experience
local experienceAdded = Value(0)
local streakLevelUpTransparency = Value(1)
local streakLevelUpTransparencySpring = Spring(streakLevelUpTransparency, 3, 1)

local currentShopItem = State.currentShopItem

local Settings = State.Settings

local wordlistName = Value "Easy"

local function getWord()
	local list = Words[wordlist:get()]
	wordlistName:set(list.Name)
	local word = list[math.random(1, #list)]
	if typeof(word) == "table" then
		word = word[if Settings["British English"]:get() then 2 else 1]
	end
	return word
end

local function openPopup(popupName)
	-- Popup system to close any existing popup when opening a new one
	return function()
		local currentPopup = MainUI.MainFrame.DarkTint.CurrentPopup
		local popup = MainUI.MainFrame:FindFirstChild(popupName) or currentPopup:FindFirstChild(popupName)
		local visible = popup.Visible
		if visible then
			popup.Visible = false
			popup.Parent = MainUI.MainFrame
			DarkTintTransparency:set(1)
		else
			local existingPopup = currentPopup:FindFirstChildOfClass "CanvasGroup"
			if existingPopup then
				existingPopup.Visible = false
				existingPopup.Parent = MainUI.MainFrame
			end

			popup.Parent = currentPopup
			popup.Position = UDim2.fromScale(0.5, 0.5)
			popup.Visible = true
			DarkTintTransparency:set(DarkTintTransparencyGoal)
		end
	end
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

local UICorner = require(Components.UICorner)
local UIPadding = require(Components.UIPadding)
local ImageButton = require(Components.ImageButton)
local Button = require(Components.Button)
local Label = require(Components.Label)
local SaveSlot = require(Components.SaveSlot)
local Popup = require(Components.Popup)
local Setting = require(Components.Setting)
local ShopOption = require(Components.ShopOption)

TypingBox = New "TextBox" {
	Name = "TypingBox",
	Position = UDim2.fromScale(0.5, 0.7),
	Size = UDim2.fromScale(0.5, 0.05),
	BackgroundColor3 = Grey0,
	TextColor3 = wordCorrect,

	FontFace = playerFont,
	PlaceholderText = "Type here (spacebar to complete word)",
	PlaceholderColor3 = Grey3,

	[OnChange "Text"] = function()
		TypingBox.Text = TypingBox.Text:sub(1, 33) -- Does not allow words longer than 32 characters + space, no word in any list is longer than 31 characters.

		if Settings["Keypress Sounds"]:get() then
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
			FontFace = playerFont,
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
						FontFace = playerFontBold,
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
						FontFace = playerFontBold,
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
									FontFace = playerFontThin,
									RichText = true,
									Text = "a <i>HELIODEX</i> game",
								},
								New "TextLabel" {
									Name = "pjstarr12",
									Position = UDim2.fromScale(0.5, 1.4),
									Size = UDim2.fromScale(1.5, 0.175),
									FontFace = playerFontThin,
									Text = "pjstarr12",

									[Children] = UIPadding(),
								},
								New "TextLabel" {
									Name = "TheWhaleCloud",
									Position = UDim2.fromScale(0.5, 1.6),
									Size = UDim2.fromScale(1.5, 0.175),
									FontFace = playerFontThin,
									Text = "TheWhaleCloud",

									[Children] = UIPadding(),
								},
								New "TextLabel" {
									Name = "Lewin4",
									Position = UDim2.fromScale(0.5, 1.8),
									Size = UDim2.fromScale(1.5, 0.175),
									FontFace = playerFontThin,
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
State.PlayScreen:set(PlayScreen)

-- Main ui time,,.,,.oaoeueuoueooaaeiiaaa

MainUI = New "ScreenGui" {
	Name = "Main",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = 0,
	IgnoreGuiInset = Settings["Fullscreen"],

	[Children] = {
		New "TextLabel" { -- could go inside MainFrame or frame
			Name = "Notification",

			Position = UDim2.fromScale(0.5, 0.15),
			Size = UDim2.fromScale(1, 1),

			Visible = false,

			TextTransparency = 1,
			FontFace = playerFont,

			ZIndex = 88,
		},

		New "Frame" {
			Name = "MainFrame",
			Size = UDim2.fromScale(1, 1),

			BackgroundTransparency = 1,
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
									FontFace = playerFont,
								},
							},
						},
						ImageButton {
							Name = "OpenShop",
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.12),
							Text = "Shop",
							Image = 7362870044,

							Activated = openPopup "Shop",
						},
						ImageButton {
							Name = "OpenLeaderboard",
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.01, 0.88),
							Text = "Leaderboard",
							Image = 10975178174,

							Activated = openPopup "Leaderboard",
						},
						ImageButton {
							Name = "OpenHelp",
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.01, 0.98),
							Text = "Help",
							Image = 7362810660,

							Activated = openPopup "Help",
						},
						ImageButton {
							Name = "OpenSettings",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.39),
							Text = "Settings",
							Image = 7362801114,

							Activated = openPopup "Settings",
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
								until ownedWordlists[Words[currentWordlist].Name]:get()

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
												FontFace = playerFont,
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

									FontFace = playerFont,
									Text = displayedWords[1],
									Visible = Computed(function()
										return not Settings["Memory Mode"]:get()
									end),
								},

								(function()
									local returns = {}
									for i = 2, 5 do
										table.insert(
											returns,
											New "TextLabel" {
												Name = "Label" .. i,

												Size = UDim2.fromScale(0.4, 0.06),
												Position = UDim2.fromScale(0.5, 0.06 * i + 0.24),

												FontFace = playerFont,
												TextTransparency = 0.6,
												Text = displayedWords[i],
												Visible = Computed(function()
													return not Settings["Blind Mode"]:get()
												end),
											}
										)
									end
									return returns
								end)(),
							},
						},
					},
				},

				-- MENU TIME
				-- OH MY GOD STOP ROCRASTINATING

				Popup {
					Name = "Help",
					Size = UDim2.fromScale(0.8, 0.8),
					Length = 6,

					-- Children does not require brackets here
					-- remember, this is a variable, children are applied in the Popup() function
					Children = {
						New "Frame" {
							Name = "Header",
							Size = UDim2.fromScale(1, 0.07),
							Position = UDim2.fromScale(0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,

							[Children] = {
								UIPadding {
									Padding = 0.03,
								},
								Button {
									Size = UDim2.fromScale(0.49, 1),
									Position = UDim2.fromScale(0, 0),
									AnchorPoint = Vector2.new(0, 0),
									Text = "Help",
									BackgroundColor3 = Black3,

									Activated = function()
										local popup = MainUI.MainFrame.DarkTint.CurrentPopup.Help.ScrollingFrame.Pages
										popup.UIPageLayout:JumpTo(popup.Help)
									end,
								},
								Button {
									Size = UDim2.fromScale(0.49, 1),
									Position = UDim2.fromScale(0.51, 0),
									AnchorPoint = Vector2.new(0, 0),
									Text = "Changelog",
									BackgroundColor3 = Black3,

									Activated = function()
										local popup = MainUI.MainFrame.DarkTint.CurrentPopup.Help.ScrollingFrame.Pages
										popup.UIPageLayout:JumpTo(popup.Changelog)
									end,
								},
							},
						},
						New "Frame" {
							Name = "Pages",
							Size = UDim2.fromScale(1, 0.9),
							Position = UDim2.fromScale(0.5, 0.1),
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,

							[Children] = {
								New "UIPageLayout" {
									ScrollWheelInputEnabled = false,
								},

								New "Frame" {
									Name = "Help",
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 2.5),
									LayoutOrder = 1,

									[Children] = New "TextLabel" {
										Name = "Text",
										AnchorPoint = Vector2.new(0.5, 0),
										Position = UDim2.fromScale(0.5, 0),
										Size = UDim2.fromScale(0.97, 1),
										FontFace = playerFont,
										RichText = true,
										Text = [[Welcome to game name goes here!
This is a game you can use to improve your speed, accuracy, and stamina while typing.

In the middle of the screen, a highlighted word will appear. Type it in the text box below, then press the spacebar once you finish a word.
The upcoming words are displayed below the current word.

The button in the top-right corner allows you to change the wordlist of your words.
New wordlists can be purchased from the Shop.

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
										TextTruncate = Enum.TextTruncate.AtEnd,
										TextXAlignment = Enum.TextXAlignment.Left,
										TextYAlignment = Enum.TextYAlignment.Top,
									},
								},
								New "Frame" {
									Name = "Changelog",
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 1),
									LayoutOrder = 2,

									[Children] = New "TextLabel" {
										Name = "Text",
										AnchorPoint = Vector2.new(0.5, 0),
										Position = UDim2.fromScale(0.5, 0),
										Size = UDim2.fromScale(0.97, 1),
										FontFace = playerFont,
										LayoutOrder = 2,
										RichText = true,
										Text = [[
<b>1.0.0</b>
Initial release

- Of course I'm just kidding, the game will never be released

<b>0.9.0</b>

- Added a new wordlist: "Words"
- Added a new wordlist: "Words 2"

<b>0.8.0</b>

- This update aint exist
]],
										TextTruncate = Enum.TextTruncate.AtEnd,
										TextXAlignment = Enum.TextXAlignment.Left,
										TextYAlignment = Enum.TextYAlignment.Top,
									},
								},
							},
						},
					},
				},

				Popup {
					Name = "Settings",
					Size = UDim2.fromScale(0.5, 0.5),

					Children = {
						New "UIGridLayout" {
							FillDirectionMaxCells = 2,
							CellSize = UDim2.fromScale(0.465, 0.125),
							CellPadding = UDim2.fromScale(0.05, 0.05),
						},

						(function()
							local returns = {}
							for i in StarterSettings do
								print(StarterSettings[i][1], StarterSettings[i][2])
								table.insert(returns, Setting(StarterSettings[i][1]))
							end
							return returns
						end)(),

						Button {
							Name = "Stats",
							Text = "Stats",
							BackgroundColor3 = Black3,
							LayoutOrder = #StarterSettings + 1,

							Activated = function()
								openPopup "Stats"()
								local statsPopup = MainUI.MainFrame.DarkTint.CurrentPopup.Stats

								if statsPopup.Visible then
									local _, stats = DataService:GetStats():await()
									local h = math.floor(stats.PlayTime / 3600)
									local userStats = {
										{
											"Total time played",
											(if h > 0 then h .. "h " else "")
												.. math.floor(stats.PlayTime % 3600 / 60)
												.. "m",
										},
										{ "Logins", stats.Logins },
										{ "Longest Streak", stats.LongestStreak },
										{ "Easy Words", stats.Words.Easy },
										{ "Medium Words", stats.Words.Medium },
										{ "Hard Words", stats.Words.Hard },
										{ "Insane Words", stats.Words.Insane },
										{ "Total typing tokens", stats.TotalCurrency },
										{ "Typing tokens spent", stats.CurrencySpent },
									}

									if statsPopup.ScrollingFrame:FindFirstChildOfClass "Frame" then
										for i in userStats do
											statsPopup.ScrollingFrame[userStats[i][1]].Stat.Text = userStats[i][2]
										end
									else
										for i in userStats do
											New "Frame" {
												Name = userStats[i][1],
												LayoutOrder = i,
												BackgroundTransparency = 1,
												Size = UDim2.fromScale(0.98, 0.1),
												Parent = statsPopup.ScrollingFrame,

												[Children] = {
													New "TextLabel" {
														Name = "StatName",
														Size = UDim2.fromScale(0.75, 1),
														Position = UDim2.fromScale(0, 0.5),
														AnchorPoint = Vector2.new(0, 0),

														Text = userStats[i][1],
														FontFace = playerFont,
														TextXAlignment = Enum.TextXAlignment.Left,
													},
													New "TextLabel" {
														Name = "Stat",
														Size = UDim2.fromScale(0.25, 1),
														Position = UDim2.fromScale(1, 0.5),
														AnchorPoint = Vector2.new(1, 0),

														Text = userStats[i][2],
														FontFace = playerFont,
														TextXAlignment = Enum.TextXAlignment.Right,
													},
												},
											}
										end
									end
								end
							end,
						},
						Button {
							Name = "Verification",
							Text = "Verification",
							BackgroundColor3 = Black3,
							LayoutOrder = #StarterSettings + 2,

							Activated = openPopup "Verification",
						},
					},
				},

				Popup {
					Name = "Stats",
					Size = UDim2.fromScale(0.5, 0.5),

					Children = New "UIListLayout" {
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
				},
				(function()
					local popup
					local txt = Value "Verification Code"
					popup = Popup {
						Name = "Verification",
						Size = UDim2.fromScale(0.5, 0.5),

						Children = {
							New "TextBox" {
								Size = UDim2.fromScale(0.7, 0.1),
								Position = UDim2.fromScale(0.5, 0.4),
								BackgroundColor3 = Grey0,

								FontFace = playerFont,
								PlaceholderText = txt,

								[Children] = {
									UICorner(),
									UIPadding {
										PaddingH = 0,
									},
								},
							},

							Button {
								Size = UDim2.fromScale(0.3, 0.1),
								Position = UDim2.fromScale(0.5, 0.53),
								Name = "Verify",
								Text = "Verify",
								BackgroundColor3 = Black3,

								Activated = function()
									local textBox = popup.ScrollingFrame.TextBox
									if string.len(textBox.Text) == 6 then
										DataService:Verify(textBox.Text):andThen(function(success)
											if success then
												textBox.Text = ""
												txt:set "Verification successful!"
												task.wait(1)
												txt:set "Verification Code"
											else
												textBox.Text = ""
												txt:set "Verification failed!"
												task.wait(1)
												txt:set "Verification Code"
											end
										end)
									else
										textBox.Text = ""
										txt:set "Code must be 6 numbers!"
										task.wait(1)
										txt:set "Verification Code"
									end
								end,
							},
						},
					}
					return popup
				end)(),

				Popup {
					Name = "Leaderboard",
					Size = UDim2.fromScale(0.5, 0.75),

					Children = {
						New "Frame" {
							Name = "Header",
							Size = UDim2.fromScale(1, 0.15),
							Position = UDim2.fromScale(0.5, 0.08),
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
										local popup =
											MainUI.MainFrame.DarkTint.CurrentPopup.Leaderboard.ScrollingFrame.Pages
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
										local popup =
											MainUI.MainFrame.DarkTint.CurrentPopup.Leaderboard.ScrollingFrame.Pages
										popup.UIPageLayout:JumpTo(popup.WordsLeaderboard)
									end,
								},

								New "TextLabel" {
									Name = "Username",
									Text = "Username",

									AnchorPoint = Vector2.new(0, 0),
									Position = UDim2.fromScale(0.1, 0.55),
									Size = UDim2.fromScale(0.25, 0.3),
									FontFace = playerFont,
								},
								New "TextLabel" {
									Name = "Level",
									Text = "Level",

									AnchorPoint = Vector2.new(0.5, 0),
									Position = UDim2.fromScale(0.6, 0.55),
									Size = UDim2.fromScale(0.2, 0.3),
									FontFace = playerFont,
								},
								New "TextLabel" {
									Name = "Words",
									Text = "Words",

									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0.55),
									Size = UDim2.fromScale(0.2, 0.3),
									FontFace = playerFont,
								},
							},
						},

						New "Frame" {
							Name = "Pages",
							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.5, 0.13),
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
									LayoutOrder = 1,

									[Children] = New "UIListLayout" {
										SortOrder = Enum.SortOrder.LayoutOrder,
									},
								},
								New "Frame" {
									Name = "WordsLeaderboard",
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 1),
									LayoutOrder = 2,

									[Children] = New "UIListLayout" {
										SortOrder = Enum.SortOrder.LayoutOrder,
									},
								},
							},
						},
					},
				},

				Popup {
					Name = "Shop",
					Size = UDim2.fromScale(0.5, 0.65),

					MainChildren = (function()
						local popup
						local buttonText = Value ""

						Observer(currentShopItem):onChange(function()
							local shopItem = currentShopItem:get()
							if shopItem.Level <= level:get() then
								buttonText:set(shopItem.ButtonText:get())
								popup.Visible = true
							else
								popup.Visible = false
							end
						end)

						popup = New "Frame" {
							Name = "PurchasePopup",
							Size = UDim2.fromScale(0.96, 0.3),
							Position = UDim2.fromScale(0.5, 0.98),
							AnchorPoint = Vector2.new(0.5, 1),
							BackgroundColor3 = Grey1,
							Visible = false,

							[Children] = {
								New "TextLabel" {
									Name = "ItemName",
									Size = UDim2.fromScale(0.6, 0.2),
									Position = UDim2.fromScale(0, 0),
									AnchorPoint = Vector2.new(0, 0),
									BackgroundTransparency = 1,
									Text = Computed(function()
										local item = currentShopItem:get()
										return if item then item.Name else ""
									end),
									TextXAlignment = Enum.TextXAlignment.Left,
									FontFace = playerFont,
								},
								New "TextLabel" {
									Name = "ItemDescription",
									Size = UDim2.fromScale(0.6, 0.8),
									Position = UDim2.fromScale(0, 0.2),
									AnchorPoint = Vector2.new(0, 0),
									BackgroundTransparency = 1,
									Text = Computed(function()
										local item = currentShopItem:get()
										return if item
											then ShopItems[item.Category].Items[item.Name].Description
											else ""
									end),
									TextXAlignment = Enum.TextXAlignment.Left,
									TextYAlignment = Enum.TextYAlignment.Top,
									FontFace = playerFont,

									[Children] = New "UITextSizeConstraint" {
										MaxTextSize = 20,
									},
								},

								New "TextButton" {
									Name = "Price",
									AnchorPoint = Vector2.new(1, 1),
									Position = UDim2.fromScale(1, 1),
									Size = UDim2.fromScale(0.2, 0.35),
									FontFace = playerFont,
									Text = buttonText,
									BackgroundColor3 = Grey3,

									[OnEvent "Activated"] = function()
										local item = currentShopItem:get()
										local levelRequirement = item.Level
										local price = item.ButtonText:get() -- awful variable name

										if price ~= "Owned" and level:get() >= levelRequirement then
											SyncService:PurchaseItem(item.Category, item.Name):andThen(function(success)
												if success then
													if ShopItems[item.Category].Name == "Wordlists" then
														ownedWordlists[item.Name]:set(true)
													end
													currency:set(currency:get() - price)
													buttonText:set "Purchase successful!"
													if item.Ownable then
														item.ButtonText:set "Owned"
													end
													task.wait(1)
													if item.Ownable then
														buttonText:set "Owned"
													else
														buttonText:set(price)
													end
												else
													buttonText:set "Purchase failed!"
													task.wait(1)
													buttonText:set(price)
												end
											end)
										end
									end,

									[Children] = {
										UICorner(),
										UIPadding(),
									},
								},

								UIPadding {
									PaddingH = 0.025,
								},
								UICorner(0.1),
							},
						}

						return popup
					end)(),

					Children = {
						New "ScrollingFrame" {
							Name = "Header",
							Size = UDim2.fromScale(0.97, 0.11),
							CanvasSize = UDim2.fromScale(1, 0.11),
							Position = UDim2.fromScale(0.5, 0.06),
							BackgroundTransparency = 1,
							AutomaticCanvasSize = Enum.AutomaticSize.X,
							ScrollingDirection = Enum.ScrollingDirection.X,

							[Children] = {
								New "UIListLayout" {
									Padding = UDim.new(0.05, 0),
									FillDirection = Enum.FillDirection.Horizontal,
								},
								(function()
									local returns = {}
									for _, v in pairs(ShopItems) do
										table.insert(
											returns,
											Button {
												Size = UDim2.fromScale(0.465, 0.75),
												AnchorPoint = Vector2.new(0, 0),
												Text = v.Name,
												BackgroundColor3 = Black3,

												Activated = function()
													local popup =
														MainUI.MainFrame.DarkTint.CurrentPopup.Shop.ScrollingFrame.Pages
													popup.UIPageLayout:JumpTo(popup[v.Name])
												end,
											}
										)
									end
									return returns
								end)(),
							},
						},
						New "Frame" {
							Name = "Pages",
							Size = UDim2.fromScale(0.97, 1),
							Position = UDim2.fromScale(0.5, 0.12),
							AnchorPoint = Vector2.new(0.5, 0),
							BackgroundTransparency = 1,

							[Children] = {
								New "UIPageLayout" {
									ScrollWheelInputEnabled = false,
								},

								(function()
									local returns = {}
									for i, v in pairs(ShopItems) do
										table.insert(
											returns,
											New "Frame" {
												Name = v.Name,
												BackgroundTransparency = 1,
												Size = UDim2.fromScale(1, 1),
												LayoutOrder = i,

												[Children] = {
													New "UIGridLayout" {
														FillDirectionMaxCells = 2,
														CellSize = UDim2.fromScale(0.465, 0.11),
														CellPadding = UDim2.fromScale(0.05, 0.025),
													},

													(function()
														local returns2 = {}
														for i2, _ in pairs(v.Items) do
															table.insert(
																returns2,
																ShopOption {
																	Name = i2,
																	Category = i,
																}
															)
														end
														return returns2
													end)(),
												},
											}
										)
									end
									return returns
								end)(),
							},
						},
					},
				},

				New "TextLabel" {
					Name = "Version",
					Size = UDim2.fromScale(0.1, 0.015),
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.fromScale(0.99, 1),
					TextXAlignment = Enum.TextXAlignment.Right,
					FontFace = playerFont,
					Text = version .. ", v" .. game.PlaceVersion,
				},
				New "Frame" {
					Name = "DarkTint",
					BackgroundColor3 = Black0,
					BackgroundTransparency = Spring(DarkTintTransparency, 25),
					Size = UDim2.fromScale(2, 2),
					ZIndex = 100,

					[Children] = New "Frame" {
						Name = "CurrentPopup",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.5, 0.5),
					},
				},
			},
		},
	},
}
State.MainUI:set(MainUI)

New "ScreenGui" {
	Name = "Background",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = -10,
	IgnoreGuiInset = true,

	[Children] = New "Frame" {
		Name = "BackgroundBackground",
		Size = UDim2.fromScale(1, 1),

		BackgroundColor3 = Black3,
		ZIndex = 5,
		[Children] = (function()
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
					return not Settings["Plain Background"]:get()
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
													then Color3.new(math.min(r + (currentLevel / 25), 0.6), r, r)
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
	},
}

-- Animate background cubes
while true do
	for i = 1, 3 do
		if not Settings["Plain Background"]:get() then
			backgroundRotation[i]:set(90 - backgroundRotation[i]:get())
		end
		task.wait(18)
	end
end
