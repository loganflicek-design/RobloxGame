# Roblox Platform Discovery, Policy, and Technical Best Practices (2025-2026)

Method note: WebFetch could not reach any roblox.com host (DNS failure), so all findings below come from WebSearch result summaries, not full-page reads. Primary Roblox URLs are cited where the search surfaced them, but exact wording should be verified. Research depth was limited (about 11 tool calls).

## What signals drive Roblox recommendations, and what should a new game optimize in the first weeks?

### Takeaway
Roblox's "Recommended For You" (Home) retrieves a candidate set per user and ranks it on engagement, retention, monetization, friend plays, similarity and variety. In 2026 Roblox shifted the optimization target to longer-term retention (28-day view), away from short-term monetization. New games are tested on small audiences first, so early-cohort quality (day-1 retention, session time, return frequency) matters most.

### Cited Findings
- Recommended For You works in two stages: it selects a subset of experiences per user, then ranks them on six signals (engagement, retention, monetization, friend plays, similar experiences, variety). Home is where most users find experiences. — [Roblox Creator Docs: Discovery](https://create.roblox.com/docs/discovery) (via search summary)
- Roblox tests new experiences on small audiences; if that cohort shows good engagement and monetization, it recommends to more similar users. A spike in new users can follow a content update. — [Creator Docs: Discovery](https://create.roblox.com/docs/discovery)
- Roblox advises getting session time and day-1 retention comparable to or above similar-experience benchmarks. Benchmarks require 100+ DAU and are not a direct algorithm signal. — [Creator Docs: Analytics](https://create.roblox.com/docs/production/analytics)
- 2025 roadmap (March 2025): improved "Recommended For You" optimizing for long-term retention, deprioritizing low-quality content (e.g., misleading titles/thumbnails or guideline violations), creator analytics explaining recommendations, friend referral system, blended search across games/avatars/people. — [Tubefilter](https://www.tubefilter.com/2025/03/20/roblox-discovery-roadmap-2025/); [VentureBeat](https://venturebeat.com/business/roblox-wants-to-improve-discovery-for-its-game-creators)
- June 2026: Roblox moved the algorithm from a 7-day view to a 28-day view measuring long-term retention. — [Roblox newsroom, June 2026](https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox)
- Q2 2026 earnings call: management said the change reduced impressions for games emphasizing short-term monetization over long-term retention and showed a positive lift in stickier-engagement games. — [Q2 2026 transcript](https://s27.q4cdn.com/984876518/files/doc_financials/2026/q2/32789865_2009724400_3775763_Transcript_EditedCopy_20260730233208.pdf)
- GameAnalytics 2025 report: the biggest 2025 shift is return frequency rather than longer sessions. — [GameAnalytics](https://www.gameanalytics.com/cn/reports/2025-roblox-report)
- Ads help the recommendation algorithm learn which users engage with your content. — [Creator Docs: Discovery](https://create.roblox.com/docs/discovery)
- Ads Manager: payment by card (18+) or Robux converted to ad credit (13+); automated bidding by budget and duration; campaigns need several days; if no progress in 3-5 days, improve onboarding/FTUE first. — [Ads Manager docs](https://create.roblox.com/docs/production/promotion/ads-manager)
- January 2026: paid "Homepage Feature" ad format for brands and creators. — [Tubefilter](https://www.tubefilter.com/2026/01/08/roblox-homepage-feature-ads-sams-club-ces/)
- Brand-integration fees move to CPM ($1.50 per thousand US visitors, $0.05 rest of world) starting 2027-01-01; this is not standard Sponsored ads. — [GameDev.net](https://gamedev.net/news/roblox-details-how-much-creators-will-pay-for-brand-integrations-r4028/)

### Inferences
- Optimize day-1 and repeat-visit (D7/D28) retention and return frequency (daily rewards, events, updates) over aggressive early monetization, since the 2026 change penalizes short-term monetization-focused games.
- Honest title/thumbnail/icon matter, as misleading ones are explicitly deprioritized.
- Spend small ad budgets only after the first-time user experience is solid, and use ads to seed the algorithm with the right audience.
- Content updates and events may re-trigger exploration bursts, so schedule updates deliberately.

### Gaps
- Exact ranking weights, the like/favorite ratio's role, and sort-specific (Discover sorts) logic were not found. The 2026 newsroom text itself could not be read; details are from a search summary.
- Influencer partnerships, social links, groups, and codes: no sources found in this pass.
- The godisageek article on a "$9B market cap drop" was a secondary blog and not used as fact.

## What are the most important 2025-2026 policy/safety changes a new developer must know?

### Takeaway
Age checks (facial estimation or ID) are now required globally for chat (January 2026) with age-banded chat. Every experience needs a content maturity label via questionnaire, since unrated games are restricted. Paid random items require full odds disclosure.

### Cited Findings
- Age checks required for chat: started December 2025 in Australia, New Zealand and Netherlands, then global in January 2026. Done via device camera (vendor Persona; images deleted after processing); ID verification optional for 13+. — [Roblox newsroom](https://about.roblox.com/newsroom/2026/01/roblox-age-checks-required-to-chat); [BusinessWire](https://secure.businesswire.com/news/home/20260107986568/en/Roblox-Requires-Users-Worldwide-to-Age-Check-to-Access-Chat)
- Age bands: under 9, 9-12, 13-15, 16-17, 18-20, 21+; bands limit who users can message; under-9 need parental consent for chat. Re-checks planned for users who look much older or younger than their stated age. — same sources
- Experts note age estimation is less reliable at age-range extremes. — [Gulf News](https://gulfnews.com/technology/media/roblox-now-requires-age-checks-for-all-users-to-access-chat-worldwide-1.500401325)
- Content maturity has labels (Minimal, Mild, Moderate, Restricted) plus content descriptors. Minimal/Mild reach Roblox Kids (5-8) and Select (9-15); Moderate reaches Select and standard (16+); Restricted is age-verified 18+ only. Without a label the game is restricted for all players; inaccurate information can lead to moderation. Violent/romantic content may be moderated regardless of label. — [Content maturity docs](https://create.roblox.com/docs/en-us/production/promotion/content-maturity)
- August 2025: "Sensitive Issues" descriptor (reportedly unavailable to under-13s); unrated experiences restricted to the developer and active collaborators. Policy on romantic/sexual content extended. — [Roblox newsroom Aug 2025](https://about.roblox.com/newsroom/2025/08/extending-roblox-policy-on-romantic-and-sexual-content)
- Paid random items (egg hatching, wheels, chests, luck boosts, pity systems, items bought with paid in-game currency) must list every outcome with numeric odds as percentages totaling 100%, with a descriptively labeled pop-up if long. — [Paid random items docs](https://create.roblox.com/docs/en-us/production/monetization/paid-random-items)
- June 2026 report: policy revised for South Korea's game law, with worldwide odds disclosure and a tool to block or replace random-item sales per region (secondary source). — [TechTimes](https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm)
- DevEx cash-out requires tax forms and may require government ID (low-quality sources). — [ConductAtlas](https://conductatlas.com/platform/roblox/roblox-privacy-and-cookie-policy/developer-exchange-program-identity-verification-and-tax-documentation/)

### Inferences
- Solo devs should complete the maturity questionnaire before launch and design for a mixed-age audience, with in-game social features that degrade gracefully if chat is gated.
- Avoid loot-box mechanics, or implement odds UI from day one.

### Gaps
- Official developer-side ID verification requirements for publishing, Kids/Select extra publishing requirements, and moderation-escalation rules were not found.
- Exact enforcement dates of the unrated-game restriction not confirmed.

## What is the recommended tech stack/workflow for a small team?

### Takeaway
Rojo + git, with Rokit (or Aftman) pinning tool versions, Wally for packages, Selene and StyLua for lint/format, and ProfileStore for player data. Studio's Assistant and built-in MCP server can accelerate work, but evidence here is thin.

### Cited Findings
- Rojo syncs a filesystem project to Studio, enabling git workflows; Selene lints Luau; Wally is the community package manager; StyLua formats; a tool manager pins versions and its config should be committed. — [oflight 2026 toolchain guide](https://www.oflight.co.jp/ja/columns/luau-developer-toolchain-rojo-selene-wally-2026) (third-party); [tooling ecosystem reference](https://mintlify.wiki/brockmartin/roblox-game-skill/reference/tooling-ecosystem) (third-party)
- ProfileStore (by loleris) provides session locking so other servers don't load stale data, one table per player profile saved on auto-save or session end, Async-suffixed yielding methods; not meant for leaderboards/global state or rapid multi-server writes. — [DevForum ProfileStore](https://devforum.roblox.com/t/profilestore/3190543); [GitHub mirror](https://github.com/ISFOR1/ProfileStore). Successor to [ProfileService](https://github.com/MadStudioRoblox/ProfileService).
- Third-party guide flags UpdateAsync with session lock and BindToClose as common traps. — [skills.sh gamedev-roblox](https://www.skills.sh/vasilyu1983/ai-agents-public/gamedev-roblox) (weak source)
- Studio can act as an MCP server (enabled from Assistant settings) letting external agents read the data model, edit instances, run scripts/tests; Assistant can connect to external LLMs (Feb 2026 report). Cube 4D generation in beta (Feb 2026). — [Roblox newsroom Feb 2026](https://about.roblox.com/newsroom/2026/02/accelerating-creation-powered-roblox-cube-foundation-model); [AI workflows docs](https://create.roblox.com/docs/vi-vn/ai/accelerated-workflows)
- Community MCP servers exist (unofficial). — [Glama listing](https://glama.ai/mcp/servers/hope1026/roblox-mcp)

### Inferences
- A reasonable stack: git + Rojo + Rokit-pinned tools + Wally + Selene + StyLua + ProfileStore, with CI running selene/stylua checks. Knit is not evidenced here; plain module/service patterns are a safe default.

### Gaps
- Rokit specifics, current versions, Knit alternatives, Open Cloud usage (publishing, DataStore API), and low-end mobile performance guidance: no reliable sources found. Verify on each repo and Creator Docs.

## Common pitfalls that sink new Roblox games

### Takeaway
Little reliable evidence was found. Only data-handling traps are sourced.

### Cited Findings
- Data: session locking and save-on-shutdown are common failure points; ProfileStore is designed to address them. — [DevForum ProfileStore](https://devforum.roblox.com/t/profilestore/3190543); [skills.sh](https://www.skills.sh/vasilyu1983/ai-agents-public/gamedev-roblox)
- Misleading titles/thumbnails are deprioritized by discovery. — [Tubefilter](https://www.tubefilter.com/2025/03/20/roblox-discovery-roadmap-2025/)
- Weak onboarding wastes ad spend. — [Ads Manager docs](https://create.roblox.com/docs/production/promotion/ads-manager)

### Inferences
- Server-authoritative validation of remotes is the standard anti-exploit principle (general knowledge, unsourced here).

### Gaps
- Exploits/anti-cheat, low-end mobile performance, and postmortems: my search returned only spam pages. Needs DevForum/Creator Docs follow-up.
