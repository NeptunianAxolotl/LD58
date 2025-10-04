
local def = {
	{
		name = "Fancy",
		bookType = "shop_3",
		size = 3,
		cost = 20,
		bookRequirement = 200,
		desc = [[The fanciest stamps.
Bring a value 200 book to enter.
Costs $20 per visit.]]
	},
	{
		name = "Standard",
		bookType = "shop_2",
		size = 3,
		cost = 5,
		bookRequirement = 80,
		desc = [[Decent stamps.
Bring a value 80 book to enter.
Costs $5 per visit.]]
	},
	{
		name = "Bargin",
		bookType = "shop_1",
		size = 3,
		cost = false,
		bookRequirement = false,
		desc = [[Terrible stamps, terribly organised.
No standards.
Free to visit.]]
	},
}

return def
