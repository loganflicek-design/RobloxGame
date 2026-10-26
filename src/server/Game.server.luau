-- Core game logic: player data, snowball throwing, damage, rewards and upgrades.
-- The server decides everything that matters (cooldowns, damage, coins); clients only ask.
local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Remotes = require(script.Parent.Remotes)
local Targets = require(script.Parent.Targets)

pcall(function()
	Players.RespawnTime = 3
end)

local effectsFolder = Instance.new("Folder")
effectsFolder.Name = "Effects"
effectsFolder.Parent = workspace

------------------------------------------------------------------------------------------
-- Player data (saved with DataStore; if the DataStore isn't available, the game still runs)
------------------------------------------------------------------------------------------
type Profile = {
	Coins: number,
	Elims: number,
	Levels: { [string]: number },
	CanSave: boolean,
}

local store = DataStoreService:GetDataStore("SnowballShowdown_v1")
local profiles: { [Player]: Profile } = {}

local function loadProfile(player: Player): Profile
	local profile: Profile = { Coins = 0, Elims = 0, Levels = {}, CanSave = true }
	for _, def in Config.Upgrades do
		profile.Levels[def.Id] = 0
	end

	local ok, data = pcall(function()
		return store:GetAsync("Player_" .. player.UserId)
	end)
	if ok then
		if type(data) == "table" then
			profile.Coins = math.max(0, tonumber(data.Coins) or 0)
			profile.Elims = math.max(0, tonumber(data.Elims) or 0)
			if type(data.Levels) == "table" then
				for id, lv in data.Levels do
					if profile.Levels[id] ~= nil and type(lv) == "number" then
						profile.Levels[id] = math.clamp(math.floor(lv), 0, Config.MaxLevel)
					end
				end
			end
		end
	else
		-- Don't overwrite someone's real save with an empty one if loading failed.
		profile.CanSave = false
		warn("[Snowball Showdown] Couldn't load saved data, progress won't be saved this session: " .. tostring(data))
		warn("[Snowball Showdown] In Studio: Game Settings > Security > turn on 'Enable Studio Access to API Services' (the place must be published).")
	end
	return profile
end

local function saveProfile(player: Player)
	local profile = profiles[player]
	if not profile or not profile.CanSave then
		return
	end
	local ok, err = pcall(function()
		store:SetAsync("Player_" .. player.UserId, {
			Coins = profile.Coins,
			Elims = profile.Elims,
			Levels = profile.Levels,
		})
	end)
	if not ok then
		warn("[Snowball Showdown] Save failed for " .. player.Name .. ": " .. tostring(err))
	end
end

local function levelOf(player: Player, id: string): number
	local profile = profiles[player]
	return profile and profile.Levels[id] or 0
end

local function statOf(player: Player, id: string): number
	return Config.GetValue(id, levelOf(player, id))
end

local function syncPlayer(player: Player)
	local profile = profiles[player]
	if not profile then
		return
	end
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		(stats :: any).Coins.Value = profile.Coins;
		(stats :: any).Frozen.Value = profile.Elims
	end
	for id, lv in profile.Levels do
		player:SetAttribute("Lv_" .. id, lv)
	end
end

local function giveCoins(player: Player, base: number): number
	local profile = profiles[player]
	if not profile then
		return 0
	end
	local amount = math.max(1, math.floor(base * statOf(player, "Greed") + 0.5))
	profile.Coins += amount
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		(stats :: any).Coins.Value = profile.Coins
	end
	return amount
end

------------------------------------------------------------------------------------------
-- Characters
------------------------------------------------------------------------------------------
local function applyCharacterStats(player: Player, fullHeal: boolean)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local maxHealth = statOf(player, "Health")
	local gained = maxHealth - humanoid.MaxHealth
	humanoid.MaxHealth = maxHealth
	if fullHeal then
		humanoid.Health = maxHealth
	elseif gained > 0 and humanoid.Health > 0 then
		humanoid.Health = math.min(maxHealth, humanoid.Health + gained)
	end
	humanoid.WalkSpeed = statOf(player, "RunSpeed")
end

-- Eliminated players turn into a frozen statue inside a block of ice that then melts away.
local function freezeCharacter(character: Model)
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return
	end
	local cube = Instance.new("Part")
	cube.Name = "IceCube"
	cube.Size = Vector3.new(5.5, 7.5, 4.5)
	cube.CFrame = root.CFrame
	cube.Material = Enum.Material.Ice
	cube.Color = Color3.fromRGB(170, 220, 255)
	cube.Transparency = 0.35
	cube.Anchored = true
	cube.CanCollide = false
	cube.CanQuery = false
	cube.CanTouch = false
	cube.Parent = effectsFolder
	TweenService:Create(cube, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.6), { Transparency = 1 }):Play()
	Debris:AddItem(cube, 3.2)
	root.Anchored = true
