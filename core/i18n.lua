-- core/i18n.lua - 多语言系统（中英日三语）

local I18n = {
    current_lang = "en",  -- 默认英文（中文/日文待完善）
    langs = {"en", "zh", "ja"},
    texts = {},
}

-- 文本库
local translations = {
    zh = {
        -- 主菜单
        title = "回合制肉鸽游戏",
        press_start = "按 空格 开始游戏",
        press_quit = "按 ESC 退出",
        language = "按 L 切换语言",

        -- 战斗界面
        energy = "能量",
        hp = "生命",
        block = "护盾",
        end_turn = "按 E 结束回合",

        -- 卡牌
        strike = "打击",
        defend = "防御",
        bash = "重击",
        damage = "伤害",

        -- 死亡
        you_died = "你死了",
        restart = "按 空格 重新开始",

        -- 奖励
        select_reward = "选择奖励",
        gold = "金币",
    },
    en = {
        -- Main Menu
        title = "Roguelike Combat Game",
        press_start = "Press SPACE to Start",
        press_quit = "Press ESC to Quit",
        language = "Press L to Switch Language",

        -- Combat
        energy = "Energy",
        hp = "HP",
        block = "Block",
        end_turn = "Press E to End Turn",

        -- Cards
        strike = "Strike",
        defend = "Defend",
        bash = "Bash",
        damage = "Damage",

        -- Death
        you_died = "YOU DIED",
        restart = "Press SPACE to Restart",

        -- Reward
        select_reward = "Select Reward",
        gold = "Gold",
    },
    ja = {
        -- メインメニュー
        title = "ローグライク戦闘ゲーム",
        press_start = "スペースで開始",
        press_quit = "ESCで終了",
        language = "Lで言語切替",

        -- 戦闘
        energy = "エネルギー",
        hp = "HP",
        block = "ブロック",
        end_turn = "Eでターン終了",

        -- カード
        strike = "打撃",
        defend = "防御",
        bash = "強打",
        damage = "ダメージ",

        -- 死亡
        you_died = "死亡しました",
        restart = "スペースで再開",

        -- 報酬
        select_reward = "報酬を選択",
        gold = "ゴールド",
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
    local text = translations[I18n.current_lang][key]
    return text or key
end

function I18n.get_lang_name()
    local names = {
        zh = "中文",
        en = "English",
        ja = "日本語",
    }
    return names[I18n.current_lang] or I18n.current_lang
end

return I18n