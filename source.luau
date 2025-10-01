--// fixed version of strekai's esp (by nam)

local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local mathHuge = math.huge
local newInstance = Instance.new
local newVector3 = Vector3.new
local newVector2 = Vector2.new
local newOffset = UDim2.fromOffset
local tableFind = table.find
local tableClone = table.clone
local localPlayer = players.LocalPlayer

local barOffset = 5
local barThickness = 3

local path = Instance.new("ScreenGui", runService:IsStudio() and players.LocalPlayer:WaitForChild("PlayerGui") or (gethui and gethui()) or game:GetService("CoreGui"))
path.IgnoreGuiInset = true

local alignments = { Top = "Center", Bottom = "Center", Right = "Left", Left = "Right" }
local options = {
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

local renderInterface = {
	cache = {},
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
	},
	enemy = tableClone(options),
	friendly = tableClone(options),
	self = tableClone(options),
}
renderInterface.__index = renderInterface

local function first_first_child(parent, name)
	if parent and parent.FindFirstChild then
		return parent:FindFirstChild(name)
	end
	return nil
end
local function find_first_child_of_class(parent, class)
	if parent and parent.FindFirstChildOfClass then
		return parent:FindFirstChildOfClass(class)
	end
	return nil
end

do
	function renderInterface.getCharacter(player)
		return player and player.Character
	end

	function renderInterface.getTool(character)
		if not character then return "None" end
		local tool = find_first_child_of_class(character, "Tool")
		return (tool and tool.Name) or "None"
	end
	-- replace with your own ways if you want
	function renderInterface.getArmor(player)
		return 75, 100
	end

	function renderInterface.getHealth(humanoid)
		if not humanoid then return 0, 100 end
		return humanoid.Health, humanoid.MaxHealth
	end

	function renderInterface.getStatus(player)
		if not player then return false end
		local character = renderInterface.getCharacter(player)
		if not character then return false end

		local humanoid = find_first_child_of_class(character, "Humanoid")
		local humanoidRootPart = first_first_child(character, "HumanoidRootPart")
		if not humanoid or not humanoidRootPart then return false end
		if humanoid.Health <= 0 then return false end

		return {
			alive = true,
			humanoid = humanoid,
			root = humanoidRootPart,
			char = character
		}
	end

	function renderInterface.isFriendly(player)
		if not player or not localPlayer then return false end
		return player.Team == localPlayer.Team
	end

	function renderInterface:create(object, properties, children)
		local instance = newInstance(object or "Frame")
		for i, v in next, properties or {} do
			local success, message = pcall(function() instance[i] = v end)
			if not success then warn("failed setprop:", i, message) end
		end
		for _, v in next, children or {} do
			local success, message = pcall(function() v.Parent = instance end)
			if not success then warn("failed parent:", message) end
		end
		if object == "Frame" then instance.BorderSizePixel = 0 end
		instance.Parent = path
		return instance
	end

	function renderInterface:scaleText(distance)
		local minimum, maximum = self.universal.textScalingMinimum, self.universal.textScalingMaximum
		local minDist, minSize = minimum[1], minimum[2]
		local maxDist, maxSize = maximum[1], maximum[2]
		return minSize + (maxSize - minSize) * (1 - (math.clamp(distance, minDist, maxDist) - minDist) / (maxDist - minDist))
	end

	function renderInterface:getBodyParts(character, rootPart, indexes, hitboxes)
		local parts = {}
		hitboxes = hitboxes or { "Head", "Arms", "Legs", "Torso" }

		if not character then return parts end

		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") and part ~= rootPart then
				local lower = part.Name:lower()
				if tableFind(hitboxes, "Head") and lower:find("head") then
					parts[indexes and part.Name or #parts + 1] = part
				elseif (tableFind(hitboxes, "Torso") and (lower:find("torso") or lower:find("upper") or lower:find("lower"))) then
					parts[indexes and part.Name or #parts + 1] = part
				elseif tableFind(hitboxes, "Arms") and (lower:find("arm") or lower:find("hand")) then
					parts[indexes and part.Name or #parts + 1] = part
				elseif tableFind(hitboxes, "Legs") and (lower:find("leg") or lower:find("foot")) then
					parts[indexes and part.Name or #parts + 1] = part
				end
			end
		end

		if #parts == 0 and rootPart then
			parts[1] = rootPart
		end

		return parts
	end

	function renderInterface:getBoundingBox(root)
		if not root then return { newVector2(0,0), newVector2(0,0), onScreen = false } end
		local character = root.Parent
		local parts = self:getBodyParts(character, root)

		local minX, minY = mathHuge, mathHuge
		local maxX, maxY = -mathHuge, -mathHuge
		local onScreen = false

		for _, part in ipairs(parts) do
			local size = part.Size / 2
			local cframe = part.CFrame
			local corners = {
				cframe * newVector3(-size.X, -size.Y, -size.Z),
				cframe * newVector3(-size.X, -size.Y,  size.Z),
				cframe * newVector3(-size.X,  size.Y, -size.Z),
				cframe * newVector3(-size.X,  size.Y,  size.Z),
				cframe * newVector3( size.X, -size.Y, -size.Z),
				cframe * newVector3( size.X, -size.Y,  size.Z),
				cframe * newVector3( size.X,  size.Y, -size.Z),
				cframe * newVector3( size.X,  size.Y,  size.Z),
			}
			for _, corner in ipairs(corners) do
				local screenPos, visible = camera:WorldToViewportPoint(corner)
				if visible then
					onScreen = true
					minX = math.min(minX, screenPos.X)
					minY = math.min(minY, screenPos.Y)
					maxX = math.max(maxX, screenPos.X)
					maxY = math.max(maxY, screenPos.Y)
				end
			end
		end

		if not onScreen then
			local screenPos, visible = camera:WorldToViewportPoint(root.Position)
			if visible then
				minX, maxX = screenPos.X, screenPos.X
				minY, maxY = screenPos.Y, screenPos.Y
				onScreen = true
			else
				return { newVector2(0, 0), newVector2(0, 0), onScreen = false }
			end
		end

		local boxSize = newVector2(math.max(2, maxX - minX), math.max(2, maxY - minY))
		local boxPosition = newVector2(math.floor(minX), math.floor(minY))

		return { boxSize, boxPosition, onScreen = onScreen }
	end
	function renderInterface:hideDrawings()
		for _, v in next, self.drawings.onScreen do
			if v then v.Visible = false end
		end
	end

	function renderInterface:construct()
		self.character = {}
		self.cframeCache = {}
		self.drawings = {
			onScreen = {
				Box = self:create("Frame", {
					BackgroundTransparency = (options.boxFillEnabled and options.boxFillColor[3]) or 1,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Name = "Box",
				}, {
					self:create("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0.00, options.boxFillColor[1]),
							ColorSequenceKeypoint.new(1.00, options.boxFillColor[2]),
						}),
						Rotation = options.boxFillRotation,
						Name = "Gradient",
					}),
					self:create("UIStroke", {
						Color = options.boxOutlineColor[1],
						Thickness = 3,
						Transparency = options.boxOutlineColor[2],
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						LineJoinMode = Enum.LineJoinMode.Miter,
						Name = "Outline",
					}),
					self:create("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Name = "Secondary",
					}, {
						self:create("UIStroke", {
							Color = options.boxColor[1],
							Transparency = options.boxColor[2],
							Thickness = 2,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							LineJoinMode = Enum.LineJoinMode.Miter,
							Name = "Main",
						}),
						self:create("Frame", {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Name = "Third",
						}, {
							self:create("UIStroke", {
								Color = options.boxOutlineColor[1],
								Thickness = 1,
								Transparency = options.boxOutlineColor[2],
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								LineJoinMode = Enum.LineJoinMode.Miter,
								Name = "Outline",
							}),
						}),
					}),
					self:create("ImageLabel", {
						Name = "Glow",
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						ScaleType = Enum.ScaleType.Slice,
						ImageTransparency = 0.65,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Image = "rbxassetid://18245826428",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, -20, 0, -20),
						Size = UDim2.new(1, 40, 1, 40),
						ZIndex = 0,
						BorderSizePixel = 0,
						SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
					})
				}),
				HealthBar = self:create("Frame", {
					BackgroundColor3 = options.healthBarOutlineColor[1],
					Name = "HBar",
				}, {
					self:create("Frame", {
						Name = "Bar",
						Position = UDim2.fromOffset(1, 1),
						Size = UDim2.new(1, -2, 1, -2),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = options.healthBarColor[4],
					}, {
						self:create("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0.00, options.healthBarColor[1]),
								ColorSequenceKeypoint.new(0.50, options.healthBarColor[2]),
								ColorSequenceKeypoint.new(1.00, options.healthBarColor[3]),
							}),
							Rotation = 90,
							Name = "Gradient",
						}),
						self:create("Frame", {
							Name = "Bar",
							BackgroundColor3 = options.healthBarOutlineColor[1],
							Size = UDim2.fromScale(1, 0)
						})
					})
				}),
				ArmorBar = self:create("Frame", {
					BackgroundColor3 = options.armorBarOutlineColor[1],
					Name = "ABar",
				}, {
					self:create("Frame", {
						Name = "Bar",
						Position = UDim2.fromOffset(1, 1),
						Size = UDim2.new(1, -2, 1, -2),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = options.armorBarColor[4],
					}, {
						self:create("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0.00, options.armorBarColor[1]),
								ColorSequenceKeypoint.new(0.50, options.armorBarColor[2]),
								ColorSequenceKeypoint.new(1.00, options.armorBarColor[3]),
							}),
							Rotation = 90,
							Name = "Gradient",
						}),
						self:create("Frame", {
							Name = "Bar",
							BackgroundColor3 = options.armorBarOutlineColor[1],
							Size = UDim2.fromScale(1, 0)
						})
					})
				}),
				Health = self:create("TextLabel", {
					BackgroundTransparency = 1,
					Name = "Health",
					FontFace = self.universal.textFont,
					TextSize = self.universal.textSize,
					TextColor3 = options.healthColor[1],
					TextTransparency = options.healthColor[2],
					TextYAlignment = Enum.TextYAlignment.Bottom,
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					self:create("UIStroke", {
						Color = options.healthOutlineColor[1],
						Transparency = options.healthOutlineColor[2],
						Thickness = 1,
						Name = "Outline",
						Enabled = options.healthOutlineEnabled
					}),
				}),
				Armor = self:create("TextLabel", {
					BackgroundTransparency = 1,
					Name = "Armor",
					FontFace = self.universal.textFont,
					TextSize = self.universal.textSize,
					TextColor3 = options.armorColor[1],
					TextTransparency = options.armorColor[2],
					TextYAlignment = Enum.TextYAlignment.Bottom,
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					self:create("UIStroke", {
						Color = options.armorOutlineColor[1],
						Transparency = options.armorOutlineColor[2],
						Thickness = 1,
						Name = "Outline",
						Enabled = options.armorOutlineEnabled
					}),
				}),
				Name = self:create("TextLabel", {
					BackgroundTransparency = 1,
					Name = "Name",
					FontFace = self.universal.textFont,
					TextSize = self.universal.textSize,
					TextColor3 = options.nameColor[1],
					TextTransparency = options.nameColor[2],
					Text = self.player and self.player.Name or "",
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					self:create("UIStroke", {
						Color = options.nameOutlineColor[1],
						Transparency = options.nameOutlineColor[2],
						Thickness = 1,
						Name = "Outline",
						Enabled = options.nameOutlineEnabled
					}),
				}),
				DisplayName = self:create("TextLabel", {
					BackgroundTransparency = 1,
					Name = "DisplayName",
					FontFace = self.universal.textFont,
					TextSize = self.universal.textSize,
					TextColor3 = options.displayNameColor[1],
					TextTransparency = options.displayNameColor[2],
					Text = self.player and self.player.DisplayName or "",
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					self:create("UIStroke", {
						Color = options.displayNameOutlineColor[1],
						Transparency = options.displayNameOutlineColor[2],
						Thickness = 1,
						Name = "Outline",
						Enabled = options.displayNameOutlineEnabled
					}),
				}),
				Distance = self:create("TextLabel", {
					BackgroundTransparency = 1,
					Name = "Distance",
					FontFace = self.universal.textFont,
					TextSize = self.universal.textSize,
					TextColor3 = options.distanceColor[1],
					TextTransparency = options.distanceColor[2],
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					self:create("UIStroke", {
						Color = options.distanceOutlineColor[1],
						Transparency = options.distanceOutlineColor[2],
						Thickness = 1,
						Name = "Outline",
						Enabled = options.distanceOutlineEnabled
					}),
				}),
				Tool = self:create("TextLabel", {
					BackgroundTransparency = 1,
					Name = "Tool",
					FontFace = self.universal.textFont,
					TextSize = self.universal.textSize,
					TextColor3 = options.toolColor[1],
					TextTransparency = options.toolColor[2],
					AutomaticSize = Enum.AutomaticSize.Y,
				}, {
					self:create("UIStroke", {
						Color = options.toolOutlineColor[1],
						Transparency = options.toolOutlineColor[2],
						Thickness = 1,
						Name = "Outline",
						Enabled = options.toolOutlineEnabled
					}),
				}),

				Right = self:create("Frame", {
					Name = "Right",
					BackgroundTransparency = 1,
					Visible = true
				}, {
					self:create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}),
				}),
				Left = self:create("Frame", {
					Name = "Left",
					BackgroundTransparency = 1,
					Visible = true
				}, {
					self:create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}),
				}),
				Bottom = self:create("Frame", {
					Name = "Bottom",
					BackgroundTransparency = 1,
					Visible = true
				}, {
					self:create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}),
				}),
				Top = self:create("Frame", {
					Name = "Top",
					BackgroundTransparency = 1,
					Visible = true
				}, {
					self:create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
					}),
				}),
			},
			offScreen = {},
		}

		self._lastBoxPos = newVector2(0, 0)
		self._lastBoxSize = newVector2(2, 2)
		self._lastUpdate = tick()

		return self
	end

	function renderInterface:deconstruct()
		if self.connection then
			self.connection:Disconnect()
			self.connection = nil
		end
		if self.drawings then
			for _, obj in pairs(self.drawings.onScreen) do
				if obj and obj.Destroy then
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end

	function renderInterface:refreshInterface()
		local config = (self.player == localPlayer and self.self) or renderInterface.isFriendly(self.player) and self.friendly or self.enemy
		-- box
		do
			local box = self.drawings.onScreen.Box
			local gradient = box:FindFirstChild("Gradient")
			local glow = box:FindFirstChild("Glow")
			local outline1 = box:FindFirstChild("Outline")
			local secondary = box:FindFirstChild("Secondary")
			local outline2 = secondary and secondary:FindFirstChild("Main")
			local outline3 = secondary and secondary:FindFirstChild("Third") and secondary.Third:FindFirstChild("Outline")

			box.BackgroundTransparency = config.boxFillEnabled and config.boxFillColor[3] or 1
			if gradient then
				gradient.Rotation = config.boxFillRotation
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, config.boxFillColor[1]),
					ColorSequenceKeypoint.new(1.00, config.boxFillColor[2]),
				})
			end
			if outline1 then
				outline1.Color = config.boxOutlineColor[1]
				outline1.Transparency = config.boxOutlineColor[2]
				outline1.Enabled = config.boxOutlineEnabled
			end
			if outline2 then
				outline2.Color = config.boxColor[1]
				outline2.Transparency = config.boxColor[2]
			end
			if outline3 then
				outline3.Color = config.boxOutlineColor[1]
				outline3.Transparency = config.boxOutlineColor[2]
				outline3.Enabled = config.boxOutlineEnabled
			end
			if glow then
				glow.ImageColor3 = config.boxGlowColor[1]
				glow.ImageTransparency = config.boxGlowColor[2]
				glow.Visible = config.boxGlowEnabled
			end
		end

		-- health bar
		do
			local bar1 = self.drawings.onScreen.HealthBar
			local bar2 = bar1:FindFirstChild("Bar")
			local topBar = bar2 and bar2:FindFirstChild("Bar")
			local gradient = bar2 and bar2:FindFirstChild("Gradient")
			bar1.BackgroundColor3 = config.healthBarOutlineColor[1]
			bar1.BackgroundTransparency = config.healthBarOutlineColor[2]
			if topBar then
				topBar.BackgroundColor3 = config.healthBarOutlineColor[1]
				topBar.BackgroundTransparency = config.healthBarOutlineColor[2]
			end
			if bar2 then
				bar2.BackgroundTransparency = config.healthBarColor[4]
			end
			if gradient then
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, config.healthBarColor[1]),
					ColorSequenceKeypoint.new(0.50, config.healthBarColor[2]),
					ColorSequenceKeypoint.new(1, config.healthBarColor[3]),
				})
			end
		end

		-- armor bar
		do
			local bar1 = self.drawings.onScreen.ArmorBar
			local bar2 = bar1:FindFirstChild("Bar")
			local topBar = bar2 and bar2:FindFirstChild("Bar")
			local gradient = bar2 and bar2:FindFirstChild("Gradient")
			bar1.BackgroundColor3 = config.armorBarOutlineColor[1]
			bar1.BackgroundTransparency = config.armorBarOutlineColor[2]
			if topBar then
				topBar.BackgroundColor3 = config.armorBarOutlineColor[1]
				topBar.BackgroundTransparency = config.armorBarOutlineColor[2]
			end
			if bar2 then
				bar2.BackgroundTransparency = config.armorBarColor[4]
			end
			if gradient then
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, config.armorBarColor[1]),
					ColorSequenceKeypoint.new(0.50, config.armorBarColor[2]),
					ColorSequenceKeypoint.new(1, config.armorBarColor[3]),
				})
			end
		end

		-- texts (name/display/distance/tool/health/armor) setup
		local function setupText(key, colorKey, outlineKey, enabledKey, positionKey)
			local text = self.drawings.onScreen[key]
			if not text then return end
			local outline = text:FindFirstChild("Outline")
			text.FontFace = renderInterface.universal.textFont
			if outline then
				outline.Color = options[outlineKey] and options[outlineKey][1] or Color3.fromRGB(0,0,0)
				outline.Transparency = options[outlineKey] and options[outlineKey][2] or 0
				outline.Enabled = options[outlineKey] and options[outlineKey].Enabled or true
			end
		end

		setupText("Name", "nameColor", "nameOutlineColor", "nameEnabled", "namePosition")
		setupText("DisplayName", "displayNameColor", "displayNameOutlineColor", "displayNameEnabled", "displayNamePosition")
		setupText("Distance", "distanceColor", "distanceOutlineColor", "distanceEnabled", "distancePosition")
		setupText("Tool", "toolColor", "toolOutlineColor", "toolEnabled", "toolPosition")
		setupText("Health", "healthColor", "healthOutlineColor", "healthEnabled", "healthPosition")
		setupText("Armor", "armorColor", "armorOutlineColor", "armorEnabled", "armorPosition")
	end

	function renderInterface:registerPlayer(player)
		self = setmetatable({}, renderInterface)
		self.player = assert(player, "expected a player!")
		self:construct()

		self:refreshInterface()

		self._lastTick = tick()
		self.connection = runService.RenderStepped:Connect(function()
			local now = tick()
			local dt = math.clamp(now - (self._lastTick or now), 0, 0.1)
			self._lastTick = now
			self:updateInterface(dt)
		end)

		renderInterface.cache[#renderInterface.cache + 1] = self
		return self
	end


	function renderInterface:updateInterface(dt)
		local dt = dt or (tick() - (self._lastUpdate or tick()))
		self._lastUpdate = tick()

		local configuration = (self.player == localPlayer and self.self) or renderInterface.isFriendly(self.player) and self.friendly or self.enemy
		if not configuration.enabled then
			self:hideDrawings()
			return
		end

		local playerData = renderInterface.getStatus(self.player)
		if not playerData or not playerData.alive then
			self:hideDrawings()
			return
		end

		local boxData = self:getBoundingBox(playerData.root)
		local boxPosition, boxSize = boxData[2], boxData[1]
		if not boxData.onScreen then
			self:hideDrawings()
			return
		end

		local localPlayerData = renderInterface.getStatus(localPlayer) or { isAlive = false, root = nil }
		local health, maxHealth = renderInterface.getHealth(playerData.humanoid)
		local armor, maxArmor = renderInterface.getArmor(self.player)
		local dist = (camera.CFrame.Position - playerData.root.Position).Magnitude
		local textSize = self.universal.textScalingEnabled and self:scaleText(dist) or self.universal.textSize

		for _, v in next, { "Left", "Right", "Top", "Bottom" } do
			local frm = self.drawings.onScreen[v]
			if frm then frm.Visible = true end
		end

		if configuration.boxEnabled then
			local box = self.drawings.onScreen.Box
			box.Size = newOffset(math.floor(boxSize.X), math.floor(boxSize.Y))
			box.Position = newOffset(math.floor(boxPosition.X), math.floor(boxPosition.Y))
			box.Visible = true

			self._lastBoxPos = boxPosition
			self._lastBoxSize = boxSize
		else
			self.drawings.onScreen.Box.Visible = false
		end

		local barPositions = { Left = {}, Right = {}, Top = {}, Bottom = {} }
		if configuration.healthBarEnabled then
			table.insert(barPositions[configuration.healthBarPosition], {
				name = "HealthBar",
				drawing = self.drawings.onScreen.HealthBar,
				health = health,
				maxHealth = maxHealth
			})
		end
		if configuration.armorBarEnabled then
			table.insert(barPositions[configuration.armorBarPosition], {
				name = "ArmorBar",
				drawing = self.drawings.onScreen.ArmorBar,
				armor = armor,
				maxArmor = maxArmor
			})
		end

		for side, bars in pairs(barPositions) do
			for i, barData in ipairs(bars) do
				local drawing = barData.drawing
				local offset = (i - 1) * (barThickness + 2)
				if not drawing then continue end

				if side == "Left" then
					drawing.Position = UDim2.fromOffset(boxPosition.X - barThickness - barOffset - offset, boxPosition.Y)
					drawing.Size = UDim2.fromOffset(barThickness, boxSize.Y)
				elseif side == "Right" then
					drawing.Position = UDim2.fromOffset(boxPosition.X + boxSize.X + barOffset + offset, boxPosition.Y)
					drawing.Size = UDim2.fromOffset(barThickness, boxSize.Y)
				elseif side == "Top" then
					drawing.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y - barThickness - barOffset - offset)
					drawing.Size = UDim2.fromOffset(boxSize.X, barThickness)
				elseif side == "Bottom" then
					drawing.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y + boxSize.Y + barOffset + offset)
					drawing.Size = UDim2.fromOffset(boxSize.X, barThickness)
				end

				local barFrame = drawing:FindFirstChild("Bar")
				local topBar = barFrame and barFrame:FindFirstChild("Bar")
				local gradient = barFrame and barFrame:FindFirstChild("Gradient")
				if barData.name == "HealthBar" and topBar and barData.maxHealth and barData.maxHealth > 0 then
					if side == "Left" or side == "Right" then
						topBar.AnchorPoint = Vector2.new(0, 0)
						topBar.Size = UDim2.fromScale(1, 1 - math.clamp(barData.health / barData.maxHealth, 0, 1))
					else
						topBar.AnchorPoint = Vector2.new(1, 0)
						topBar.Position = UDim2.fromScale(1, 0)
						topBar.Size = UDim2.fromScale(1 - math.clamp(barData.health / barData.maxHealth, 0, 1), 1)
					end
				end
				if barData.name == "ArmorBar" and topBar and barData.maxArmor and barData.maxArmor > 0 then
					if side == "Left" or side == "Right" then
						topBar.AnchorPoint = Vector2.new(0, 0)
						topBar.Size = UDim2.fromScale(1, 1 - math.clamp(barData.armor / barData.maxArmor, 0, 1))
					else
						topBar.AnchorPoint = Vector2.new(1, 0)
						topBar.Position = UDim2.fromScale(1, 0)
						topBar.Size = UDim2.fromScale(1 - math.clamp(barData.armor / barData.maxArmor, 0, 1), 1)
					end
				end

				drawing.Visible = true
			end
		end

		if not configuration.healthBarEnabled and self.drawings.onScreen.HealthBar then
			self.drawings.onScreen.HealthBar.Visible = false
		end
		if not configuration.armorBarEnabled and self.drawings.onScreen.ArmorBar then
			self.drawings.onScreen.ArmorBar.Visible = false
		end

		local function calcSideOffset(tbl)
			return #tbl > 0 and (#tbl * barThickness + (#tbl - 1) * 2 + barOffset) or 0
		end
		local sideOffsets = {
			Left = calcSideOffset(barPositions.Left),
			Right = calcSideOffset(barPositions.Right),
			Top = calcSideOffset(barPositions.Top),
			Bottom = calcSideOffset(barPositions.Bottom)
		}

		self.drawings.onScreen.Right.Position = UDim2.fromOffset(boxPosition.X + boxSize.X + sideOffsets.Right + 5, boxPosition.Y)
		self.drawings.onScreen.Right.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		self.drawings.onScreen.Left.Position = UDim2.fromOffset(boxPosition.X - boxSize.X - sideOffsets.Left - 5, boxPosition.Y)
		self.drawings.onScreen.Left.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		self.drawings.onScreen.Bottom.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y + boxSize.Y + sideOffsets.Bottom + 5)
		self.drawings.onScreen.Bottom.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		self.drawings.onScreen.Top.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y - boxSize.Y - sideOffsets.Top - 5)
		self.drawings.onScreen.Top.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		if configuration.healthEnabled then
			local text = self.drawings.onScreen.Health
			text.Parent = self.drawings.onScreen[configuration.healthPosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.healthPosition]]
			text.TextSize = textSize
			text.Text = math.floor(health) .. configuration.healthSuffix
			text.Visible = true
		else
			self.drawings.onScreen.Health.Visible = false
		end

		if configuration.armorEnabled then
			local text = self.drawings.onScreen.Armor
			text.Parent = self.drawings.onScreen[configuration.armorPosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.armorPosition]]
			text.TextSize = textSize
			text.Text = math.floor(armor) .. configuration.armorSuffix
			text.Visible = true
		else
			self.drawings.onScreen.Armor.Visible = false
		end

		if configuration.nameEnabled then
			local text = self.drawings.onScreen.Name
			text.Parent = self.drawings.onScreen[configuration.namePosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.namePosition]]
			text.TextSize = textSize
			text.Text = self.player and self.player.Name or ""
			text.Visible = true
		else
			self.drawings.onScreen.Name.Visible = false
		end

		if configuration.displayNameEnabled then
			local text = self.drawings.onScreen.DisplayName
			text.Parent = self.drawings.onScreen[configuration.displayNamePosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.displayNamePosition]]
			text.TextSize = textSize
			text.Text = self.player and self.player.DisplayName or ""
			text.Visible = true
		else
			self.drawings.onScreen.DisplayName.Visible = false
		end

		if configuration.distanceEnabled then
			local text = self.drawings.onScreen.Distance
			text.Parent = self.drawings.onScreen[configuration.distancePosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.distancePosition]]
			text.TextSize = textSize
			text.Text = localPlayerData and localPlayerData.alive and math.round((localPlayerData.root.Position - playerData.root.Position).Magnitude) or 0
			text.Visible = true
		else
			self.drawings.onScreen.Distance.Visible = false
		end

		if configuration.toolEnabled then
			local text = self.drawings.onScreen.Tool
			text.Parent = self.drawings.onScreen[configuration.toolPosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.toolPosition]]
			text.TextSize = textSize
			text.Text = renderInterface.getTool(playerData.char)
			text.Visible = true
		else
			self.drawings.onScreen.Tool.Visible = false
		end
	end
end

return renderInterface
--[[
for _, v in next, game:GetService("Players"):GetPlayers() do
    renderInterface:registerPlayer(v)
end

renderInterface:refreshInterface() -- // updates colors, this is a seperate function to improve performance

for i, v in next, renderInterface.cache do
    v.connection:Disconnect()
    for i, v in next, v.drawings.onScreen do
        v:Destroy()
    end 
end ]]
