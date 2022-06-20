local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local WordService = Knit.CreateService({
	Name = "WordService",
})

function WordService.Client:GetWord()
	return ""--Words.easyList[math.random(1, #Words.easyList)]
end

function WordService.Client:GetWordlist(_, howMany) 
	-- OHHHHHHHHHHHHHHHH that's why I couldn't get data saving in the original game working
	-- It's a RemoteEvent. First argument is always the player.

	howMany = howMany or 6
	local list = {}
	for i = 1, howMany do
		list[i] = ""--Words.easyList[math.random(1, #Words.easyList)]
	end
	return list
end

return WordService
