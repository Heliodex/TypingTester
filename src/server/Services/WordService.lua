local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Words = require(script.Parent.Parent.Words)

local WordService = Knit.CreateService({
	Name = "WordService",
})

function WordService.Client:GetWord()
	return Words.mediumList[math.random(1, #Words.mediumList)]
end

function WordService.Client:GetWordlist(_, howMany) 
	-- OHHHHHHHHHHHHHHHH that's why I couldn't get data saving in the original game working
	-- It's a RemoteEvent. First argument is always the player.

	howMany = howMany or 6
	local list = {}
	for i = 1, howMany do
		list[i] = Words.mediumList[math.random(1, #Words.mediumList)]
	end
	return list
end

return WordService
