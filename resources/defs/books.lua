
local names = util.GetDefDirList("resources/images/book_backs", "png")
local data = {}

local offset = {
	money_bag = 0.5,
	alley = 0.5,
	auspost = 0.5,
	international = 0.5,
	national = 0.5,
	stan = 0.5,
	outside = 0.5,
}

local backgroundScale = 0.7
local scale = {
	["table"] = 1,
	alley = backgroundScale,
	auspost = backgroundScale,
	international = backgroundScale,
	national = backgroundScale,
	stan = backgroundScale,
	outside = backgroundScale,
}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/book_backs/" .. names[i] .. ".png",
		form = "image",
		xScale = scale[names[i]] or 0.45,
		yScale = scale[names[i]] or 0.45,
		xOffset = offset[names[i]] or 0,
		yOffset = offset[names[i]] or 0,
	}
end

return data
