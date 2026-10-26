-- Snowman targets: throw snowballs at them for coins. They fall apart and rebuild later.
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Targets = {}

local MAX_HEALTH = 60
local RESPAWN_TIME = 8

local SNOW = Color3.fromRGB(240, 246, 255)

local folder = workspace:FindFirstChild("Targets")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "Targets"
	folder.Parent = workspace
end

local function ball(parent: Instance, name: string, diameter: number, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.one * diameter
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.Snow
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function block(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- Facing -Z (front of the snowman).
local function build(position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "Snowman"

	local baseY = position.Y
	local bottomD, midD, headD = 5.5, 4, 2.8
	local bottomY = baseY + bottomD / 2
	local midY = baseY + bottomD - 0.7 + midD / 2
	local headY = baseY + bottomD - 0.7 + midD - 0.5 + headD / 2

	local bottom = ball(model, "Bottom", bottomD, Vector3.new(position.X, bottomY, position.Z), SNOW)
	local mid = ball(model, "Middle", midD, Vector3.new(position.X, midY, position.Z), SNOW)
	local head = ball(model, "Head", headD, Vector3.new(position.X, headY, position.Z), SNOW)
	model.PrimaryPart = bottom

	local face = CFrame.new(position.X, headY, position.Z)
	-- Coal eyes and smile
	for _, side in { -1, 1 } do
		ball(model, "Eye", 0.4, (face * CFrame.new(side * 0.5, 0.35, -headD / 2 + 0.1)).Position, Color3.fromRGB(25, 25, 30), Enum.Material.SmoothPlastic).CanCollide = false
	end
	for i = -2, 2 do
		local dy = -0.45 + (math.abs(i) == 2 and 0.2 or 0) + (math.abs(i) == 1 and 0.05 or 0)
		ball(model, "Smile", 0.22, (face * CFrame.new(i * 0.3, dy, -headD / 2 + 0.12)).Position, Color3.fromRGB(25, 25, 30), Enum.Material.SmoothPlastic).CanCollide = false
	end
	-- Carrot nose
	block(model, "Nose", Vector3.new(0.35, 0.35, 1.5), face * CFrame.new(0, 0, -headD / 2 - 0.45), Color3.fromRGB(255, 130, 40))
	-- Scarf
	local scarf = block(
		model,
		"Scarf",
		Vector3.new(0.7, 3.1, 3.1),
		CFrame.new(position.X, midY + midD / 2 - 0.35, position.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(215, 45, 55),
		Enum.Material.Fabric
	)
	scarf.Shape = Enum.PartType.Cylinder
	block(
		model,
		"ScarfTail",
		Vector3.new(0.5, 2, 0.35),
		CFrame.new(position.X + 0.9, midY + midD / 2 - 1.4, position.Z - 1.6) * CFrame.Angles(math.rad(-10), 0, math.rad(8)),
		Color3.fromRGB(215, 45, 55),
		Enum.Material.Fabric
	)
	-- Buttons
	for i = 0, 2 do
		ball(model, "Button", 0.45, Vector3.new(position.X, midY + 0.9 - i * 0.9, position.Z - math.sqrt(math.max((midD / 2) ^ 2 - (0.9 - i * 0.9) ^ 2, 0))), Color3.fromRGB(40, 40, 50), Enum.Material.SmoothPlastic).CanCollide = false
	end
	-- Stick arms
	for _, side in { -1, 1 } do
		block(
			model,
			"Arm",
			Vector3.new(3.4, 0.3, 0.3),
			CFrame.new(position.X + side * 3, midY + 0.7, position.Z) * CFrame.Angles(0, 0, side * math.rad(25)),
			Color3.fromRGB(95, 62, 35),
			Enum.Material.Wood
		)
	end
	-- Top hat
	local hatBase = block(
		model,
		"HatBrim",
		Vector3.new(0.25, 3.2, 3.2),
		CFrame.new(position.X, headY + headD / 2 - 0.2, position.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(30, 30, 38)
	)
	hatBase.Shape = Enum.PartType.Cylinder
	local hatTop = block(
		model,
		"HatTop",
		Vector3.new(1.8, 2.1, 2.1),
		CFrame.new(position.X, headY + headD / 2 + 0.8, position.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(30, 30, 38)
	)
	hatTop.Shape = Enum.PartType.Cylinder
	block(
		model,
		"HatBand",
		Vector3.new(0.4, 2.15, 2.15),
		CFrame.new(position.X, headY + headD / 2 + 0.15, position.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(190, 40, 50)
	).Shape = Enum.PartType.Cylinder

	-- Health bar
	local gui = Instance.new("BillboardGui")
	gui.Name = "HealthBar"
	gui.Size = UDim2.fromOffset(110, 16)
	gui.StudsOffsetWorldSpace = Vector3.new(0, headD / 2 + 3.6, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 140
	gui.Adornee = head
	gui.Parent = model

	local back = Instance.new("Frame")
	back.Name = "Back"
	back.Size = UDim2.fromScale(1, 1)
	back.BackgroundColor3 = Color3.fromRGB(20, 28, 45)
	back.BackgroundTransparency = 0.2
	back.BorderSizePixel = 0
	back.Parent = gui
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(1, 0)
	backCorner.Parent = back
	local backStroke = Instance.new("UIStroke")
	backStroke.Color = Color3.fromRGB(140, 205, 255)
	backStroke.Thickness = 1.5
	backStroke.Parent = back

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(255, 120, 95)
	fill.BorderSizePixel = 0
	fill.Parent = back
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	model:SetAttribute("IsTarget", true)
	model:SetAttribute("Health", MAX_HEALTH)
	model:SetAttribute("SpawnPosition", position)
	model.Parent = folder
	return model
end

local function wobble(model: Model)
	if model:GetAttribute("Wobbling") then
		return
	end
	model:SetAttribute("Wobbling", true)
	task.spawn(function()
		local base = model:GetPivot()
		for i = 1, 8 do
			if not model.Parent or model:GetAttribute("Dead") then
				break
			end
			local angle = math.rad(7) * (1 - i / 9) * (i % 2 == 0 and 1 or -1)
			model:PivotTo(base * CFrame.Angles(0, 0, angle))
			task.wait(0.035)
		end
		if model.Parent and not model:GetAttribute("Dead") then
			model:PivotTo(base)
		end
		model:SetAttribute("Wobbling", nil)
	end)
end

local function shatter(model: Model)
	model:SetAttribute("Dead", true)
	local gui = model:FindFirstChild("HealthBar")
	if gui then
		gui:Destroy()
	end
	local center = model:GetPivot().Position
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = true
			part.CollisionGroup = "Default"
			local away = (part.Position - center + Vector3.new(0, 1, 0))
			if away.Magnitude < 0.1 then
				away = Vector3.new(0, 1, 0)
			end
			part.AssemblyLinearVelocity = away.Unit * math.random(18, 34) + Vector3.new(0, math.random(10, 25), 0)
			part.AssemblyAngularVelocity = Vector3.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8))
			TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2.2), { Transparency = 1 }):Play()
		end
	end
	Debris:AddItem(model, 3.5)
end

-- Returns (damage actually dealt, whether this broke the snowman).
function Targets.Damage(model: Model, amount: number): (number, boolean)
	if model:GetAttribute("Dead") then
		return 0, false
	end
	local health = model:GetAttribute("Health") :: number
	local dealt = math.min(health, amount)
	health -= amount
	model:SetAttribute("Health", health)

	local gui = model:FindFirstChild("HealthBar")
	local fill = gui and gui:FindFirstChild("Back") and gui.Back:FindFirstChild("Fill")
	if fill then
		TweenService:Create(fill, TweenInfo.new(0.15), { Size = UDim2.fromScale(math.max(health, 0) / MAX_HEALTH, 1) }):Play()
	end

	if health <= 0 then
		local position = model:GetAttribute("SpawnPosition") :: Vector3
		shatter(model)
		task.delay(RESPAWN_TIME, function()
			build(position)
		end)
		return dealt, true
	end

	wobble(model)
	return dealt, false
end

function Targets.Create(position: Vector3): Model
	return build(position)
end

return Targets
