# Roblox Monetization and Retention Mechanics (2025-2026)

Method note: the search tool returned summaries; direct page fetches of create.roblox.com failed (DNS), so Creator Docs claims come via search summaries, not full-page reads. Treat figures marked UNVERIFIED as needing a check against the primary page.

## Which monetization patterns are most effective, and which are risky under Roblox policy?

### Takeaway
Core Robux tools are game passes (one-time), developer products (repeatable), and paid private servers, all with a 30% platform cut. Paid random items (eggs, wheels, luck boosts) are the main policy-risk area: exact odds must be disclosed, and some regions (Brazil) bar under-18s. No reliable public conversion-rate benchmarks were found.

### Cited Findings
- Platform takes 30% of game passes, developer products and private server subscriptions (creator keeps 70%); passes are permanent one-time buys, developer products repeatable; a blog claims products often out-earn passes in simulator/tycoon games (secondary, unverified) — [obby.fun](https://www.obby.fun/blog/how-to-make-money-on-roblox)
- Private servers are a monthly Robux fee set by the creator; common range cited 10-200 Robux — [obby.fun](https://www.obby.fun/blog/how-to-make-money-on-roblox)
- Roblox Plus: $4.99/month player subscription giving 10% off eligible Robux purchases (20% from month 3), subsidized by Roblox so creators earn the same per purchase. Creators earn 250 Robux/month for the first three consecutive months per newly acquired subscriber (up to 750 Robux), with a 60-day hold; subscribers get free paid private servers and creators are paid for time spent in them — [Roblox Plus docs](https://create.roblox.com/docs/production/monetization/roblox-plus), [DevForum announcement](https://devforum.roblox.com/t/introducing-roblox-plus/4567894/1)
- Paid random items policy: covers capsule items (wheels, eggs, chests), enhancement/combination items, and probability modifiers (luck boosts, pity). Must show every outcome with numeric odds as percentages summing to 100%; long lists may sit behind a clickable pop-up labelled with a descriptive word (a bare (i) icon is insufficient); applies to direct and indirect Robux purchases — [Paid random items docs](https://create.roblox.com/docs/production/monetization/paid-random-items)
- TechTimes (June 2026, secondary) reports Roblox revised the policy to comply with South Korea's game law, applied worldwide, including indirect purchases (keys/tickets) and tooling to block or swap random items for guaranteed purchases where local rules require — [TechTimes](https://www.techtimes.com/articles/319148/20260626/koreas-loot-box-rules-push-roblox-disclose-item-odds-worldwide.htm)
- Brazil: users under 18 cannot access paid random item mechanics; creators must use PolicyService API, otherwise the experience is unplayable for under-18s in Brazil — [Roblox Brazil Digital ECA update](https://en.help.roblox.com/hc/cs/articles/48706630819476-Brazil-Digital-ECA-Updates)
- Rewarded Video ads: launched April 2025 with Google (opt-in full-screen up to 30s for in-game perks, bought via Google Ad Manager) — [Roblox newsroom](https://corp.roblox.com/newsroom/2025/04/roblox-scales-video-ads-partners-with-google); self-serve in Aug 2025 for experiences with avg 100K+ DAU (28 days), minimal/mild maturity, good standing, with expansion planned — [DevForum](https://devforum.roblox.com/t/more-creators-can-now-use-rewarded-video-ads/3838678); a Studio drag-and-drop plug-in reportedly planned for Q4 2026 — [MediaPost](https://www.mediapost.com/publications/article/417959/)
- Steal a Brainrot: Bloomberg estimate cited at over $64M real-money purchases since launch (secondhand) — [Wikipedia](https://en.wikipedia.org/wiki/Steal_a_Brainrot)
- Q2 2026: revenue +36% to $1.5B but bookings only +8% to $1.6B, attributed to lower per-hour monetization among younger US/Canada users; Q3 bookings guided to $1.58-1.65B — [Roblox Q2 2026 8-K](https://www.sec.gov/Archives/edgar/data/0001315098/000162828026051059/ex991-robloxq22026earnin.htm) (figures via search summary; one aggregator's $2.2B/152M DAU conflicts and appears wrong)

### Inferences
- Randomized-reward mechanics common in top pet/collector games now carry compliance cost (odds UI, regional gating); a safe design offers guaranteed alternatives and pity/odds displays.
- Platform bookings softness suggests monetization-per-hour is under pressure; durable subscriptions/private servers and ads diversify revenue.

### Gaps
- No credible visitor-to-buyer or payer conversion benchmarks found.
- Not confirmed: a third-party claim that cross-experience pass/product sales were disabled May 30, 2026.
- Limited-time offers, gifting and Immersive Ads specifics (rates, creator payout) not found in sources.
- Exact under-13/age-based rules for paid random items beyond Brazil not found.

## Creator payout / DevEx rates and 2025-2026 changes

### Takeaway
DevEx reportedly rose to $0.0038 per earned Robux for Robux earned from Sept 5, 2025 (from $0.0035), per third-party sites only. Engagement-Based Payouts were replaced by Creator Rewards in July 2025.

### Cited Findings
- DevEx $0.0038/earned Robux from Sept 5, 2025 (earlier Robux at $0.0035); 30,000 earned-Robux minimum; only earned Robux count — [bloxodes](https://bloxodes.com/tools/roblox-devex-calculator), [levvvel](https://levvvel.com/gaming-tools/devex-calculator/) (third-party; official page not read; sources conflict on Premium requirement and one lists $0.0025/$0.0035 — [ultimatefinancecalculator](https://www.ultimatefinancecalculator.com/calculators/roblox-developer-earnings-calculator))
- Engagement-Based Payouts deprecated July 24, 2025, replaced by Creator Rewards — [EBP docs](https://create.roblox.com/docs/en-us/production/monetization/engagement-based-payouts.md)
- Creator Rewards: 5 Robux per Active Spender spending 10+ minutes in an experience in a day (among their first three launched that day), plus an audience expansion reward; uncapped; stated intent that creators in aggregate earn more than under EBP — [DevForum](https://devforum.roblox.com/t/introducing-creator-rewards-earn-more-by-growing-the-community/3777628)
- Creators complain about a 60-day hold on payouts — [DevForum thread](https://devforum.roblox.com/t/shorten-the-hold-period-of-engagement-payouts-or-restore-the-old-premium-payouts-system/3956591) (user feedback)
- DevEx payouts about $1.5B in 2025 (RoLearn analysis); another outlet cites roughly $1.7B and +50% YoY (period unclear) — [RoLearn](https://rolearn.dev/insights/developer-payouts-billion-dollar-economy), [SAYS](https://says.com/my/tech/roblox-creators-earn-1-7-billion-developer-payouts)

### Inferences
- At $0.0038, 70% of $1 of Robux spend is not equal to $0.70; gross-to-cash is roughly: 1 Robux sale yields 0.7 earned Robux, about $0.0027 cash (calculation, depends on the rate being correct).

### Gaps
- Official DevEx page not verified. Claims that 73% of developers earned more under Creator Rewards (Substack) and Premium share of revenue (~10%) are unverified.

## Retention benchmarks and drivers

### Takeaway
Roblox does not publish numeric "good" D1/D7 targets; it gives per-experience benchmark scorecards against similar games (100+ DAU) and says to reach benchmark D1 and session time before scaling UA.

### Cited Findings
- Benchmarks update daily, are not a discovery ranking signal; low D7 often indicates weak progression — [Analytics docs](https://create.roblox.com/docs/production/analytics), [analytics essentials](https://create.roblox.com/docs/production/game-design/analytics-essentials)
- Retention can be viewed by acquisition source with selectable benchmark set — [DevForum](https://devforum.roblox.com/t/analytics-view-retention-by-acquisition-source-and-select-your-benchmark-set/4010157)
- Third-party claim: 40% D1 is exceptional for roleplay but mediocre for obbies (illustrative only) — [Rowatcher](https://rowatcher.com/news/the-roblox-analytics-stack-how-studios-win-with-data-in-2026)

### Inferences
- Benchmark by genre rather than citing universal numbers.

### Gaps
- No official numeric D1/D7 figures found; no source for daily-reward/streak impact.

## Events, update cadence and live-ops in top games

### Takeaway
Top games run near-continuous event calendars; Grow a Garden sustained a long tail while Steal a Brainrot's trend-driven peaks decayed fast. Grow a Garden shifted from weekly events toward depth in Aug 2025.

### Cited Findings
- Jandel (Aug 2025) said weekly events were hard to keep fresh and shifted focus to farm depth ("Method Era") — [NME](https://www.nme.com/news/gaming-news/roblox-grow-a-garden-major-changes-coming-update-cooking-3884432)
- Event calendars of week-long drops with shorter slots; Mega Harvest drew 7M+ RSVPs; Summer event July 2026 (listing sites with inconsistent dates) — [AllThingsHow](https://allthings.how/grow-a-garden-events-schedule/)
- Steal a Brainrot CCU reportedly fell ~80% within two weeks of peak; Grow a Garden held audience for months; GaG peak reported 21.9-22.4M, SaB peak 25.2-25.8M (sources conflict) — [Rowatcher](https://rowatcher.com/news/is-the-brainrot-trend-dying-what-ccu-data-from-three-top-games-reveals), [RoLearn](https://rolearn.dev/insights/grow-a-garden-ccu-record-analysis)
- GaG loop: plant, grow, collect pets, return tomorrow; short mobile sessions credited — [Rowatcher March 2026](https://rowatcher.com/news/the-10-fastest-growing-roblox-games-in-march-2026)

### Inferences
- Evergreen loop plus collectibles outlasts meme-driven games; event fatigue is a real risk.

### Gaps
- No developer postmortems or primary data on daily rewards, streaks, trading, leaderboards, or RDC live-ops talks were found.
