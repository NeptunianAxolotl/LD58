
local books = util.LoadDefDirectory("defs/books")
local newBooks = {}

for name, def in pairs(books) do
	def.name = name
	newBooks[name] = def
end

local data = {
	defs = newBooks,
}

return data
