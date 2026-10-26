-- On-screen HUD: coins, health, crosshair, hit markers, toasts, kill feed and elimination banners.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ui = require(script.Parent.Ui)
local Colors = Ui.Colors

local player = Players.LocalPlayer

local Hud = {}

local refs: { [string]: any } = {}

local function escapeRich(text: string): string
	return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function colorHex(color: Color3): string
	return string.format("#%02x%02x%02x", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

------------------------------------------------------------------------------------------
-- Building the UI
------------------------------------------------------------------------------------------
local function buildStatsCard(gui: ScreenGui)
	local card = Ui.new("Frame", {
		Name = "Stats",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 16, 1, -16),
		Size = UDim2.fromOffset(210, 92),
		BackgroundColor3 = Colors.Panel,
		BackgroundTransparency = 0.12,
		Parent = gui,
	}, { Ui.corner(16), Ui.stroke(Colors.IceDark, 2, 0.15) })

	refs.coins = Ui.label({
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromOffset(16, 30),
		Size = UDim2.new(1, -32, 0, 40),
		Text = "🪙 0",
		TextSize = 34,
		TextColor3 = Colors.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	refs.coinScale = Ui.new("UIScale", { Parent = refs.coins })

	refs.frozen = Ui.label({
		Position = UDim2.fromOffset(16, 56),
		Size = UDim2.new(1, -32, 0, 28),
		Text = "🧊 0 frozen",
		TextSize = 20,
		TextColor3 = Colors.Ice,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	refs.coinPopup = Ui.label({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 22, 0, -6),
		Size = UDim2.fromOffset(120, 26),
		Text = "",
		TextSize = 24,
		TextColor3 = Colors.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		TextStrokeTransparency = 1,
		Parent = card,
	})
end

local function buildHealthBar(gui: ScreenGui)
	local back = Ui.new("Frame", {
		Name = "Health",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -22),
		Size = UDim2.fromOffset(380, 36),
		BackgroundColor3 = Colors.Panel,
		BackgroundTransparency = 0.12,
		Parent = gui,
	}, { Ui.corner(18), Ui.stroke(Colors.IceDark, 2, 0.15) })

	local holder = Ui.new("Frame", {
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = back,
	}, { Ui.corner(14) })

	refs.healthFill = Ui.new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colors.Green,
		BorderSizePixel = 0,
		Parent = holder,
	}, {
		Ui.corner(14),
		Ui.new("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 190)),
		}),
	})

	refs.healthText = Ui.label({
		Size = UDim2.fromScale(1, 1),
		Text = "❤ 100 / 100",
		TextSize = 19,
		TextStrokeTransparency = 0.5,
		TextStrokeColor3 = Color3.fromRGB(10, 20, 40),
		ZIndex = 3,
		Parent = back,
	})
end

local function buildCrosshair(gui: ScreenGui)
	local crosshair = Ui.new("Frame", {
		Name = "Crosshair",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(60, 60),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = gui,
	})
	refs.crosshair = crosshair

	Ui.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Parent = crosshair,
	}, { Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }), Ui.stroke(Colors.Text, 2, 0.1) })

	Ui.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(4, 4),
		BackgroundColor3 = Colors.Text,
		BorderSizePixel = 0,
		ZIndex = 20,
		Parent = crosshair,
	}, { Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	refs.cooldownBack = Ui.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.5, 18),
		Size = UDim2.fromOffset(46, 5),
		BackgroundColor3 = Colors.Panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
		Parent = crosshair,
	}, { Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	refs.cooldownFill = Ui.new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Colors.Ice,
		BorderSizePixel = 0,
		ZIndex = 21,
		Parent = refs.cooldownBack,
	}, { Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	refs.hitMarker = Ui.label({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(40, 40),
		Text = "✕",
		TextSize = 34,
		TextTransparency = 1,
		TextStrokeTransparency = 1,
		TextStrokeColor3 = Color3.fromRGB(10, 20, 40),
		ZIndex = 22,
		Parent = crosshair,
	})
	refs.hitScale = Ui.new("UIScale", { Parent = refs.hitMarker })
end

local function buildFeeds(gui: ScreenGui)
	refs.toasts = Ui.new("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 84),
		Size = UDim2.fromOffset(400, 200),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		Ui.new("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	refs.killFeed = Ui.new("Frame", {
		Name = "KillFeed",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0.4, 0),
		Size = UDim2.fromOffset(320, 200),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		Ui.new("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	refs.banners = Ui.new("Frame", {
		Name = "Banners",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.18),
		Size = UDim2.fromOffset(500, 120),
		BackgroundTransparency = 1,
		Parent = gui,
	})
end

