-- Manages ranks
-- Directly been copied from legacy tsbb

local red = Color3.new(0.75, 0, 0)
local green = Color3.new(0.2, 1, 0)
local darkgreen = Color3.new(0, 0.5, 0)
local orange = Color3.new(0.9, 0.5, 0)
local cyan = Color3.new(0, 0.9, 0.9)
local blue = Color3.new(0, 0.5, 1)
local darkblue = Color3.new(0, 0, 1)
local yellow = Color3.new(0.8, 0.75, 0)
local black = Color3.new(0, 0, 0)
local grey = Color3.new(0.5, 0.5, 0.5)
local uigrey = Color3.fromRGB(42, 42, 42)

local gradients = { -- Yanderedev Moment
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, uigrey),
		ColorSequenceKeypoint.new(1, uigrey),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, cyan),
		ColorSequenceKeypoint.new(1, blue),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, blue),
		ColorSequenceKeypoint.new(1, darkblue),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, orange),
		ColorSequenceKeypoint.new(1, green),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, red),
		ColorSequenceKeypoint.new(1, blue),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, darkgreen),
		ColorSequenceKeypoint.new(1, green),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, black),
		ColorSequenceKeypoint.new(1, red),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, grey),
		ColorSequenceKeypoint.new(1, black),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, green),
		ColorSequenceKeypoint.new(1, yellow),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, blue),
		ColorSequenceKeypoint.new(1, grey),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, grey),
		ColorSequenceKeypoint.new(1, orange),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, green),
		ColorSequenceKeypoint.new(1, black),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, black),
		ColorSequenceKeypoint.new(1, darkblue),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, yellow),
		ColorSequenceKeypoint.new(1, orange),
	},
}

return function(level)
	if level < 10 then
		return {
			Text = "None",
			Colour = gradients[1],
		}
	elseif level < 20 then
		return {
			Text = "Typical Typer",
			Colour = gradients[2],
		}
	elseif level < 30 then
		return {
			Text = "Fast Fingers",
			Colour = gradients[3],
		}
	elseif level < 40 then
		return {
			Text = "Speedy Speller",
			Colour = gradients[4],
		}
	elseif level < 50 then
		return {
			Text = "Rapid Reader",
			Colour = gradients[5],
		}
	elseif level < 60 then
		return {
			Text = "Computing Cadet",
			Colour = gradients[6],
		}
	elseif level < 70 then
		return {
			Text = "Wonderful Writer",
			Colour = gradients[7],
		}
	elseif level < 80 then
		return {
			Text = "Keyboard Knight",
			Colour = gradients[8],
		}
	elseif level < 90 then
		return {
			Text = "Terrific Typist",
			Colour = gradients[9],
		}
	elseif level < 100 then
		return {
			Text = "Obsessed Orthographer",
			Colour = gradients[10],
		}
	elseif level < 110 then
		return {
			Text = "Studious Stenographer",
			Colour = gradients[11],
		}
	elseif level < 120 then
		return {
			Text = "Hypersonic Hacker",
			Colour = gradients[12],
		}
	elseif level < 130 then
		return {
			Text = "Word Wizard",
			Colour = gradients[13],
		}
	else
		return {
			Text = "Document Deity",
			Colour = gradients[14],
		}
	end
end
