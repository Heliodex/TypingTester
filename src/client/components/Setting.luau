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

return function(props)
	local clickable = true

	Observer(dataLoaded):onChange(function()
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
				FontFace = playerFont,
				Text = props.Text,
				TextXAlignment = Enum.TextXAlignment.Right,
			},
		},
	}
end
