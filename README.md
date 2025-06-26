# Seraph

An unfinished open source ESP module; created for Roblox. 
Any executors shouldn't have any problems using this; and if so make sure to write an issue.
Some features are still yet to be added; like highlighting & tracers, which will be added whenever im motivated to work on it
![image](https://github.com/user-attachments/assets/9c50f758-20f8-4a93-bbf2-4547386c7e77)

# Documentation

```lua
local renderInterface = require(Path) -- // or local renderInterface = loadstring(game:HttpGet("link"))()

for _, v in next, game:GetService("Players"):GetPlayers() do
    renderInterface:registerPlayer(v)
end

renderInterface:refreshInterface() -- // updates colors, this is a seperate function to improve performance

for i, v in next, renderInterface.cache do -- // to disconnect
    v.connection:Disconnect()
    for i, v in next, v.drawings.onScreen do
        v:Destroy()
    end 
end 
```

```lua
universal = {
    textFont = Font.new("rbxasset://fonts/families/Zekton.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    textSize = 13,
    textCasing = "Normal Case",
    textScalingEnabled = false,
    textScalingMinimum = { 10, 8 },
    textScalingMaximum = { 200, 13 },
    measurement = "studs",
    limitDistance = false,
    maxDistance = 2500,
    minDistance = 0,
    renderTime = 0.05,
}
```

```lua
enemy / friendly / self = {
	enabled = true,
	boxEnabled = true,
	boxColor = { Color3.fromRGB(255, 255, 255), 0 },
	boxOutlineEnabled = true,
	boxOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	boxGlowEnabled = true,
	boxGlowColor = { Color3.fromRGB(255, 255, 255), 0.65 },
	boxFillEnabled = true,
	boxFillRotation = 90,
	boxFillColor = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(100, 100, 100), 0.5},
	healthBarEnabled = true,
	healthBarColor = { Color3.fromRGB(0, 255, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 0), 0 },
	healthBarPosition = "Left",
	healthBarOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	armorBarEnabled = true,
	armorBarColor = { Color3.fromRGB(0, 0, 255), Color3.fromRGB(100, 100, 255), Color3.fromRGB(255, 255, 255), 0 },
	armorBarPosition = "Bottom",
	armorBarOutlineColor = { Color3.fromRGB(0, 0, 0), 0},
	healthEnabled = true,
	healthMin = 0,
	healthSuffix = "%",
	healthPosition = "Left",
	healthColor = { Color3.fromRGB(100, 255, 100), 0 },
	healthOutlineEnabled = true,
	healthOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	armorEnabled = true,
	armorMin = 0,
	armorSuffix = "%",
	armorPosition = "Bottom",
	armorColor = { Color3.fromRGB(100, 100, 255), 0 },
	armorOutlineEnabled = true,
	armorOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	nameEnabled = true,
	namePosition = "Top",
	nameColor = { Color3.fromRGB(255, 255, 255), 0 },
	nameOutlineEnabled = true,
	nameOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	displayNameEnabled = false,
	displayNamePosition = "Right",
	displayNameColor = { Color3.fromRGB(255, 255, 255), 0 },
	displayNameOutlineEnabled = true,
	displayNameOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	distanceEnabled = true,
	distancePosition = "Right",
	distanceColor = { Color3.fromRGB(255, 255, 255), 0 },
	distanceOutlineEnabled = true,
	distanceOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
	toolEnabled = true,
	toolPosition = "Right",
	toolColor = { Color3.fromRGB(255, 255, 255), 0 },
	toolOutlineEnabled = true,
	toolOutlineColor = { Color3.fromRGB(0, 0, 0), 0 },
}
```
