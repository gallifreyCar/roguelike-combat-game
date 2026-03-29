# Card Sacrifice - Auto-Battler Roguelike

A deck-building auto-battler game inspired by **Inscryption**, built with **LÖVE (Love2D)** and **Lua**.

## Features

- 🎴 **Card Placement**: Place cards on a 4-slot board
- ⚔️ **Auto-Battle**: Cards attack automatically each turn
- 💀 **Sacrifice Mechanic**: Kill your own cards to gain Blood resource
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

### Phase 1: Card Placement
1. **Select a card** from your hand using `Q/W/E/R/T`
2. **Place on board** using `1-4` (slot number)
3. Cards with **cost** require **Blood** resource
4. **Sacrifice** your placed cards to gain Blood (when they die = +1 Blood)

### Phase 2: Battle
5. Press `SPACE` to start the battle phase
6. Cards **attack automatically**:
   - If enemy card in same lane → attack that card
   - If lane is empty → attack enemy directly

### Win Condition
- Reduce enemy HP to 0 to win!

## Controls

| Key | Action |
|-----|--------|
| `Q/W/E/R/T` | Select card from hand |
| `1-4` | Place card on slot |
| `SPACE` | Start battle / Confirm |
| `R` | Restart (after game over) |
| `ESC` | Quit |

## Cards

| Card | Cost | Attack | HP | Special |
|------|------|--------|-----|---------|
| Squirrel | 0 | 0 | 1 | Free to place |
| Stoat | 1 | 1 | 2 | Basic card |
| Wolf | 2 | 2 | 2 | Balanced |
| Bullfrog | 1 | 1 | 4 | Tanky |
| Raven | 2 | 2 | 3 | Air Strike |
| Grizzly | 3 | 4 | 6 | Heavy hitter |

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
- [x] Enemy AI
- [ ] More cards and sigils
- [ ] Roguelike progression
- [ ] Boss battles
- [ ] Art and animations
- [ ] Sound effects

## Inspiration

- [Inscryption](https://www.inscryption.com/) - Core mechanics
- [Slay the Spire](https://www.megacrit.com/) - Roguelike structure

## License

MIT