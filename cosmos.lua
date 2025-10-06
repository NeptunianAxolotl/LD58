
local World = require("world")
SoundHandler = require("soundHandler")
--MusicHandler = require("musicHandler")
MusicHandler = require("bgmHandler")
MainMenuHandler = require("mainMenuHandler")

local self = {}
local api = {}

-- Cosmos handles the world level, restarting the world,
-- and things that persist between worlds.

--------------------------------------------------
-- Music
--------------------------------------------------

function api.ToggleMusic()
	self.musicEnabled = not self.musicEnabled
	if not self.musicEnabled then
		MusicHandler.StopCurrentTrack()
	end
end

function api.MusicEnabled()
	return self.musicEnabled
end

--------------------------------------------------
-- Resets etc
--------------------------------------------------

function api.RestartWorld()
	World.Initialize(api, self.curLevelData)
end

function api.GetScrollSpeeds()
	return (self.grabInput and self.mouseScrollSpeed) or 0, self.keyScrollSpeed
end

function api.GetPersistentData()
	return self.persistentDataTable
end

function api.ToggleGrabInput()
	self.grabInput = not self.grabInput
	love.mouse.setGrabbed(self.grabInput)
end

function api.ScrollSpeedChange(change)
	self.mouseScrollSpeed = self.mouseScrollSpeed * change
	self.keyScrollSpeed = self.keyScrollSpeed * change
end

function api.TransposePlacementMode()
	return self.transposePlacementMode
end

function api.SetSkipTutorial(state)
	self.skipTutorial = state
end

function api.WantSkipTutorial()
	return self.skipTutorial
end

function api.QuitGame()
	love.event.quit()
end

function api.ToggleGodMode(state)
	self.godMode = not self.godMode
end

function api.IsGodMode(state)
	return self.godMode
end

--------------------------------------------------
-- Draw
--------------------------------------------------

function api.Draw()
	World.Draw()
end

function api.ViewResize(width, height)
	World.ViewResize(width, height)
end

function api.TakeScreenshot()
	love.filesystem.createDirectory("screenshots")
	print("working", love.filesystem.getWorkingDirectory())
	print("save", love.filesystem.getSaveDirectory())
	love.graphics.captureScreenshot("screenshots/screenshot_" .. math.floor(math.random()*100000) .. "_.png")
end

function api.GetRealTime()
	return self.realTime
end

--------------------------------------------------
-- Get
--------------------------------------------------

function api.GetWorld()
	return World
end

--------------------------------------------------
-- Input
--------------------------------------------------

function api.KeyPressed(key, scancode, isRepeat)
	if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.RestartWorld()
		return true
	end
	if key == "escape" then
		MainMenuHandler.ToggleMenu()
		return true
	end
	if key == "m" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.ToggleMusic()
		return true
	end
	if key == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.TakeScreenshot()
		return true
	end
	if Global.DEV_TOOLS_ENABLED then
		if key == "t" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
			self.transposePlacementMode = not self.transposePlacementMode
		end
		if key == "space" then
			self.skipTutorial = not self.skipTutorial
		end
		if key == "return" or key == "kpenter" then
			api.ToggleGodMode()
			self.skipTutorial = true
		end
	end
	return World.KeyPressed(key, scancode, isRepeat)
end

function api.MousePressed(x, y, button)
	return World.MousePressed(x, y, button)
end

function api.MouseReleased(x, y, button)
	return World.MouseReleased(x, y, button)
end

function api.MouseMoved(x, y, dx, dy)
	World.MouseMoved(x, y, dx, dy)
end

--------------------------------------------------
-- Update and Initialize
--------------------------------------------------

function api.Update(dt, realDt)
	self.realTime = self.realTime + realDt
	MusicHandler.Update(realDt)
	SoundHandler.Update(realDt)
	World.Update(dt)
end

function api.Initialize()
	self = {
		realTime = 0,
		musicEnabled = true,
		mouseScrollSpeed = Global.MOUSE_SCROLL_MULT,
		keyScrollSpeed = Global.KEYBOARD_SCROLL_MULT,
		grabInput = Global.MOUSE_SCROLL_MULT > 0,
		transposePlacementMode = false,
		skipTutorial = false,
	}
	MainMenuHandler.Initialize(api)
	MusicHandler.Initialize(api)
	SoundHandler.Initialize(api)
	World.Initialize(api, self.curLevelData)
end

return api
