
local NewStamp = require("objects/stamp")
local ShopDefsData = require("defs/shopDefs")
local ShopDefs = ShopDefsData.def

local self = {}
local api = {}

local menuOptions = {
	"Quit",
	"Restart",
	"Toggle Music",
	"Colourblind Mode",
	"Fullscreen",
	"Brutal",
}
local menuTooltip = {
	Brutal = function ()
		return string.format("Brutal - %s\nShops offer higher ♥ books and the books are more organised.\nProgress is much slower.", self.cosmos.GetBrutal() and "Enabled" or "Disabled")
	end,
}

if Global.DEV_TOOLS_ENABLED then
	menuOptions[#menuOptions + 1] = "Money++"
	menuOptions[#menuOptions + 1] ="Disable Tutorial"
	menuOptions[#menuOptions + 1] = "God Mode"
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.MousePressed(x, y, button)
	if self.hoveredMenuAction == "Menu" then
		api.ToggleMenu()
	elseif self.hoveredMenuAction == "Quit" then
		self.cosmos.QuitGame()
	elseif self.hoveredMenuAction == "Restart" then
		self.cosmos.RestartWorld()
	elseif self.hoveredMenuAction == "Toggle Music" then
		self.cosmos.ToggleMusic()
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
			local hovered = InterfaceUtil.DrawButton(overX + 20, offset, 350, 60, mousePos, menuOptions[i], false, false, false, false, 2, 8)
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
