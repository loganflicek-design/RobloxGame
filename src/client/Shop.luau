-- Upgrade shop: a button on the HUD (or the U key) opens a panel with one card per upgrade.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Ui = require(script.Parent.Ui)
local Colors = Ui.Colors

local player = Players.LocalPlayer

local Shop = {}

local PANEL_WIDTH, PANEL_HEIGHT = 640, 480

local isOpen = false
local panel: Frame
local panelScale: UIScale
local coinLabel: TextLabel
local badge: Frame
local badgeLabel: TextLabel
local cards: { [string]: any } = {}
local buyRemote: RemoteEvent
local baseScale = 1

function Shop.IsOpen(): boolean
	return isOpen
end

local function levelOf(id: string): number
	return player:GetAttribute("Lv_" .. id) or 0
end

local function currentCoins(): number
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	return coins and (coins :: IntValue).Value or 0
end

local function refresh()
	local coins = currentCoins()
	coinLabel.Text = "🪙 " .. Ui.commas(coins)

	local affordable = 0
	for _, def in Config.Upgrades do
		local card = cards[def.Id]
		local level = levelOf(def.Id)
		local maxed = level >= Config.MaxLevel

		for index, pip in card.pips do
			pip.BackgroundColor3 = index <= level and Colors.Ice or Colors.Locked
		end

		local current = Config.FormatValue(def.Id, Config.GetValue(def.Id, level))
		if maxed then
			card.stat.Text = current .. "  (MAX)"
			card.buy.Text = "MAX"
			card.buy.BackgroundColor3 = Colors.Gold
			card.buy.TextColor3 = Color3.fromRGB(60, 40, 0)
			card.buy.AutoButtonColor = false
		else
			local cost = Config.GetCost(def.Id, level)
			card.stat.Text = current .. "  →  " .. Config.FormatValue(def.Id, Config.GetValue(def.Id, level + 1))
			card.buy.Text = "🪙 " .. Ui.commas(cost)
			card.buy.AutoButtonColor = true
			if coins >= cost then
				affordable += 1
				card.buy.BackgroundColor3 = Colors.Green
				card.buy.TextColor3 = Color3.fromRGB(10, 50, 28)
			else
				card.buy.BackgroundColor3 = Colors.Locked
				card.buy.TextColor3 = Colors.Muted
			end
		end
	end

	badge.Visible = affordable > 0
	badgeLabel.Text = tostring(affordable)
end

local function fitToScreen()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	baseScale = math.clamp(math.min((viewport.X - 24) / PANEL_WIDTH, (viewport.Y - 24) / PANEL_HEIGHT), 0.4, 1)
	if isOpen then
		panelScale.Scale = baseScale
	end
end

function Shop.SetOpen(state: boolean)
	if state == isOpen then
		return
	end
	isOpen = state
	if state then
		refresh()
		fitToScreen()
		panelScale.Scale = baseScale * 0.85
		panel.Visible = true
		Ui.tween(panelScale, 0.22, { Scale = baseScale }, Enum.EasingStyle.Back)
	else
		panel.Visible = false
	end
end

function Shop.Toggle()
	Shop.SetOpen(not isOpen)
end

