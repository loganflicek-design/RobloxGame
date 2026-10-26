-- Builds the snowy arena (ground, cliffs, forts, trees, pond, plaza, lamps) and sets up the lighting.
-- Everything is generated at runtime, so there's nothing to place by hand in Studio.
local Lighting = game:GetService("Lighting")

local Targets = require(script.Parent.Targets)

local rng = Random.new(2024)

local ARENA = 320
local HALF = ARENA / 2
local PLAZA_RADIUS = 24

local SNOW = Color3.fromRGB(238, 245, 255)
local ICE = Color3.fromRGB(165, 215, 245)
local PINE = Color3.fromRGB(34, 92, 62)
local PINE_DARK = Color3.fromRGB(24, 70, 52)
local WOOD = Color3.fromRGB(98, 64, 38)
local ROCK = Color3.fromRGB(92, 98, 116)
local LAMP_WARM = Color3.fromRGB(255, 205, 140)
local XMAS_COLORS = {
	Color3.fromRGB(255, 80, 90),
	Color3.fromRGB(255, 210, 90),
	Color3.fromRGB(110, 200, 255),
	Color3.fromRGB(120, 235, 150),
	Color3.fromRGB(255, 140, 220),
}

-- Remove the default template pieces; this map brings its own ground and spawns.
for _, name in { "Baseplate", "SpawnLocation" } do
	local old = workspace:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

local mapFolder = Instance.new("Folder")
mapFolder.Name = "SnowMap"
mapFolder.Parent = workspace

local function make(props: { [string]: any }): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.Snow
	part.Color = SNOW
	local parent = props.Parent or mapFolder
	for key, value in props do
		if key ~= "Parent" then
			(part :: any)[key] = value
		end
	end
	part.Parent = parent
	return part
end

-- Parts that are only scenery: no collision, no raycast hits.
local function scenery(props: { [string]: any }): Part
	props.CanCollide = false
	props.CanQuery = false
	props.CanTouch = false
	return make(props)
end

local upright = CFrame.Angles(0, 0, math.rad(90)) -- turns a cylinder (axis X) to stand up

------------------------------------------------------------------------------------------
-- Placement bookkeeping so objects don't overlap
------------------------------------------------------------------------------------------
local taken: { { x: number, z: number, r: number } } = {}

local function isFree(x: number, z: number, r: number): boolean
	for _, other in taken do
		local dx, dz = x - other.x, z - other.z
		local minDist = r + other.r
		if dx * dx + dz * dz < minDist * minDist then
			return false
		end
	end
	return true
end

local function claim(x: number, z: number, r: number)
	table.insert(taken, { x = x, z = z, r = r })
end

local function findSpot(r: number, margin: number): Vector3?
	for _ = 1, 60 do
		local x = rng:NextNumber(-(HALF - margin), HALF - margin)
		local z = rng:NextNumber(-(HALF - margin), HALF - margin)
		if isFree(x, z, r) then
			claim(x, z, r)
			return Vector3.new(x, 0, z)
		end
	end
	return nil
end

claim(0, 0, PLAZA_RADIUS + 14) -- spawn plaza
claim(34, 0, 16) -- the car

------------------------------------------------------------------------------------------
-- Ground, cliffs, distant hills
------------------------------------------------------------------------------------------
make({
	Name = "Ground",
	Size = Vector3.new(ARENA, 6, ARENA),
	CFrame = CFrame.new(0, -3, 0),
})
-- Snowfield stretching out past the cliffs (just for the view)
scenery({
	Name = "OuterGround",
	Size = Vector3.new(1600, 4, 1600),
	CFrame = CFrame.new(0, -2.15, 0),
	Color = Color3.fromRGB(226, 236, 250),
})

local function buildCliffs()
	local folder = Instance.new("Folder")
	folder.Name = "Cliffs"
	folder.Parent = mapFolder
	local segments = 18
	local segLength = (ARENA + 40) / segments
	for side = 0, 3 do
		local sideRotation = CFrame.Angles(0, math.rad(side * 90), 0)
		for i = 0, segments - 1 do
			local along = -ARENA / 2 - 20 + (i + 0.5) * segLength
			local height = rng:NextNumber(24, 44)
			local thickness = rng:NextNumber(12, 18)
			local lean = math.rad(rng:NextNumber(-5, 5))
			local cf = sideRotation
				* CFrame.new(along, height / 2 - 4, HALF + thickness / 2 - 2)
				* CFrame.Angles(math.rad(rng:NextNumber(-3, 3)), lean, 0)
			make({
				Name = "Cliff",
				Size = Vector3.new(segLength + 3, height, thickness),
				CFrame = cf,
				Material = Enum.Material.Glacier,
				Color = ICE:Lerp(SNOW, rng:NextNumber(0, 0.5)),
				Parent = folder,
			})
			-- Snow cap
			make({
				Name = "CliffCap",
				Size = Vector3.new(segLength + 4, 2.5, thickness + 1.5),
				CFrame = cf * CFrame.new(0, height / 2, 0),
				Parent = folder,
			})
		end
	end
