
local def = {
	{
		name = "Join Stamp Elite",
		bookType = {
			{probability = 1.0, bookType = "shop_6"},
		},
		size = 3,
		cost = 0,
		bookRequirement = 600,
		continuoValue = 5,
		desc = [[Ascend to stamp collector glory.]]
	},
	{
		name = "World Stamp Congress",
		bookType = {
			{probability = 0.4, bookType = "shop_5"},
			{probability = 0.3, bookType = "shop_5_thin"},
			{probability = 0.3, bookType = "shop_5_wide"},
		},
		size = 3,
		cost = 40,
		bookRequirement = 400,
		continuoValue = 4,
		desc = [[The fanciest stamps.
Bring a value 400 book to enter.
Costs $40 to visit.]]
	},
	{
		name = "National Stamp Show",
		bookType = {
			{probability = 0.2, bookType = "shop_4"},
			{probability = 0.4, bookType = "shop_4_thin"},
			{probability = 0.4, bookType = "shop_4_wide"},
		},
		size = 3,
		cost = 20,
		bookRequirement = 300,
		continuoValue = 3,
		desc = [[The fanciest stamps.
Bring a value 300 book to enter.
Costs $20 to visit.]]
	},
	{
		name = "Stan's Fine Stamps",
		bookType = {
			{probability = 0.6, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_thin"},
			{probability = 0.2, bookType = "shop_3_wide"},
		},
		size = 3,
		cost = 10,
		bookRequirement = 200,
		continuoValue = 2,
		desc = [[The fanciest stamps.
Bring a value 200 book to enter.
Costs $10 to visit.]]
	},
	{
		name = "Serviceable Stamps",
		bookType = {
			{probability = 0.6, bookType = "shop_2"},
			{probability = 0.2, bookType = "shop_2_thin"},
			{probability = 0.2, bookType = "shop_2_wide"},
		},
		size = 3,
		cost = 5,
		continuoValue = 2,
		giveBooksUpTo = 3,
		giveBookType = "shop_1_thin",
		giveBookText = "Welcome to Serviceable Stamps. You look like an avid collector, have another stamp book, on the house.",
		bookRequirement = 100,
		desc = [[Decent stamps.
Bring a value 100 book to enter.
Costs $5 to visit.]]
	},
	{
		name = "Stamp Alley",
		bookType = {
			{probability = 0.4, bookType = "shop_1"},
			{probability = 0.2, bookType = "shop_1_thin"},
			{probability = 0.2, bookType = "shop_1_wide"},
			{probability = 0.1, bookType = "shop_1_tiny"},
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
