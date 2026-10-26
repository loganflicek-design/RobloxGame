local Controls = require(script.Controls)
local Effects = require(script.Effects)
local Hud = require(script.Hud)
local Shop = require(script.Shop)

Hud.Start()
Shop.Start()
Controls.Start(Hud, Shop)
Effects.Start(Hud)
