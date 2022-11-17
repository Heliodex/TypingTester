local ReplicatedStorage = game:GetService "ReplicatedStorage"
local ShopItems = require(ReplicatedStorage.Shared.ShopItems)

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
local dataLoaded = State.dataLoaded
local Colours = State.Colours
local playerFont = State.playerFont
local level = State.level
local currentShopItem = State.currentShopItem
local ownedWordlists = State.ownedWordlists

local Components = script.Parent
local UIPadding = require(Components.UIPadding)
local UICorner = require(Components.UICorner)

return function(props)
	local item = ShopItems[props.Category].Items[props.Name]
	local categoryName = ShopItems[props.Category].Name
	local labelText = Value(item.Price)
	local levelRequirement = item.Level

	if item.Ownable then
		Observer(dataLoaded):onChange(function()
			DataService:ItemOwned(categoryName, props.Name):andThen(function(owned)
				if owned then
					labelText:set "Owned"
					ownedWordlists[props.Name]:set(true)
				end
			end)
		end)
	end

	return New "TextButton" {
		Name = props.Name,

		AnchorPoint = if props.Right then Vector2.new(1, 0) else Vector2.new(0, 0),
		BackgroundColor3 = Colours.Grey3,

		[OnEvent "Activated"] = function()
			currentShopItem:set {
				Name = props.Name,
				Category = props.Category,
				CategoryName = categoryName,
				Level = item.Level,
				Ownable = item.Ownable,
				ButtonText = labelText,
			}
		end,

		[Children] = {
			New "TextLabel" {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.05, 0.5),
				Size = UDim2.fromScale(0.6, 0.8),
				FontFace = playerFont,

				TextColor3 = Colours.White,
				Text = props.Name,
				TextXAlignment = Enum.TextXAlignment.Left,
			},

			New "TextLabel" {
				Name = "Price",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(0.95, 0.5),
				Size = UDim2.fromScale(0.25, 1),
				FontFace = playerFont,

				TextColor3 = Colours.White,
				Text = labelText,

				[Children] = UIPadding(),
			},

			New "Frame" {
				Name = "LevelLock",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 0.15,
				BackgroundColor3 = Colours.Black0,
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
						ImageColor3 = Colours.White,
					},
					New "TextLabel" {
						Position = UDim2.fromScale(0.6, 0.5),
						Size = UDim2.fromScale(0.7, 0.7),
						FontFace = playerFont,
						TextColor3 = Colours.White,
						Text = "Level " .. levelRequirement,
					},
				},
			},

			UICorner(),
		},
	}
end