end

local function buildDistantHills()
	local folder = Instance.new("Folder")
	folder.Name = "Hills"
	folder.Parent = mapFolder
	for i = 1, 18 do
		local angle = (i / 18) * math.pi * 2 + rng:NextNumber(-0.1, 0.1)
		local distance = rng:NextNumber(330, 430)
		local diameter = rng:NextNumber(170, 290)
		scenery({
			Name = "Hill",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * diameter,
			Position = Vector3.new(math.cos(angle) * distance, -diameter * 0.34, math.sin(angle) * distance),
			Color = Color3.fromRGB(214, 226, 246):Lerp(Color3.fromRGB(170, 190, 225), rng:NextNumber(0, 0.6)),
			CastShadow = false,
			Parent = folder,
		})
	end
end

------------------------------------------------------------------------------------------
-- Props
------------------------------------------------------------------------------------------
local function buildPine(parent: Instance, position: Vector3, scale: number)
	local trunkHeight = 6 * scale
	make({
		Name = "Trunk",
		Size = Vector3.new(1.4 * scale, trunkHeight, 1.4 * scale),
		CFrame = CFrame.new(position + Vector3.new(0, trunkHeight / 2, 0)),
		Material = Enum.Material.Wood,
		Color = WOOD,
		Parent = parent,
	})
	local tiers = { { 5, 11 }, { 8.5, 8.5 }, { 12, 6 } } -- { height above ground, diameter }
	for index, tier in tiers do
		local y = tier[1] * scale
		local diameter = tier[2] * scale
		local color = index % 2 == 0 and PINE_DARK or PINE
		scenery({
			Name = "Tier",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(1.3 * scale, diameter, diameter),
			CFrame = CFrame.new(position + Vector3.new(0, y, 0)) * upright,
			Material = Enum.Material.Grass,
			Color = color,
			Parent = parent,
		})
		scenery({
			Name = "TierSnow",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.45 * scale, diameter * 0.82, diameter * 0.82),
			CFrame = CFrame.new(position + Vector3.new(0, y + 0.8 * scale, 0)) * upright,
			Parent = parent,
		})
	end
end

local function buildRock(position: Vector3)
	local w, h, d = rng:NextNumber(4, 9), rng:NextNumber(3, 6), rng:NextNumber(4, 9)
	local yaw = CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0)
	local base = CFrame.new(position + Vector3.new(0, h / 2 - 0.4, 0)) * yaw
	make({
		Name = "Rock",
		Size = Vector3.new(w, h, d),
		CFrame = base,
		Material = Enum.Material.Slate,
		Color = ROCK,
	})
	make({
		Name = "RockSnow",
		Size = Vector3.new(w * 0.92, 0.9, d * 0.92),
		CFrame = base * CFrame.new(0, h / 2, 0),
	})
end

local function buildLamp(position: Vector3)
	local folder = Instance.new("Model")
	folder.Name = "Lamp"
	folder.Parent = mapFolder
	make({
		Name = "Pole",
		Size = Vector3.new(0.6, 11, 0.6),
		CFrame = CFrame.new(position + Vector3.new(0, 5.5, 0)),
		Material = Enum.Material.Metal,
		Color = Color3.fromRGB(38, 42, 58),
		Parent = folder,
	})
	make({
		Name = "Base",
		Size = Vector3.new(1.8, 1, 1.8),
		CFrame = CFrame.new(position + Vector3.new(0, 0.5, 0)),
		Material = Enum.Material.Metal,
		Color = Color3.fromRGB(38, 42, 58),
		Parent = folder,
	})
	local head = make({
		Name = "Bulb",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 2,
		Position = position + Vector3.new(0, 11.8, 0),
		Material = Enum.Material.Neon,
		Color = LAMP_WARM,
		CanCollide = false,
		CanQuery = false,
		Parent = folder,
	})
	make({
		Name = "Cap",
		Size = Vector3.new(2.8, 0.5, 2.8),
		CFrame = CFrame.new(position + Vector3.new(0, 13, 0)),
		Color = SNOW,
		CanCollide = false,
		CanQuery = false,
		Parent = folder,
	})
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 196, 120)
	light.Range = 34
	light.Brightness = 2.4
	light.Shadows = false
	light.Parent = head
