# Roguelike Combat Game

A turn-based deck-building roguelike game built with **LÖVE (Love2D)** and **Lua**.

Inspired by *Slay the Spire* and built with the same technology stack as *Balatro*.

## Features

- 🎴 **Deck Building**: Build your deck with Strike, Defend, and special cards
- ⚔️ **Turn-based Combat**: Strategic card play with energy system
- 👾 **Enemy AI**: Enemies with intent system (attack/defend/buff)
- 🌍 **Multi-language Support**: English, Chinese, Japanese (WIP)

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

### Controls

| Key | Action |
|-----|--------|
| `1-5` | Play card |
| `E` | End turn |
| `L` | Switch language |
| `Space` | Start game / Confirm |
| `ESC` | Quit |

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
2. **Combat**: Play cards using number keys `1-5`
3. **Energy**: Each card costs energy (shown in top-left corner)
4. **Block**: Block absorbs damage, resets each turn
5. **End Turn**: Press `E` to end your turn
6. **Enemy Intent**: Enemy shows their next action (ATK/DEF/BUF)
7. **Victory**: Defeat the enemy to win!

## Cards

| Card | Cost | Effect |
|------|------|--------|
| Strike | 1 | Deal 6 damage |
| Defend | 1 | Gain 5 block |
| Bash | 2 | Deal 8 damage |

## Roadmap

- [x] Basic combat system
- [x] Card system
- [x] Enemy AI with intent display
- [ ] More cards and enemies
- [ ] Roguelike loop (floors, rewards)
- [ ] Relics system
- [ ] Save system
- [ ] Art and animations

## Development

Built with ❤️ using LÖVE framework.

## License

MIT