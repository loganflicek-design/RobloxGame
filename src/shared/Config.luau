-- Shared game config: upgrade definitions and tuning numbers.
-- Used by the server (real stats) and the client (shop previews).

local Config = {}

Config.GameName = "Snowball Showdown"
Config.MaxLevel = 8

-- Gravity applied to snowballs, as a fraction of workspace gravity (lower = flatter throws).
Config.SnowballGravityScale = 0.25
Config.SnowballLifetime = 6

Config.Rewards = {
	HitPlayer = 4,
	SplashPlayer = 2,
	Eliminate = 35,
	HitSnowman = 2,
	BreakSnowman = 12,
}

-- Each upgrade: stat = Base + PerLevel * level. Cost = floor(BaseCost * CostGrowth ^ level).
Config.Upgrades = {
	{
		Id = "Damage",
		Name = "Snow Punch",
		Desc = "Snowballs hit harder",
		Icon = "💥",
		Base = 12,
		PerLevel = 3,
		BaseCost = 40,
		Suffix = " dmg",
		Decimals = 0,
	},
	{
		Id = "Speed",
		Name = "Cannon Arm",
		Desc = "Snowballs fly faster and farther",
		Icon = "🚀",
		Base = 85,
		PerLevel = 10,
		BaseCost = 35,
		Suffix = " st/s",
		Decimals = 0,
	},
	{
		Id = "FireRate",
		Name = "Quick Hands",
		Desc = "Throw snowballs more often",
		Icon = "⚡",
		Base = 0.8,
		PerLevel = -0.07,
		Min = 0.24,
		BaseCost = 50,
		Suffix = "s delay",
		Decimals = 2,
	},
	{
		Id = "Size",
		Name = "Mega Balls",
		Desc = "Bigger snowballs are easier to land",
		Icon = "⛄",
		Base = 1.1,
		PerLevel = 0.2,
		BaseCost = 45,
		Suffix = " size",
		Decimals = 1,
	},
	{
		Id = "Splash",
		Name = "Powder Burst",
		Desc = "Snowballs splash nearby enemies for half damage",
		Icon = "❄️",
		Base = 0,
		PerLevel = 2.5,
		BaseCost = 60,
		Suffix = " radius",
		Decimals = 1,
	},
	{
		Id = "Health",
		Name = "Thick Coat",
		Desc = "More health before you freeze",
		Icon = "🧥",
		Base = 100,
		PerLevel = 25,
		BaseCost = 40,
		Suffix = " HP",
		Decimals = 0,
	},
	{
		Id = "RunSpeed",
		Name = "Snow Boots",
		Desc = "Run faster across the snow",
		Icon = "👢",
		Base = 16,
		PerLevel = 1.5,
		BaseCost = 30,
		Suffix = " speed",
		Decimals = 1,
	},
	{
		Id = "Greed",
		Name = "Coin Magnet",
		Desc = "Earn more coins from everything",
		Icon = "🪙",
		Base = 1,
		PerLevel = 0.15,
		BaseCost = 70,
		Suffix = "x coins",
		Decimals = 2,
	},
}

Config.CostGrowth = 1.55

Config.UpgradeById = {}
for _, def in Config.Upgrades do
	Config.UpgradeById[def.Id] = def
end

function Config.GetValue(id: string, level: number): number
	local def = Config.UpgradeById[id]
	local value = def.Base + def.PerLevel * level
	if def.Min then
		value = math.max(value, def.Min)
	end
	return value
end

function Config.GetCost(id: string, level: number): number
	local def = Config.UpgradeById[id]
	return math.floor(def.BaseCost * Config.CostGrowth ^ level)
end

function Config.FormatValue(id: string, value: number): string
	local def = Config.UpgradeById[id]
	local format = "%." .. def.Decimals .. "f"
	return string.format(format, value) .. def.Suffix
end

return Config
