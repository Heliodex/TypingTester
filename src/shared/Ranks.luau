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
local purple = Color3.new(0.5, 0, 1) -- 7f00ff
local black = Color3.new(0, 0, 0) -- 000000
local grey = Color3.new(0.5, 0.5, 0.5) -- 7f7f7f
local uigrey = Color3.fromRGB(42, 42, 42) -- 2a2a2a

local ranks = {
	{ -- 0-10
		Text = "None",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, uigrey),
			ColorSequenceKeypoint.new(1, uigrey),
		},
	},
	{ -- 10-20
		Text = "Typical Typer",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, blue),
			ColorSequenceKeypoint.new(1, cyan),
		},
		Badge = 2128769583,
	},
	{ -- 20-30
		Text = "Fast Fingers",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, darkblue),
			ColorSequenceKeypoint.new(1, blue),
		},
		Badge = 2128769584,
	},
	{ -- 30-40
		Text = "Speedy Speller",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, orange),
			ColorSequenceKeypoint.new(1, green),
		},
		Badge = 2128776064,
	},
	{ -- 40-50
		Text = "Rapid Reader",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, red),
			ColorSequenceKeypoint.new(1, blue),
		},
		Badge = 2128776071,
	},
	{ -- 50-60
		Text = "Computing Cadet",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, darkgreen),
			ColorSequenceKeypoint.new(1, green),
		},
		Badge = 2128776072,
	},
	{ -- 60-70
		Text = "Keyboard Knight",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, black),
			ColorSequenceKeypoint.new(1, red),
		},
		Badge = 2128776114,
	},
	{ -- 70-80
		Text = "Writing Warrior",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, grey),
			ColorSequenceKeypoint.new(1, black),
		},
		Badge = 2128776121,
	},
	{ -- 80-90
		Text = "Terrific Typist",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, green),
			ColorSequenceKeypoint.new(1, yellow),
		},
		Badge = 2128794964,
	},
	{ -- 90-100
		Text = "Obsessed Orthographer",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, blue),
			ColorSequenceKeypoint.new(1, grey),
		},
		Badge = 2128794965,
	},
	{ -- 100-110
		Text = "Studious Stenographer",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, grey),
			ColorSequenceKeypoint.new(1, orange),
		},
		Badge = 2128794967,
	},
	{ -- 110-120
		Text = "Hypersonic Hacker",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, green),
			ColorSequenceKeypoint.new(1, black),
		},
		Badge = 2128794973,
	},
	{ -- 120-130
		Text = "Word Wizard",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, black),
			ColorSequenceKeypoint.new(1, darkblue),
		},
		Badge = 2128794974,
	},
	{ -- 130-140
		Text = "Document Deity",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, orange),
			ColorSequenceKeypoint.new(1, yellow),
		},
		Badge = 2128814956,
	},
	{ -- 140-150
		Text = "Literacy Legend",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, pink),
			ColorSequenceKeypoint.new(1, orange),
		},
		Badge = 2128814958,
	},
	{ -- 150-160
		Text = "Textual Titan",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, purple),
			ColorSequenceKeypoint.new(1, red),
		},
	},
	{ -- 160-170
		Text = "Manuscript Master",
		Colour = ColorSequence.new {
			ColorSequenceKeypoint.new(0, darkgreen),
			ColorSequenceKeypoint.new(1, orange),
		},
	},

	-- Script Savant?
	-- Grammar Guru?
	-- Scribe Supreme?
}

local test = function(level)
	level = math.floor(level / 10)
	if level > #ranks - 1 then
		level = #ranks - 1
	end
	return ranks[level + 1]
end

return test
