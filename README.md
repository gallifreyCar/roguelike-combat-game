# Roguelike Combat Game

A turn-based deck-building roguelike game built with **LÖVE (Love2D)** and **Lua**.

Inspired by *Slay the Spire* and built with the same technology stack as *Balatro*.

## Features

- **Deck Building**: Build a persistent run deck through battle rewards
- **Lane Combat**: Place creatures into 4 lanes, sacrifice cards for blood, then resolve a combat round
- **Enemy AI**: Enemies show intent each round: attack, defend, or buff
- **Shared Data**: Love2D and the browser prototype use the same Lua card and level data

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

### Browser Prototype

This repo also includes a browser-playable prototype that is easier to test and debug.

```bash
cd /Users/gallifreycar/Documents/roguelike-game
python3 tools/export_web_data.py
python3 -m http.server 8765
```

Then open:

```text
http://127.0.0.1:8765/web/
```

The browser data is generated from `data/cards.lua` and `data/levels.lua`.
After changing card or level definitions, run:

```bash
python3 tools/export_web_data.py
```

### Controls

| Key | Action |
|-----|--------|
| Mouse | Select hand card, then click an empty player lane |
| Right click / Sacrifice | Sacrifice a player card for +1 blood |
| `Space` | Start game / Battle |
| `R` | Restart run |
| `ESC` | Return to menu |

## Project Structure

```
roguelike-game/
├── main.lua          # Entry point
├── conf.lua          # LÖVE configuration
├── core/
│   ├── state.lua     # State machine
│   ├── input.lua     # Input handling
│   └── i18n.lua      # Internationalization
├── scenes/
│   ├── menu.lua      # Main menu
│   ├── combat.lua    # Battle scene
│   ├── victory.lua   # Victory screen
│   └── death.lua     # Death screen
├── systems/
│   ├── deck.lua      # Card/deck management
│   └── enemy.lua     # Enemy AI
└── assets/           # Sprites, fonts, sounds
```

## Gameplay

1. **Start**: Press `Space` on the menu
2. **Map**: Choose the next available node
3. **Combat**: Play creature cards into lanes using blood
4. **Sacrifice**: Sacrifice your cards to gain more blood when needed
5. **Battle**: Press Battle or `Space` to resolve one combat round
6. **Reward**: Pick a card or gold, then continue to the next node

## Roadmap

- [x] Basic combat system
- [x] Card system
- [x] Enemy AI with intent display
- [x] More cards and enemies
- [x] Roguelike loop (floors, rewards)
- [x] Browser-playable prototype
- [x] Shared Lua-to-Web data export
- [ ] Relics / shop system
- [ ] More polished animation and audio pass

## Development

Built with ❤️ using LÖVE framework.

## License

MIT
