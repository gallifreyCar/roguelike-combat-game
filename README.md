# Blood Cards 🃏

A deck-building roguelike auto-battler game built with **LÖVE (Love2D)** and **Lua**.

---

## 🇺🇸 English

### Features

- 🎴 **Card Placement**: Drag cards to a 4-slot board
- ⚔️ **Auto-Battle**: Cards attack automatically each turn
- 💀 **Sacrifice Mechanic**: Right-click cards to gain Blood resource
- 🎯 **Sigil System**: 13 unique card abilities
- 🗺️ **Roguelike Map**: Branching paths with different node types
- 🏆 **Achievement System**: 9 achievements to unlock
- 💾 **Save System**: Progress auto-save

### Quick Start

```bash
# Install LÖVE 11.5+
# macOS
brew install love

# Run the game
love .
```

### How to Play

1. **Blood Economy**: Start with 1 Blood, +1 per turn (max: 6)
2. **Card Placement**: Drag cards from hand to board slots
3. **Sacrifice**: Right-click cards for +1 Blood
4. **Battle**: Click BATTLE button to auto-fight
5. **Win**: Reduce enemy HP to 0

### Cards (18 Total)

| Card | Cost | ATK | HP | Ability |
|------|------|-----|-----|---------|
| Squirrel | 0 | 0 | 1 | Free sacrifice material |
| Stoat | 1 | 1 | 2 | Basic attacker |
| Wolf | 2 | 2 | 2 | Balanced fighter |
| Grizzly | 3 | 4 | 6 | Heavy hitter |
| Hydra | 5 | 3 | 4 | Splits on death |

### Project Structure

```
roguelike-game/
├── main.lua          # Entry point
├── scenes/           # Game scenes
├── systems/          # Game systems
├── data/             # Card/Level definitions
├── ui/               # UI components
├── config/           # Settings
└── utils/            # Utilities
```

---

## 🇨🇳 中文

### 游戏特色

- 🎴 **卡牌放置**：拖拽卡牌到4格棋盘
- ⚔️ **自动战斗**：卡牌自动攻击
- 💀 **献祭系统**：右键点击卡牌获得Blood资源
- 🎯 **印记系统**：13种独特卡牌能力
- 🗺️ **肉鸽地图**：分支路线，不同节点类型
- 🏆 **成就系统**：9种成就等待解锁
- 💾 **存档系统**：自动保存进度

### 快速开始

```bash
# 安装 LÖVE 11.5+
# macOS
brew install love

# 运行游戏
love .
```

### 游戏玩法

1. **Blood经济**：开局1点Blood，每回合+1（上限6）
2. **放置卡牌**：从手牌拖拽到棋盘格子
3. **献祭**：右键点击场上卡牌获得+1 Blood
4. **战斗**：点击BATTLE按钮自动战斗
5. **胜利**：将敌方HP降为0

### 卡牌（共18张）

| 卡牌 | 费用 | 攻击 | 血量 | 特点 |
|------|------|------|------|------|
| Squirrel | 0 | 0 | 1 | 免费献祭材料 |
| Stoat | 1 | 1 | 2 | 基础攻击 |
| Wolf | 2 | 2 | 2 | 平衡型 |
| Grizzly | 3 | 4 | 6 | 重击型 |
| Hydra | 5 | 3 | 4 | 死亡分裂 |

---

## 🇯🇵 日本語

### 特徴

- 🎴 **カード配置**：カードを4マスのボードにドラッグ
- ⚔️ **オートバトル**：カードが自動で攻撃
- 💀 **生贄システム**：右クリックでBloodリソース獲得
- 🎯 **刻印システム**：13種類のユニークな能力
- 🗺️ **ローグライクマップ**：分岐ルートと異なるノードタイプ
- 🏆 **実績システム**：9つの実績を解放
- 💾 **セーブシステム**：進行状況の自動保存

### クイックスタート

```bash
# LÖVE 11.5+をインストール
# macOS
brew install love

# ゲームを実行
love .
```

### 遊び方

1. **Blood経済**：開始時1 Blood、毎ターン+1（最大6）
2. **カード配置**：手札からボードにドラッグ
3. **生贄**：右クリックで+1 Blood獲得
4. **バトル**：BATTLEボタンで自動戦闘
5. **勝利**：敵のHPを0にする

### カード（全18種）

| カード | コスト | 攻撃力 | HP | 特徴 |
|--------|--------|--------|-----|------|
| Squirrel | 0 | 0 | 1 | 無料の生贄素材 |
| Stoat | 1 | 1 | 2 | 基本アタッカー |
| Wolf | 2 | 2 | 2 | バランス型 |
| Grizzly | 3 | 4 | 6 | 重打撃型 |
| Hydra | 5 | 3 | 4 | 死亡時分裂 |

---

## 🇰🇷 한국어

### 특징

- 🎴 **카드 배치**: 카드를 4칸 보드에 드래그
- ⚔️ **오토 배틀**: 카드가 자동으로 공격
- 💀 **희생 시스템**: 우클릭으로 Blood 자원 획득
- 🎯 **인장 시스템**: 13가지 고유 능력
- 🗺️ **로그라이크 맵**: 분기 경로와 다양한 노드 타입
- 🏆 **업적 시스템**: 9개 업적 해금
- 💾 **세이브 시스템**: 진행 상황 자동 저장

### 빠른 시작

```bash
# LÖVE 11.5+ 설치
# macOS
brew install love

# 게임 실행
love .
```

### 플레이 방법

1. **Blood 경제**: 시작 시 1 Blood, 매 턴 +1 (최대 6)
2. **카드 배치**: 핸드에서 보드로 드래그
3. **희생**: 우클릭으로 +1 Blood 획득
4. **배틀**: BATTLE 버튼으로 자동 전투
5. **승리**: 적 HP를 0으로 만들기

### 카드 (총 18장)

| 카드 | 비용 | 공격력 | HP | 특징 |
|------|------|--------|-----|------|
| Squirrel | 0 | 0 | 1 | 무료 희생 재료 |
| Stoat | 1 | 1 | 2 | 기본 공격 |
| Wolf | 2 | 2 | 2 | 밸런스형 |
| Grizzly | 3 | 4 | 6 | 강타형 |
| Hydra | 5 | 3 | 4 | 사망 시 분열 |

---

## 🎮 Controls / 操作 / 操作 / 조작

| Key | Action |
|-----|--------|
| Left-click + drag | Place card |
| Right-click | Sacrifice card |
| Space | Start battle |
| ESC | Back / Menu |
| 1-3 | Select options |

---

## 📋 Roadmap

- [x] Auto-battle system
- [x] Card placement on board
- [x] Sacrifice/Blood mechanic
- [x] Drag and drop UI
- [x] 18 cards with 13 sigils
- [x] Roguelike map progression
- [x] Boss battles
- [x] Achievement system
- [x] Save/Load system
- [ ] Art and animations
- [ ] Sound effects

---

## 🛠️ Tech Stack

- **Engine**: LÖVE 11.5 (Love2D)
- **Language**: Lua (LuaJIT)
- **Architecture**: Entity-Component-System inspired

---

## 📄 License

MIT

---

*This is a hobby project for learning game development with LÖVE framework.*

*这是一个使用LÖVE框架学习游戏开发的爱好项目。*

*これはLÖVEフレームワークでゲーム開発を学ぶ趣味のプロジェクトです。*

*이것은 LÖVE 프레임워크로 게임 개발을 배우는 취미 프로젝트입니다.*