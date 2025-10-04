
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local NewBook = require("objects/book")

local api = {}

function api.GetBook(def)
	return NewBook(def)
end

function api.DrawBook(self, pos, scale)
end

return api
