local camera, players, runService = workspace.CurrentCamera, game:GetService("Players"), game:GetService("RunService")
local mathHuge, newInstance, newVector3, newVector2 = math.huge, Instance.new, Vector3.new, Vector2.new
local newOffset = UDim2.fromOffset
local findFirstChild, findFirstChildOfClass, isA =
	workspace.FindFirstChild, workspace.FindFirstChildOfClass, workspace.IsA
local tableFind, tableClone = table.find, table.clone
local localPlayer = players.LocalPlayer 

local barOffset = 5 
local barThickness = 3 

local path = Instance.new("ScreenGui",  runService:IsStudio() and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") or (gethui and gethui()) or game:GetService("CoreGui")); path.IgnoreGuiInset = true
local alignments = { ["Top"] = "Center", ["Bottom"] = "Center", ["Right"] = "Left", ["Left"] = "Right" }
local lastRendered = 0
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
do
	-- // functions

	function renderInterface.getCharacter(player: Player): any
		return player.Character
	end

	function renderInterface.getTool(character: Model): string
		local tool = findFirstChildOfClass(character, "Tool")

		return (tool and tool.Name) or "None"
	end

	function renderInterface.getArmor(player: Player): number -- // Placeholder
		return 75, 100
	end

	function renderInterface.getHealth(humanoid: Humanoid): number
		return humanoid.Health, humanoid.MaxHealth
	end

	function renderInterface.getStatus(player : Player): any
		if not player then
			return false
		end

		local character = renderInterface.getCharacter(player)
		if not character then
			return false
		end

		local humanoid = findFirstChildOfClass(character, "Humanoid")
		local humanoidRootPart = findFirstChild(character, "HumanoidRootPart")
		if not humanoid or not humanoidRootPart then
			return false
		end

		if humanoid.Health <= 0 then
			return false
		end

		return {
			alive = true, 
			humanoid = humanoid, 
			root = humanoidRootPart, 
			char = character
		}
	end

	function renderInterface.isFriendly(player : Player) : any 
		return player.Team == localPlayer.Team 
	end

	-- // methods

	function renderInterface:create(object: string, properties: { any }, children: { any }): any
		local instance = newInstance(object or "Frame")

		for i, v in next, properties or {} do
			local success, message = pcall(function()
				instance[i] = v
			end)

			if not success then
				warn("failed to create instance; " .. message)
			end
		end

		for i, v in next, children or {} do
			local success, message = pcall(function()
				v.Parent = instance
			end)

			if not success then
				warn("failed to parent object to instance; " .. message)
			end
		end

		if object == "Frame" then
			instance.BorderSizePixel = 0
		end

		instance.Parent = path

		return instance
	end

	function renderInterface:scaleText(distance: number): number
		local minimum, maximum = self.universal.textScalingMinimum, self.universal.textScalingMaximum
		local minDist, minSize = minimum[1], minimum[2]
		local maxDist, maxSize = maximum[1], maximum[2]

		return minSize + (maxSize - minSize) * (1 - (math.clamp(distance, minDist, maxDist) - minDist) / (maxDist - minDist))
	end

	function renderInterface:getBodyParts(character, rootPart, indexes, hitboxes)
		local parts = {}
		hitboxes = hitboxes or {"Head", "Arms", "Legs"} -- "Torso"
		--
		for index, part in pairs(character:GetChildren()) do
			if isA(part, "BasePart") and part ~= rootPart then
				if tableFind(hitboxes, "Head") and part.Name:lower():find("head") then
					parts[indexes and part.Name or #parts + 1] = part
				elseif tableFind(hitboxes, "Torso") and part.Name:lower():find("torso") then
					parts[indexes and part.Name or #parts + 1] = part
				elseif tableFind(hitboxes, "Arms") and part.Name:lower():find("arm") then
					parts[indexes and part.Name or #parts + 1] = part
				elseif tableFind(hitboxes, "Legs") and part.Name:lower():find("leg") then
					parts[indexes and part.Name or #parts + 1] = part
				elseif (tableFind(hitboxes, "Arms") and part.Name:lower():find("hand")) or (tableFind(hitboxes, "Legs ") and part.Name:lower():find("foot")) then
					parts[indexes and part.Name or #parts + 1] = part
				end
			end
		end
		--
		return parts
	end

	function renderInterface:getBoundingBox(root)
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
				local screenPos, visible = camera:worldToViewportPoint(corner)
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
			local screenPos, visible = camera:worldToViewportPoint(root.Position)
			if visible then
				minX, maxX = screenPos.X, screenPos.X
				minY, maxY = screenPos.Y, screenPos.Y
				onScreen = true
			else
				minX, maxX, minY, maxY = 0, 0, 0, 0
			end
		end

		-- Ensure the box is always at least 2x2 pixels
		local boxSize = newVector2(math.max(2, maxX - minX), math.max(2, maxY - minY))
		local boxPosition = newVector2(math.floor(minX), math.floor(minY))

		return {boxSize, boxPosition, onScreen = onScreen}
	end

	function renderInterface:hideDrawings()
		for i, v in next, self.drawings.onScreen do 
			v.Visible = false 
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
						ImageColor3 = Color3.fromRGB(255, 255, 255),  -- Use your theme's accent color
						ScaleType = Enum.ScaleType.Slice,
						ImageTransparency = 0.65,  -- Adjust transparency as needed
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Image = "rbxassetid://18245826428",  -- You may want to find a suitable glow asset
						BackgroundTransparency = 1,
						Position = UDim2.new(0, -20, 0, -20),
						Size = UDim2.new(1, 40, 1, 40),
						ZIndex = 0,  -- Ensure it's behind other elements
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
							Size = UDim2.fromScale(1, 0) -- second number is to scale based off hp
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
							Size = UDim2.fromScale(1, 0) -- second number is to scale based off hp
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
					Text = self.player.Name,
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
					Text = self.player.DisplayName,
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

				-- // sides 

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

		return self 
	end

	function renderInterface:deconstruct()
	end 

	function renderInterface:refreshInterface()
		local config = (self.player == localPlayer and self.self) or renderInterface.isFriendly(self.player) and self.friendly or self.enemy

		do -- // bounded box
			local box = self.drawings.onScreen.Box 
			local gradient = box.Gradient 
			local glow = box.Glow 
			local outline1 = box.Outline 
			local outline2 = box.Secondary.Main 
			local outline3 = box.Secondary.Third.Outline 

			box.Transparency = config.boxFillEnabled and config.boxFillColor[3] or 1

			gradient.Rotation = config.boxFillRotation 
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, config.boxFillColor[1]),
				ColorSequenceKeypoint.new(1.00, config.boxFillColor[2]),
			})

			outline1.Color = config.boxOutlineColor[1]
			outline1.Transparency = config.boxOutlineColor[2]
			outline1.Enabled = config.boxOutlineEnabled 

			outline2.Color = config.boxColor[1]
			outline2.Transparency = config.boxColor[2]
			outline3.Color = config.boxOutlineColor[1]
			outline3.Transparency = config.boxOutlineColor[2]
			outline3.Enabled = config.boxOutlineEnabled 

			glow.ImageColor3 = config.boxGlowColor[1]
			glow.ImageTransparency = config.boxGlowColor[2]
			glow.Visible = config.boxGlowEnabled 
		end

		do -- // health bar
			local bar1 = self.drawings.onScreen.HealthBar 
			local bar2 = bar1.Bar 
			local bar3 = bar2.Bar 
			local gradient = bar2.Gradient 

			bar1.BackgroundColor3 = config.healthBarOutlineColor[1]
			bar1.BackgroundTransparency = config.healthBarOutlineColor[2]
			bar3.BackgroundColor3 = config.healthBarOutlineColor[1]
			bar3.BackgroundTransparency = config.healthBarOutlineColor[2]

			bar2.BackgroundTransparency = config.healthBarColor[4]

			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, config.healthBarColor[1]),
				ColorSequenceKeypoint.new(0.50, config.healthBarColor[2]),
				ColorSequenceKeypoint.new(1, config.healthBarColor[3]),
			})
		end

		do -- // armor bar
			local bar1 = self.drawings.onScreen.ArmorBar 
			local bar2 = bar1.Bar 
			local bar3 = bar2.Bar 
			local gradient = bar2.Gradient 

			bar1.BackgroundColor3 = config.armorBarOutlineColor[1]
			bar1.BackgroundTransparency = config.armorBarOutlineColor[2]
			bar3.BackgroundColor3 = config.armorBarOutlineColor[1]
			bar3.BackgroundTransparency = config.armorBarOutlineColor[2]

			bar2.BackgroundTransparency = config.armorBarColor[4]

			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, config.armorBarColor[1]),
				ColorSequenceKeypoint.new(0.50, config.armorBarColor[2]),
				ColorSequenceKeypoint.new(1, config.armorBarColor[3]),
			})
		end

		do -- // name 
			local text = self.drawings.onScreen.Name 
			local outline = text.Outline

			text.TextColor3 = config.nameColor[1]
			text.TextTransparency = config.nameColor[2]
			text.FontFace = renderInterface.universal.textFont  

			outline.Color = config.nameOutlineColor[1]
			outline.Transparency = config.nameOutlineColor[2]
			outline.Enabled = config.nameOutlineEnabled 
		end

		do -- // displayName
			local text = self.drawings.onScreen.DisplayName 
			local outline = text.Outline

			text.TextColor3 = config.displayNameColor[1]
			text.TextTransparency = config.displayNameColor[2]
			text.FontFace = renderInterface.universal.textFont  

			outline.Color = config.displayNameOutlineColor[1]
			outline.Transparency = config.displayNameOutlineColor[2]
			outline.Enabled = config.displayNameOutlineEnabled 
		end

		do -- // distance
			local text = self.drawings.onScreen.Distance 
			local outline = text.Outline

			text.TextColor3 = config.distanceColor[1]
			text.TextTransparency = config.distanceColor[2]
			text.FontFace = renderInterface.universal.textFont  

			outline.Color = config.distanceOutlineColor[1]
			outline.Transparency = config.distanceOutlineColor[2]
			outline.Enabled = config.distanceOutlineEnabled 
		end

		do -- // tool
			local text = self.drawings.onScreen.Tool
			local outline = text.Outline

			text.TextColor3 = config.toolColor[1]
			text.TextTransparency = config.toolColor[2]
			text.FontFace = renderInterface.universal.textFont  

			outline.Color = config.toolOutlineColor[1]
			outline.Transparency = config.toolOutlineColor[2]
			outline.Enabled = config.toolOutlineEnabled 
		end

		do -- // health
			local text = self.drawings.onScreen.Health 
			local outline = text.Outline

			text.TextColor3 = config.healthColor[1]
			text.TextTransparency = config.healthColor[2]
			text.FontFace = renderInterface.universal.textFont  

			outline.Color = config.healthOutlineColor[1]
			outline.Transparency = config.healthOutlineColor[2]
			outline.Enabled = config.healthOutlineEnabled 
		end

		do -- // armor
			local text = self.drawings.onScreen.Armor
			local outline = text.Outline

			text.TextColor3 = config.armorColor[1]
			text.TextTransparency = config.armorColor[2]
			text.FontFace = renderInterface.universal.textFont  

			outline.Color = config.armorOutlineColor[1]
			outline.Transparency = config.armorOutlineColor[2]
			outline.Enabled = config.armorOutlineEnabled 
		end
	end

	function renderInterface:registerPlayer(player : Player) : any 
		self = setmetatable({}, renderInterface)
		self.player = assert(player, "expected a player!")
		self:construct()
		self.connection = runService.Heartbeat:Connect(function()
			local rendered = tick() 
			if rendered - lastRendered < renderInterface.universal.renderTime then return end 
			self:updateInterface()
			lastRendered = rendered
		end)
		renderInterface.cache[#renderInterface.cache + 1] = self 
		return self 
	end
	
	function renderInterface:updateInterface()
		local configuration = (self.player == localPlayer and self.self) or renderInterface.isFriendly(self.player) and self.friendly or self.enemy

		if not configuration.enabled then 
			self:hideDrawings()
			return
		end

		local playerData = renderInterface.getStatus(self.player)

		if not playerData.alive then 
			self:hideDrawings()
			return 
		end

		local boxData = self:getBoundingBox(playerData.root)
		local boxPosition, boxSize = boxData[2], boxData[1]

		if not boxData.onScreen then 
			self:hideDrawings()
			return 
		end

		local localPlayerData = renderInterface.getStatus(localPlayer)
		local health, maxHealth = renderInterface.getHealth(playerData.humanoid)
		local armor, maxArmor = renderInterface.getArmor(self.player)
		local textSize = self.universal.textScalingEnabled and self:scaleText((camera.CFrame.Position - playerData.root.Position).Magnitude) or self.universal.textSize 

		-- Show all sideframes
		for i, v in next, {"Left", "Right", "Top", "Bottom"} do
			self.drawings.onScreen[v].Visible = true 
		end

		-- Show/hide box
		if configuration.boxEnabled then 
			local box = self.drawings.onScreen.Box 
			box.Size = newOffset(boxSize.X, boxSize.Y)
			box.Position = newOffset(boxPosition.X, boxPosition.Y)
			box.Visible = true
		else
			self.drawings.onScreen.Box.Visible = false
		end
		local barPositions = {Left = {}, Right = {}, Top = {}, Bottom = {}}

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

		-- Position bars with proper stacking
		for side, bars in pairs(barPositions) do
			for i, barData in ipairs(bars) do
				local drawing = barData.drawing
				local offset = (i - 1) * (barThickness + 2) -- 2px spacing between bars

				if side == "Left" then
					drawing.Position = UDim2.fromOffset(boxPosition.X - barThickness - barOffset - offset, boxPosition.Y)
					drawing.Size = UDim2.fromOffset(barThickness, boxSize.Y)

					-- Configure health bar
					if barData.name == "HealthBar" then
						local healthBar = drawing.Bar
						local topBar = healthBar.Bar
						healthBar.Gradient.Rotation = 90
						topBar.AnchorPoint = Vector2.new(0, 0)
						topBar.Size = UDim2.fromScale(1, 1 - math.clamp(barData.health / barData.maxHealth, 0, 1))
					end

					-- Configure armor bar
					if barData.name == "ArmorBar" then
						local armorBar = drawing.Bar
						local topBar = armorBar.Bar
						armorBar.Gradient.Rotation = 90
						topBar.AnchorPoint = Vector2.new(0, 0)
						topBar.Size = UDim2.fromScale(1, 1 - math.clamp(barData.armor / barData.maxArmor, 0, 1))
					end

				elseif side == "Right" then
					drawing.Position = UDim2.fromOffset(boxPosition.X + boxSize.X + barOffset + offset, boxPosition.Y)
					drawing.Size = UDim2.fromOffset(barThickness, boxSize.Y)

					-- Configure health bar
					if barData.name == "HealthBar" then
						local healthBar = drawing.Bar
						local topBar = healthBar.Bar
						healthBar.Gradient.Rotation = 90
						topBar.AnchorPoint = Vector2.new(0, 0)
						topBar.Size = UDim2.fromScale(1, 1 - math.clamp(barData.health / barData.maxHealth, 0, 1))
					end

					-- Configure armor bar
					if barData.name == "ArmorBar" then
						local armorBar = drawing.Bar
						local topBar = armorBar.Bar
						armorBar.Gradient.Rotation = 90
						topBar.AnchorPoint = Vector2.new(0, 0)
						topBar.Size = UDim2.fromScale(1, 1 - math.clamp(barData.armor / barData.maxArmor, 0, 1))
					end

				elseif side == "Top" then
					drawing.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y - barThickness - barOffset - offset)
					drawing.Size = UDim2.fromOffset(boxSize.X, barThickness)

					-- Configure health bar
					if barData.name == "HealthBar" then
						local healthBar = drawing.Bar
						local topBar = healthBar.Bar
						healthBar.Gradient.Rotation = 0
						topBar.AnchorPoint = Vector2.new(1, 0)
						topBar.Position = UDim2.fromScale(1, 0)
						topBar.Size = UDim2.fromScale(1 - math.clamp(barData.health / barData.maxHealth, 0, 1), 1)
					end

					-- Configure armor bar
					if barData.name == "ArmorBar" then
						local armorBar = drawing.Bar
						local topBar = armorBar.Bar
						armorBar.Gradient.Rotation = 0
						topBar.AnchorPoint = Vector2.new(1, 0)
						topBar.Position = UDim2.fromScale(1, 0)
						topBar.Size = UDim2.fromScale(1 - math.clamp(barData.armor / barData.maxArmor, 0, 1), 1)
					end

				elseif side == "Bottom" then
					drawing.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y + boxSize.Y + barOffset + offset)
					drawing.Size = UDim2.fromOffset(boxSize.X, barThickness)

					-- Configure health bar
					if barData.name == "HealthBar" then
						local healthBar = drawing.Bar
						local topBar = healthBar.Bar
						healthBar.Gradient.Rotation = 0
						topBar.AnchorPoint = Vector2.new(1, 0)
						topBar.Position = UDim2.fromScale(1, 0)
						topBar.Size = UDim2.fromScale(1 - math.clamp(barData.health / barData.maxHealth, 0, 1), 1)
					end

					-- Configure armor bar
					if barData.name == "ArmorBar" then
						local armorBar = drawing.Bar
						local topBar = armorBar.Bar
						armorBar.Gradient.Rotation = 0
						topBar.AnchorPoint = Vector2.new(1, 0)
						topBar.Position = UDim2.fromScale(1, 0)
						topBar.Size = UDim2.fromScale(1 - math.clamp(barData.armor / barData.maxArmor, 0, 1), 1)
					end
				end

				drawing.Visible = true
			end
		end

		-- Hide bars that aren't enabled
		if not configuration.healthBarEnabled then
			self.drawings.onScreen.HealthBar.Visible = false
		end
		if not configuration.armorBarEnabled then
			self.drawings.onScreen.ArmorBar.Visible = false
		end

		-- Calculate total bar offsets for each side
		local sideOffsets = {
			Left = #barPositions.Left > 0 and (#barPositions.Left * barThickness + (#barPositions.Left - 1) * 2 + barOffset) or 0,
			Right = #barPositions.Right > 0 and (#barPositions.Right * barThickness + (#barPositions.Right - 1) * 2 + barOffset) or 0,
			Top = #barPositions.Top > 0 and (#barPositions.Top * barThickness + (#barPositions.Top - 1) * 2 + barOffset) or 0,
			Bottom = #barPositions.Bottom > 0 and (#barPositions.Bottom * barThickness + (#barPositions.Bottom - 1) * 2 + barOffset) or 0
		}

		-- Position sideframes with proper offsets (5px gap from bars or box)
		self.drawings.onScreen.Right.Position = UDim2.fromOffset(boxPosition.X + boxSize.X + sideOffsets.Right + 5, boxPosition.Y)
		self.drawings.onScreen.Right.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		self.drawings.onScreen.Left.Position = UDim2.fromOffset(boxPosition.X - boxSize.X - sideOffsets.Left - 5, boxPosition.Y)
		self.drawings.onScreen.Left.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		self.drawings.onScreen.Bottom.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y + boxSize.Y + sideOffsets.Bottom + 5)
		self.drawings.onScreen.Bottom.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		self.drawings.onScreen.Top.Position = UDim2.fromOffset(boxPosition.X, boxPosition.Y - boxSize.Y - sideOffsets.Top - 5)
		self.drawings.onScreen.Top.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

		-- Handle text elements
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
			text.Visible = true
		else
			self.drawings.onScreen.Name.Visible = false
		end

		if configuration.displayNameEnabled then 
			local text = self.drawings.onScreen.DisplayName 
			text.Parent = self.drawings.onScreen[configuration.displayNamePosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.displayNamePosition]]
			text.TextSize = textSize 
			text.Visible = true
		else
			self.drawings.onScreen.DisplayName.Visible = false
		end

		if configuration.distanceEnabled then 
			local text = self.drawings.onScreen.Distance 
			text.Parent = self.drawings.onScreen[configuration.distancePosition]
			text.TextXAlignment = Enum.TextXAlignment[alignments[configuration.distancePosition]]
			text.TextSize = textSize 
			text.Text = localPlayerData.isAlive and math.round((localPlayerData.root.Position - playerData.root.Position).Magnitude) or 0
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
