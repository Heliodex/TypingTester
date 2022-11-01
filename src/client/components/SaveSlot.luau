local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local LocalPlayer = Players.LocalPlayer
local Sounds = ReplicatedStorage.Sounds
local Ranks = require(ReplicatedStorage.Shared.Ranks)
local Knit = require(ReplicatedStorage.Packages.Knit)
local DataService = Knit.GetService "DataService"

local Fusion = require(script.Parent.Parent.Fusion)
local Children = Fusion.Children
local Computed = Fusion.Computed
local New = Fusion.New
local Observer = Fusion.Observer
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value

local State = require(script.Parent.Parent.State)
local MainUI = State.MainUI
local PlayScreen = State.PlayScreen
local MainFrameSize = State.MainFrameSize
local White = State.White
local Grey3 = State.Grey3
local playerFont = State.playerFont
local currency = State.currency
local experience = State.experience
local level = State.level
local wordsTyped = State.wordsTyped
local dataPrepared = State.dataPrepared
local dataLoaded = State.dataLoaded

local Components = script.Parent
local UIPadding = require(Components.UIPadding)
local UICorner = require(Components.UICorner)

local loadingData = false

-- Was quite the trip to get working
local function populateLeaderboard(leaderboard, page)
	for _, v in ipairs(leaderboard) do
		local you = v.Player == "You"

		-- Load users on leaderboard
		-- very slow, so it would make the game load slowly if it was done at creation of the leaderboard popup
		task.spawn(function()
			New "Frame" {
				Name = "LeaderboardPerson",
				Parent = page,

				Size = UDim2.fromScale(1, 0.1),
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
								FontFace = playerFont,
							},
							New "TextLabel" {
								Name = "Level",
								Text = if you then level else v.Level,

								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.6, 0.5),
								Size = UDim2.fromScale(0.2, 0.8),
								FontFace = playerFont,
							},
							New "TextLabel" {
								Name = "Words",
								Text = if you then wordsTyped else v.Words,

								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.fromScale(1, 0.5),
								Size = UDim2.fromScale(0.2, 0.8),
								FontFace = playerFont,
							},
						},
					},
				},
			}
		end)
	end
end

return function(props)
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
					if not data then
						print "Data not prepared yet!"
						text:set "Data not prepared yet, try again."
						task.wait(1)
						text:set("Save slot " .. props.SaveSlot)
						loadingData = false
						return
					end
					currency:set(data.Currency)
					experience:set(data.Experience)
					level:set(data.Level)
					wordsTyped:set(data.WordsTyped)

					dataLoaded:set(true)
					print "Data loaded!"

					PlayScreen:get().Frame.Visible = false
					Sounds.music:Play()
					MainFrameSize:set(UDim2.fromScale(1, 1))

					DataService:LevelLeaderboard():andThen(function(leaderboard)
						populateLeaderboard(
							leaderboard,
							MainUI:get().MainFrame.Leaderboard.ScrollingFrame.Pages.LevelLeaderboard
						)
					end)
					DataService:WordsLeaderboard():andThen(function(leaderboard)
						populateLeaderboard(
							leaderboard,
							MainUI:get().MainFrame.Leaderboard.ScrollingFrame.Pages.WordsLeaderboard
						)
					end)
				end, function()
					print "Error while loading data!"
					text:set "Error loading data!"
					task.wait(1)
					text:set("Save slot " .. props.SaveSlot)
					loadingData = false
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

				FontFace = playerFont,
			},

			New "TextLabel" {
				Name = "SaveSlotPreview",
				Text = previewText,

				Size = UDim2.fromScale(0.3, 0.8),
				Position = UDim2.fromScale(0.98, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				TextXAlignment = Enum.TextXAlignment.Right,

				FontFace = playerFont,
			},
		},
	}
end