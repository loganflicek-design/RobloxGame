-- World effects on the client: snowball visuals, impact bursts, damage numbers and falling snow.
-- The server decides hits; this just draws the same flight path so it looks smooth.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Ui = require(script.Parent.Ui)

local Effects = {}

local SNOW_COLOR = Color3.fromRGB(246, 250, 255)
local FLAKE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local PUFF_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"

local folder = Instance.new("Folder")
folder.Name = "ClientEffects"
folder.Parent = workspace

local function anchoredPoint(cframe: CFrame): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.one * 0.2
	part.CFrame = cframe
	part.Parent = folder
	return part
end

local function burst(position: Vector3, normal: Vector3, size: number)
	local point = anchoredPoint(CFrame.lookAt(position, position + normal))

	local flakes = Instance.new("ParticleEmitter")
	flakes.Texture = FLAKE_TEXTURE
	flakes.Rate = 0
	flakes.Lifetime = NumberRange.new(0.4, 0.9)
	flakes.Speed = NumberRange.new(10, 22)
	flakes.SpreadAngle = Vector2.new(65, 65)
	flakes.EmissionDirection = Enum.NormalId.Front
	flakes.Acceleration = Vector3.new(0, -45, 0)
	flakes.Size = NumberSequence.new(0.55 * size, 0)
	flakes.Color = ColorSequence.new(SNOW_COLOR)
	flakes.LightEmission = 0.35
	flakes.Parent = point
	flakes:Emit(16)

	local puff = Instance.new("ParticleEmitter")
	puff.Texture = PUFF_TEXTURE
	puff.Rate = 0
	puff.Lifetime = NumberRange.new(0.35, 0.6)
	puff.Speed = NumberRange.new(4, 10)
	puff.SpreadAngle = Vector2.new(80, 80)
	puff.EmissionDirection = Enum.NormalId.Front
	puff.Size = NumberSequence.new(1.4 * size, 3 * size)
	puff.Transparency = NumberSequence.new(0.35, 1)
	puff.Color = ColorSequence.new(SNOW_COLOR)
	puff.Parent = point
	puff:Emit(5)

	Debris:AddItem(point, 1.5)
end

local function splashRing(position: Vector3, radius: number)
	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Ball
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CanTouch = false
	ring.CastShadow = false
	ring.Material = Enum.Material.Neon
	ring.Color = Color3.fromRGB(170, 225, 255)
	ring.Transparency = 0.5
	ring.Size = Vector3.one * 1
	ring.Position = position
	ring.Parent = folder
	Ui.tween(ring, 0.4, { Size = Vector3.one * radius * 2, Transparency = 1 })
	Debris:AddItem(ring, 0.5)
end

local function spawnProjectile(
	_id: number,
	userId: number,
	origin: Vector3,
	velocity: Vector3,
	gravity: number,
	size: number,
	splash: number,
	startTime: number
)
	local ball = Instance.new("Part")
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * size
	ball.Position = origin
	ball.Material = Enum.Material.Snow
	ball.Color = SNOW_COLOR
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.CastShadow = false

	local top = Instance.new("Attachment")
	top.Position = Vector3.new(0, size * 0.45, 0)
	top.Parent = ball
	local bottom = Instance.new("Attachment")
	bottom.Position = Vector3.new(0, -size * 0.45, 0)
	bottom.Parent = ball
	local trail = Instance.new("Trail")
	trail.Attachment0 = top
	trail.Attachment1 = bottom
	trail.Lifetime = 0.3
	trail.MinLength = 0
	trail.LightEmission = 0.5
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 210, 255))
	trail.Transparency = NumberSequence.new(0.25, 1)
	trail.Parent = ball
	ball.Parent = folder

	local owner = Players:GetPlayerByUserId(userId)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { owner and owner.Character or folder, folder }
	params.RespectCanCollide = true

	local acceleration = Vector3.new(0, -gravity, 0)
	local lastPosition = origin
	local connection: RBXScriptConnection
	local function finish()
		connection:Disconnect()
		ball:Destroy()
	end

	connection = RunService.RenderStepped:Connect(function()
		local age = math.max(workspace:GetServerTimeNow() - startTime, 0)
		local position = origin + velocity * age + acceleration * (0.5 * age * age)
		local delta = position - lastPosition
		local hit: RaycastResult? = nil
		if delta.Magnitude > 0.001 then
			hit = workspace:Spherecast(lastPosition, size / 2, delta, params)
		end

		if hit then
			burst(hit.Position, hit.Normal, size)
			if splash > 0 then
				splashRing(lastPosition + delta.Unit * hit.Distance, splash)
			end
			finish()
		elseif age > Config.SnowballLifetime or position.Y < -80 then
			finish()
		else
			ball.Position = position
			lastPosition = position
		end
	end)
