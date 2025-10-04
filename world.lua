
EffectsHandler = require("effectsHandler")
TableHandler = require("tableHandler")
BookHelper = require("bookHelper")

InterfaceUtil = require("utilities/interfaceUtilities")
Delay = require("utilities/delay")

CameraHandler = require("cameraHandler")
Camera = require("utilities/cameraUtilities")

GameHandler = require("gameHandler") -- Handles the gamified parts of the game, such as score, progress and interface.

local PriorityQueue = require("include/PriorityQueue")

local self = {}
local api = {}

function api.SetMenuState(newState)
	self.menuState = newState
end

function api.ToggleMenu()
	self.menuState = not self.menuState
end

function api.GetPaused()
	return self.paused or self.menuState
end

function api.GetGameOver()
	return self.gameWon or self.gameLost, self.gameWon, self.gameLost, self.overType
end

function api.GetLifetime()
	return self.lifetime
end

function api.Restart()
	self.cosmos.RestartWorld()
end

function api.GetCosmos()
	return self.cosmos
end

function api.SetGameOver(hasWon, overType)
	if self.gameWon or self.gameLost or TerrainHandler.InEditMode() then
		return
	end
	
	if hasWon then
		self.gameWon = true
	else
		self.gameLost = true
		self.overType = overType
	end
end

--------------------------------------------------
-- Input
--------------------------------------------------

function api.KeyPressed(key, scancode, isRepeat)
	if key == "escape" then
		api.ToggleMenu()
	end
	if key == "p" then
		api.ToggleMenu()
	end
	if api.GetGameOver() then
		return -- No doing actions
	end
	if GameHandler.KeyPressed and GameHandler.KeyPressed(key, scancode, isRepeat) then
		return
	end
end

function api.MousePressed(x, y, button)
	if GameHandler.MousePressed(x, y, button) then
		return
	end
	if api.GetPaused() then
		return
	end
	local uiX, uiY = self.interfaceTransform:inverse():transformPoint(x, y)
	
	if api.GetGameOver() then
		return -- No doing actions
	end
	
	if TableHandler.MousePressed(x, y, button) then
		return
	end
	
	-- Send event to game components
	if Global.DEBUG_PRINT_CLICK_POS and button == 2 then
		print("{")
		print([[    name = "BLA",]])
		print("    pos = {" .. (math.floor(x/10)*10) .. ", " .. (math.floor(y/10)*10) .. "},")
		print("},")
		return true
	end
end

function api.MouseReleased(x, y, button)
	x, y = CameraHandler.GetCameraTransform():inverse():transformPoint(x, y)
	-- Send event to game components
end

function api.MouseMoved(x, y, dx, dy)
	
end

--------------------------------------------------
-- Transforms
--------------------------------------------------

function api.WorldToScreen(pos)
	local x, y = CameraHandler.GetCameraTransform():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.ScreenToWorld(pos)
	local x, y = CameraHandler.GetCameraTransform():inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.ScreenToInterface(pos)
	local x, y = self.interfaceTransform:inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.GetMousePositionInterface()
	local x, y = love.mouse.getPosition()
	return api.ScreenToInterface({x, y})
end

function api.GetMousePosition()
	local x, y = love.mouse.getPosition()
	return api.ScreenToWorld({x, y})
end

function api.WorldScaleToScreenScale()
	local m11 = CameraHandler.GetCameraTransform():getMatrix()
	return m11
end

function api.GetOrderMult()
	return self.orderMult
end

function api.GetCameraExtents(buffer)
	local screenWidth, screenHeight = love.window.getMode()
	local topLeftPos = api.ScreenToWorld({0, 0})
	local botRightPos = api.ScreenToWorld({screenWidth, screenHeight})
	buffer = buffer or 0
	return topLeftPos[1] - buffer, topLeftPos[2] - buffer, botRightPos[1] + buffer, botRightPos[2] + buffer
end

function api.GetPhysicsWorld()
	return PhysicsHandler.GetPhysicsWorld()
end

local function UpdateCamera(dt)
	CameraHandler.Update(dt)
end

function api.GetCameraInitalPosition()
	return {500, 500}
end

--------------------------------------------------
-- Updates
--------------------------------------------------

function api.ViewResize(width, height)
end

function api.Update(dt)
	GameHandler.Update(dt)
	if api.GetPaused() then
		UpdateCamera(dt)
		return
	end
	TableHandler.Update(dt)
	
	self.lifetime = self.lifetime + dt
	Delay.Update(dt)
	InterfaceUtil.Update(dt)
	
	EffectsHandler.Update(dt)
	UpdateCamera(dt)
end

function api.Draw()
	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)
	
	local windowX, windowY = love.window.getMode()
	if windowX/windowY > Global.WINDOW_X/Global.WINDOW_Y then
		local edge = (windowX - Global.WINDOW_X*windowY/Global.WINDOW_Y) / 2
		self.interfaceTransform:setTransformation(edge, 0, 0, windowY/Global.WINDOW_Y, windowY/Global.WINDOW_Y, 0, 0)
	else
		local edge = (windowY - Global.WINDOW_Y*windowX/Global.WINDOW_X) / 2
		self.interfaceTransform:setTransformation(0, edge, 0, windowX/Global.WINDOW_X, windowX/Global.WINDOW_X, 0, 0)
	end
	love.graphics.replaceTransform(self.interfaceTransform)
	
	-- Draw interface
	GameHandler.Draw(drawQueue)
	TableHandler.Draw(drawQueue)
	EffectsHandler.Draw(drawQueue)
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	love.graphics.replaceTransform(self.emptyTransform)
end

function api.Initialize(cosmos, levelData)
	self = {}
	self.cosmos = cosmos
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	self.paused = false
	self.lifetime = Global.DEBUG_START_LIFETIME or 0
	
	Delay.Initialise()
	InterfaceUtil.Initialize()
	EffectsHandler.Initialize(api)
	
	GameHandler.Initialize(api)
	TableHandler.Initialize(api)
	
	CameraHandler.Initialize(api)
end

return api
