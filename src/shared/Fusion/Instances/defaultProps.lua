--[[
	Stores 'sensible default' properties to be applied to instances created by
	the New function.

	Modified with custom defaults
]]

local ENABLE_SENSIBLE_DEFAULTS = true

if ENABLE_SENSIBLE_DEFAULTS then
	return {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling",
		},

		BillboardGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling",
		},

		SurfaceGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling",

			SizingMode = "PixelsPerStud",
			PixelsPerStud = 50,
		},

		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,

			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		},

		ScrollingFrame = {
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,

			ScrollBarImageColor3 = Color3.new(),

			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},

		TextLabel = {
			BorderSizePixel = 0,

			Text = "",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,

			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		},

		TextButton = {
			BorderSizePixel = 0,

			AutoButtonColor = true,

			Text = "",
			TextColor3 = Color3.new(1, 1, 1),

			TextScaled = true,
		},

		TextBox = {
			BorderSizePixel = 0,

			ClearTextOnFocus = false,

			Text = "",
			TextColor3 = Color3.new(1, 1, 1),

			AnchorPoint = Vector2.new(0.5, 0.5),
			TextScaled = true,
		},

		UIGridLayout = {
			SortOrder = Enum.SortOrder.LayoutOrder,
		},

		ImageLabel = {
			BorderSizePixel = 0,

			BackgroundTransparency = 1,
		},

		ImageButton = {
			BorderSizePixel = 0,

			AutoButtonColor = true,
		},

		ViewportFrame = {
			BorderSizePixel = 0,
		},

		VideoFrame = {
			BorderSizePixel = 0,
		},

		Part = {
			BottomSurface = Enum.SurfaceType.Smooth,
			TopSurface = Enum.SurfaceType.Smooth,
		},
	}
else
	return {}
end
