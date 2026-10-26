# Roblox Game UI/UX and Visual Design Patterns (2025-2026)

Research caveat: WebFetch was unavailable (DNS failure), so all findings come from search-result summaries only; no full pages were read. Search found little game-specific UI/art analysis of top titles. Many "tips" hits were low-quality SEO pages and are flagged as such.

## What UI conventions do top games share (HUD, currency, shop, daily rewards, inventory grids)?

### Takeaway
Primary-source evidence on conventions is thin. Commercial simulator UI kits and freelancer briefs consistently describe the same component set (Main HUD, Shop, Pets, Upgrades, Rebirth, Index, currency/level, progress bars, inventory capacity). Treat this as a description of the genre template, not verified analysis of specific top games.

### Cited Findings
- A simulator UI pack lists Main HUD, Shop, Upgrades, Rebirth and Index menus plus currency/level UI, progression bars and inventory capacity UI; style is "bright and colorful, focus on readability". — [Modern Cartoon Simulator UI](https://builtbybit.com/resources/modern-cartoon-simulator-ui.109159/)
- Another pack lists Main HUD, Shop System, Pets System, Upgrades Menu, Rebirth Menu, Currency & Level UI and Progression Bars. — [Cartoony UI Pack Pro+](https://builtbybit.com/resources/cartoony-ui-pack-pro-ui-system.107727/)
- Shop layout pattern: category-based layout, product cards with images, price icons for both Robux and in-game currency, dark clean style. — [Advanced Roblox Shop System](https://builtbybit.com/resources/advanced-roblox-shop-system.87338/)
- Core simulator HUD elements named in a freelancer brief: health, currency, backpack capacity, boost timers; stated challenge is keeping essential info visible without distracting from the core loop. — [Freelancer brief](https://www.freelancer.com/projects/roblox/cartoon-roblox-simulator-gui-design)
- Third-party (non-official) guidance: status stats in top corners, actions at bottom center for thumb reach on mobile; min tappable mobile button 44x44 px; test on real devices. — [creation.dev](https://www.creation.dev/blog/roblox-ui-design-best-practices)
- Egg/pet hatching UI kit pattern: tap to hatch, egg shake animation, pet slides away/reveals. — [Egg Hatching System](https://aidenshop.itch.io/egghatchsystem)
- Top 2025 games for context: Grow a Garden, Steal a Brainrot (peak ~25.4M CCU Oct 2025, other outlet says 25.2M), 99 Nights in the Forest set records; Brookhaven RP and Blox Fruits in top 10 every month. — [Newzoo via GameDev Reports](https://gamedevreports.substack.com/p/newzoo-top-roblox-games-in-2025); [PocketGamer.biz](https://www.pocketgamer.biz/robloxs-steal-a-brainrot-becomes-first-game-to-surpass-25m-concurrent-players)

### Inferences
- The shared template is: currency/stat readout at top, persistent shortcut buttons to Shop/Pets/Index/Rebirth on a screen edge, capacity bar, boost timers, grid-based inventory/index. This is inferred from kit feature lists, not observed in top games directly.
- Daily reward UI conventions: no source found.

### Gaps
- No source analyzing actual HUD layouts of Grow a Garden, Steal a Brainrot, Blox Fruits etc.; needs manual screenshots/YouTube review.
- No source on daily reward UI, left-side button column conventions, typography/fonts, color palettes of top games.
- The creation.dev guidance is unofficial; the 44x44 figure is not from Roblox docs.

## How do top games handle first-60-seconds onboarding / FTUE?

### Takeaway
Roblox's official guidance: teach essentials, get to the fun quickly, leave players wanting more; judge by Day 1 retention; A/B test tutorial steps with Experiments.

### Cited Findings
- Roblox treats onboarding/FTUE as the first few minutes of play, judged by Day 1 retention; practices: teach the essentials, get to the fun quickly, leave players wanting more; recommends A/B testing individual steps (e.g., short dialogue vs guided arrow) and using Experiments to find drop-off points. — [Roblox Creator Docs: Onboarding](https://create.roblox.com/docs/en-us/production/game-design/onboarding) (seen via search summary only)
- Secondary: first 30-60 seconds critical; teach contextually with visual cues, interactive prompts, guided first actions; Roblox players have low patience for tutorials. — [creation.dev glossary](https://www.creation.dev/glossary/onboarding)
- Community onboarding framework exists: OnBoard. — [DevForum](https://devforum.roblox.com/t/release-onboard-%E2%80%94-modern-lightweight-onboarding-tutorial-framework/4751478)

### Inferences
- Contextual, short, action-first tutorials with measurable steps are the recommended direction.

### Gaps
- No concrete breakdowns of top games' first minute; full doc page not read (fetch failed).

## What art styles dominate and what thumbnail/icon patterns convert?

### Takeaway
Official guidance emphasizes accurate, unique 16:9 thumbnails and Roblox's thumbnail A/B personalization optimized for qualified play-through rate. Style dominance (low-poly, chibi, etc.) is not supported by any source I found.

### Cited Findings
- Thumbnails 16:9, ideally 1920x1080; non-16:9 is stretched. Unique, relevant imagery showing what players will find has more impact. Thumbnail testing needs at least 2 active thumbnails and optimizes qualified play-through rate, not raw clicks. — [Roblox Creator Docs: Thumbnails](https://create.roblox.com/docs/en-us/production/publishing/thumbnails) (via search summary)
- Unofficial tips (SEO-quality, low reliability): one or two focal subjects, bold contrasting colors, character in action pose, minimal large text, test at ~150x84 and ~100x56. Sources disagree on dimensions (420x420 icon vs 1920x1080). — [various template sites](https://smtp.compagnie-des-sens.fr/08Q/758/topStgszbRobloxThumbnails)
- A claimed "40% CTR increase from Roblox internal data" has no verifiable source; do not use.
- DevForum critique example: pixelated thumbnail and over-simple logo; suggested GFX scene with posed characters in game environment. — [DevForum](https://devforum.roblox.com/t/feedback-on-icon-and-thumbnail/1783501)

### Inferences
- Because Roblox optimizes for qualified play-through, misleading clickbait thumbnails are penalized by design.

### Gaps
- No data on dominant art styles or measured CTR patterns for 2025-26 top games.

## Mobile and console pitfalls, and Roblox-recommended practices (safe areas, scaling)

### Takeaway
~80% of users are on mobile, so design mobile-first. Use ScreenGui.ScreenInsets (default CoreUISafeInsets) for interactive UI; use UIScale/UIAspectRatioConstraint/UISizeConstraint for scaling.

### Cited Findings
- 80% of Roblox users on mobile (Newzoo 2025); Roblox annual report: mobile 80% of 2024 DAU, PC 17%, console 3%; only 24% of players aged 10-65 play exclusively on mobile. — [Newzoo via GameDev Reports](https://gamedevreports.substack.com/p/newzoo-roblox-as-a-platform-in-2025); [PocketGamer.biz](https://www.pocketgamer.biz/80-of-roblox-users-are-on-mobile-contributing-46-of-robux-revenue)
- Mobile ~11.5B of ~14B hours in Q3 2025 (~82%, my arithmetic from one secondary report). — [Outlook Respawn](https://respawn.outlookindia.com/gaming/gaming-news/is-roblox-the-new-netflix-gaming-platform-nears-10b-monthly-hours)
- ScreenInsets: None (only for non-interactive backgrounds; can hide under notches), DeviceSafeInsets (clears cutouts, not top bar), CoreUISafeInsets (default; clears cutouts and core UI; recommended for interactive UI), TopbarSafeInsets. ClipToDeviceSafeArea defaults true. — [ScreenInsets enum](https://create.roblox.com/docs/reference/engine/enums/ScreenInsets.md); [ScreenGui](https://create.roblox.com/docs/reference/engine/classes/ScreenGui.md)
- GuiService.TopbarInset gives unobstructed top-bar area; DevForum reports new top bar differs in size/position on mobile vs PC (community advice, not official). — [DevForum](https://devforum.roblox.com/t/inconsistent-top-bar/3228098)
- UIScale multiplies parent size and children (tween for hover effects); UIAspectRatioConstraint enforces ratio, overrides UIListLayout size; UISizeConstraint sets min/max. — [Size modifiers](https://create.roblox.com/docs/en-us/ui/size-modifiers)

### Inferences
- Keep important buttons inside CoreUISafeInsets, use scale-based sizing plus aspect-ratio and size constraints, and test on phone emulators.

### Gaps
- No official minimum touch-target size or console/gamepad UI guidance found.

## Juice (animation, sound, particles) and free tools

### Takeaway
Tween-driven feedback paired with sound/particles is the standard; reserve bouncy easing for key moments. Libraries: Fusion, React-lua, Roact.

### Cited Findings
- Tween Completed event used to chain shake/burst/reveal; Sine/Quad for natural motion, Bounce/Elastic for playful, but overuse distracts; pair tweens with sounds/particles. — [skill guide](https://skillselion.com/skills/nonlooped/roblox-suite/roblox-animation) (low-authority)
- Fusion: reactive UI library for Roblox/Luau; React-lua: Roblox-maintained Luau port of React 17.x, install via Wally; Roact: older React-inspired; Luix VS Code extension supports React-Luau, Roact, Fusion, Vide; Quark: small MIT reactive UI lib. — [Fusion](https://cdn.jsdelivr.net/npm/@rbxts/fusion@0.2.0/README.md); [DevForum React+Roblox](https://devforum.roblox.com/t/how-to-react-roblox/2964543); [Luix](https://github.com/ericplane/Luix)
- Free Figma template with Roblox UI components/device frames exists. — [creation.dev UI kits](https://www.creation.dev/tools/ui-kits)

### Inferences
- For a small team, plain Instances + UIScale/tweens is lowest risk; Fusion/React-lua pay off for dynamic shop/inventory lists.

### Gaps
- No source on recommended fonts (commonly used Roblox fonts like GothamBold/FredokaOne not verified here), and no free Studio UI kit verified.
