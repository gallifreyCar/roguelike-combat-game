# Blood Cards - Auto-Battler Roguelike

A deck-building auto-battler game built with **LÖVE (Love2D)** and **Lua**.

## Features

- 🎴 **Card Placement**: Drag cards to a 4-slot board
- ⚔️ **Auto-Battle**: Cards attack automatically each turn
- 💀 **Sacrifice Mechanic**: Right-click your cards to gain Blood resource
- 👻 **Card Death**: Cards have HP and can die in battle
- 🤖 **Enemy AI**: Enemy places cards and attacks automatically

## Quick Start

### Prerequisites

- [LÖVE 11.5+](https://love2d.org/)

### Run

```bash
# macOS
/Applications/love.app/Contents/MacOS/love .

# Linux
love .

# Windows
love.exe .
```

## How to Play

### Blood Economy
- You start with 1 Blood each turn
- Blood resets to 1 at the start of each turn (max: 6)
- Right-click your cards on board to **sacrifice** for +1 Blood

### Card Placement
1. **Drag** cards from right panel to empty slots
2. Cards with **cost** require Blood
3. Click **BATTLE** button to start combat

### Battle
- Cards attack automatically in lanes
- If enemy card in same lane → attack that card
- If lane empty → attack enemy directly

### Win Condition
- Reduce enemy HP to 0 to win!

## Cards

| Card | Cost | Attack | HP | Notes |
|------|------|--------|-----|-------|
| Squirrel | 0 | 0 | 1 | Free, good for sacrifice |
| Stoat | 1 | 1 | 2 | Basic attacker |
| Wolf | 2 | 2 | 2 | Balanced fighter |
| Bullfrog | 1 | 1 | 4 | Tanky |
| Raven | 2 | 2 | 3 | Air support |
| Grizzly | 3 | 4 | 6 | Heavy hitter |

## Controls

| Input | Action |
|-------|--------|
| Left-click + drag | Place card |
| Right-click card | Sacrifice for Blood |
| Click BATTLE | Start combat |
| SPACE | Start battle |

## Project Structure

```
roguelike-game/
├── main.lua          # Entry point
├── conf.lua          # LÖVE configuration
├── core/
│   ├── state.lua     # State machine
│   └── input.lua     # Input handling
├── scenes/
│   ├── menu.lua      # Main menu
│   ├── combat.lua    # Battle scene
│   ├── victory.lua   # Victory screen
│   └── death.lua     # Death screen
├── systems/
│   └── enemy.lua     # Enemy AI
└── data/
    └── cards.lua     # Card definitions
```

## Roadmap

- [x] Auto-battle system
- [x] Card placement on board
- [x] Sacrifice/Blood mechanic
- [x] Drag and drop UI
- [ ] More cards and abilities
- [ ] Roguelike map progression
- [ ] Boss battles
- [ ] Art and animations
- [ ] Sound effects

## License

MIT

---

*This is a hobby project for learning game development with LÖVE framework.*