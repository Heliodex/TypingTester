-- Written 2021/10/04

-- Main UI-buliding script

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Fusion = require(ReplicatedStorage.Shared.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Spring = Fusion.Spring
local State = Fusion.State

local White = Color3.fromRGB(255, 255, 255)
local Grey5 = Color3.fromRGB(178, 178, 178)
local Grey3 = Color3.fromRGB(102, 102, 102)
local Grey2 = Color3.fromRGB(84, 84, 84)
local Grey1 = Color3.fromRGB(60, 60, 60)
local Grey0 = Color3.fromRGB(42, 42, 42)
local Black = Color3.fromRGB(16, 14, 12)
local DarkBlack = Color3.new() -- hehehuehehuehe

local Green = Color3.fromRGB(0, 255, 0)

local playerFontThin = Enum.Font.Gotham
local playerFont = Enum.Font.GothamMedium -- "iT'S dePreCaTEd!!!!1!!!!11"
local playerFontBold = Enum.Font.GothamBold

local codeFont = Enum.Font.RobotoMono

local Sounds = ReplicatedStorage.Sounds

local PlayScreen
local MainUI

local MainFrameSize = State(UDim2.fromScale(0.8, 0.8))
local DarkTintTransparency = State(1)
local DarkTintTransparencyGoal = 0.5

function RandomString(length) -- thanks, mysterious4579		https://gist.github.com/haggen/2fd643ea9a261fea2094#gistcomment-2640881
	local res = ""
	for _ = 1, length do
		res = res .. string.char(math.random(97, 122)) -- needs more random
	end
	return res
end

local function UICorner(corner)
	return New("UICorner")({
		CornerRadius = UDim.new(corner or 0.2, 0),
	})
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

	return New("UIPadding")({
		PaddingBottom = UDim.new(props.PaddingV, 0),
		PaddingTop = UDim.new(props.PaddingV, 0),
		PaddingLeft = UDim.new(props.PaddingH, 0),
		PaddingRight = UDim.new(props.PaddingH, 0),
	})
end

local function NextWords(props)
	return New("TextLabel")({
		Name = props.Name,

		Size = UDim2.fromScale(0.4, 0.06),
		Position = UDim2.fromScale(0.5, props.Pos),
		BackgroundTransparency = 1,

		Font = playerFont,
		TextColor3 = Grey5,
		Text = "next word",
	})
end

local function BackgroundDesign()
	local returns = {}

	for i = 1, 11 do
		local temp = (i - 3.5) / 5

		local box = New("TextLabel")({
			Name = "BackgroundDesign" .. tostring(i),

			BackgroundTransparency = 1,
			Size = UDim2.fromScale(2.41, 0.1),
			Position = UDim2.fromScale(0.5, temp),

			Font = codeFont,
			TextColor3 = Grey0,
			TextTransparency = 0.65,
			Text = RandomString(215),
		})
		table.insert(returns, box)
	end
	return returns
end

local function Button(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.ImageSize = props.ImageSize or 0.3
	props.SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeXY

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale) -- i hate

	return New("TextButton")({
		Name = props.Name,

		Size = props.Size,

		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = Grey3,
		AutoButtonColor = true,

		SizeConstraint = props.SizeConstraint,

		[OnEvent("Activated")] = props.Activated,

		[Children] = {
			UICorner(props.Corner),
			UIPadding({
				PaddingH = 0.075 / ratio, -- at least it works well
			}),

			New("TextLabel")({
				Text = props.Text,

				Size = UDim2.fromScale(props.LabelWidth, 1),
				Position = UDim2.fromScale(0.9, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),

				BackgroundTransparency = 1,
				Font = playerFont,
			}),

			New("ImageLabel")({
				Size = UDim2.fromScale(props.ImageSize, props.ImageSize),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),

				Image = "rbxassetid://" .. tostring(props.Image),
				[Children] = New("UIAspectRatioConstraint")({
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Width,
				}),
			}),
		},
	})
end

local function Label(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.LabelPosition = props.LabelPosition or 0.9

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale)

	return New("TextLabel")({
		Name = props.Name,

		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		BackgroundColor3 = Grey0,

		[Children] = {
			UICorner(),
			UIPadding({
				PaddingH = 0.075 / ratio, -- ratio
			}),

			New("TextLabel")({
				Text = props.Text,

				Size = UDim2.fromScale(props.LabelWidth, 1),
				Position = UDim2.fromScale(props.LabelPosition, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),

				BackgroundTransparency = 1,
				Font = playerFont,
			}),

			New("ImageLabel")({
				Size = UDim2.fromScale(0.3, 0.3),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),

				Image = "rbxassetid://" .. tostring(props.Image),
				[Children] = New("UIAspectRatioConstraint")({
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Width,
				}),
			}),
		},
	})
