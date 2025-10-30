local MenuLib = require(game.ReplicatedStorage.MenuLib)

local menu = MenuLib.new("Moon", UDim2.new(0.5, -210, 0.5, -160))

local tab1 = menu:AddTab("Main")
local tab2 = menu:AddTab("Settings")

menu:AddButton(tab1, "Print Hello", function()
	print("Hello from Moon!")
end)

menu:AddToggle(tab1, "God Mode", false, function(state)
	print("God Mode:", state)
end)

menu:AddSlider(tab2, "Speed", 16, 200, 50, function(val)
	print("Speed set to:", val)
end)

menu:AddDropdown(tab2, "Theme", {"Dark", "Light", "Ocean"}, 1, function(i, name)
	print("Theme:", name)
end)