end

local function damageNumber(position: Vector3, amount: number, killed: boolean)
	local point = anchoredPoint(CFrame.new(position + Vector3.new(math.random(-10, 10) / 10, 2.5, math.random(-10, 10) / 10)))
	local gui = Ui.new("BillboardGui", {
		Size = UDim2.fromOffset(140, 50),
		AlwaysOnTop = true,
		StudsOffset = Vector3.new(0, 0, 0),
		Adornee = point,
		Parent = point,
	})
	local text = killed and ("❄ " .. math.round(amount)) or tostring(math.round(amount))
	local label = Ui.label({
		Size = UDim2.fromScale(1, 1),
		Text = text,
		TextSize = killed and 34 or 26,
		TextColor3 = killed and Ui.Colors.Gold or Ui.Colors.Text,
		TextStrokeTransparency = 0.25,
		TextStrokeColor3 = Color3.fromRGB(10, 20, 45),
		Parent = gui,
	})
	local scale = Ui.new("UIScale", { Scale = 0.4, Parent = label })
	Ui.tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
	Ui.tween(gui, 0.9, { StudsOffset = Vector3.new(0, 4.5, 0) })
	task.delay(0.45, function()
		Ui.tween(label, 0.45, { TextTransparency = 1, TextStrokeTransparency = 1 })
	end)
	Debris:AddItem(point, 1.1)
end

local function startSnowfall()
	local camera = workspace.CurrentCamera
	local emitterPart = anchoredPoint(CFrame.new(0, 40, 0))
	emitterPart.Name = "Snowfall"
	emitterPart.Size = Vector3.new(110, 1, 110)

	local snow = Instance.new("ParticleEmitter")
	snow.Texture = FLAKE_TEXTURE
	snow.Rate = 260
	snow.Lifetime = NumberRange.new(6, 8)
	snow.Speed = NumberRange.new(7, 11)
	snow.EmissionDirection = Enum.NormalId.Bottom
	snow.SpreadAngle = Vector2.new(12, 12)
	snow.Acceleration = Vector3.new(3, 0, 1)
	snow.Size = NumberSequence.new(0.3)
	snow.Color = ColorSequence.new(SNOW_COLOR)
	snow.Transparency = NumberSequence.new(0.15)
	snow.LightEmission = 0.4
	snow.Rotation = NumberRange.new(0, 360)
	snow.RotSpeed = NumberRange.new(-60, 60)
	snow.Shape = Enum.ParticleEmitterShape.Box
	snow.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	snow.Parent = emitterPart

	RunService.RenderStepped:Connect(function()
		camera = workspace.CurrentCamera or camera
		emitterPart.Position = camera.CFrame.Position + Vector3.new(0, 38, 0)
	end)
end

function Effects.Start(hud: any)
	local remotes = ReplicatedStorage:WaitForChild("Remotes")

	remotes:WaitForChild("Projectile").OnClientEvent:Connect(spawnProjectile)
	remotes:WaitForChild("Hit").OnClientEvent:Connect(function(position: Vector3, amount: number, killed: boolean)
		damageNumber(position, amount, killed)
		hud.HitMarker(killed)
	end)

	startSnowfall()
end

return Effects
