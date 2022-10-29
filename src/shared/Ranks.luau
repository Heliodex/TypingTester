-- Manages ranks
-- Directly been copied from legacy tsbb

local pink = Color3.new(1, 0, 0.5) -- ff007f
local red = Color3.new(0.75, 0, 0) -- bf0000
local orange = Color3.new(0.9, 0.5, 0) -- e57f00
local yellow = Color3.new(0.8, 0.75, 0) -- ccbf00
local green = Color3.new(0.2, 1, 0) -- 33ff00
local darkgreen = Color3.new(0, 0.5, 0) -- 007f00
local cyan = Color3.new(0, 0.9, 0.9) -- 00e5e5
local blue = Color3.new(0, 0.5, 1) -- 007fff
local darkblue = Color3.new(0, 0, 1) -- 0000ff
local black = Color3.new(0, 0, 0) -- 000000
local grey = Color3.new(0.5, 0.5, 0.5) -- 7f7f7f
local uigrey = Color3.fromRGB(42, 42, 42) -- 2a2a2a

local gradients = { -- Yanderedev Moment
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, uigrey),
		ColorSequenceKeypoint.new(1, uigrey),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, blue),
		ColorSequenceKeypoint.new(1, cyan),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, darkblue),
		ColorSequenceKeypoint.new(1, blue),
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
		ColorSequenceKeypoint.new(0, orange),
		ColorSequenceKeypoint.new(1, yellow),
	},
	ColorSequence.new {
		ColorSequenceKeypoint.new(0, pink),
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
			Badge = 2128769583,
		}
	elseif level < 30 then
		return {
			Text = "Fast Fingers",
			Colour = gradients[3],
			Badge = 2128769584,
		}
	elseif level < 40 then
		return {
			Text = "Speedy Speller",
			Colour = gradients[4],
			Badge = 2128776064,
		}
	elseif level < 50 then
		return {
			Text = "Rapid Reader",
			Colour = gradients[5],
			Badge = 2128776071,
		}
	elseif level < 60 then
		return {
			Text = "Computing Cadet",
			Colour = gradients[6],
			Badge = 2128776072,
		}
	elseif level < 70 then
		return {
			Text = "Keyboard Knight",
			Colour = gradients[7],
			Badge = 2128776114,
		}
	elseif level < 80 then
		return {
			Text = "Writing Warrior",
			Colour = gradients[8],
			Badge = 2128776121,
		}
	elseif level < 90 then
		return {
			Text = "Terrific Typist",
			Colour = gradients[9],
			Badge = 2128794964,
		}
	elseif level < 100 then
		return {
			Text = "Obsessed Orthographer",
			Colour = gradients[10],
			Badge = 2128794965,
		}
	elseif level < 110 then
		return {
			Text = "Studious Stenographer",
			Colour = gradients[11],
			Badge = 2128794967,
		}
	elseif level < 120 then
		return {
			Text = "Hypersonic Hacker",
			Colour = gradients[12],
			Badge = 2128794973,
		}
	elseif level < 130 then
		return {
			Text = "Word Wizard",
			Colour = gradients[13],
			Badge = 2128794974,
		}
	elseif level < 140 then
		return {
			Text = "Document Deity",
			Colour = gradients[14],
			Badge = 2128814956,
		}
	else
		return {
			Text = "Literacy Legend",
			Colour = gradients[15],
			Badge = 2128814958,
		}
	end
end
