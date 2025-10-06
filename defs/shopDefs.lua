
local def = {
	{
		name = "Join Stamp Elite",
		bookType = {
			{probability = 0.8, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_tall"},
		},
		size = 3,
		cost = 20,
		bookRequirement = 200,
		continuoValue = 3,
		desc = [[Do it.]]
	},
	{
		name = "World Stamp Congress",
		bookType = {
			{probability = 0.8, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_tall"},
		},
		size = 3,
		cost = 20,
		bookRequirement = 200,
		continuoValue = 3,
		desc = [[The fanciest stamps.
Bring a value 200 book to enter.
Costs $20 to visit.]]
	},
	{
		name = "National Stamp Show",
		bookType = {
			{probability = 0.8, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_tall"},
		},
		size = 3,
		cost = 20,
		bookRequirement = 200,
		continuoValue = 3,
		desc = [[The fanciest stamps.
Bring a value 200 book to enter.
Costs $20 to visit.]]
	},
	{
		name = "Stan's Fine Stamps",
		bookType = {
			{probability = 0.8, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_tall"},
		},
		size = 3,
		cost = 20,
		bookRequirement = 200,
		continuoValue = 3,
		desc = [[The fanciest stamps.
Bring a value 200 book to enter.
Costs $20 to visit.]]
	},
	{
		name = "Serviceable Stamps",
		bookType = {
			{probability = 1, bookType = "shop_2"},
		},
		size = 3,
		cost = 5,
		continuoValue = 2,
		giveBooksUpTo = 3,
		giveBookType = "shop_1_thin",
		giveBookText = "Have another stamp book, on the house.",
		bookRequirement = 80,
		desc = [[Decent stamps.
Bring a value 80 book to enter.
Costs $5 to visit.]]
	},
	{
		name = "Stamp Alley",
		bookType = {
			{probability = 0.5, bookType = "shop_1"},
			{probability = 0.5, bookType = "shop_1_thin"},
		},
		size = 3,
		cost = 1,
		continuoValue = 0,
		waiveCostIfNoMoney = true,
		bookRequirement = false,
		desc = [[Terrible stamps, terribly organised.
No standards.
Costs $1 to visit, if you can pay.]]
	},
	{
		name = "Test",
		bookType = util.NormaliseWeightedList({
			{probability = 1, bookType = "large_test"},
			{probability = 1, bookType = "test_shop"},
			{probability = 1, bookType = "shop_1_thin"},
		}),
		size = 3,
		cost = false,
		continuoValue = 4,
		bookRequirement = false,
		desc = [[Test.]]
	},
}

local data = {
	def = def,
	starterShop = 6,
	shopLookahead = 2,
}

return data
