-- Input: aim at the cursor (or screen centre on touch devices) and throw snowballs.
-- Click or hold the mouse button to throw; on phones a THROW button appears.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Controls = {}

local ACTION_NAME = "SnowballThrow"
local AIM_DISTANCE = 400

function Controls.Start(hud: any, shop: any)
	local player = Players.LocalPlayer
	local throwRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Throw") :: RemoteEvent

	local touchOnly = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
	local holding = false
	local nextThrowAt = 0

	local function cooldown(): number
		return Config.GetValue("FireRate", player:GetAttribute("Lv_FireRate") or 0)
	end

	local function screenPoint(): Vector2
		local camera = workspace.CurrentCamera
		if touchOnly then
			return camera.ViewportSize / 2
		end
		return UserInputService:GetMouseLocation()
	end

	-- The world point under the cursor; the server works out the arc to get there.
	local function aimPoint(): Vector3?
		local camera = workspace.CurrentCamera
		if not camera then
			return nil
		end
		local point = screenPoint()
		local ray = camera:ViewportPointToRay(point.X, point.Y)

		local ignore = {}
		for _, instance in { player.Character, workspace:FindFirstChild("ClientEffects"), workspace:FindFirstChild("Effects") } do
			table.insert(ignore, instance)
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignore
		params.RespectCanCollide = true

		local result = workspace:Raycast(ray.Origin, ray.Direction * AIM_DISTANCE, params)
		if result then
			return result.Position
		end
		return ray.Origin + ray.Direction * AIM_DISTANCE
	end

	local function tryThrow()
		if shop.IsOpen() then
			return
		end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		local now = os.clock()
		if now < nextThrowAt then
			return
		end
		local target = aimPoint()
		if not target then
			return
		end
		nextThrowAt = now + cooldown()
		throwRemote:FireServer(target)
	end

	ContextActionService:BindAction(ACTION_NAME, function(_, state)
		if state == Enum.UserInputState.Begin then
			holding = true
			tryThrow()
		elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
			holding = false
		end
		return Enum.ContextActionResult.Sink
	end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	ContextActionService:SetTitle(ACTION_NAME, "THROW")
	ContextActionService:SetPosition(ACTION_NAME, UDim2.new(1, -170, 1, -190))

	RunService.RenderStepped:Connect(function()
		local open = shop.IsOpen()
		if not touchOnly then
			UserInputService.MouseIconEnabled = open
		end
		hud.SetCrosshairVisible(not open)
		hud.SetCrosshair(screenPoint())

		if holding then
			tryThrow()
		end

		local total = cooldown()
		local remaining = math.max(nextThrowAt - os.clock(), 0)
		hud.SetCooldown(total > 0 and (1 - remaining / total) or 1)
	end)
end

return Controls
