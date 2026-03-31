-- core/i18n.lua - 多语言系统（中英日韩四语）

local I18n = {
    current_lang = "en",
    langs = {"en", "zh", "ja", "ko"},
    texts = {},
}

-- 完整文本库
local translations = {
    en = {
        -- 主菜单
        title = "CARD SACRIFICE",
        subtitle = "A Roguelike Auto-Battler",
        how_to_play = "HOW TO PLAY:",
        instruction1 = "1. DRAG cards from right panel",
        instruction2 = "2. DROP on empty slots",
        instruction3 = "3. Cards need BLOOD (cost)",
        instruction4 = "4. Dead cards = +1 Blood",
        instruction5 = "5. Click BATTLE to fight!",
        instruction6 = "Cards attack automatically each turn.",
        start_game = ">> START GAME <<",
        settings = "[ SETTINGS ]",
        press_hint = "Click buttons or press SPACE to start",
        quick_start = "Quick Start: Space or Click 'Start Game'",
        how_to_play_title = "=== HOW TO PLAY ===",
        tip_deploy = "1. DEPLOY CARDS",
        tip_deploy_desc = "Drag cards from hand to board slots (costs Blood)",
        tip_sacrifice = "2. SACRIFICE",
        tip_sacrifice_desc = "Right-click board cards to gain Blood",
        tip_battle = "3. BATTLE!",
        tip_battle_desc = "Press Space to start combat - cards auto-attack",
        tip_fusion = "4. FUSION",
        tip_fusion_desc = "Combine same cards for stronger versions",
        tip_progression = "5. PROGRESSION",
        tip_progression_desc = "Win battles to unlock permanent upgrades",
        progression = "Progression (Upgrades)",
        achievements_btn = "Achievements",
        tutorial = "How to Play (Tutorial)",
        deck_builder = "Deck Builder",
        need_15_cards = "Need exactly 15 cards!",
        start_run = "START RUN",
        your_deck = "Your Deck",
        available_cards = "Available Cards",
        avg_cost = "Avg Cost",
        cards_count = "Cards",
        deck_cleared = "Deck cleared",
        deck_saved = "Deck saved!",
        deck_filled = "Deck filled randomly!",
        starting_game = "Starting game...",
        back = "← Back",
        clear = "Clear",
        random_fill = "Random Fill",
        save_deck = "Save Deck",
        card_collection = "Card Collection",
        cards_unlocked = "Cards Unlocked",
        keyboard_shortcuts = "KEYBOARD SHORTCUTS:",
        shortcuts_desc = "Space=Start | Tab=View Deck | ESC=Back | R=Retry",

        -- 【新增】新手引导增强
        first_game_hint = "First game? Press H for tutorial!",
        tutorial_welcome = "Welcome!",
        tutorial_welcome_desc = "A roguelike auto-battler. Win battles to progress!",
        tutorial_goal = "Goal",
        tutorial_goal_desc = "Defeat enemy cards. Clear 8 levels to win!",
        tutorial_hand_title = "Hand",
        tutorial_hand_desc = "RIGHT panel cards. Drag to board.",
        tutorial_blood_title = "Blood",
        tutorial_blood_desc = "Cost in red circle. Start: 1 Blood/turn.",
        tutorial_sacrifice_title = "Sacrifice",
        tutorial_sacrifice_desc = "RIGHT-click board card for +1 Blood!",
        tutorial_battle_title = "Battle",
        tutorial_battle_desc = "Press SPACE. Cards auto-attack!",
        tutorial_auto_title = "Combat",
        tutorial_auto_desc = "Attack opposite. Higher ATK wins!",
        tutorial_tips_title = "Tips",
        tutorial_tips_1 = "1. Free Squirrel = 0 cost",
        tutorial_tips_2 = "2. Sacrifice weak for Blood",
        tutorial_tips_3 = "3. * = special ability",
        tutorial_tips_4 = "4. Win = permanent upgrades!",
        tutorial_skip = "Skip",
        tutorial_next = "Next",
        tutorial_step = "%d/%d",
        tooltip_drag_hint = "[Drag to play]",
        tooltip_sacrifice_hint = "[Right-click: +1 Blood]",
        tooltip_cost_hint = "Blood cost",
        tooltip_sigil_hint = "Special ability",
        first_win_msg = "First victory! Great!",
        easy_mode_hint = "Easy start: 1 weak enemy!",
        hover_space = "[Space] Battle",
        hover_tab = "[Tab] Deck",
        hover_esc = "[ESC] Menu",

        -- 战斗界面
        your_board = "YOUR BOARD",
        your_hand = "YOUR HAND",
        cards = "cards",
        hp = "HP",
        blood = "Blood",
        turn = "Turn",
        deck = "Deck",
        discard = "Discard",
        battle_btn = ">> BATTLE <<",
        battle_progress = "Battle in progress...",
        next_level = "Next Level",
        victory = "VICTORY!",
        retry_level = "Retry Level 1",
        drag_hint = "drag",
        right_click_sacrifice = "Right-click to sacrifice",
        sacrifice_msg = "Sacrificed %s for +1 Blood!",
        blood_max = "Blood already at max (%d)!",
        need_blood = "Need %d Blood! Right-click a card to sacrifice.",
        placed = "%s placed!",
        slot_occupied = "Slot occupied! Sacrifice first with RIGHT-click.",
        combat_hint = "Left-click: drag  |  Right-click: sacrifice  |  Space: battle  |  ESC: menu",
        enemy = "Enemy",
        dragging = "Dragging %s",
        your_card_died = "Your %s died!",
        enemy_card_died = "Enemy %s died!",
        enemy_card_revived = "Enemy %s revived!",
        turn_blood = "Turn %d - Blood: %d/%d",
        boss_damage = "%s → Boss (-%d HP)",
        air_strike_boss = "%s [AIR] → Boss (-%d HP)",

        -- 敌人意图
        atk = "ATK",
        def = "DEF",
        buf = "BUF",

        -- 死亡界面
        defeated = "DEFEATED",
        fallen = "Your cards have fallen...",
        retry = ">> RETRY <<",
        menu_btn = "[ESC] Menu",
        death_hint = "SPACE: Retry  |  ESC: Return to Menu",

        -- 设置界面
        settings_title = "SETTINGS",
        master_volume = "Master Volume",
        music_volume = "Music Volume",
        sfx_volume = "SFX Volume",
        fullscreen = "Fullscreen",
        language = "Language",
        show_tutorial = "Show Tutorial",
        reset = "Reset",
        back = "[ESC] Back",
        settings_hint = "UP/DOWN Select  |  LEFT/RIGHT Change  |  ENTER/ESC Save & Back",
        on = "ON",
        off = "OFF",

        -- 地图
        map_title = "[ MAP ]",
        boss = "BOSS",
        floor = "Floor",
        you_are_here = "You are here",
        click_select = "Click to select this node",
        ok = "[OK]",
        node_battle = "Battle",
        node_elite = "Elite",
        node_reward = "Reward",
        node_fusion = "Fusion",
        node_shop = "Shop",
        node_event = "Event",

        -- 奖励
        select_reward = "SELECT REWARD",
        gold = "Gold",

        -- 奖励界面
        reward_choose = "Choose a card to add to your deck",
        reward_cost = "Cost",
        reward_atk = "ATK",
        reward_hp = "HP",
        reward_hint = "Press 1-3 to select, ENTER to confirm, ESC to skip",
        reward_added = "Added %s to deck!",

        -- 商店
        purchase_success = "Purchased",
        purchase_failed = "Purchase failed",
        not_enough_gold = "Not enough Gold",

        -- 商店界面
        shop_title = "SHOP & DECK",
        shop_my_deck = "MY DECK",
        shop_shop = "SHOP",
        shop_deck_info = "Deck: %d cards",
        shop_draw_pile = "Draw Pile: %d",
        shop_discard = "Discard: %d",
        shop_hand = "Hand: %d",
        shop_empty = "Your deck is empty. Win battles to add cards!",
        shop_cost = "Cost",
        shop_atk = "ATK",
        shop_hp = "HP",
        shop_price = "Price",
        shop_buy = "BUY",
        shop_back = "[ESC] Back to Map",

        -- 融合
        fusion_title = "CARD FUSION",
        fusion_same_card = "Same Card",
        fusion_dice = "Dice Fusion",
        fusion_dice_hint = "Select 2 different cards for risky fusion!",
        fusion_no_pairs = "No same-card pairs available for fusion",
        fusion_need_two = "You need 2 of the same card to fuse",
        fusion_select_pair = "Select a pair to fuse:",
        fusion_atk = "ATK",
        fusion_hp = "HP",
        fusion_need_two_cards = "Need at least 2 cards in deck for fusion",
        fusion_click_select = "Click to select cards for fusion:",
        fusion_recipes = "Available fusion recipes:",
        fusion_enhanced = "Enhanced",
        fusion_success_rate = "Success",
        fusion_no_recipe = "No fusion recipe available for this combination",
        fusion_select_another = "Select another card...",
        fusion_success = "Fusion success! Created %s",
        fusion_back = "[ESC] Back",

        -- 胜利
        victory_title = "VICTORY!",
        all_levels = "All levels cleared!",
        continue_btn = "Continue",

        -- 卡牌名称
        card_squirrel = "Squirrel",
        card_battle_squirrel = "Battle Squirrel",
        card_stoat = "Stoat",
        card_bullfrog = "Bullfrog",
        card_rat = "Rat",
        card_turtle = "Turtle",
        card_wolf = "Wolf",
        card_raven = "Raven",
        card_adder = "Adder",
        card_skunk = "Skunk",
        card_cat = "Cat",
        card_grizzly = "Grizzly",
        card_moose = "Moose",
        card_mantis = "Mantis",
        card_ox = "Ox",
        card_eagle = "Eagle",
        card_hydra = "Hydra",
        card_guardian_dog = "Guardian Dog",
        -- 新卡牌
        card_bat = "Bat",
        card_snail = "Snail",
        card_fox = "Fox",
        card_bee = "Bee",
        card_snake = "Snake",
        card_spider = "Spider",
        card_crow = "Crow",
        card_rabbit = "Rabbit",
        card_boar = "Boar",
        card_owl = "Owl",
        card_lion = "Lion",
        card_shark = "Shark",
        card_scorpion = "Scorpion",
        card_frog_king = "Frog King",
        card_bear = "Bear",
        card_kraken = "Kraken",
        card_blood_worm = "Blood Worm",
        card_gem_crab = "Gem Crab",
        card_assassin_bug = "Assassin Bug",
        card_ghost_wolf = "Ghost Wolf",
        card_dragon = "Dragon",
        card_phoenix = "Phoenix",
        card_titan = "Titan",
        card_mirror_cat = "Mirror Cat",
        card_queen_bee = "Queen Bee",
        -- 词条牌
        card_insight = "Insight",
        card_combo_wolf = "Combo Wolf",
        card_death_raven = "Death Raven",
        card_hunter = "Hunter",
        card_burst_cat = "Burst Cat",
        card_deathcard = "Death Card",

        -- 印记名称和描述
        sigil_air_strike_name = "Air Strike",
        sigil_air_strike_desc = "Flying - attacks directly if lane empty",
        sigil_tough_name = "Tough",
        sigil_tough_desc = "+2 Max HP",
        sigil_undead_name = "Undead",
        sigil_undead_desc = "Revive once after death",
        sigil_bifurcated_name = "Bifurcated",
        sigil_bifurcated_desc = "Attack 2 lanes",
        sigil_poison_name = "Poison",
        sigil_poison_desc = "Enemy loses 1 HP per turn",
        sigil_stinky_name = "Stinky",
        sigil_stinky_desc = "Reduce opposite enemy ATK",
        sigil_guardian_name = "Guardian",
        sigil_guardian_desc = "Protect adjacent cards",
        sigil_charge_name = "Charge",
        sigil_charge_desc = "Attack adjacent lanes too",
        sigil_double_strike_name = "Double Strike",
        sigil_double_strike_desc = "Attack twice per turn",
        sigil_trample_name = "Trample",
        sigil_trample_desc = "Overflow damage hits player",
        sigil_sharp_quills_name = "Sharp Quills",
        sigil_sharp_quills_desc = "Deal damage when attacked",
        sigil_bone_snake_name = "Bone Snake",
        sigil_bone_snake_desc = "Leave a 1/1 snake on death",
        sigil_hydra_name = "Hydra",
        sigil_hydra_desc = "Split into 2 snakes on death",
        sigil_draw_name = "Draw",
        sigil_draw_desc = "Draw 2 cards when placed",
        sigil_combo_name = "Combo",
        sigil_combo_desc = "Next card costs 1 less",
        sigil_death_draw_name = "Death Draw",
        sigil_death_draw_desc = "Draw 2 cards when this dies",
        sigil_kill_bonus_name = "Hunter",
        sigil_kill_bonus_desc = "+1 ATK when killing enemy",
        sigil_turn_blood_name = "Blood Maker",
        sigil_turn_blood_desc = "+1 Blood at turn start",

        -- 存档系统
        save_game = "SAVE GAME",
        load_game = "LOAD GAME",
        select_slot_save = "Select a slot to save your progress",
        select_slot_load = "Select a slot to load your game",
        slot_number = "Slot %d",
        slot_empty = "EMPTY SLOT",
        slot_new_game = "Start new game here",
        save_slot_empty = "This slot is empty!",
        save_corrupted = "Save file corrupted!",
        save_corrupted_label = "[CORRUPTED]",
        save_loaded = "Game loaded successfully!",
        save_load_failed = "Failed to load game",
        save_saved = "Game saved successfully!",
        save_failed = "Failed to save game",
        save_created = "New save created!",
        save_deleted = "Save deleted!",
        save_level = "Level: %d",
        save_coins = "Gold: %d",
        save_deck = "Deck: %d cards",
        save_progress = "Map: Row %d",
        save_battles = "Battles won: %d",
        save_wins = "Victories: %d",
        load = "Load",
        save = "Save",
        new_save = "New",
        confirm_delete_title = "DELETE SAVE?",
        confirm_delete_content = "Delete save in slot %d?",
        confirm = "Confirm",
        cancel = "Cancel",
        save_select_hint = "1-3: Select slot  |  Enter: Confirm  |  ESC: Back  |  D: Delete",
    },
    zh = {
        -- 主菜单
        title = "卡牌献祭",
        subtitle = "回合制肉鸽自动战斗",
        how_to_play = "游戏说明：",
        instruction1 = "1. 从右侧拖拽卡牌",
        instruction2 = "2. 放到空格子上",
        instruction3 = "3. 卡牌需要鲜血（费用）",
        instruction4 = "4. 死亡卡牌 = +1 鲜血",
        instruction5 = "5. 点击战斗开始！",
        instruction6 = "卡牌每回合自动攻击。",
        start_game = ">> 开始游戏 <<",
        settings = "[ 设置 ]",
        press_hint = "按 空格 开始，S 键设置",
        quick_start = "快速开始：空格 或 点击「开始游戏」",
        how_to_play_title = "=== 游戏说明 ===",
        tip_deploy = "1. 放置卡牌",
        tip_deploy_desc = "从手牌拖拽卡牌到棋盘格子（消耗鲜血）",
        tip_sacrifice = "2. 献祭卡牌",
        tip_sacrifice_desc = "右键点击棋盘上的卡牌获得鲜血",
        tip_battle = "3. 开始战斗！",
        tip_battle_desc = "按空格开始战斗 - 卡牌自动攻击",
        tip_fusion = "4. 卡牌融合",
        tip_fusion_desc = "合并相同卡牌获得强化版本",
        tip_progression = "5. 局外成长",
        tip_progression_desc = "赢得战斗解锁永久升级",
        progression = "局外成长（升级）",
        achievements_btn = "成就",
        tutorial = "游戏说明（教程）",
        deck_builder = "牌组构建",
        need_15_cards = "需要恰好15张牌！",
        start_run = "开始冒险",
        your_deck = "你的牌组",
        available_cards = "可选卡牌",
        avg_cost = "平均费用",
        cards_count = "卡牌",
        deck_cleared = "牌组已清空",
        deck_saved = "牌组已保存！",
        deck_filled = "随机填充完成！",
        starting_game = "开始游戏...",
        back = "← 返回",
        clear = "清空",
        random_fill = "随机填充",
        save_deck = "保存牌组",
        card_collection = "卡牌图鉴",
        cards_unlocked = "已解锁卡牌",
        keyboard_shortcuts = "键盘快捷键：",
        shortcuts_desc = "空格=开始 | Tab=查看牌组 | ESC=返回 | R=重试",

        -- 战斗界面
        your_board = "你的棋盘",
        your_hand = "你的手牌",
        cards = "张",
        hp = "生命",
        blood = "鲜血",
        turn = "回合",
        deck = "牌组",
        discard = "弃牌",
        battle_btn = ">> 战斗 <<",
        battle_progress = "战斗进行中...",
        next_level = "下一关",
        victory = "胜利！",
        retry_level = "重试第1关",
        drag_hint = "拖拽",
        right_click_sacrifice = "右键献祭",
        sacrifice_msg = "献祭 %s 获得 +1 鲜血！",
        blood_max = "鲜血已满 (%d)！",
        need_blood = "需要 %d 鲜血！右键献祭卡牌。",
        placed = "%s 已放置！",
        slot_occupied = "格子被占用！先右键献祭。",
        combat_hint = "左键：拖拽  |  右键：献祭  |  空格：战斗  |  ESC：菜单",
        enemy = "敌人",
        dragging = "拖拽中 %s",
        your_card_died = "你的%s死亡了！",
        enemy_card_died = "敌方%s死亡了！",
        enemy_card_revived = "敌方%s复活了！",
        turn_blood = "回合 %d - 鲜血: %d/%d",
        boss_damage = "%s → Boss (-%d HP)",
        air_strike_boss = "%s [飞行] → Boss (-%d HP)",

        -- 敌人意图
        atk = "攻击",
        def = "防御",
        buf = "增益",

        -- 死亡界面
        defeated = "战败",
        fallen = "你的卡牌已倒下...",
        retry = ">> 重试 <<",
        menu_btn = "[ESC] 菜单",
        death_hint = "空格：重试  |  ESC：返回菜单",

        -- 设置界面
        settings_title = "设置",
        master_volume = "主音量",
        music_volume = "音乐音量",
        sfx_volume = "音效音量",
        fullscreen = "全屏",
        language = "语言",
        show_tutorial = "显示教程",
        reset = "重置",
        back = "[ESC] 返回",
        settings_hint = "上/下 选择  |  左/右 调整  |  回车/ESC 保存返回",
        on = "开",
        off = "关",

        -- 地图
        map_title = "[ 地图 ]",
        boss = "首领",
        floor = "第",
        you_are_here = "你在这里",
        click_select = "点击选择此节点",
        ok = "[完成]",
        node_battle = "战斗",
        node_elite = "精英",
        node_reward = "奖励",
        node_fusion = "融合",
        node_shop = "商店",
        node_event = "事件",

        -- 奖励
        select_reward = "选择奖励",
        gold = "金币",

        -- 奖励界面
        reward_choose = "选择一张卡牌加入牌组",
        reward_cost = "费用",
        reward_atk = "攻击",
        reward_hp = "生命",
        reward_hint = "按1-3选择，回车确认，ESC跳过",
        reward_added = "已将 %s 加入牌组！",

        -- 商店
        purchase_success = "购买成功",
        purchase_failed = "购买失败",
        not_enough_gold = "金币不足",

        -- 商店界面
        shop_title = "商店与牌库",
        shop_my_deck = "我的牌库",
        shop_shop = "商店",
        shop_deck_info = "牌库: %d 张",
        shop_draw_pile = "抽牌堆: %d",
        shop_discard = "弃牌堆: %d",
        shop_hand = "手牌: %d",
        shop_empty = "牌库为空。赢得战斗获得卡牌！",
        shop_cost = "费用",
        shop_atk = "攻击",
        shop_hp = "生命",
        shop_price = "价格",
        shop_buy = "购买",
        shop_back = "[ESC] 返回地图",

        -- 融合
        fusion_title = "卡牌融合",
        fusion_same_card = "同卡融合",
        fusion_dice = "骰子融合",
        fusion_dice_hint = "选择2张不同卡牌进行风险融合！",
        fusion_no_pairs = "没有可融合的同卡对",
        fusion_need_two = "需要2张相同卡牌才能融合",
        fusion_select_pair = "选择一对卡牌融合：",
        fusion_atk = "攻击",
        fusion_hp = "生命",
        fusion_need_two_cards = "牌组至少需要2张卡牌",
        fusion_click_select = "点击选择融合卡牌：",
        fusion_recipes = "可用融合配方：",
        fusion_enhanced = "强化卡牌",
        fusion_success_rate = "成功率",
        fusion_no_recipe = "此组合没有融合配方",
        fusion_select_another = "选择另一张卡牌...",
        fusion_success = "融合成功！创建了 %s",
        fusion_back = "[ESC] 返回",

        -- 胜利
        victory_title = "胜利！",
        all_levels = "全部通关！",
        continue_btn = "继续",

        -- 卡牌名称
        card_squirrel = "松鼠",
        card_battle_squirrel = "战斗松鼠",
        card_stoat = "白鼬",
        card_bullfrog = "牛蛙",
        card_rat = "老鼠",
        card_turtle = "乌龟",
        card_wolf = "狼",
        card_raven = "渡鸦",
        card_adder = "蝰蛇",
        card_skunk = "臭鼬",
        card_cat = "猫",
        card_grizzly = "灰熊",
        card_moose = "驼鹿",
        card_mantis = "螳螂",
        card_ox = "公牛",
        card_eagle = "老鹰",
        card_hydra = "九头蛇",
        card_guardian_dog = "守卫犬",
        -- 新卡牌
        card_bat = "蝙蝠",
        card_snail = "蜗牛",
        card_fox = "狐狸",
        card_bee = "蜜蜂",
        card_snake = "蛇",
        card_spider = "蜘蛛",
        card_crow = "乌鸦",
        card_rabbit = "兔子",
        card_boar = "野猪",
        card_owl = "猫头鹰",
        card_lion = "狮子",
        card_shark = "鲨鱼",
        card_scorpion = "蝎子",
        card_frog_king = "青蛙王",
        card_bear = "熊",
        card_kraken = "海妖",
        card_blood_worm = "血虫",
        card_gem_crab = "宝石蟹",
        card_assassin_bug = "刺客虫",
        card_ghost_wolf = "幽灵狼",
        card_dragon = "龙",
        card_phoenix = "凤凰",
        card_titan = "泰坦",
        card_mirror_cat = "镜像猫",
        card_queen_bee = "蜂后",
        -- 词条牌
        card_insight = "洞察",
        card_combo_wolf = "连击狼",
        card_death_raven = "亡语渡鸦",
        card_hunter = "猎手",
        card_burst_cat = "爆发猫",
        card_deathcard = "死亡卡牌",

        -- 印记名称和描述
        sigil_air_strike_name = "飞行",
        sigil_air_strike_desc = "直接攻击敌方玩家",
        sigil_tough_name = "坚韧",
        sigil_tough_desc = "+2 最大生命值",
        sigil_undead_name = "复活",
        sigil_undead_desc = "死亡后复活一次",
        sigil_bifurcated_name = "双击",
        sigil_bifurcated_desc = "同时攻击两列",
        sigil_poison_name = "剧毒",
        sigil_poison_desc = "敌人每回合-1生命",
        sigil_stinky_name = "恶臭",
        sigil_stinky_desc = "降低对面敌人攻击力",
        sigil_guardian_name = "守护",
        sigil_guardian_desc = "保护相邻卡牌",
        sigil_charge_name = "冲锋",
        sigil_charge_desc = "同时攻击相邻两列",
        sigil_double_strike_name = "双打",
        sigil_double_strike_desc = "每回合攻击两次",
        sigil_trample_name = "践踏",
        sigil_trample_desc = "溢出伤害打玩家",
        sigil_sharp_quills_name = "尖刺",
        sigil_sharp_quills_desc = "受击时反伤",
        sigil_bone_snake_name = "骨蛇",
        sigil_bone_snake_desc = "死亡留下1/1小蛇",
        sigil_hydra_name = "分裂",
        sigil_hydra_desc = "死亡分裂成两条蛇",
        sigil_draw_name = "过牌",
        sigil_draw_desc = "放置时抽2张牌",
        sigil_combo_name = "连击",
        sigil_combo_desc = "下张牌费用-1",
        sigil_death_draw_name = "亡语",
        sigil_death_draw_desc = "死亡时抽2张牌",
        sigil_kill_bonus_name = "猎杀",
        sigil_kill_bonus_desc = "击杀敌人+1攻击",
        sigil_turn_blood_name = "血源",
        sigil_turn_blood_desc = "回合开始+1鲜血",

        -- 存档系统
        save_game = "保存游戏",
        load_game = "加载游戏",
        select_slot_save = "选择槽位保存游戏进度",
        select_slot_load = "选择槽位加载游戏",
        slot_number = "槽位 %d",
        slot_empty = "空槽位",
        slot_new_game = "在此开始新游戏",
        save_slot_empty = "此槽位为空！",
        save_corrupted = "存档文件已损坏！",
        save_corrupted_label = "[已损坏]",
        save_loaded = "游戏加载成功！",
        save_load_failed = "加载游戏失败",
        save_saved = "游戏保存成功！",
        save_failed = "保存游戏失败",
        save_created = "新存档已创建！",
        save_deleted = "存档已删除！",
        save_level = "等级: %d",
        save_coins = "金币: %d",
        save_deck = "牌组: %d 张",
        save_progress = "地图: 第 %d 行",
        save_battles = "胜利场次: %d",
        save_wins = "通关次数: %d",
        load = "加载",
        save = "保存",
        new_save = "新建",
        confirm_delete_title = "删除存档？",
        confirm_delete_content = "确定删除槽位 %d 的存档？",
        confirm = "确认",
        cancel = "取消",
        save_select_hint = "1-3: 选择槽位 | 回车: 确认 | ESC: 返回 | D: 删除",
    },
    ja = {
        -- メインメニュー
        title = "カードサクリファイス",
        subtitle = "ローグライクオートバトル",
        how_to_play = "遊び方：",
        instruction1 = "1. 右パネルからカードをドラッグ",
        instruction2 = "2. 空きスロットにドロップ",
        instruction3 = "3. カードにはBLOOD（コスト）が必要",
        instruction4 = "4. 死んだカード = +1 Blood",
        instruction5 = "5. BATTLEをクリック！",
        instruction6 = "カードは毎ターン自動攻撃。",
        start_game = ">> ゲーム開始 <<",
        settings = "[ 設定 ]",
        press_hint = "スペースで開始、Sで設定",
        quick_start = "クイックスタート：スペース または 「ゲーム開始」をクリック",
        how_to_play_title = "=== 遊び方 ===",
        tip_deploy = "1. カード配置",
        tip_deploy_desc = "手札からボードにカードをドラッグ（ブラッド消費）",
        tip_sacrifice = "2. 生贄",
        tip_sacrifice_desc = "ボードのカードを右クリックでブラッド獲得",
        tip_battle = "3. バトル！",
        tip_battle_desc = "スペースで戦闘開始 - カードが自動攻撃",
        tip_fusion = "4. 融合",
        tip_fusion_desc = "同じカードを合体して強化",
        tip_progression = "5. 進行",
        tip_progression_desc = "戦闘勝利で永久アップグレード解放",
        progression = "進行（アップグレード）",
        achievements_btn = "実績",
        tutorial = "遊び方（チュートリアル）",
        deck_builder = "デッキ構築",
        need_15_cards = "正確に15枚必要です！",
        start_run = "開始",
        your_deck = "あなたのデッキ",
        available_cards = "利用可能なカード",
        avg_cost = "平均コスト",
        cards_count = "カード",
        deck_cleared = "デッキをクリア",
        deck_saved = "デッキを保存！",
        deck_filled = "ランダム填充完了！",
        starting_game = "ゲーム開始...",
        back = "← 戻る",
        clear = "クリア",
        random_fill = "ランダム填充",
        save_deck = "デッキ保存",
        card_collection = "カード図鑑",
        cards_unlocked = "解除カード",
        keyboard_shortcuts = "キーボードショートカット：",
        shortcuts_desc = "スペース=開始 | Tab=デッキ表示 | ESC=戻る | R=再試行",

        -- 戦闘
        your_board = "あなたのボード",
        your_hand = "あなたの手札",
        cards = "枚",
        hp = "HP",
        blood = "ブラッド",
        turn = "ターン",
        deck = "デッキ",
        discard = "捨札",
        battle_btn = ">> バトル <<",
        battle_progress = "バトル中...",
        next_level = "次のレベル",
        victory = "勝利！",
        retry_level = "レベル1から再挑戦",
        drag_hint = "ドラッグ",
        right_click_sacrifice = "右クリックで生贄",
        sacrifice_msg = "%s を生贄にして +1 ブラッド獲得！",
        blood_max = "ブラッドは最大です (%d)！",
        need_blood = "%d ブラッドが必要！右クリックでカードを生贄に。",
        placed = "%s を配置！",
        slot_occupied = "スロット使用中！右クリックで生贄に。",
        combat_hint = "左クリック：ドラッグ  |  右クリック：生贄  |  スペース：バトル  |  ESC：メニュー",
        enemy = "敵",
        dragging = "%s をドラッグ中",
        your_card_died = "あなたの %s が死亡！",
        enemy_card_died = "敵の %s が死亡！",
        enemy_card_revived = "敵の %s が復活！",
        turn_blood = "ターン %d - ブラッド: %d/%d",
        boss_damage = "%s → ボス (-%d HP)",
        air_strike_boss = "%s [空] → ボス (-%d HP)",

        -- 敵の意図
        atk = "攻撃",
        def = "防御",
        buf = "強化",

        -- 死亡
        defeated = "敗北",
        fallen = "カードが倒れました...",
        retry = ">> 再挑戦 <<",
        menu_btn = "[ESC] メニュー",
        death_hint = "スペース：再挑戦  |  ESC：メニュー",

        -- 設定
        settings_title = "設定",
        master_volume = "マスター音量",
        music_volume = "音楽音量",
        sfx_volume = "効果音音量",
        fullscreen = "フルスクリーン",
        language = "言語",
        show_tutorial = "チュートリアル表示",
        reset = "リセット",
        back = "[ESC] 戻る",
        settings_hint = "上/下 選択  |  左/右 変更  |  Enter/ESC 保存して戻る",
        on = "オン",
        off = "オフ",

        -- 地图
        map_title = "[ マップ ]",
        boss = "ボス",
        floor = "階",
        you_are_here = "現在地",
        click_select = "クリックして選択",
        ok = "[完了]",
        node_battle = "戦闘",
        node_elite = "エリート",
        node_reward = "報酬",
        node_fusion = "融合",
        node_shop = "ショップ",
        node_event = "イベント",

        -- 报酬
        select_reward = "報酬を選択",
        gold = "ゴールド",

        -- 奖励界面
        reward_choose = "デッキに追加するカードを選択",
        reward_cost = "コスト",
        reward_atk = "攻撃",
        reward_hp = "HP",
        reward_hint = "1-3で選択、Enterで確定、ESCでスキップ",
        reward_added = "%s をデッキに追加！",

        -- 商店
        purchase_success = "購入成功",
        purchase_failed = "購入失敗",
        not_enough_gold = "ゴールド不足",

        -- 商店界面
        shop_title = "ショップ＆デッキ",
        shop_my_deck = "マイデッキ",
        shop_shop = "ショップ",
        shop_deck_info = "デッキ: %d枚",
        shop_draw_pile = "山札: %d",
        shop_discard = "捨札: %d",
        shop_hand = "手札: %d",
        shop_empty = "デッキが空です。戦闘に勝ってカードを追加！",
        shop_cost = "コスト",
        shop_atk = "攻撃",
        shop_hp = "HP",
        shop_price = "価格",
        shop_buy = "購入",
        shop_back = "[ESC] マップに戻る",

        -- 融合
        fusion_title = "カード融合",
        fusion_same_card = "同カード",
        fusion_dice = "ダイス融合",
        fusion_dice_hint = "2枚の異なるカードを選んでリスク融合！",
        fusion_no_pairs = "融合可能な同カードペアがありません",
        fusion_need_two = "融合には同じカードが2枚必要です",
        fusion_select_pair = "融合するペアを選択：",
        fusion_atk = "攻撃",
        fusion_hp = "HP",
        fusion_need_two_cards = "デッキに最低2枚のカードが必要です",
        fusion_click_select = "クリックして融合カードを選択：",
        fusion_recipes = "利用可能な融合レシピ：",
        fusion_enhanced = "強化カード",
        fusion_success_rate = "成功率",
        fusion_no_recipe = "この組み合わせには融合レシピがありません",
        fusion_select_another = "別のカードを選択...",
        fusion_success = "融合成功！%s を作成",
        fusion_back = "[ESC] 戻る",

        -- カード名称
        card_squirrel = "リス",
        card_battle_squirrel = "バトゥルリス",
        card_stoat = "オコジョ",
        card_bullfrog = "ウシガエル",
        card_rat = "ネズミ",
        card_turtle = "カメ",
        card_wolf = "オオカミ",
        card_raven = "ワタリガラス",
        card_adder = "クサリヘビ",
        card_skunk = "スカンク",
        card_cat = "ネコ",
        card_grizzly = "ハイイログマ",
        card_moose = "ヘラジカ",
        card_mantis = "カマキリ",
        card_ox = "オックス",
        card_eagle = "ワシ",
        card_hydra = "ヒドラ",
        card_guardian_dog = "ガーディアンドッグ",
        -- 新カード
        card_bat = "コウモリ",
        card_snail = "カタツムリ",
        card_fox = "キツネ",
        card_bee = "ミツバチ",
        card_snake = "ヘビ",
        card_spider = "クモ",
        card_crow = "カラス",
        card_rabbit = "ウサギ",
        card_boar = "イノシシ",
        card_owl = "フクロウ",
        card_lion = "ライオン",
        card_shark = "サメ",
        card_scorpion = "サソリ",
        card_frog_king = "カエルキング",
        card_bear = "クマ",
        card_kraken = "クラーケン",
        card_blood_worm = "ブラッドワーム",
        card_gem_crab = "ジェムクラブ",
        card_assassin_bug = "アサシンバグ",
        card_ghost_wolf = "ゴーストウルフ",
        card_dragon = "ドラゴン",
        card_phoenix = "フェニックス",
        card_titan = "タイタン",
        card_mirror_cat = "ミラーキャット",
        card_queen_bee = "クイーンビー",
        -- 特殊カード
        card_insight = "インサイト",
        card_combo_wolf = "コンボウルフ",
        card_death_raven = "デスレイヴン",
        card_hunter = "ハンター",
        card_burst_cat = "バーストキャット",
        card_deathcard = "デスカード",

        -- 印記名称和描述
        sigil_air_strike_name = "空撃",
        sigil_air_strike_desc = "飛行 - レーンが空なら直接攻撃",
        sigil_tough_name = "タフ",
        sigil_tough_desc = "+2 最大HP",
        sigil_undead_name = "不死",
        sigil_undead_desc = "死後に一度復活",
        sigil_bifurcated_name = "分断",
        sigil_bifurcated_desc = "2レーン攻撃",
        sigil_poison_name = "毒",
        sigil_poison_desc = "敵は毎ターン1HP減少",
        sigil_stinky_name = "悪臭",
        sigil_stinky_desc = "対面の敵の攻撃力低下",
        sigil_guardian_name = "守護",
        sigil_guardian_desc = "隣接カードを保護",
        sigil_charge_name = "突撃",
        sigil_charge_desc = "隣接レーンも攻撃",
        sigil_double_strike_name = "二段撃",
        sigil_double_strike_desc = "毎ターン2回攻撃",
        sigil_trample_name = "踏み付け",
        sigil_trample_desc = "余剰ダメージがプレイヤーに命中",
        sigil_sharp_quills_name = "尖刺",
        sigil_sharp_quills_desc = "攻撃された時にダメージ",
        sigil_bone_snake_name = "骨蛇",
        sigil_bone_snake_desc = "死後に1/1の蛇を残す",
        sigil_hydra_name = "ヒドラ",
        sigil_hydra_desc = "死後に2匹の蛇に分裂",
        sigil_draw_name = "ドロー",
        sigil_draw_desc = "配置時に2枚ドロー",
        sigil_combo_name = "コンボ",
        sigil_combo_desc = "次のカードのコスト-1",
        sigil_death_draw_name = "死ドロー",
        sigil_death_draw_desc = "死時に2枚ドロー",
        sigil_kill_bonus_name = "ハンター",
        sigil_kill_bonus_desc = "敵を倒すと+1攻撃",
        sigil_turn_blood_name = "ブラッドメイカー",
        sigil_turn_blood_desc = "ターン開始時に+1ブラッド",

        -- 存档系统
        save_game = "ゲーム保存",
        load_game = "ゲーム読込",
        select_slot_save = "保存するスロットを選択",
        select_slot_load = "読み込むスロットを選択",
        slot_number = "スロット %d",
        slot_empty = "空スロット",
        slot_new_game = "新ゲームを開始",
        save_slot_empty = "このスロットは空です！",
        save_corrupted = "セーブデータが破損！",
        save_corrupted_label = "[破損]",
        save_loaded = "ゲーム読込成功！",
        save_load_failed = "読込失敗",
        save_saved = "ゲーム保存成功！",
        save_failed = "保存失敗",
        save_created = "新セーブ作成！",
        save_deleted = "セーブ削除！",
        save_level = "レベル: %d",
        save_coins = "ゴールド: %d",
        save_deck = "デッキ: %d枚",
        save_progress = "マップ: %d階",
        save_battles = "勝利: %d回",
        save_wins = "クリア: %d回",
        load = "読込",
        save = "保存",
        new_save = "新規",
        confirm_delete_title = "セーブ削除？",
        confirm_delete_content = "スロット %dのセーブを削除？",
        confirm = "確認",
        cancel = "取消",
        save_select_hint = "1-3: スロット選択 | Enter: 確定 | ESC: 戻る | D: 削除",

        -- 胜利
        victory_title = "勝利！",
        all_levels = "全レベルクリア！",
        continue_btn = "続ける",
    },
    ko = {
        -- 메인 메뉴
        title = "카드 희생",
        subtitle = "로그라이크 오토 배틀",
        how_to_play = "게임 방법:",
        instruction1 = "1. 오른쪽 패널에서 카드 드래그",
        instruction2 = "2. 빈 슬롯에 드롭",
        instruction3 = "3. 카드에는 BLOOD(비용)가 필요",
        instruction4 = "4. 죽은 카드 = +1 Blood",
        instruction5 = "5. BATTLE 클릭!",
        instruction6 = "카드는 매 턴 자동 공격.",
        start_game = ">> 게임 시작 <<",
        settings = "[ 설정 ]",
        press_hint = "스페이스로 시작, S로 설정",
        quick_start = "빠른 시작: 스페이스 또는 '게임 시작' 클릭",
        how_to_play_title = "=== 게임 방법 ===",
        tip_deploy = "1. 카드 배치",
        tip_deploy_desc = "패에서 보드로 카드 드래그 (블러드 소모)",
        tip_sacrifice = "2. 희생",
        tip_sacrifice_desc = "보드 카드 우클릭으로 블러드 획득",
        tip_battle = "3. 배틀!",
        tip_battle_desc = "스페이스로 전투 시작 - 카드 자동 공격",
        tip_fusion = "4. 융합",
        tip_fusion_desc = "같은 카드 합체로 강화",
        tip_progression = "5. 진행",
        tip_progression_desc = "전투 승리로 영구 업그레이드 해제",
        progression = "진행 (업그레이드)",
        achievements_btn = "업적",
        tutorial = "게임 방법 (튜토리얼)",
        deck_builder = "덱 구축",
        need_15_cards = "정확히 15장 필요!",
        start_run = "시작",
        your_deck = "당신의 덱",
        available_cards = "사용 가능 카드",
        avg_cost = "평균 코스트",
        cards_count = "카드",
        deck_cleared = "덱 클리어",
        deck_saved = "덱 저장!",
        deck_filled = "랜덤 채우기 완료!",
        starting_game = "게임 시작...",
        back = "← 뒤로",
        clear = "클리어",
        random_fill = "랜덤 채우기",
        save_deck = "덱 저장",
        card_collection = "카드 도감",
        cards_unlocked = "해제 카드",
        keyboard_shortcuts = "키보드 단축키:",
        shortcuts_desc = "스페이스=시작 | Tab=덱 보기 | ESC=뒤로 | R=재시도",

        -- 전투
        your_board = "당신의 보드",
        your_hand = "당신의 패",
        cards = "장",
        hp = "HP",
        blood = "블러드",
        turn = "턴",
        deck = "덱",
        discard = "버린 패",
        battle_btn = ">> 배틀 <<",
        battle_progress = "배틀 진행 중...",
        next_level = "다음 레벨",
        victory = "승리!",
        retry_level = "레벨 1부터 재시도",
        drag_hint = "드래그",
        right_click_sacrifice = "우클릭으로 희생",
        sacrifice_msg = "%s 희생으로 +1 블러드!",
        blood_max = "블러드 최대 (%d)!",
        need_blood = "%d 블러드 필요! 우클릭으로 카드 희생.",
        placed = "%s 배치!",
        slot_occupied = "슬롯 사용 중! 우클릭으로 희생.",
        combat_hint = "좌클릭: 드래그  |  우클릭: 희생  |  스페이스: 배틀  |  ESC: 메뉴",
        enemy = "적",
        dragging = "%s 드래그 중",
        your_card_died = "당신의 %s 사망!",
        enemy_card_died = "적 %s 사망!",
        enemy_card_revived = "적 %s 부활!",
        turn_blood = "턴 %d - 블러드: %d/%d",
        boss_damage = "%s → 보스 (-%d HP)",
        air_strike_boss = "%s [공중] → 보스 (-%d HP)",

        -- 적 의도
        atk = "공격",
        def = "방어",
        buf = "강화",

        -- 사망
        defeated = "패배",
        fallen = "카드가 쓰러졌습니다...",
        retry = ">> 재시도 <<",
        menu_btn = "[ESC] 메뉴",
        death_hint = "스페이스: 재시도  |  ESC: 메뉴",

        -- 설정
        settings_title = "설정",
        master_volume = "마스터 볼륨",
        music_volume = "음악 볼륨",
        sfx_volume = "효과음 볼륨",
        fullscreen = "전체화면",
        language = "언어",
        show_tutorial = "튜토리얼 표시",
        reset = "리셋",
        back = "[ESC] 뒤로",
        settings_hint = "상/하 선택  |  좌/우 변경  |  Enter/ESC 저장 후 뒤로",
        on = "켜기",
        off = "끄기",

        -- 맵
        map_title = "[ 맵 ]",
        boss = "보스",
        floor = "층",
        you_are_here = "현재 위치",
        click_select = "클릭하여 선택",
        ok = "[완료]",
        node_battle = "전투",
        node_elite = "엘리트",
        node_reward = "보상",
        node_fusion = "융합",
        node_shop = "상점",
        node_event = "이벤트",

        -- 보상
        select_reward = "보상 선택",
        gold = "골드",

        -- 보상 화면
        reward_choose = "덱에 추가할 카드 선택",
        reward_cost = "비용",
        reward_atk = "공격",
        reward_hp = "HP",
        reward_hint = "1-3으로 선택, Enter로 확인, ESC로 건너뛰기",
        reward_added = "%s를 덱에 추가!",

        -- 상점
        purchase_success = "구매 성공",
        purchase_failed = "구매 실패",
        not_enough_gold = "골드 부족",

        -- 상점 화면
        shop_title = "상점 & 덱",
        shop_my_deck = "내 덱",
        shop_shop = "상점",
        shop_deck_info = "덱: %d장",
        shop_draw_pile = "뽑기 더미: %d",
        shop_discard = "버린 더미: %d",
        shop_hand = "패: %d",
        shop_empty = "덱이 비어있습니다. 전투에서 승리하여 카드를 획득하세요!",
        shop_cost = "비용",
        shop_atk = "공격",
        shop_hp = "HP",
        shop_price = "가격",
        shop_buy = "구매",
        shop_back = "[ESC] 맵으로",

        -- 융합
        fusion_title = "카드 융합",
        fusion_same_card = "동일 카드",
        fusion_dice = "주사위 융합",
        fusion_dice_hint = "2장의 다른 카드를 선택하여 리스크 융합!",
        fusion_no_pairs = "융합 가능한 동일 카드 쌍이 없습니다",
        fusion_need_two = "융합하려면 같은 카드가 2장 필요합니다",
        fusion_select_pair = "융합할 쌍을 선택:",
        fusion_atk = "공격",
        fusion_hp = "HP",
        fusion_need_two_cards = "덱에 최소 2장의 카드가 필요합니다",
        fusion_click_select = "클릭하여 융합 카드 선택:",
        fusion_recipes = "사용 가능한 융합 레시피:",
        fusion_enhanced = "강화 카드",
        fusion_success_rate = "성공률",
        fusion_no_recipe = "이 조합에는 융합 레시피가 없습니다",
        fusion_select_another = "다른 카드 선택...",
        fusion_success = "융합 성공! %s 생성",
        fusion_back = "[ESC] 뒤로",

        -- 카드 이름
        card_squirrel = "다람쥐",
        card_battle_squirrel = "전투 다람쥐",
        card_stoat = "족제비",
        card_bullfrog = "황소개구리",
        card_rat = "쥐",
        card_turtle = "거북",
        card_wolf = "늑대",
        card_raven = "까마귀",
        card_adder = "독사",
        card_skunk = "스컹크",
        card_cat = "고양이",
        card_grizzly = "회색곰",
        card_moose = "말코손바닥사슴",
        card_mantis = "사마귀",
        card_ox = "황소",
        card_eagle = "독수리",
        card_hydra = "히드라",
        card_guardian_dog = "수호견",
        -- 새 카드
        card_bat = "박쥐",
        card_snail = "달팽이",
        card_fox = "여우",
        card_bee = "꿀벌",
        card_snake = "뱀",
        card_spider = "거미",
        card_crow = "까치",
        card_rabbit = "토끼",
        card_boar = "멧돼지",
        card_owl = "부엉이",
        card_lion = "사자",
        card_shark = "상어",
        card_scorpion = "전갈",
        card_frog_king = "개구리 왕",
        card_bear = "곰",
        card_kraken = "크라켄",
        card_blood_worm = "피 지렁이",
        card_gem_crab = "보석 게",
        card_assassin_bug = "암살 벌레",
        card_ghost_wolf = "유령 늑대",
        card_dragon = "용",
        card_phoenix = "불사조",
        card_titan = "타이탄",
        card_mirror_cat = "거울 고양이",
        card_queen_bee = "여왕벌",
        -- 특수 카드
        card_insight = "통찰",
        card_combo_wolf = "콤보 늑대",
        card_death_raven = "죽음의 까마귀",
        card_hunter = "사냥꾼",
        card_burst_cat = "폭발 고양이",
        card_deathcard = "죽음의 카드",

        -- 문양 이름과 설명
        sigil_air_strike_name = "공중 타격",
        sigil_air_strike_desc = "비행 - 레인 비면 직접 공격",
        sigil_tough_name = "강인",
        sigil_tough_desc = "+2 최대 HP",
        sigil_undead_name = "불사",
        sigil_undead_desc = "사망 후 한 번 부활",
        sigil_bifurcated_name = "분할",
        sigil_bifurcated_desc = "2 레인 공격",
        sigil_poison_name = "독",
        sigil_poison_desc = "적 매 턴 1HP 감소",
        sigil_stinky_name = "악취",
        sigil_stinky_desc = "맞은편 적 공격력 감소",
        sigil_guardian_name = "수호",
        sigil_guardian_desc = "인접 카드 보호",
        sigil_charge_name = "돌격",
        sigil_charge_desc = "인접 레인도 공격",
        sigil_double_strike_name = "이중 타격",
        sigil_double_strike_desc = "매 턴 2회 공격",
        sigil_trample_name = "짓밟기",
        sigil_trample_desc = "넘침 데미지가 플레이어에",
        sigil_sharp_quills_name = "날카운 가시",
        sigil_sharp_quills_desc = "공격받을 때 데미지",
        sigil_bone_snake_name = "뱀 뼈",
        sigil_bone_snake_desc = "사망 시 1/1 뱀 남김",
        sigil_hydra_name = "히드라",
        sigil_hydra_desc = "사망 시 2마리 뱀 분열",
        sigil_draw_name = "드로우",
        sigil_draw_desc = "배치 시 2장 드로우",
        sigil_combo_name = "콤보",
        sigil_combo_desc = "다음 카드 비용 -1",
        sigil_death_draw_name = "사망 드로우",
        sigil_death_draw_desc = "사망 시 2장 드로우",
        sigil_kill_bonus_name = "사냥꾼",
        sigil_kill_bonus_desc = "적 처치시 +1 공격",
        sigil_turn_blood_name = "블러드 메이커",
        sigil_turn_blood_desc = "턴 시작시 +1 블러드",

        -- 存档系统
        save_game = "게임 저장",
        load_game = "게임 불러오기",
        select_slot_save = "저장할 슬롯 선택",
        select_slot_load = "불러올 슬롯 선택",
        slot_number = "슬롯 %d",
        slot_empty = "빈 슬롯",
        slot_new_game = "새 게임 시작",
        save_slot_empty = "이 슬롯은 비어있습니다!",
        save_corrupted = "세이브 데이터 손상!",
        save_corrupted_label = "[손상]",
        save_loaded = "게임 불러오기 성공!",
        save_load_failed = "불러오기 실패",
        save_saved = "게임 저장 성공!",
        save_failed = "저장 실패",
        save_created = "새 세이브 생성!",
        save_deleted = "세이브 삭제!",
        save_level = "레벨: %d",
        save_coins = "골드: %d",
        save_deck = "덱: %d장",
        save_progress = "맵: %d층",
        save_battles = "승리: %d회",
        save_wins = "클리어: %d회",
        load = "불러오기",
        save = "저장",
        new_save = "새로",
        confirm_delete_title = "세이브 삭제?",
        confirm_delete_content = "슬롯 %d의 세이브를 삭제?",
        confirm = "확인",
        cancel = "취소",
        save_select_hint = "1-3: 슬롯 선택 | Enter: 확인 | ESC: 뒤로 | D: 삭제",

        -- 승리
        victory_title = "승리!",
        all_levels = "모든 레벨 클리어!",
        continue_btn = "계속",
    },
}

