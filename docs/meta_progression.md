# Meta Progression System Design

## Overview

The meta progression system provides permanent upgrades and unlocks that persist between runs,
enhancing the roguelike experience with a sense of long-term progression.

## Design Goals

1. **Meaningful Progression**: Each run contributes to permanent growth
2. **Balanced Unlocks**: Rewards skillful play without trivializing content
3. **Player Agency**: Multiple upgrade paths to suit different playstyles
4. **Clear Feedback**: Visual indicators for unlocks and upgrades

---

## 1. Unlock Points System

### Earning Points

| Achievement | Points |
|-------------|--------|
| Win a run | +1 |
| Win without dying | +1 bonus |
| Win on Hard Mode | +2 |
| First win ever | +3 bonus |

### Current Implementation

Points are awarded in `scenes/victory.lua` and stored in `progress.unlock_points`.

---

## 2. Permanent Upgrades

### 2.1 Starting Stats

| Upgrade | Max Level | Cost per Level | Effect |
|---------|-----------|----------------|--------|
| HP Boost | 5 | 1/2/3/4/5 | +2 HP per level |
| Gold Boost | 5 | 1/1/2/2/3 | +10 starting gold |
| Blood Boost | 3 | 2/3/4 | +1 starting blood |

### 2.2 Starting Deck

| Upgrade | Max Level | Cost | Effect |
|---------|-----------|------|--------|
| Better Squirrel | 1 | 3 | Squirrels have +1 HP |
| Starting Rare | 1 | 5 | Begin with 1 random rare card |

### 2.3 Economy

| Upgrade | Max Level | Cost | Effect |
|---------|-----------|------|--------|
| Gold Bonus | 5 | 1/2/2/3/3 | +10% gold from all sources |

---

## 3. Card Unlock System

### Unlock Conditions

| Card ID | Unlock Condition |
|---------|------------------|
| guardian_dog | Win 1 run |
| hydra | Win 3 runs |
| deathcard | Win 5 runs |
| (future cards) | Various achievements |

### Unlock Pool

Unlocked cards are added to the available card pool for rewards and shops.
They do NOT automatically appear in the starting deck.

---

## 4. Data Structure

### Save Data Extension

```lua
progress = {
    -- Currency
    unlock_points = 0,
    total_exp = 0,
    level = 1,

    -- Statistics
    total_runs = 0,
    wins = 0,
    best_win_streak = 0,
    current_streak = 0,

    -- Upgrades (key = upgrade_id, value = level)
    upgrades = {
        hp_boost = 0,
        gold_boost = 0,
        blood_boost = 0,
        better_squirrel = false,
        starting_rare = false,
        gold_bonus = 0,
    },

    -- Unlocks (list of unlocked content IDs)
    unlocked_cards = {},
    unlocked_sigils = {},
    unlocked_features = {},
}
```

---

## 5. Integration Points

### 5.1 Game Start (menu.lua)

```lua
-- Apply meta progression bonuses
local MetaProgression = require("systems.meta_progression")
MetaProgression.apply_starting_bonuses()
```

### 5.2 Victory (victory.lua)

```lua
-- Process run completion
MetaProgression.process_victory(run_stats)
```

### 5.3 Combat Init (combat.lua)

```lua
-- Use modified starting values
local hp = Settings.player_max_hp + MetaProgression.get_bonus("hp_boost")
```

---

## 6. UI Considerations

### Progression Hub (Future)

A dedicated scene for viewing and spending unlock points:

- Current points display
- Upgrade purchase interface
- Card collection viewer
- Achievement progress

### Victory Screen Enhancements

- Show earned points
- Display new unlocks
- Level up animation

---

## 7. Balance Guidelines

### Power Curve

- Level 0 player: Base game difficulty
- Fully upgraded: ~20% easier start, still challenging
- Hard Mode: For players seeking challenge

### Time to Unlock

- First new card: 1 win (~30 min)
- All cards: ~15-20 wins
- All upgrades: ~25-30 wins

---

## 8. Future Expansion

### Planned Features

1. **Character Classes**: Unlock alternative starting decks
2. **Sigil Unlocks**: Permanent sigil upgrades
3. **Challenge Modes**: Unlockable difficulty modifiers
4. **Cosmetics**: Card backs, UI themes

### Achievement System

- Speedrun achievements
- No-damage runs
- Specific card combos
- Challenge completions