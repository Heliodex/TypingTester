local Fusion = require(script.Parent.Parent.Fusion)
local New = Fusion.New

return function(props)
	if props then
		props.Padding = props.Padding or 0.075
		props.PaddingV = props.PaddingV or props.Padding
		props.PaddingH = props.PaddingH or props.Padding
	else
		props = {
			Padding = 0.075,
			PaddingV = 0.075,
			PaddingH = 0.075,
		}
	end

	return New "UIPadding" {
		PaddingBottom = UDim.new(props.PaddingV, 0),
		PaddingTop = UDim.new(props.PaddingV, 0),
		PaddingLeft = UDim.new(props.PaddingH, 0),
		PaddingRight = UDim.new(props.PaddingH, 0),
	}
end
