local ContentProvider = game:GetService "ContentProvider"
local Images = {
	Checked = "rbxassetid://7523095951",
	Unchecked = "rbxassetid://7523096047",
	Playing = "rbxassetid://7517177224",
	Muted = "rbxassetid://7517176989",
}

local imagesArray = {}
for _, image in pairs(Images) do
	table.insert(imagesArray, image)
end

task.spawn(function()
	ContentProvider:PreloadAsync(imagesArray)
end)

return Images
