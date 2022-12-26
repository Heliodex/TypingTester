--[[
	The list contains categories, which contain items
	
	Item: Something that can be bought in the shop
		Description: Appears below the name after clicking on an item
		Price: The price of the item
		Level: The level required to buy the item
		Ownable: If false, the item can be bought multiple times
]]

return {
	{
		Name = "Wordlists",
		Items = {
			["Medium words"] = {
				Description = "Words between 4 and 7 letters long. Harder, but more rewarding. They give 2 typing tokens and 20-26 exp per word.",
				Price = 40,
				Level = 5,
				Ownable = true,
			},
			["Hard words"] = {
				Description = "Words between 7 and 10 letters long. They give 3 typing tokens and 35-42 exp per word.",
				Price = 100,
				Level = 10,
				Ownable = true,
			},
			["Insane words"] = {
				Description = "Some of the longest words in English. They give 5 typing tokens and 57-65 exp per word.",
				Price = 600,
				Level = 20,
				Ownable = true,
			},
		},
	},
	{
		Name = "Coming soon...",
		Items = {
			-- ["TestItem"] = {
			-- 	Description = "whatsu p bruh wburth this is a test item tdonot buy",
			-- 	Price = 5555555555555555,
			-- 	Level = 1,
			-- 	Ownable = false,
			-- },
		},
	},
}