end

local function Popup(props)
	local popup
	popup = New("Frame")({
		Name = props.Name,

		Size = props.Size or UDim2.fromScale(0.8, 0.8),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Grey2,
		Visible = false,
		ZIndex = props.ZIndex or 120, -- bruh darktint moment

		[Children] = {
			UICorner(props.Corner),

			New("ScrollingFrame")({
				Active = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(1, 0.85),
				CanvasSize = UDim2.fromScale(1, 2.5),

				ScrollingDirection = Enum.ScrollingDirection.Y,

				[Children] = props.Children,
			}),

			New("TextLabel")({
				Name = "Label",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Grey1,

				Position = UDim2.new(0.5, 0, 0, 16),
				Size = UDim2.fromScale(1, 0.08), -- I don't like it. 0.08 barely works okay enough.
				Font = playerFontBold,
				Text = props.Title,

				[Children] = New("TextButton")({
					Name = "CloseButton",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = Black,

					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromScale(1, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Font = Enum.Font.SourceSans,

					Text = "X",
					AutoButtonColor = true,

					[OnEvent("Activated")] = function()
						popup.Visible = false
						DarkTintTransparency:set(1)
					end,
				}),
			}),
		},
	})
	return popup
end

local function SettingsOption(props)
	local VerticalPos = 0.03 + ((props.Row or 0) * 0.07) -- even worse

	return New("Frame")({
		Name = props.Name,
		BackgroundColor3 = White,

		AnchorPoint = if props.Right then Vector2.new(1, 0) else Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Position = if props.Right then UDim2.fromScale(0.97, VerticalPos) else UDim2.fromScale(0.03, VerticalPos),
		Size = UDim2.fromScale(0.45, 0.05),

		[Children] = {
			New("ImageButton")({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = "rbxassetid://7523096047",
			}),
			New("TextLabel")({
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.15, 0.5),
				Size = UDim2.fromScale(0.8, 1),
				Font = playerFont,
				Text = props.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		},
	})
end

local function ShopOption(props)
	local VerticalPos = 0.03 + ((props.Row or 0) * 0.07) -- even worse, css grid much

	return New("Frame")({
		Name = props.Name,
		BackgroundColor3 = White,

		AnchorPoint = if props.Right then Vector2.new(1, 0) else Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Position = if props.Right then UDim2.fromScale(0.97, VerticalPos) else UDim2.fromScale(0.03, VerticalPos),
		Size = UDim2.fromScale(0.45, 0.05),

		[Children] = {
			New("TextLabel")({
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				Font = playerFont,
				Text = props.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			New("TextButton")({
				Name = "Price",

				BackgroundColor3 = Grey3,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.25, 1),
				Font = playerFont,
				Text = props.Price or "Price",
				AutoButtonColor = true,

				[Children] = {
					UIPadding(),
					UICorner(),
				},
			}),
		},
	})
end

PlayScreen = New("ScreenGui")({
	Name = "PlayScreen",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = 10,
	IgnoreGuiInset = true,

	[Children] = New("Frame")({
		BackgroundColor3 = Black,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			New("Frame")({ -- Credits
				Name = "Credits",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.9, 0.65),
				Size = UDim2.fromScale(0.1, 0.1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,

				[Children] = New("ImageLabel")({
					Name = "HeliodexLogo",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					ZIndex = 6,
					Image = "rbxassetid://7501730261",

					[Children] = {
						New("TextLabel")({
							Name = "a Heliodex game",
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 1.1),
							Size = UDim2.fromScale(1.8, 0.2),
							Font = playerFontThin,
							RichText = true,
							Text = "a <i>HELIODEX</i> game",
						}),
						New("TextLabel")({
							Name = "pjstarr12",
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 1.4),
							Size = UDim2.fromScale(1.5, 0.175),
							Font = playerFontThin,
							Text = "pjstarr12",

							[Children] = UIPadding(),
						}),
						New("TextLabel")({
							Name = "TheWhaleCloud",
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 1.6),
							Size = UDim2.fromScale(1.5, 0.175),
							Font = playerFontThin,
							Text = "TheWhaleCloud",

							[Children] = UIPadding(),
						}),
						New("TextLabel")({
							Name = "Lewin4",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = White,
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 1.8),
							Size = UDim2.fromScale(1.5, 0.175),
							Font = playerFontThin,
							Text = "Lewin4",

							[Children] = UIPadding(),
						}),
					},
				}),
			}),

			Button({
				Name = "Play",
				Size = UDim2.fromScale(0.17, 0.075),
				Position = UDim2.fromScale(0.5, 0.5),
				Text = "Play",
				Image = 8156398078,

				Activated = function() -- o this is how you do functions
					PlayScreen.Frame.Visible = false
					Sounds.music:Play()
					MainFrameSize:set(UDim2.fromScale(1, 1))
				end,
			}),

			New("TextLabel")({ -- Title
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.35),
				Size = UDim2.fromScale(0.3, 0.175),
				Font = playerFontBold,
				RichText = true,
				Text = "typing simulator but better",

				[Children] = New("UIPadding")({
					PaddingBottom = UDim.new(0.1, 0),
					PaddingLeft = UDim.new(0.1, 0),
					PaddingRight = UDim.new(0.1, 0),
					PaddingTop = UDim.new(0.1, 0),
				}),
			}),
		},
	}),
})

