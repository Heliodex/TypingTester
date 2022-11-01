local Fusion = require(script.Parent.Parent.Fusion)
local New = Fusion.New

return function(corner)
	return New "UICorner" {
		CornerRadius = UDim.new(corner or 0.2, 0),
	}
end
