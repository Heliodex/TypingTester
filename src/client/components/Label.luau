local Fusion = require(script.Parent.Parent.Fusion)
local Children = Fusion.Children
local New = Fusion.New

local State = require(script.Parent.Parent.State)
local Grey0 = State.Grey0
local playerFont = State.playerFont

local Components = script.Parent
local UICorner = require(Components.UICorner)
local UIPadding = require(Components.UIPadding)

return function(props)
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

				FontFace = playerFont,
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