end

local function buildFort(position: Vector3)
	local folder = Instance.new("Model")
	folder.Name = "Fort"
	folder.Parent = mapFolder
	-- Open side faces the middle of the arena.
	local root = CFrame.lookAt(position, Vector3.new(0, position.Y, 0))

	local function wall(size: Vector3, offset: Vector3, color: Color3?)
		return make({
			Name = "FortWall",
			Size = size,
			CFrame = root * CFrame.new(offset),
			Color = color or SNOW,
			Parent = folder,
		})
	end

	wall(Vector3.new(15, 5, 2.2), Vector3.new(0, 2.5, 5))
	wall(Vector3.new(2.2, 5, 9), Vector3.new(-6.5, 2.5, 0.5))
	wall(Vector3.new(2.2, 5, 9), Vector3.new(6.5, 2.5, 0.5))
	for _, x in { -5, 0, 5 } do
		wall(Vector3.new(2.4, 1.6, 2.2), Vector3.new(x, 5.8, 5))
	end
	wall(Vector3.new(4, 2.4, 2), Vector3.new(-3.5, 1.2, -4.2))
	wall(Vector3.new(4, 2.4, 2), Vector3.new(3.5, 1.2, -4.2))
	-- Icy trim along the back wall
	make({
		Name = "FortTrim",
		Size = Vector3.new(15.2, 0.5, 2.4),
		CFrame = root * CFrame.new(0, 4.9, 5),
		Material = Enum.Material.Ice,
		Color = ICE,
		Parent = folder,
	})
	-- Snowball stockpile
	for i, offset in { Vector3.new(-1.5, 0.7, 2.8), Vector3.new(0, 0.7, 3.2), Vector3.new(1.6, 0.7, 2.7), Vector3.new(0.4, 1.9, 3), Vector3.new(-0.9, 0.7, 1.7) } do
		scenery({
			Name = "Snowball" .. i,
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * 1.5,
			CFrame = root * CFrame.new(offset),
			Parent = folder,
		})
	end
	-- Flag
	local flagColor = XMAS_COLORS[rng:NextInteger(1, #XMAS_COLORS)]
	make({
		Name = "Pole",
		Size = Vector3.new(0.3, 9, 0.3),
		CFrame = root * CFrame.new(6.5, 9.5, 5),
		Material = Enum.Material.Wood,
		Color = WOOD,
		CanCollide = false,
		Parent = folder,
	})
	make({
		Name = "Flag",
		Size = Vector3.new(3.2, 1.8, 0.15),
		CFrame = root * CFrame.new(5, 12.4, 5),
		Material = Enum.Material.Fabric,
		Color = flagColor,
		CanCollide = false,
		Parent = folder,
	})
end

local function buildMound(position: Vector3, diameter: number)
	scenery({
		Name = "Mound",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * diameter,
		Position = position + Vector3.new(0, -diameter * 0.2, 0),
		Color = SNOW:Lerp(Color3.fromRGB(210, 225, 248), rng:NextNumber(0, 0.5)),
	}).CanCollide = true
end

local function buildPond(position: Vector3, radius: number)
	local pond = make({
		Name = "IcePond",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.4, radius * 2, radius * 2),
		CFrame = CFrame.new(position + Vector3.new(0, 0.15, 0)) * upright,
		Material = Enum.Material.Ice,
		Color = Color3.fromRGB(150, 205, 240),
		Reflectance = 0.22,
	})
	pond.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.02, 0, 100, 1) -- slippery!
	-- Frozen rim
	make({
		Name = "PondRim",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3, radius * 2 + 3, radius * 2 + 3),
		CFrame = CFrame.new(position + Vector3.new(0, 0.05, 0)) * upright,
		Color = Color3.fromRGB(225, 238, 252),
	})
end

