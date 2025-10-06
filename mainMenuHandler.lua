
local NewStamp = require("objects/stamp")
local ShopDefsData = require("defs/shopDefs")
local ShopDefs = ShopDefsData.def

local self = {}
local api = {}

local menuOptions = {
	"Quit",
	"Restart",
	"Toggle Music",
	"Money++",
	"Disable Tutorial",
}

--------------------------------------------------
-- API
--------------------------------------------------

function api.MousePressed(x, y, button)
	if self.hoveredMenuAction == "Menu" then
		api.ToggleMenu()
	elseif self.hoveredMenuAction == "Restart" then
		self.cosmos.RestartWorld()
	elseif self.hoveredMenuAction == "Quit" then
		self.cosmos.QuitGame()
	elseif self.hoveredMenuAction == "Money++" then
		TableHandler.AddMoney(1000)
	elseif self.hoveredMenuAction == "Disable Tutorial" then
		self.cosmos.SetSkipTutorial(true)
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
			self.hoveredMenuAction = InterfaceUtil.DrawButton(overX + 20, offset, 270, 60, mousePos, menuOptions[i], false, false, false, false, 2, 8) or self.hoveredMenuAction
			offset = offset - 80
		end
	end})
end

function api.Initialize(cosmos)
	self = {
		cosmos = cosmos,
		menuOpen = false,
	}
end

return api