-- Main ui time,,.,,.oaoeueuoueooaaeiiaaa

MainUI = New("ScreenGui")({
	Name = "Main",
	Parent = LocalPlayer.PlayerGui,
	DisplayOrder = 0,
	IgnoreGuiInset = true,

	[Children] = {
		New("TextLabel")({ -- should this go inside the frame??
			Name = "Warning",

			Position = UDim2.fromScale(0.5, 0.15),
			Size = UDim2.fromScale(1, 1),

			Visible = false,

			BackgroundTransparency = 1,
			TextTransparency = 1,
			Font = playerFont,

			ZIndex = 88,
		}),

		New("Frame")({
			Name = "MainFrame",
			Size = UDim2.fromScale(1, 1),

			ZIndex = 5,

			[Children] = {
				New("Frame")({ -- UIFrame
					Size = Spring(MainFrameSize, 12, 1),
					BackgroundTransparency = 1,

					ZIndex = 5,

					[Children] = {
						Button({
							Name = "OpenHelp",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.01, 0.98),
							Text = "Help",
							Image = 7362810660,

							Activated = function()
								MainUI.MainFrame.Help.Visible = not MainUI.MainFrame.Help.Visible

								if MainUI.MainFrame.Help.Visible then
									DarkTintTransparency:set(DarkTintTransparencyGoal)
								else
									DarkTintTransparency:set(1)
								end
							end,
						}),
						Button({
							Name = "SaveData",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0.01, 0.88),
							Text = "Save",
							Image = 7415450693,
						}),
						Button({
							Name = "OpenShop",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.12),
							Text = "Shop",
							Image = 7362870044,

							Activated = function()
								MainUI.MainFrame.Shop.Visible = not MainUI.MainFrame.Shop.Visible

								if MainUI.MainFrame.Shop.Visible then
									DarkTintTransparency:set(DarkTintTransparencyGoal)
								else
									DarkTintTransparency:set(1)
								end
							end,
						}),
						Button({
							Name = "OpenSettings",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.39),
							Text = "Settings",
							Image = 7362801114,

							Activated = function()
								MainUI.MainFrame.Settings.Visible = not MainUI.MainFrame.Settings.Visible

								if MainUI.MainFrame.Settings.Visible then
									DarkTintTransparency:set(DarkTintTransparencyGoal)
								else
									DarkTintTransparency:set(1)
								end
							end,
						}),
						Button({
							Name = "AudioToggle",
							Size = UDim2.fromScale(0.15, 0.15),
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromScale(0.99, 0.98),
							Text = "",
							Image = 7517177224,

							Corner = 0.1,
							ImageSize = 0.9,
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
						}),
						Label({
							Name = "Currency",
							Size = UDim2.fromScale(0.22, 0.075),
							AnchorPoint = Vector2.new(0, 0),
							Position = UDim2.fromScale(0.01, 0.02),
							Text = "0 Typing Tokens",
							Image = 7367251392,

							LabelWidth = 0.7,
							LabelPosition = 0.95,
						}),
						Label({
							Name = "Words",
							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromScale(0.5, 0.02),
							Text = "0 Words",
							Image = 7367083297,
						}),

						New("TextButton")({ -- why from scratch
							Name = "DifficultyButton",

							Size = UDim2.fromScale(0.17, 0.075),
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.02),
							BackgroundColor3 = Grey3,
							AutoButtonColor = true,

							[Children] = {
								UICorner(),
								UIPadding({
									PaddingH = 0.033,
								}),

								New("IntValue")({
									Name = "DifficultyLevel",
									Value = 1,
								}),

								New("TextLabel")({
									Text = "Change Difficulty:",

									Size = UDim2.fromScale(0.6, 0.5),
									Position = UDim2.fromScale(0.9, 0.25),
									AnchorPoint = Vector2.new(1, 0.5),

									BackgroundTransparency = 1,
									Font = playerFont,
								}),

								New("TextLabel")({
									Name = "DifficultyLevelText",
									Text = "Easy",

									Size = UDim2.fromScale(0.6, 0.5),
									Position = UDim2.fromScale(0.9, 0.75),
									AnchorPoint = Vector2.new(1, 0.5),

									BackgroundTransparency = 1,
									Font = playerFont,
								}),

								New("ImageLabel")({
									Size = UDim2.fromScale(0.3, 0.3),
									Position = UDim2.fromScale(0, 0.5),
									AnchorPoint = Vector2.new(0, 0.5),

									Image = "rbxassetid://7363005276",
									[Children] = New("UIAspectRatioConstraint")({
										AspectRatio = 1,
										AspectType = Enum.AspectType.ScaleWithParentSize,
										DominantAxis = Enum.DominantAxis.Width,
									}),
								}),
							},
						}),

						New("Frame")({
							Name = "LevelMenu",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.fromScale(0.99, 0.115),
							Size = UDim2.fromScale(0.17, 0.255),
							BackgroundColor3 = Grey3,

							[Children] = {
								UICorner(0.05),
								UIPadding({
									Padding = 0.04,
								}),

								Label({
									Name = "Rank",
									Size = UDim2.fromScale(1, 0.32),
									AnchorPoint = Vector2.new(0.5, 1),
									Position = UDim2.fromScale(0.5, 1),
									Text = "Rank",
									Image = 7456285956,
								}),
								Label({
									Name = "Level",
									Size = UDim2.fromScale(1, 0.25),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Text = "Level 1",
									Image = 7367078076,
								}),
								Label({
									Name = "Experience",
									Size = UDim2.fromScale(1, 0.2),
									AnchorPoint = Vector2.new(0.5, 0),
									Position = UDim2.fromScale(0.5, 0),
									Text = "Amount until level up",

									Image = 261481376, -- DELETE THIS. AWFUL	-- ok, it did end up getting content deleted

									LabelWidth = 1,
									LabelPosition = 1,
								}),

								New("Frame")({
									Name = "BarHolder",
									Size = UDim2.fromScale(1, 0.08),
									Position = UDim2.fromScale(0.5, 0.28),

									BackgroundColor3 = Grey0,

									[Children] = {
										UICorner(0.5),

										[Children] = {
											New("Frame")({
												Name = "Bar",
												Size = UDim2.fromScale(0.5, 1),
												AnchorPoint = Vector2.new(0, 0),
												Position = UDim2.fromScale(0, 0),

												BackgroundColor3 = Green,

												[Children] = {
													UICorner(0.5),
												},
											}),
										},
									},
								}),
							},
						}),

						New("TextBox")({
							Name = "TypingBox",
							Position = UDim2.fromScale(0.5, 0.7),
							Size = UDim2.fromScale(0.5, 0.05),
							BackgroundColor3 = Grey0,

							Font = playerFont,
							PlaceholderText = "Type here (spacebar to complete word)",

							[Children] = {
								UICorner(),
								UIPadding(),
							},
						}),

						New("Folder")({
							Name = "NextWordLabels",

							[Children] = {
								New("TextLabel")({
									Name = "CurrentWordLabel",

									Size = UDim2.fromScale(0.4, 0.06),
									Position = UDim2.fromScale(0.5, 0.3),
									BackgroundTransparency = 1,

									Font = playerFont,
									Text = "word here",
								}),

								NextWords({
									Pos = 0.36,
									Name = "Label2",
								}),
								NextWords({
									Pos = 0.42,
									Name = "Label3",
								}),
								NextWords({
									Pos = 0.48,
									Name = "Label4",
								}),
								NextWords({
									Pos = 0.54,
									Name = "Label5",
								}),
							},
						}),
					},
				}),

				New("UIGradient")({
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 30, 28)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 10, 8)),
					}),
					Rotation = 110,
				}),

				New("Frame")({
					Name = "BackgroundDesign",

					Size = UDim2.fromScale(1.5, 0.75),
					BackgroundTransparency = 1,

					Rotation = -20,
					ZIndex = -50,

					[Children] = {
						New("Frame")({
							Name = "Frame1",

							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,

							[Children] = BackgroundDesign(),
						}),

						New("Frame")({
							Name = "Frame2",

							Size = UDim2.fromScale(1, 1),
							Position = UDim2.fromScale(0.5, 0.6),
							BackgroundTransparency = 1,

							[Children] = BackgroundDesign(),
						}),
					},
				}),

				-- MENU TIME
				-- OH MY GOD STOP PROCRASTINATING

				Popup({
					Name = "Help",
					Title = "HELP",
					Size = UDim2.fromScale(0.8, 0.8),
					Corner = 0.04,
					ZIndex = 120,

					-- Children does not require brackets here
					-- remember, this is a variable, children are applied in the Popup() function
					Children = New("TextLabel")({
						Name = "Text",
						AnchorPoint = Vector2.new(0.5, 0.9),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 1),
						Size = UDim2.fromScale(0.97, 1.1),
						Font = playerFont,
						RichText = true,
						Text = "Welcome to game name goes here!<br />This is a game you can use to improve your speed, accuracy, and stamina while typing.<br /><br />In the middle of the screen, a highlighted word will appear. Type it in the text box below, then press the spacebar once you finish a word.<br />The upcoming words are displayed below the current word.<br /><br />The button in the top-right corner allows you to change the difficulty of your words.<br /><br />Easy words can be between 2 and 4 letters long. They are the easiest to type.<br />They give 1 typing token and 12-15 exp per word.<br /><br />Medium words can be between 4 and 7 letters long. Harder, but more rewarding.<br />They give 2 typing tokens and 20-26 exp per word.<br /><br />Hard words can be between 7 and 10 letters long.<br />They give 3 typing tokens and 35-42 exp per word.<br /><br />Insane words were added as a joke, they are some of the longest words in English.<br />They give 5 typing tokens and 57-65 exp per word.<br /><br />Experience is used to level up. Each level requires 100 more experience to level up than the one before it.<br />Ranks are gained every 10 levels.<br /><br />Developers:<br />pjstarr12<br />TheWhaleCloud<br />Lewin4<br /><br />The soundtrack for the game is Click by C418.<br />Thanks to icons8 for providing the icons.<br /><br />Inspired by:<br />Monkeytype by Miodec<br />Typing Simulator by S-GAMES",
						TextSize = 28,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				Popup({
					Name = "Settings",
					Title = "SETTINGS",

					Size = UDim2.fromScale(0.5, 0.5),
					Corner = 0.04,
					ZIndex = 130,

					Children = {
						SettingsOption({
							Name = "Keysounds",
							Text = "Keypress Sounds",
						}),
						SettingsOption({
							Name = "Blind",
							Text = "Blind Mode",
							Right = true,
						}),
						SettingsOption({
							Name = "Memory",
							Text = "Memory Mode",
							Row = 1,
						}),
						SettingsOption({
							Name = "PlainBG",
							Text = "Plain Background",
							Row = 1,
							Right = true,
						}),
					},
				}),

				Popup({
					Name = "Shop",
					Title = "SHOP",

					Size = UDim2.fromScale(0.5, 0.5),
					Corner = 0.04,
					ZIndex = 120,

					Children = {
						ShopOption({
							Name = "MediumDifficulty",
							Text = "Medium Difficulty",
							Price = 40,
						}),
						ShopOption({
							Name = "HardDifficulty",
							Text = "Hard Difficulty",
							Right = true,
							Price = 100, -- the price is right
						}),
						ShopOption({
							Name = "InsaneDifficulty",
							Text = "Insane Difficulty",
							Row = 1,
							Price = 600,
						}),
					},
				}),

				New("Frame")({
					Name = "DarkTint",
					BackgroundColor3 = DarkBlack,
					BackgroundTransparency = Spring(DarkTintTransparency, 25),
					Size = UDim2.fromScale(2, 2),
					ZIndex = 100,
				}),
			},
		}),
	},
})