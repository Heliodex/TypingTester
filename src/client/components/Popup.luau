local UserInputService = game:GetService "UserInputService"

local Fusion = require(script.Parent.Parent.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value

local State = require(script.Parent.Parent.State)
local MainUI = State.MainUI
local DarkTintTransparency = State.DarkTintTransparency
local Grey2 = State.Grey2
local Grey1 = State.Grey1
local Black2 = State.Black2
local playerFont = State.playerFont
local playerFontBold = State.playerFontBold

local Components = script.Parent
local UICorner = require(Components.UICorner)
local UIPadding = require(Components.UIPadding)

return function(props)
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
	local pos = Value(props.Position or UDim2.fromScale(0.5, 0.5))
	local mousePos = Vector2.new()
	local popupPos = pos:get()
	popup = New "CanvasGroup" {
		Name = props.Name,

		Size = props.Size or UDim2.fromScale(0.8, 0.8),
		Position = pos,
		BackgroundColor3 = Grey2,
		Visible = false,

		[Children] = {
			UICorner(props.Corner or 0.04),

			New "ScrollingFrame" {
				Active = true,
				Position = UDim2.fromScale(0.5, 0.556), -- perfect values
				Size = UDim2.fromScale(1, 0.888),
				CanvasSize = UDim2.fromScale(0.9, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,

				[Children] = {
					UIPadding {
						Padding = 0.01,
					},
					props.Children,
				},
			},

			New "TextButton" {
				Name = "Top",
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = Grey1,
				AutoButtonColor = false,

				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 0.1),

				[OnEvent "MouseButton1Down"] = function()
					mousePos = UserInputService:GetMouseLocation()
					popupPos = popup.Position
				end,

				[OnEvent "MouseMoved"] = function()
					if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						local newPos = UserInputService:GetMouseLocation() - (mousePos or Vector2.new())
						pos:set(UDim2.new(0.5, newPos.X + popupPos.X.Offset, 0.5, newPos.Y + popupPos.Y.Offset))
					end
				end,

				[Children] = {
					New "TextLabel" {
						Name = "Label",
						Size = UDim2.fromScale(0.8, 0.8),

						FontFace = playerFontBold,
						Text = string.upper(props.Name),
					},

					New "TextButton" {
						Name = "CloseButton",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Black2,

						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromScale(1, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						FontFace = playerFont,

						Text = "X",
						AutoButtonColor = true,

						-- Has to be MouseButton1Down because of glitchy dragging
						[OnEvent "MouseButton1Down"] = function()
							popup.Visible = false
							popup.Parent = MainUI:get().MainFrame

							if not props.NoBG then
								DarkTintTransparency:set(1)
							end
						end,

						[Children] = UIPadding(),
					},
				},
			},

			props.MainChildren,
		},
	}
	return popup
end
