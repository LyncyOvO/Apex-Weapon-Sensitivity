# Parameter provenance

Access/reference date: 2026-10-26. This is a **controlled historical-reference scenario**, not a fully audited season snapshot.

| Field | Reference | Status |
|---|---|---|
| R-301 13→14; Flatline 18→19; CAR 13→14 body damage | EA Takeover patch notes | Official patch change; other inputs held fixed |
| Baseline mags R-301 21, Flatline 19, CAR 19 | EA Shockwave patch notes | Earlier values carried forward; intervening updates not exhaustively audited |
| RPM 810 / 600 / 930 | Later Tracker Nation weapon pages | Historical applicability assumed, not verified |
| Gap 3.2 / 3.1 / 2.13 seconds | Later Tracker Nation empty reload reports | Proxy for last-shot-to-next-mag-first-shot gap; not measured |
| Magazine +2, gap −0.2 | Analyst-defined intervention | Hypothetical, not claimed actual patch changes |

Primary patch sources:
- https://www.ea.com/games/apex-legends/apex-legends/news/takeover-patch-notes
- https://www.ea.com/games/apex-legends/apex-legends/news/shockwave-patch-notes

Timing/RPM reference pages:
- https://tracker-nation.com/en/apex/waffen/r-301-carbine
- https://tracker-nation.com/en/apex/waffen/vk-47-flatline
- https://tracker-nation.com/en/apex/waffen/c-a-r-smg

Detailed earlier audit is retained in data/source_audit.csv for these three weapons. It includes attachment tiers not used by this final analysis; only data/weapons.csv controls the calculations. Do not use a later page's current damage or magazine as if it were an S24 value. Website ratings are documented separately and are not used as parameter sources.
