# Closure sweep over the 58 published places — S14

**Complete. All 58 checked.** This is the sweep `DP-10` asked for and `BL-44`/`BL-48` recommended:
the published places are the only ones a visitor can reach, and nobody had ever verified they still
exist.

Scope: `docs/research/facets-58-batch.csv`, frozen and checksummed (`5e13fc48…`), derived offline as
`(starred OR tier = destination) AND no conflict` and reconciled three ways against STATUS.

## Result

| | |
|---|---|
| Checked | **58** |
| Open | **54** |
| **Closed** | **3** |
| Uncertain | **1** |

**~5% closed, against 9% in the unreviewed set.** Lower, which makes sense — the published 58 are the
top of the guide. But three of them are restaurants a visitor can click today.

### The three closures

| id | Place | When | Evidence |
|---|---|---|---|
| `025` | **Gina's on Congress** | ~Apr 2026 | Yelp CLOSED; **`published` and `starred`** |
| `057` | **Vince Young Steakhouse** | 24 Jan 2026 | KVUE, KXAN, CBS Austin. Closed after 15 years |
| `009` | **Chez L'Amour** (St. Augustine) | — | The city's own tourism site titles the page "Permanently Closed" |

### The one in doubt

- **`020 Fabrik`** — Yelp reports **"Temporarily Closed"**. Michelin-recommended, 16 seats, a
  seven-course plant-based tasting menu that changes each season. Temporary and permanent look
  identical from outside for a restaurant this small. Worth a direct check rather than a guess.

## `DP-10` is answered

**Gina's on Congress is closed.** The S10 research batch had found three independent closure signals
against one counter-signal — the restaurant's own site, still live with hours. The site won at the
time and the question was left open for Michael. It should not have been: the site outlived the
restaurant by months.

The wider point `DP-10` made still stands and is now measured: 511 places came from map albums
collected over years, and it was never plausible that Gina's was the only one. It was not.

## What the sweep taught, beyond the three names

**Address discipline saved a fourth false positive.** `049 Sway` looks closed from a name search —
two of the brand's locations are marked CLOSED on Yelp, on S 1st St and at the Domain. **Ours is
Bee Caves Road in West Lake Hills, which is open.** That is the third time in this project that a
two-location brand nearly produced a wrong closure, after Café Blue and Dos Olivos.

**A successor is still the strongest signal.** Neighborhood Sushi is moving into 1417 S First — the
address where Sway is marked closed. A different business taking a space settles what contradictory
listings cannot.

**`022 Franklin Barbecue` closes every August for ten days** so the crew can take a holiday. A sweep
run in the wrong week, reading only hours, would have flagged it.

## Data defect found while sweeping

**`055 Vaudeville` has `city = Austin` and an address in Fredericksburg** (230 E Main St). The city
column drives the public guide's city gate, so this record would appear under Austin for a visitor
and is 80 miles away. Recorded in `BL-47` with the other address defects.

## What this is not

The sweep produces **no tags and no writes.** A `status = 'closed'` is a statement about a real
business, and three of them at once changes what the guide claims — that decision is the curator's,
and it is `BL-44`.
