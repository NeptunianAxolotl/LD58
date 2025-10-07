
local NewStamp = require("objects/stamp")
local ShopDefsData = require("defs/shopDefs")
local ShopDefs = ShopDefsData.def

local self = {}
local api = {}

local menuOptions = {
	"Quit",
	"Restart",
	"Music Volume",
	"Colourblind Mode",
	"Fullscreen",
	"Brutal",
}
local menuTooltip = {
	Brutal = function ()
		return string.format("Brutal - %s\nShops offer higher ♥ books and the books are more organised.\nProgress is much slower.", self.cosmos.GetBrutal() and "Enabled" or "Disabled")
	end,
}
local menuSliders = {
	["Music Volume"] = {
		drawFunc = function ()
			return self.cosmos.GetMusicVolume()/2
		end,
		changeFunc = function (frac)
			self.cosmos.SetMusicVolume(frac*2)
		end,
	}
}

if Global.DEV_TOOLS_ENABLED then
	menuOptions[#menuOptions + 1] = "Money++"
	menuOptions[#menuOptions + 1] ="Disable Tutorial"
	menuOptions[#menuOptions + 1] = "God Mode"
end

local function UpdateSliderDrag()
	local slider = self.sliderHeld and menuSliders[self.sliderHeld] and menuSliders[self.sliderHeld]
	if not (slider and slider.extents) then
		return
	end
	local mousePos = self.cosmos.GetWorld().GetMousePositionInterface()
	slider.changeFunc(math.max(0, math.min(1, (mousePos[1] - slider.extents.x) / slider.extents.width)))
	return true
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.MouseReleased(x, y, button)
	self.sliderHeld = false
end

function api.MouseMoved(x, y, dx, dy)
	return UpdateSliderDrag()
end

function api.MousePressed(x, y, button)
	self.sliderHeld = false
	if menuSliders[self.hoveredMenuAction] then
		self.sliderHeld = self.hoveredMenuAction
		UpdateSliderDrag()
	elseif self.hoveredMenuAction == "Menu" then
		api.ToggleMenu()
	elseif self.hoveredMenuAction == "Quit" then
		self.cosmos.QuitGame()
	elseif self.hoveredMenuAction == "Restart" then
		self.cosmos.RestartWorld()
	elseif self.hoveredMenuAction == "Colourblind Mode" then
		self.cosmos.ToggleColorblindMode()
	elseif self.hoveredMenuAction == "Money++" then
		TableHandler.AddMoney(1000)
	elseif self.hoveredMenuAction == "Disable Tutorial" then
		self.cosmos.SetSkipTutorial(true)
	elseif self.hoveredMenuAction == "God Mode" then
		TableHandler.AddMoney(10000)
		self.cosmos.ToggleGodMode()
	elseif self.hoveredMenuAction == "Fullscreen" then
		self.fullscreen = not self.fullscreen
		love.window.setFullscreen(self.fullscreen)
	elseif self.hoveredMenuAction == "Brutal" then
		self.cosmos.ToggleBrutal()
	elseif self.menuOpen then
		self.menuOpen = false
		return true
	end
	return self.menuOpen
end

function api.ToggleMenu()
	self.menuOpen = not self.menuOpen
end

function api.Draw(drawQueue)
	drawQueue:push({y=1000; f=function()
		self.hoveredMenuAction = false
		local mousePos = self.cosmos.GetWorld().GetMousePositionInterface()
		
		local sx, sy = TableHandler.GetSideboardDrawPosition(0)
		self.hoveredMenuAction = InterfaceUtil.DrawButton(sx - 20, sy - 8, 135, 60, mousePos, "Menu", false, false, false, false, 2, 8) or self.hoveredMenuAction
		
		if not self.menuOpen then
			return
		end
		local overX = 150
		local offset = Global.WINDOW_Y * 0.035 + 80*6
		for i = 1, #menuOptions do
			local slider = menuSliders[menuOptions[i]]
			if slider and not slider.extents then
				slider.extents = {x = overX + 20, width = 350}
			end
			local hovered = InterfaceUtil.DrawButton(overX + 20, offset, 350, 60, mousePos, menuOptions[i], false, false, false, false, 2, 8, false, false, slider and slider.drawFunc())
			if hovered then
				self.hoveredMenuAction = hovered
				if menuTooltip[menuOptions[i]] then
					TableHandler.SetTooltip(menuTooltip[menuOptions[i]]())
				end
			end
			offset = offset - 80
		end
	end})
end

function api.Initialize(cosmos)
	self = {
		cosmos = cosmos,
		menuOpen = false,
		fullscreen = true,
	}
end

return api
