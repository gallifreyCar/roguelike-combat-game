# Blood Cards 🃏

A deck-building roguelike auto-battler game built with **LÖVE (Love2D)** and **Lua**.

**[中文](./docs/README_CN.md)** | **[日本語](./docs/README_JA.md)** | **[한국어](./docs/README_KO.md)**

---

## Features

- 🎴 **Card Placement**: Drag cards to a 4-slot board
- ⚔️ **Auto-Battle**: Cards attack automatically each turn
- 💀 **Sacrifice Mechanic**: Right-click cards to gain Blood resource
- 🎯 **Sigil System**: 13 unique card abilities
- 🔮 **Fusion System**: Combine cards with dice-roll risk
- 🗺️ **Roguelike Map**: Branching paths with different node types
- 🏆 **Achievement System**: 9 achievements to unlock
- 💾 **Save System**: Progress auto-save
- 🌐 **Multi-language**: EN/CN/JP/KR

## Quick Start

```bash
# Install LÖVE 11.5+
# macOS
brew install love

# Run the game
love .
```

## How to Play

1. **Blood Economy**: Start with 1 Blood, +1 per turn (max: 6)
2. **Card Placement**: Drag cards from hand to board slots
3. **Sacrifice**: Right-click cards for +1 Blood
4. **Battle**: Click BATTLE button to auto-fight
5. **Win**: Reduce enemy HP to 0

## Cards (18 Total)

| Card | Cost | ATK | HP | Ability |
|------|------|-----|-----|---------|
| Squirrel | 0 | 0 | 1 | Free sacrifice material |
| Stoat | 1 | 1 | 2 | Basic attacker |
| Wolf | 2 | 2 | 2 | Balanced fighter |
| Bullfrog | 1 | 1 | 4 | Tank with Tough sigil |
| Adder | 2 | 1 | 2 | Poison attacker |
| Raven | 2 | 2 | 3 | Flying (Air Strike) |
| Grizzly | 3 | 4 | 6 | Heavy hitter |
| Mantis | 3 | 3 | 2 | Double Strike |
| Cat | 2 | 1 | 1 | Undead (revives once) |
| Hydra | 5 | 3 | 4 | Splits on death |

## Map Nodes

| Node | Description |
|------|-------------|
| [!] Battle | Fight enemies |
| [E] Elite | Tougher battle, better rewards |
| [+] Reward | Choose a new card |
| [F] Fusion | Combine cards |
| [$] Shop | View deck |
| [?] Event | Random encounter |
| [BOSS] | Final battle |

## Fusion System

### Same-Card Fusion
- Fuse 2 identical cards for guaranteed upgrade
- +1 ATK, +2 HP, chance for new sigil

### Dice Fusion
- Fuse 2 different cards with risk/reward
- Success rate varies (30%-90%)
- Creates powerful combo cards:
  - **Poison Wolf**: Adder + Wolf
  - **Sky Hunter**: Raven + Wolf
  - **Legendary Beast**: Grizzly + Eagle

## Controls

| Key | Action |
|-----|--------|
| Left-click + drag | Place card |
| Right-click | Sacrifice card |
| Space | Start battle |
| ESC | Back / Menu |
| Tab | Switch mode |

## Project Structure

```
roguelike-game/
├── main.lua          # Entry point
├── scenes/           # Game scenes
│   ├── menu.lua      # Main menu
│   ├── map.lua       # Map selection
│   ├── combat.lua    # Battle scene
│   ├── reward.lua    # Card reward
│   ├── fusion.lua    # Card fusion
│   ├── shop.lua      # Deck viewer
│   └── settings.lua  # Settings
├── systems/          # Game systems
│   ├── deck.lua      # Deck management
│   ├── fusion.lua    # Fusion logic
│   ├── map.lua       # Map generation
│   └── sigils.lua    # Sigil effects
├── data/             # Card/Level definitions
├── ui/               # UI components
├── config/           # Settings
└── utils/            # Utilities
```

## Roadmap

- [x] Auto-battle system
- [x] Card placement on board
- [x] Sacrifice/Blood mechanic
- [x] Drag and drop UI
- [x] 18 cards with 13 sigils
- [x] Roguelike map progression
- [x] Boss battles
- [x] Achievement system
- [x] Save/Load system
- [x] Multi-language support
- [x] Dice fusion system
- [ ] Art and animations
- [ ] Sound effects
- [ ] Shop functionality

## Tech Stack

- **Engine**: LÖVE 11.5 (Love2D)
- **Language**: Lua (LuaJIT)
- **Architecture**: Entity-Component-System inspired

## License

MIT

---

*This is a hobby project for learning game development with LÖVE framework.*