local function buildDamageFlash(gui: ScreenGui)
	local group = Ui.new("CanvasGroup", {
		Name = "DamageFlash",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Active = false,
		ZIndex = 0,
		Parent = gui,
	})
	refs.damageFlash = group
	local strips = {
		{ Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 0.25), Rotation = 90 },
		{ Position = UDim2.fromScale(0, 0.75), Size = UDim2.fromScale(1, 0.25), Rotation = 270 },
		{ Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(0.18, 1), Rotation = 0 },
		{ Position = UDim2.fromScale(0.82, 0), Size = UDim2.fromScale(0.18, 1), Rotation = 180 },
	}
	for _, strip in strips do
		Ui.new("Frame", {
			Position = strip.Position,
			Size = strip.Size,
			BackgroundColor3 = Colors.Red,
			BorderSizePixel = 0,
			Parent = group,
		}, {
			Ui.new("UIGradient", {
				Rotation = strip.Rotation,
				Transparency = NumberSequence.new(0.2, 1),
			}),
		})
	end
end

local function buildHint(gui: ScreenGui)
	local hint = Ui.label({
		Name = "Hint",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -66),
		Size = UDim2.fromOffset(460, 24),
		Text = "Click (or hold) to throw  •  U for upgrades",
		TextSize = 17,
		Font = Ui.BodyFont,
		TextColor3 = Colors.Text,
		TextStrokeTransparency = 0.4,
		TextStrokeColor3 = Color3.fromRGB(10, 20, 40),
		Parent = gui,
	})
	task.delay(16, function()
		Ui.tween(hint, 1, { TextTransparency = 1, TextStrokeTransparency = 1 })
	end)
end

------------------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------------------
function Hud.SetCrosshair(position: Vector2)
	refs.crosshair.Position = UDim2.fromOffset(position.X, position.Y)
end

function Hud.SetCrosshairVisible(visible: boolean)
	refs.crosshair.Visible = visible
end

function Hud.SetCooldown(alpha: number)
	local ready = alpha >= 1
	refs.cooldownBack.Visible = not ready
	refs.cooldownFill.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
end

function Hud.HitMarker(killed: boolean)
	local marker = refs.hitMarker
	marker.TextColor3 = killed and Colors.Red or Colors.Text
	marker.TextTransparency = 0
	marker.TextStrokeTransparency = 0.3
	refs.hitScale.Scale = 1.5
	Ui.tween(refs.hitScale, 0.12, { Scale = 1 })
	Ui.tween(marker, killed and 0.5 or 0.28, { TextTransparency = 1, TextStrokeTransparency = 1 })
end

local function trimChildren(container: Instance, limit: number)
	local entries = {}
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then
			table.insert(entries, child)
		end
	end
	for i = 1, #entries - limit do
		entries[i]:Destroy()
	end
end

local layoutCounter = 0
local function nextOrder(): number
	layoutCounter += 1
	return layoutCounter
end

local function popGroup(group: CanvasGroup, holdTime: number)
	Ui.tween(group, 0.2, { GroupTransparency = 0 })
	task.delay(holdTime, function()
		if group.Parent then
			local fade = Ui.tween(group, 0.4, { GroupTransparency = 1 })
			fade.Completed:Connect(function()
				group:Destroy()
			end)
		end
	end)
end

function Hud.Toast(text: string, kind: string?)
	local accent = Colors.Ice
	if kind == "success" then
		accent = Colors.Green
	elseif kind == "error" then
		accent = Colors.Red
	end
	local group = Ui.new("CanvasGroup", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Colors.Panel,
		BackgroundTransparency = 0.08,
		GroupTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = refs.toasts,
	}, { Ui.corner(12), Ui.stroke(accent, 2, 0.1), Ui.padding(12) })
	Ui.label({
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = text,
		TextSize = 20,
		TextColor3 = accent,
		Parent = group,
	})
	trimChildren(refs.toasts, 4)
	popGroup(group, 2.6)
end

local function streakTitle(streak: number): string?
	if streak == 2 then
		return "DOUBLE FREEZE!"
	elseif streak == 3 then
		return "TRIPLE FREEZE!"
	elseif streak == 4 then
		return "ULTRA FREEZE!"
	elseif streak >= 5 then
		return "BLIZZARD x" .. streak .. "!"
	end
	return nil
end

