
local StampDefData = require("defs/stampDefs")
local StampDefs = StampDefData.defs

local function NewBook(def)
	local self = {}
	local api = {}
	self.bonusDisplayTable = IterableMap.New()
	self.width = def.width
	self.height = def.height
	self.stamps = def.stamps
	self.score = BookHelper.CalculateBookScore(self, self.bonusDisplayTable)
	self.position = def.position or {math.random()*2 - 1, 0}
	self.velocity = {0, 0}
	
	function api.SetPosition(newPos)
		self.position = newPos
		self.velocity = {0, 0}
	end
	
	function api.GetPosition()
		return self.position
	end
	
	function api.GetOfferOffset()
		return self.width == 2 and -10 or self.width == 3 and -2 or 4
	end
	
	function api.UpdatePhysics(dt, index, otherBooks)
		local accel = {-12*self.position[1], 0}
		for i = 1, #otherBooks do
			if i ~= index then
				local other = otherBooks[i]
				local oPos = other.GetPosition()
				local width = math.max(2.4, other.GetWidth()) + math.max(2.4, self.width) + 1.2
				if math.abs(self.position[1] - oPos[1]) < width*0.15 then
					local sign = (oPos[1] > self.position[1]) and 1 or -1
					local val = (width*0.15 - math.abs(self.position[1] - oPos[1]))
					accel[1] = accel[1] - 250*sign*val*val
				end
			end
		end
		accel[1] = math.min(200, math.max(-200, accel[1]))
		local speed = math.abs(self.velocity[1]) + 0.05
		self.velocity = util.Add(util.Mult(dt, accel), self.velocity)
		self.velocity = util.Mult(math.max(0, (0.8 - speed/(0.8 + speed))), self.velocity)
		self.position = util.Add(util.Mult(dt, self.velocity), self.position)
		if TableHandler.BookOnOffer() == index then
			self.position[2] = self.position[2] + 6*dt
		else
			self.position[2] = self.position[2] - 6*dt
		end
		self.position[1] = math.max(-1, math.min(1, self.position[1]))
		self.position[2] = math.max(0, math.min(1, self.position[2]))
	end
	
	function api.GetSelfData()
		return self
	end
	
	function api.GetScore()
		return self.score
	end
	
	function api.GetWidth()
		return self.width
	end
	
	function api.GetHeight()
		return self.height
	end
	
	function api.GetStampAt(x, y)
		return self.stamps[x] and self.stamps[x][y]
	end
  
  function api.GetFullness()
    local capacity = self.height * self.width
    local count = 0
    for i=1,self.width do
      for j=1,self.height do
        local s = api.GetStampAt(i,j)
        if s ~= nil
        then count = count + 1.0
        end
      end
    end
    return count / capacity
  end
	
	function api.ReplaceStamp(x, y, replacement)
		replacement, self.stamps[x][y] = TableHandler.PlaceStampAndMaybeDoAbility(replacement, self.stamps[x][y], api, x, y)
		IterableMap.Clear(self.bonusDisplayTable)
		self.score = BookHelper.CalculateBookScore(self, self.bonusDisplayTable)
		return replacement
	end
	
	function api.GetBonusIterationData()
		local bonusCount, keyByIndex, bonusByKey = IterableMap.GetBarbarianData(self.bonusDisplayTable)
		return bonusCount, keyByIndex, bonusByKey
	end
	
	function api.Draw(x, y, scale, hoverType, index, drawBonuses)
		local xScale = scale * Global.STAMP_WIDTH
		local yScale = scale * Global.STAMP_HEIGHT
		for i = 1, self.width do
			for j = 1, self.height do
				if not hoverType or not TableHandler.JustCheckUnderMouse(x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale) then
					love.graphics.setColor(0, 0, 0, 1)
					love.graphics.setLineWidth(2)
					love.graphics.rectangle("line", x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale)
				end
			end
		end
		for i = 1, self.width do
			for j = 1, self.height do
				local underMouse = hoverType and TableHandler.CheckAndSetUnderMouse(
					x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale,
					{type = hoverType, book = api, index = index, x = i, y = j}
				)
				if underMouse then
					love.graphics.setColor(0.2, 1, 0.2, 1)
					love.graphics.setLineWidth(3)
					love.graphics.rectangle("line", x + (i - 1)*xScale, y + (j - 1)*yScale, xScale, yScale)
				end
				if self.stamps[i][j] then
					self.stamps[i][j].Draw(x + (i - 0.5)*xScale, y + (j - 0.5)*yScale, scale)
				end
			end
		end
	end
	
	return api
end

return NewBook