local function buildGift(position: Vector3, size: number, color: Color3)
	local yaw = CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0)
	local base = CFrame.new(position + Vector3.new(0, size / 2, 0)) * yaw
	make({
		Name = "Gift",
		Size = Vector3.one * size,
		CFrame = base,
		Material = Enum.Material.SmoothPlastic,
		Color = color,
	})
	make({
		Name = "RibbonA",
		Size = Vector3.new(size * 0.18, size + 0.1, size + 0.1),
		CFrame = base,
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(255, 240, 200),
		CanCollide = false,
	})
	make({
		Name = "RibbonB",
		Size = Vector3.new(size + 0.1, size + 0.1, size * 0.18),
		CFrame = base,
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(255, 240, 200),
		CanCollide = false,
	})
end

local function buildPlaza()
	local folder = Instance.new("Folder")
	folder.Name = "Plaza"
	folder.Parent = mapFolder

	make({
		Name = "PlazaGlow",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3, (PLAZA_RADIUS + 1.2) * 2, (PLAZA_RADIUS + 1.2) * 2),
		CFrame = CFrame.new(0, 0.15, 0) * upright,
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(110, 195, 255),
		Parent = folder,
	})
	make({
		Name = "PlazaFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, PLAZA_RADIUS * 2, PLAZA_RADIUS * 2),
		CFrame = CFrame.new(0, 0.3, 0) * upright,
		Material = Enum.Material.Slate,
		Color = Color3.fromRGB(62, 76, 108),
		Parent = folder,
	})
	make({
		Name = "PlazaInner",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.65, 20, 20),
		CFrame = CFrame.new(0, 0.3, 0) * upright,
		Material = Enum.Material.Marble,
		Color = Color3.fromRGB(215, 228, 248),
		Parent = folder,
	})

	-- Spawn pads in a ring
	for i = 0, 7 do
		local angle = (i / 8) * math.pi * 2
		local position = Vector3.new(math.cos(angle) * 16, 0.9, math.sin(angle) * 16)
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "SnowSpawn" .. i
		spawn.Size = Vector3.new(6, 0.6, 6)
		spawn.CFrame = CFrame.lookAt(position, Vector3.new(0, 0.9, 0))
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Duration = 0
		spawn.Material = Enum.Material.Neon
		spawn.Color = Color3.fromRGB(120, 200, 255)
		spawn.Transparency = 0.35
		spawn.TopSurface = Enum.SurfaceType.Smooth
		spawn.BottomSurface = Enum.SurfaceType.Smooth
		local decal = spawn:FindFirstChildOfClass("Decal")
		if decal then
			decal:Destroy()
		end
		spawn.Parent = folder
	end

	-- Giant Christmas tree in the middle
	local tiers = { { 6, 22 }, { 11, 17.5 }, { 16, 13 }, { 20.5, 9 }, { 24.5, 5 } }
	make({
		Name = "TreeTrunk",
		Size = Vector3.new(4, 7, 4),
		CFrame = CFrame.new(0, 3.5, 0),
		Material = Enum.Material.Wood,
		Color = WOOD,
		Parent = folder,
	})
	for index, tier in tiers do
		make({
			Name = "TreeTier",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2.6, tier[2], tier[2]),
			CFrame = CFrame.new(0, tier[1], 0) * upright,
			Material = Enum.Material.Grass,
			Color = index % 2 == 0 and PINE_DARK or PINE,
			CanCollide = false,
			Parent = folder,
		})
		make({
			Name = "TreeSnow",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.7, tier[2] * 0.85, tier[2] * 0.85),
			CFrame = CFrame.new(0, tier[1] + 1.5, 0) * upright,
			CanCollide = false,
			Parent = folder,
		})
	end
	local star = make({
		Name = "Star",
		Shape = Enum.PartType.Ball,
		Size = Vector3.one * 3.4,
		Position = Vector3.new(0, 29, 0),
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 225, 110),
		CanCollide = false,
		Parent = folder,
	})
	local starLight = Instance.new("PointLight")
	starLight.Color = Color3.fromRGB(255, 220, 130)
	starLight.Range = 60
	starLight.Brightness = 2.5
	starLight.Shadows = false
	starLight.Parent = star
	-- String lights spiralling up the tree
	for i = 1, 56 do
		local t = i / 56
		local y = 5 + t * 21
		local radius = (29 - y) * 0.42 + 0.6
		local angle = i * 0.95
		local bulb = make({
			Name = "TreeLight",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * 0.9,
			Position = Vector3.new(math.cos(angle) * radius, y, math.sin(angle) * radius),
			Material = Enum.Material.Neon,
			Color = XMAS_COLORS[(i - 1) % #XMAS_COLORS + 1],
			CanCollide = false,
			CanQuery = false,
			Parent = folder,
		})
		if i % 7 == 0 then
			local light = Instance.new("PointLight")
			light.Color = bulb.Color
			light.Range = 16
			light.Brightness = 1.2
			light.Shadows = false
			light.Parent = bulb
		end
	end
	-- Presents under the tree
	for i = 1, 9 do
		local angle = (i / 9) * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
		local distance = rng:NextNumber(5.5, 9)
		buildGift(
			Vector3.new(math.cos(angle) * distance, 0.6, math.sin(angle) * distance),
			rng:NextNumber(2, 3.6),
			XMAS_COLORS[rng:NextInteger(1, #XMAS_COLORS)]
		)
	end

	-- Lamps around the plaza edge
	for i = 0, 7 do
		local angle = ((i + 0.5) / 8) * math.pi * 2
		buildLamp(Vector3.new(math.cos(angle) * (PLAZA_RADIUS + 2.5), 0, math.sin(angle) * (PLAZA_RADIUS + 2.5)))
	end
end

------------------------------------------------------------------------------------------
-- Lighting
------------------------------------------------------------------------------------------
local function setupLighting()
	Lighting.ClockTime = 17.3
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(78, 92, 125)
	Lighting.OutdoorAmbient = Color3.fromRGB(118, 134, 172)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 205, 160)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.5
	Lighting.GlobalShadows = true

	if not Lighting:FindFirstChildOfClass("Sky") then
		local sky = Instance.new("Sky")
		sky.StarCount = 3000
		sky.Parent = Lighting
	end

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.34
	atmosphere.Offset = 0.2
	atmosphere.Color = Color3.fromRGB(192, 202, 230)
	atmosphere.Decay = Color3.fromRGB(104, 118, 160)
	atmosphere.Glare = 0.25
	atmosphere.Haze = 1.3
	atmosphere.Parent = Lighting

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
	bloom.Intensity = 0.5
	bloom.Size = 28
	bloom.Threshold = 1.6
	bloom.Parent = Lighting

	local correction = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
	correction.Brightness = 0.02
	correction.Contrast = 0.12
	correction.Saturation = 0.12
	correction.TintColor = Color3.fromRGB(235, 242, 255)
	correction.Parent = Lighting

	local rays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect")
	rays.Intensity = 0.07
	rays.Spread = 0.8
	rays.Parent = Lighting
end

------------------------------------------------------------------------------------------
-- Build it all
------------------------------------------------------------------------------------------
setupLighting()
buildCliffs()
buildDistantHills()
buildPlaza()

-- Frozen pond
local pondPosition = Vector3.new(-82, 0, 66)
claim(pondPosition.X, pondPosition.Z, 38)
buildPond(pondPosition, 30)

-- Snowy mounds to climb on
for _ = 1, 6 do
	local diameter = rng:NextNumber(28, 44)
	local spot = findSpot(diameter * 0.55, 18)
	if spot then
		buildMound(spot, diameter)
	end
end

-- Forts
for _ = 1, 8 do
	local spot = findSpot(14, 26)
	if spot then
		buildFort(spot)
	end
end

-- Rocks
for _ = 1, 24 do
	local spot = findSpot(6, 16)
	if spot then
		buildRock(spot)
	end
end

-- Pine trees
local forest = Instance.new("Folder")
forest.Name = "Forest"
forest.Parent = mapFolder
for _ = 1, 70 do
	local spot = findSpot(5, 12)
	if spot then
		buildPine(forest, spot, rng:NextNumber(0.8, 1.5))
	end
end
-- A tree line just outside the cliffs for atmosphere
for i = 1, 36 do
	local angle = (i / 36) * math.pi * 2
	local distance = HALF + rng:NextNumber(60, 110)
	buildPine(forest, Vector3.new(math.cos(angle) * distance, -0.1, math.sin(angle) * distance), rng:NextNumber(2.4, 3.6))
end

-- Lamps scattered around the arena
for _ = 1, 10 do
	local spot = findSpot(4, 18)
	if spot then
		buildLamp(spot)
	end
end

-- Snowman targets
for _ = 1, 16 do
	local spot = findSpot(7, 20)
	if spot then
		Targets.Create(spot)
	end
end