function I18n.init()
    I18n.texts = translations
end

function I18n.set_lang(lang)
    if translations[lang] then
        I18n.current_lang = lang
    end
end

function I18n.toggle_lang()
    local current_index = 1
    for i, lang in ipairs(I18n.langs) do
        if lang == I18n.current_lang then
            current_index = i
            break
        end
    end
    local next_index = (current_index % #I18n.langs) + 1
    I18n.current_lang = I18n.langs[next_index]
end

function I18n.t(key)
    local lang_texts = translations[I18n.current_lang]
    if lang_texts and lang_texts[key] then
        return lang_texts[key]
    end
    -- Fallback to English
    if translations.en[key] then
        return translations.en[key]
    end
    return key
end

function I18n.get_lang_name()
    local names = {
        zh = "中文",
        en = "English",
        ja = "日本語",
        ko = "한국어",
    }
    return names[I18n.current_lang] or I18n.current_lang
end

-- 格式化文本（支持参数替换）
function I18n.tf(key, ...)
    local text = I18n.t(key)
    return string.format(text, ...)
end

-- 获取卡牌名称翻译
function I18n.card_name(card_id)
    local key = "card_" .. card_id
    local lang_texts = translations[I18n.current_lang]
    if lang_texts and lang_texts[key] then
        return lang_texts[key]
    end
    -- Fallback to English
    if translations.en[key] then
        return translations.en[key]
    end
    -- 最后返回原始 ID
    return card_id
end

-- 获取印记名称和描述翻译
function I18n.sigil_info(sigil_id)
    local name_key = "sigil_" .. sigil_id .. "_name"
    local desc_key = "sigil_" .. sigil_id .. "_desc"

    local name = I18n.t(name_key)
    local desc = I18n.t(desc_key)

    -- 如果没有找到翻译，返回默认值
    if name == name_key then
        name = sigil_id:gsub("_", " "):gsub("^%l", string.upper)
    end
    if desc == desc_key then
        desc = ""
    end

    return name, desc
end

-- 检查翻译完整性
function I18n.check_completeness()
    local en_keys = {}
    local missing = {}

    -- 收集所有英文键
    for key, _ in pairs(translations.en) do
        en_keys[key] = true
    end

    -- 检查每种语言
    for _, lang in ipairs(I18n.langs) do
        if lang ~= "en" then
            missing[lang] = {}
            for key, _ in pairs(en_keys) do
                if not translations[lang] or not translations[lang][key] then
                    table.insert(missing[lang], key)
                end
            end
        end
    end

    return missing
end

-- 获取翻译覆盖率统计
function I18n.get_coverage()
    local total = 0
    for _ in pairs(translations.en) do
        total = total + 1
    end

    local coverage = {}
    for _, lang in ipairs(I18n.langs) do
        local count = 0
        if translations[lang] then
            for key, _ in pairs(translations[lang]) do
                if translations.en[key] then
                    count = count + 1
                end
            end
        end
        coverage[lang] = {
            translated = count,
            total = total,
            percent = math.floor(count / total * 100)
        }
    end

    return coverage
end

-- 打印翻译报告
function I18n.print_report()
    print("\n=== i18n Coverage Report ===")
    local coverage = I18n.get_coverage()
    for lang, data in pairs(coverage) do
        print(string.format("%s: %d/%d (%d%%)", lang, data.translated, data.total, data.percent))
    end

    local missing = I18n.check_completeness()
    for lang, keys in pairs(missing) do
        if #keys > 0 then
            print(string.format("\n%s missing %d keys:", lang, #keys))
            for i, key in ipairs(keys) do
                if i <= 10 then
                    print("  - " .. key)
                end
            end
            if #keys > 10 then
                print("  ... and " .. (#keys - 10) .. " more")
            end
        end
    end
    print("=============================\n")
end

return I18n