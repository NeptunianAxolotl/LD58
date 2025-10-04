
local self = {}
local api = {}
local world

--------------------------------------------------
-- 
--------------------------------------------------


--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end

function api.Draw(drawQueue)
	drawQueue:push({y=800; f=function()
		local xOff = Global.WINDOW_X *0.2
		local yOff = Global.WINDOW_Y *0.6
		for i = 1, #self.books do
			self.books[i].Draw({xOff, yOff}, 120)
			xOff = xOff + 200
		end
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
	}
	
	self.books[#self.books + 1] = BookHelper.GetBook({})
end

return api
