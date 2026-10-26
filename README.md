# RobloxGame

Code lives in git and syncs live into Roblox Studio with [Rojo](https://rojo.space).

## Connect Roblox Studio

1. Clone this repo on your computer and install tools: `rokit install` (or install Rojo 7.4.x manually).
2. Install the **Rojo plugin** in Studio: run `rojo plugin install`, or get it from the Creator Store.
3. In the repo folder run: `rojo serve`
4. In Studio, open a place (or a new Baseplate), go to **Plugins → Rojo → Connect** (default `localhost:34872`).
5. Edit files in `src/` — changes sync into Studio instantly.

Layout: `src/server` → ServerScriptService, `src/client` → StarterPlayerScripts, `src/shared` → ReplicatedStorage.

Build a place file: `rojo build -o build/RobloxGame.rbxl`
