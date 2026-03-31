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
        combat_hint = "左クリック：ドラッグ  |  右クリック：生贄  |  スペース：バトル  |  ESC：メニュー",

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

        -- 报酬
        select_reward = "報酬を選択",
        gold = "ゴールド",

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
        combat_hint = "좌클릭: 드래그  |  우클릭: 희생  |  스페이스: 배틀  |  ESC: 메뉴",

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

        -- 보상
        select_reward = "보상 선택",
        gold = "골드",

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

return I18n