end

local function onCharacter(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then
		return
	end
	humanoid.BreakJointsOnDeath = false
	applyCharacterStats(player, true)
	player:SetAttribute("Streak", 0)

	local forceField = Instance.new("ForceField")
	forceField.Visible = true
	forceField.Parent = character
	Debris:AddItem(forceField, 3)

	humanoid.Died:Connect(function()
		player:SetAttribute("Streak", 0)
		freezeCharacter(character)
	end)
end

------------------------------------------------------------------------------------------
-- Damage and rewards
------------------------------------------------------------------------------------------
type Projectile = {
	id: number,
	owner: Player,
	ownerCharacter: Model,
	origin: Vector3,
	velocity: Vector3,
	accel: Vector3,
	startTime: number,
	lastPosition: Vector3,
	radius: number,
	damage: number,
	splash: number,
	params: RaycastParams,
}

-- Walks up from a hit part to the humanoid character or snowman target it belongs to.
local function findDamageable(instance: Instance): Model?
	local model = instance:FindFirstAncestorOfClass("Model")
	while model do
		if model:FindFirstChildOfClass("Humanoid") or model:GetAttribute("IsTarget") then
			return model
		end
		local parent = model.Parent
		model = parent and parent:FindFirstAncestorOfClass("Model")
	end
	return nil
end

local function applyDamage(projectile: Projectile, model: Model, amount: number, hitPosition: Vector3, isSplash: boolean)
	local owner = projectile.owner
	local ownerValid = owner.Parent == Players and profiles[owner] ~= nil
	local rewards = Config.Rewards

	if model:GetAttribute("IsTarget") then
		local dealt, broke = Targets.Damage(model, amount)
		if dealt <= 0 or not ownerValid then
			return
		end
		giveCoins(owner, broke and rewards.BreakSnowman or rewards.HitSnowman)
		Remotes.Hit:FireClient(owner, hitPosition, dealt, broke)
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local victim = Players:GetPlayerFromCharacter(model)
	if victim == owner or model:FindFirstChildOfClass("ForceField") then
		return
	end

	local before = humanoid.Health
	humanoid:TakeDamage(amount)
	local dealt = before - math.max(humanoid.Health, 0)
	local killed = humanoid.Health <= 0
	if dealt <= 0 or not ownerValid then
		return
	end

	giveCoins(owner, isSplash and rewards.SplashPlayer or rewards.HitPlayer)
	Remotes.Hit:FireClient(owner, hitPosition, dealt, killed)

	if killed then
		local victimName = victim and victim.DisplayName or model.Name
		local coins = giveCoins(owner, rewards.Eliminate)
		local profile = profiles[owner]
		profile.Elims += 1
		local stats = owner:FindFirstChild("leaderstats")
		if stats then
			(stats :: any).Frozen.Value = profile.Elims
		end
		local streak = (owner:GetAttribute("Streak") or 0) + 1
		owner:SetAttribute("Streak", streak)
		Remotes.Elim:FireClient(owner, victimName, streak, coins)
		Remotes.KillFeed:FireAllClients(owner.DisplayName, victimName)
	end
end

local function splashDamage(projectile: Projectile, center: Vector3, skip: Model?)
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = { projectile.ownerCharacter }
	overlap.RespectCanCollide = true

	local seen: { [Model]: boolean } = {}
	for _, part in workspace:GetPartBoundsInRadius(center, projectile.splash, overlap) do
		local model = findDamageable(part)
		if model and model ~= skip and not seen[model] then
			seen[model] = true
			local pivot = model:GetPivot().Position
			local distance = (pivot - center).Magnitude
			-- Cover blocks splash damage.
			local blocked = workspace:Raycast(center, pivot - center, projectile.params)
			if not blocked or blocked.Instance:IsDescendantOf(model) then
				local falloff = 1 - math.clamp(distance / projectile.splash, 0, 1) * 0.5
				applyDamage(projectile, model, projectile.damage * 0.5 * falloff, pivot, true)
			end
		end
	end
end

------------------------------------------------------------------------------------------
-- Throwing
------------------------------------------------------------------------------------------
-- Launch velocity so a ball with the given speed and gravity passes through `target` (flat "low" arc).
local function launchVelocity(origin: Vector3, target: Vector3, speed: number, gravity: number): Vector3
	local delta = target - origin
	local flat = Vector3.new(delta.X, 0, delta.Z)
	local x = flat.Magnitude
	if x < 0.5 then
		return (delta.Magnitude > 0.01 and delta.Unit or Vector3.new(0, 1, 0)) * speed
	end
	local speed2 = speed * speed
	local discriminant = speed2 * speed2 - gravity * (gravity * x * x + 2 * delta.Y * speed2)
	local tanTheta = 1 -- out of range: lob at 45 degrees
	if discriminant >= 0 then
		tanTheta = (speed2 - math.sqrt(discriminant)) / (gravity * x)
	end
	local cosTheta = 1 / math.sqrt(1 + tanTheta * tanTheta)
	local sinTheta = tanTheta * cosTheta
	return flat.Unit * (speed * cosTheta) + Vector3.new(0, speed * sinTheta, 0)
end

local projectiles: { [number]: Projectile } = {}
local nextProjectileId = 0
local nextThrowAt: { [Player]: number } = {}

local function isFiniteVector(v: Vector3): boolean
	return v.Magnitude == v.Magnitude and v.Magnitude < 1e5
end

Remotes.Throw.OnServerEvent:Connect(function(player: Player, target: any)
	if typeof(target) ~= "Vector3" or not isFiniteVector(target) then
		return
	end
	if not profiles[player] then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head") :: BasePart?
	if not character or not humanoid or not head or humanoid.Health <= 0 then
		return
	end

	local now = os.clock()
	if now < (nextThrowAt[player] or 0) - 0.08 then
		return
	end
	nextThrowAt[player] = now + statOf(player, "FireRate")

	local origin = head.Position - Vector3.new(0, 0.2, 0)
	local gravity = workspace.Gravity * Config.SnowballGravityScale
	local speed = statOf(player, "Speed")
	local velocity = launchVelocity(origin, target, speed, gravity)
	local size = statOf(player, "Size")
	local splash = statOf(player, "Splash")

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	params.RespectCanCollide = true

	nextProjectileId += 1
	local startTime = workspace:GetServerTimeNow()
	projectiles[nextProjectileId] = {
		id = nextProjectileId,
		owner = player,
		ownerCharacter = character,
		origin = origin,
		velocity = velocity,
		accel = Vector3.new(0, -gravity, 0),
		startTime = startTime,
		lastPosition = origin,
		radius = size / 2,
		damage = statOf(player, "Damage"),
		splash = splash,
		params = params,
	}
	Remotes.Projectile:FireAllClients(nextProjectileId, player.UserId, origin, velocity, gravity, size, splash, startTime)
end)

RunService.Heartbeat:Connect(function()
	local now = workspace:GetServerTimeNow()
	for id, projectile in projectiles do
		local age = now - projectile.startTime
		local position = projectile.origin + projectile.velocity * age + projectile.accel * (0.5 * age * age)
		local delta = position - projectile.lastPosition
		local hit: RaycastResult? = nil
		if delta.Magnitude > 0.001 then
			hit = workspace:Spherecast(projectile.lastPosition, projectile.radius, delta, projectile.params)
		end

		if hit then
			local center = projectile.lastPosition + delta.Unit * hit.Distance
			local direct = findDamageable(hit.Instance)
			if direct then
				applyDamage(projectile, direct, projectile.damage, hit.Position, false)
			end
			if projectile.splash > 0 then
				splashDamage(projectile, center, direct)
			end
			projectiles[id] = nil
		elseif age > Config.SnowballLifetime or position.Y < -80 then
			projectiles[id] = nil
		else
			projectile.lastPosition = position
		end
	end
end)

------------------------------------------------------------------------------------------
-- Upgrades
------------------------------------------------------------------------------------------
Remotes.BuyUpgrade.OnServerEvent:Connect(function(player: Player, id: any)
	if type(id) ~= "string" then
		return
	end
	local def = Config.UpgradeById[id]
	local profile = profiles[player]
	if not def or not profile then
		return
	end

	local level = profile.Levels[id]
	if level >= Config.MaxLevel then
		return
	end
	local cost = Config.GetCost(id, level)
	if profile.Coins < cost then
		Remotes.Notify:FireClient(player, "Not enough coins!", "error")
		return
	end

	profile.Coins -= cost
	profile.Levels[id] = level + 1
	syncPlayer(player)
	applyCharacterStats(player, false)
	Remotes.Notify:FireClient(player, def.Icon .. " " .. def.Name .. " upgraded to level " .. (level + 1) .. "!", "success")
end)

------------------------------------------------------------------------------------------
-- Joining and leaving
------------------------------------------------------------------------------------------
local function onPlayerAdded(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = stats
	local frozen = Instance.new("IntValue")
	frozen.Name = "Frozen"
	frozen.Parent = stats
	stats.Parent = player

	local profile = loadProfile(player)
	if player.Parent ~= Players then
		return
	end
	profiles[player] = profile
	syncPlayer(player)

	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		task.spawn(onCharacter, player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	saveProfile(player)
	profiles[player] = nil
	nextThrowAt[player] = nil
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		saveProfile(player)
	end
end)

task.spawn(function()
	while true do
		task.wait(90)
		for player in profiles do
			task.spawn(saveProfile, player)
		end
	end
end)
