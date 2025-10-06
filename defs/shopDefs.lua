
local def = {
	{
		name = "Join Elite Stamp Cabal",
		bookType = {
			{probability = 1.0, bookType = "shop_6"},
		},
		size = 3,
		cost = 0,
		bookRequirement = 600,
		continuoValue = 5,
		shopImage = "international",
		desc = [[The very best collectors gather for international trade.
Bring a ♥ 500 book to enter.
Cost: $5]]
	},
	{
		name = "World Stamp Congress",
		qualityDist = util.NormaliseWeightedList({
			{probability = 0, qual = 1},
			{probability = 1, qual = 2},
			{probability = 0.8, qual = 3},
		}),
		bookType = {
			{probability = 0.4, bookType = "shop_5"},
			{probability = 0.3, bookType = "shop_5_thin"},
			{probability = 0.3, bookType = "shop_5_wide"},
		},
		size = 3,
		cost = 5,
		bookRequirement = 500,
		shopImage = "international",
		continuoValue = 4,
		desc = [[The very best collectors gather for international trade.
Bring a ♥ 500 book to enter.
Cost: $5]]
	},
	{
		name = "National Stamp Show",
		qualityDist = util.NormaliseWeightedList({
			{probability = 0.1, qual = 1},
			{probability = 1, qual = 2},
			{probability = 0.3, qual = 3},
		}),
		bookType = {
			{probability = 0.2, bookType = "shop_4"},
			{probability = 0.4, bookType = "shop_4_thin"},
			{probability = 0.4, bookType = "shop_4_wide"},
		},
		size = 3,
		cost = 4,
		bookRequirement = 250,
		shopImage = "national",
		continuoValue = 3,
		desc = [[Collectors from all over the nation gather to trade stamps.
Bring a ♥ 250 book to enter.
Cost: $4]]
	},
	{
		name = "Stan's Fine Stamps",
		qualityDist = util.NormaliseWeightedList({
			{probability = 0.5, qual = 1},
			{probability = 1, qual = 2},
			{probability = 0.1, qual = 3},
		}),
		bookType = {
			{probability = 0.6, bookType = "shop_3"},
			{probability = 0.2, bookType = "shop_3_thin"},
			{probability = 0.2, bookType = "shop_3_wide"},
		},
		size = 3,
		cost = 3,
		bookRequirement = 150,
		shopImage = "stan",
		continuoValue = 2,
		desc = [[The finest stamps Stan has to offer.
Bring a ♥ 150 book to enter.
Cost: $3]]
	},
	{
		name = "Serviceable Stamps",
		qualityDist = util.NormaliseWeightedList({
			{probability = 0.9, qual = 1},
			{probability = 1, qual = 2},
			{probability = 0, qual = 3},
		}),
		bookType = {
			{probability = 0.6, bookType = "shop_2"},
			{probability = 0.2, bookType = "shop_2_thin"},
			{probability = 0.2, bookType = "shop_2_wide"},
		},
		size = 3,
		cost = 2,
		continuoValue = 2,
		giveBooksUpTo = 3,
		giveBookType = "shop_1_thin",
		giveBookText = "Welcome to Serviceable Stamps. You look like an avid collector, have another stamp book, on the house.",
		bookRequirement = 90,
		shopImage = "auspost",
		desc = [[Trade stamps indoors.
Bring a ♥ 90 book to enter.
Cost: $2]]
	},
	{
		name = "Stamp Alley",
		qualityDist = util.NormaliseWeightedList({
			{probability = 1, qual = 1},
			{probability = 0.2, qual = 2},
			{probability = 0, qual = 3},
		}),
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
		shopImage = "alley",
		desc = [[Poorly kept stamps, poorly organised.
Cost: $1, but free to enter if you have no money.]]
	},
	{
		name = "Reroll",
		rerollButton = true,
	},
	{
		name = "Test",
		qualityDist = util.NormaliseWeightedList({
			{probability = 1, qual = 1},
			{probability = 1, qual = 2},
			{probability = 1, qual = 3},
		}),
		bookType = util.NormaliseWeightedList({
			{probability = 1, bookType = "large_test"},
			{probability = 1, bookType = "test_shop"},
			{probability = 1, bookType = "shop_1_thin"},
		}),
		size = 3,
		cost = false,
		continuoValue = 4,
		bookRequirement = false,
		shopImage = "alley",
		desc = [[Test.]]
	},
}

for i = 1, #def do
	def[i].index = i
end

local data = {
	def = def,
	defaultShopImage = "outside",
	starterShop = 6,
	shopLookahead = 1,
}

return data
