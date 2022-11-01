--!strict

--[[
	Stores 'sensible default' properties to be applied to instances created by
	the New function.
]]

return {
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},

	BillboardGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},

	SurfaceGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
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
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,

		ScrollBarImageColor3 = Color3.new(),

		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	},

	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,

		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,

		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	},

	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,

		AutoButtonColor = true,

		Text = "",
		TextColor3 = Color3.new(1, 1, 1),

		TextScaled = true,
	},

	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
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
	
	UIPageLayout = {
		SortOrder = Enum.SortOrder.LayoutOrder,
		EasingStyle = Enum.EasingStyle.Quint,
	},

	ImageLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,

		BackgroundTransparency = 1,
	},

	ImageButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,

		AutoButtonColor = true,
	},

	ViewportFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
	},

	VideoFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
	},

	CanvasGroup = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,

		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	},

	Part = {
		BottomSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
	},
}
