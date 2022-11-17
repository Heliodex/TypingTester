local Fusion = require(script.Parent.Parent.Fusion)
local Children = Fusion.Children
local New = Fusion.New
local OnEvent = Fusion.OnEvent

local State = require(script.Parent.Parent.State)
local Colours = State.Colours
local playerFont = State.playerFont

local Components = script.Parent
local UICorner = require(Components.UICorner)
local UIPadding = require(Components.UIPadding)

return function(props)
	props.LabelWidth = props.LabelWidth or 0.6
	props.ImageSize = props.ImageSize or 0.3
	props.Size = props.Size or UDim2.fromScale(0.17, 0.075)
	props.SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeXY
	props.LayoutOrder = props.LayoutOrder or nil

	local ratio = (props.Size.Width.Scale / props.Size.Height.Scale) -- i hate
	local clickable = true

	return New "TextButton" {
		Name = props.Name,

		Size = props.Size,
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position,
		BackgroundColor3 = props.BackgroundColor3 or Colours.Grey3,
		LayoutOrder = props.LayoutOrder,

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

				FontFace = playerFont,
				TextColor3 = Colours.White,
			},
		},
	}
end
