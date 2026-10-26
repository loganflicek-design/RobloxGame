-- Tiny helpers for building UI from code, plus the shared colour palette.
local TweenService = game:GetService("TweenService")

local Ui = {}

Ui.Colors = {
	Panel = Color3.fromRGB(14, 24, 44),
	PanelLight = Color3.fromRGB(28, 44, 74),
	Ice = Color3.fromRGB(125, 205, 255),
	IceDark = Color3.fromRGB(58, 128, 205),
	Gold = Color3.fromRGB(255, 208, 90),
	Green = Color3.fromRGB(86, 214, 134),
	Red = Color3.fromRGB(255, 96, 106),
	Text = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(160, 182, 214),
	Locked = Color3.fromRGB(70, 82, 108),
}

Ui.TitleFont = Enum.Font.FredokaOne
Ui.BodyFont = Enum.Font.GothamMedium

function Ui.new(className: string, props: { [string]: any }?, children: { Instance }?): any
	local instance = Instance.new(className)
	local parent = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				(instance :: any)[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	instance.Parent = parent
	return instance
end

function Ui.corner(radius: number): UICorner
	return Ui.new("UICorner", { CornerRadius = UDim.new(0, radius) })
end

function Ui.stroke(color: Color3, thickness: number, transparency: number?): UIStroke
	return Ui.new("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Ui.padding(amount: number): UIPadding
	return Ui.new("UIPadding", {
		PaddingTop = UDim.new(0, amount),
		PaddingBottom = UDim.new(0, amount),
		PaddingLeft = UDim.new(0, amount),
		PaddingRight = UDim.new(0, amount),
	})
end

function Ui.tween(instance: Instance, duration: number, goal: { [string]: any }, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
		goal
	)
	tween:Play()
	return tween
end

function Ui.label(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = Ui.TitleFont,
		TextColor3 = Ui.Colors.Text,
		TextSize = 18,
		BorderSizePixel = 0,
	}
	for key, value in props do
		defaults[key] = value
	end
	return Ui.new("TextLabel", defaults)
end

-- 1234567 -> "1,234,567"
function Ui.commas(n: number): string
	local text = tostring(math.floor(n))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

return Ui