local function buildCard(def: any, order: number, parent: Instance)
	local card = Ui.new("Frame", {
		Name = def.Id,
		BackgroundColor3 = Colors.PanelLight,
		BackgroundTransparency = 0.1,
		LayoutOrder = order,
		Parent = parent,
	}, { Ui.corner(14), Ui.stroke(Colors.IceDark, 1.5, 0.5) })

	Ui.new("Frame", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = Colors.Panel,
		Parent = card,
	}, {
		Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
		Ui.stroke(Colors.Ice, 2, 0.3),
		Ui.label({ Size = UDim2.fromScale(1, 1), Text = def.Icon, TextSize = 28 }),
	})

	Ui.label({
		Position = UDim2.fromOffset(70, 8),
		Size = UDim2.new(1, -80, 0, 24),
		Text = def.Name,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	Ui.label({
		Position = UDim2.fromOffset(70, 32),
		Size = UDim2.new(1, -80, 0, 30),
		Text = def.Desc,
		TextSize = 12,
		Font = Ui.BodyFont,
		TextColor3 = Colors.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = card,
	})

	local stat = Ui.label({
		Position = UDim2.fromOffset(12, 68),
		Size = UDim2.fromOffset(160, 18),
		Text = "",
		TextSize = 15,
		TextColor3 = Colors.Ice,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local pipRow = Ui.new("Frame", {
		Position = UDim2.fromOffset(12, 94),
		Size = UDim2.fromOffset(150, 8),
		BackgroundTransparency = 1,
		Parent = card,
	}, {
		Ui.new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local pips = {}
	for i = 1, Config.MaxLevel do
		pips[i] = Ui.new("Frame", {
			Size = UDim2.fromOffset(16, 8),
			BackgroundColor3 = Colors.Locked,
			BorderSizePixel = 0,
			LayoutOrder = i,
			Parent = pipRow,
		}, { Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	end

	local buy = Ui.new("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -10, 1, -10),
		Size = UDim2.fromOffset(110, 36),
		BackgroundColor3 = Colors.Locked,
		Font = Ui.TitleFont,
		TextSize = 18,
		Text = "",
		TextColor3 = Colors.Muted,
		Parent = card,
	}, { Ui.corner(10) })
	buy.Activated:Connect(function()
		if levelOf(def.Id) < Config.MaxLevel then
			buyRemote:FireServer(def.Id)
		end
	end)

	cards[def.Id] = { stat = stat, pips = pips, buy = buy }
end

function Shop.Start()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	buyRemote = remotes:WaitForChild("BuyUpgrade") :: RemoteEvent

	local gui = Ui.new("ScreenGui", {
		Name = "SnowShop",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = player:WaitForChild("PlayerGui"),
	})

	-- HUD button
	local button = Ui.new("TextButton", {
		Name = "ShopButton",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 16, 1, -116),
		Size = UDim2.fromOffset(210, 52),
		BackgroundColor3 = Colors.IceDark,
		Font = Ui.TitleFont,
		TextSize = 21,
		Text = UserInputService.KeyboardEnabled and "⬆ UPGRADES  [U]" or "⬆ UPGRADES",
		TextColor3 = Colors.Text,
		Parent = gui,
	}, {
		Ui.corner(16),
		Ui.stroke(Colors.Ice, 2, 0.1),
		Ui.new("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 190, 210)),
		}),
	})
	button.Activated:Connect(Shop.Toggle)

	badge = Ui.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Colors.Gold,
		Visible = false,
		ZIndex = 5,
		Parent = button,
	}, { Ui.new("UICorner", { CornerRadius = UDim.new(1, 0) }), Ui.stroke(Colors.Panel, 2, 0) })
	badgeLabel = Ui.label({
		Size = UDim2.fromScale(1, 1),
		Text = "0",
		TextSize = 16,
		TextColor3 = Color3.fromRGB(60, 40, 0),
		ZIndex = 6,
		Parent = badge,
	})

	-- Panel
	panel = Ui.new("Frame", {
		Name = "ShopPanel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
		BackgroundColor3 = Colors.Panel,
		BackgroundTransparency = 0.04,
		Visible = false,
		Active = true,
		Parent = gui,
	}, { Ui.corner(22), Ui.stroke(Colors.Ice, 2.5, 0.1) })
	panelScale = Ui.new("UIScale", { Parent = panel })

	Ui.label({
		Position = UDim2.fromOffset(24, 14),
		Size = UDim2.fromOffset(300, 40),
		Text = "❄ UPGRADES",
		TextSize = 32,
		TextColor3 = Colors.Ice,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})
	coinLabel = Ui.label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -72, 0, 18),
		Size = UDim2.fromOffset(220, 36),
		Text = "🪙 0",
		TextSize = 26,
		TextColor3 = Colors.Gold,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = panel,
	})
	local close = Ui.new("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = Colors.PanelLight,
		Font = Ui.TitleFont,
		Text = "✕",
		TextSize = 22,
		TextColor3 = Colors.Red,
		Parent = panel,
	}, { Ui.corner(12) })
	close.Activated:Connect(function()
		Shop.SetOpen(false)
	end)
	Ui.new("Frame", {
		Position = UDim2.fromOffset(16, 64),
		Size = UDim2.new(1, -32, 0, 2),
		BackgroundColor3 = Colors.PanelLight,
		BorderSizePixel = 0,
		Parent = panel,
	})

	local list = Ui.new("ScrollingFrame", {
		Position = UDim2.fromOffset(16, 76),
		Size = UDim2.new(1, -32, 1, -92),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Colors.Ice,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = panel,
	}, {
		Ui.new("UIGridLayout", {
			CellSize = UDim2.fromOffset(292, 118),
			CellPadding = UDim2.fromOffset(10, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
	})
	for index, def in Config.Upgrades do
		buildCard(def, index, list)
	end

	-- Keep everything in sync
	refresh()
	player.AttributeChanged:Connect(refresh)
	task.spawn(function()
		local stats = player:WaitForChild("leaderstats")
		local coins = stats:WaitForChild("Coins") :: IntValue
		coins.Changed:Connect(refresh)
		refresh()
	end)

	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen)
	end
	fitToScreen()

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.U then
			Shop.Toggle()
		end
	end)
end

return Shop
