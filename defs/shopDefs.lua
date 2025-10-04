
local def = {
	{
		name = "Fancy",
		bookType = {
			{probability = 0.8, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_tall"},
		},
		size = 3,
		cost = 20,
		bookRequirement = 200,
		desc = [[The fanciest stamps.
Bring a value 200 book to enter.
Costs $20 per visit.]]
	},
	{
		name = "Standard",
		bookType = {
			{probability = 1, bookType = "shop_2"},
		},
		size = 3,
		cost = 5,
		bookRequirement = 80,
		desc = [[Decent stamps.
Bring a value 80 book to enter.
Costs $5 per visit.]]
	},
	{
		name = "Bargin",
		bookType = {
			{probability = 0.5, bookType = "shop_1"},
			{probability = 0.5, bookType = "shop_1_thin"},
		},
		size = 3,
		cost = false,
		bookRequirement = false,
		desc = [[Terrible stamps, terribly organised.
No standards.
Free to visit.]]
	},
}

return def
