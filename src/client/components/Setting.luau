local ReplicatedStorage = game:GetService "ReplicatedStorage"
local Images = require(script.Parent.Parent.Images)

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataService = Knit.GetService "DataService"
local SyncService = Knit.GetService "SyncService"

local Fusion = require(script.Parent.Parent.Fusion)
local Children = Fusion.Children
local Computed = Fusion.Computed
local New = Fusion.New
local Observer = Fusion.Observer
local OnEvent = Fusion.OnEvent

local State = require(script.Parent.Parent.State)
local dataLoaded = State.dataLoaded
local playerFont = State.playerFont
local Settings = State.Settings
local layoutOrder = 0

return function(name)
	local clickable = true

	Observer(dataLoaded):onChange(function()
		DataService:GetSetting(name):andThen(function(value)
			Settings[name]:set(value)
		end)
	end)

	layoutOrder += 1
	return New "TextButton" {
		Name = name,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,

		[OnEvent "Activated"] = function()
			if clickable then
				clickable = false

				Settings[name]:set(not Settings[name]:get())

				SyncService:ChangeSetting(name)
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
					return if Settings[name]:get() then Images.Checked else Images.Unchecked
				end),
			},
			New "TextLabel" {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.7, 0.8),
				FontFace = playerFont,
				Text = name,
				TextXAlignment = Enum.TextXAlignment.Right,
			},
		},
	}
end
