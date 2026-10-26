-- Creates (once) and returns every RemoteEvent the game uses.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NAMES = {
	"Throw", -- client -> server: aim point
	"BuyUpgrade", -- client -> server: upgrade id
	"Projectile", -- server -> all: a snowball was thrown
	"Hit", -- server -> thrower: hit marker / damage number
	"Elim", -- server -> killer: elimination banner
	"KillFeed", -- server -> all: who froze who
	"Notify", -- server -> one: small toast message
}

local folder = ReplicatedStorage:FindFirstChild("Remotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
end

local remotes: { [string]: RemoteEvent } = {}
for _, name in NAMES do
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	remotes[name] = remote
end

return remotes