function Hud.EliminationBanner(victimName: string, streak: number, coins: number)
	for _, old in refs.banners:GetChildren() do
		old:Destroy()
	end
	local group = Ui.new("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Parent = refs.banners,
	}, {
		Ui.new("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	Ui.label({
		Size = UDim2.new(1, 0, 0, 46),
		Text = "❄ FROZEN " .. victimName .. " ❄",
		TextSize = 38,
		TextColor3 = Colors.Ice,
		TextStrokeTransparency = 0.3,
		TextStrokeColor3 = Color3.fromRGB(10, 25, 60),
		LayoutOrder = 1,
		Parent = group,
	})
	local sub = "+" .. coins .. " 🪙"
	local title = streakTitle(streak)
	if title then
		sub = title .. "   " .. sub
	end
	Ui.label({
		Size = UDim2.new(1, 0, 0, 30),
		Text = sub,
		TextSize = 24,
		TextColor3 = Colors.Gold,
		TextStrokeTransparency = 0.3,
		TextStrokeColor3 = Color3.fromRGB(10, 25, 60),
		LayoutOrder = 2,
		Parent = group,
	})
	local scale = Ui.new("UIScale", { Scale = 0.6, Parent = group })
	Ui.tween(scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
	popGroup(group, 2.2)
end

function Hud.KillFeedEntry(killer: string, victim: string)
	local group = Ui.new("CanvasGroup", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Colors.Panel,
		BackgroundTransparency = 0.25,
		GroupTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = refs.killFeed,
	}, { Ui.corner(10), Ui.padding(8) })
	Ui.label({
		AutomaticSize = Enum.AutomaticSize.XY,
		RichText = true,
		Text = string.format(
			'<font color="%s">%s</font>  ❄  <font color="%s">%s</font>',
			colorHex(Colors.Ice),
			escapeRich(killer),
			colorHex(Colors.Red),
			escapeRich(victim)
		),
		TextSize = 17,
		Font = Enum.Font.GothamBold,
		Parent = group,
	})
	trimChildren(refs.killFeed, 5)
	popGroup(group, 5)
end

------------------------------------------------------------------------------------------
-- Live updates
------------------------------------------------------------------------------------------
local function updateHealth(humanoid: Humanoid, previous: number?)
	local maxHealth = math.max(humanoid.MaxHealth, 1)
	local health = math.max(humanoid.Health, 0)
	local ratio = math.clamp(health / maxHealth, 0, 1)

	local color = Colors.Green
	if ratio < 0.25 then
		color = Colors.Red
	elseif ratio < 0.5 then
		color = Color3.fromRGB(255, 170, 70)
	end
	Ui.tween(refs.healthFill, 0.2, { Size = UDim2.fromScale(ratio, 1), BackgroundColor3 = color })
	refs.healthText.Text = "❤ " .. math.ceil(health) .. " / " .. math.ceil(maxHealth)

	if previous and health < previous - 0.5 then
		refs.damageFlash.GroupTransparency = 0.15
		Ui.tween(refs.damageFlash, 0.6, { GroupTransparency = 1 })
	end
end

local function bindCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then
		return
	end
	local last = humanoid.Health
	updateHealth(humanoid, nil)
	humanoid.HealthChanged:Connect(function(health)
		updateHealth(humanoid, last)
		last = health
	end)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		updateHealth(humanoid, nil)
	end)
end

local function bindStats()
	local stats = player:WaitForChild("leaderstats")
	local coins = stats:WaitForChild("Coins") :: IntValue
	local frozen = stats:WaitForChild("Frozen") :: IntValue

	local lastCoins = coins.Value
	local function showCoins()
		refs.coins.Text = "🪙 " .. Ui.commas(coins.Value)
		local gained = coins.Value - lastCoins
		lastCoins = coins.Value
		if gained > 0 then
			refs.coinScale.Scale = 1.18
			Ui.tween(refs.coinScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
			local popup = refs.coinPopup
			popup.Text = "+" .. gained
			popup.Position = UDim2.new(0, 22, 0, -4)
			popup.TextTransparency = 0
			popup.TextStrokeTransparency = 0.4
			Ui.tween(popup, 0.9, { Position = UDim2.new(0, 22, 0, -26), TextTransparency = 1, TextStrokeTransparency = 1 })
		end
	end
	coins.Changed:Connect(showCoins)
	showCoins()

	local function showFrozen()
		refs.frozen.Text = "🧊 " .. Ui.commas(frozen.Value) .. " frozen"
	end
	frozen.Changed:Connect(showFrozen)
	showFrozen()
end

function Hud.Start()
	local gui = Ui.new("ScreenGui", {
		Name = "SnowHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 5,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})
	refs.gui = gui

	buildDamageFlash(gui)
	buildStatsCard(gui)
	buildHealthBar(gui)
	buildFeeds(gui)
	buildCrosshair(gui)
	buildHint(gui)

	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	remotes:WaitForChild("Elim").OnClientEvent:Connect(Hud.EliminationBanner)
	remotes:WaitForChild("KillFeed").OnClientEvent:Connect(Hud.KillFeedEntry)
	remotes:WaitForChild("Notify").OnClientEvent:Connect(Hud.Toast)

	task.spawn(bindStats)
	player.CharacterAdded:Connect(bindCharacter)
	if player.Character then
		task.spawn(bindCharacter, player.Character)
	end
end

return Hud
