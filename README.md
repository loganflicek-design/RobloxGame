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

## Snowball Showdown

A snowball-fight game. Everything (map, UI, effects) is generated from code, so there's nothing to place by hand in Studio.

- **Throw:** click or hold the mouse (a THROW button shows up on mobile). Snowballs arc to wherever your cursor points.
- **Coins:** earned for hitting players and snowman targets, plus a bonus for freezing someone.
- **Upgrades:** press `U` (or the Upgrades button) to spend coins on 8 upgrades: damage, throw speed, fire rate, snowball size, splash, health, run speed and coin bonus.
- **Saving:** coins, frozen count and upgrades are saved with DataStore. In Studio, publish the place and turn on *Game Settings > Security > Enable Studio Access to API Services*, otherwise progress simply won't save while testing.

Where things live:

| Path | What it does |
| --- | --- |
| `src/shared/Config.luau` | Upgrade list, costs, rewards, tuning numbers |
| `src/server/Game.server.luau` | Throwing, damage, coins, upgrades, saving |
| `src/server/Map.server.luau` | Builds the arena, props and lighting |
| `src/server/Targets.luau` | Snowman targets |
| `src/server/Car.server.luau` | The drivable car |
| `src/client/*.luau` | HUD, shop, controls and visual effects |

To add an upgrade, add an entry to `Config.Upgrades` (the shop card is generated automatically) and use `Config.GetValue("<Id>", level)` where it should take effect.
