
local NewStamp = require("objects/stamp")

local self = {}
local api = {}

--------------------------------------------------
-- API
--------------------------------------------------


function api.JustCheckUnderMouse(x, y, width, height)
	local mouse = self.world.GetMousePositionInterface()
	return util.PosInRectangle(mouse, x, y, width, height)
end

function api.CheckAndSetUnderMouse(x, y, width, height, thing)
	if not api.JustCheckUnderMouse(x, y, width, height) then
		return false
	end
	self.underMouse = thing
	return true
end

local function PlaceStamp(placePos)
	if not placePos then
		return false
	end
	if placePos.type == "sideboard" then
		local index = placePos.index
		local sideStamp = self.sideboard[index] or false
		self.sideboard[index] = self.heldStamp or false
		self.heldStamp = sideStamp
		local leftEmptySpace = self.heldStamp and not self.sideboard[index]
		return leftEmptySpace
	elseif placePos.type == "book" then
		local book = placePos.book
		local bookStamp = book.ReplaceStamp(placePos.x, placePos.y, self.heldStamp or false)
		local leftEmptySpace = bookStamp and not self.heldStamp
		self.heldStamp = bookStamp
		return leftEmptySpace
	end
end

function api.MousePressed(x, y, button)
	if button == 1 then
		if not self.underMouse then
			return
		end
		if PlaceStamp(self.underMouse) then
			self.emptySpot = self.underMouse
		end
	elseif button == 2 and self.heldStamp and self.emptySpot then
		PlaceStamp(self.emptySpot)
		self.emptySpot = false
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	
	self.underMouse = false
end


function api.Draw(drawQueue)
	if self.heldStamp then
		drawQueue:push({y=500; f=function()
			if self.heldStamp then
				local mouse = self.world.GetMousePositionInterface()
				local scale = 120
				self.heldStamp.Draw(mouse[1], mouse[2], scale)
			end
		end})
	end
	drawQueue:push({y=100; f=function()
		local xOff = Global.WINDOW_X *0.08
		local yOff = Global.WINDOW_Y *0.6
		local scale = 120
		
		for i = 1, self.sideboardSize do
			local underMouse = api.CheckAndSetUnderMouse(xOff, yOff, scale, scale, {type = "sideboard", index = i})
			love.graphics.setLineWidth(3)
			if underMouse then
				love.graphics.setColor(0.2, 1, 0.2, 1)
			else
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle("line", xOff, yOff, scale, scale)
			if self.sideboard[i] then
				self.sideboard[i].Draw(xOff + scale/2, yOff + scale/2, scale)
			end
			yOff = yOff + scale + 20
		end
		
		xOff = Global.WINDOW_X *0.2
		yOff = Global.WINDOW_Y *0.6
		for i = 1, #self.books do
			self.books[i].Draw(xOff, yOff, scale)
			xOff = xOff + 400
		end
	end})
end

function api.Initialize(world)
	self = {
		world = world,
		books = {},
		sideboardSize = 2,
		sideboard = {},
	}
	self.sideboard[2] = NewStamp({name = "basic_stamp", cost = 1 + math.floor(math.random()*10)})
	
	self.books[#self.books + 1] = BookHelper.GetBook({})
	self.books[#self.books + 1] = BookHelper.GetBook({})
end

return api
