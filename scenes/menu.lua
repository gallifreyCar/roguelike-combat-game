-- scenes/menu.lua - 主菜单场景
-- 使用 Theme 和 Components 重构，响应式布局
-- 【Round 3 改进】增强按钮交互反馈、视觉层次、过渡动画

local Menu = {}
local State = require("core.state")
local Map = require("systems.map")
local Deck = require("systems.deck")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local MetaProgression = require("systems.meta_progression")
local Save = require("systems.save")
local Animation = require("systems.animation")
local Sound = require("systems.sound")

-- 模块私有状态
local buttons = {}
local pressed_btn = nil      -- 按下状态追踪

function Menu.enter()
    -- 场景过渡动画
    Animation.fade_in(0.3)

    -- 【性能优化】清理所有动画和UI缓存（防止内存泄漏）
    Animation.clear()
    Components.clear_all()

    -- 初始化局外成长系统
    MetaProgression.init()

    -- 初始化成就系统
    local Achievements = require("systems.achievements")
    Achievements.init()

    -- 手动计算按钮位置，避免高度修改导致错位
    local win_w, win_h = Layout.get_size()
    local btn_w = 200
    local btn_h1 = 55  -- 主按钮高度（增加）
    local btn_h2 = 42  -- 小按钮高度（增加）
    local gap = 12

    -- 计算总高度
    local start_x = (win_w - btn_w) / 2
    local start_y = win_h * 0.52  -- 按钮区域起始位置

    buttons = {}
    -- 第一个按钮（开始游戏，大按钮）
    buttons[1] = {x = start_x, y = start_y, width = btn_w, height = btn_h1, id = "start"}
    -- 第二个按钮（设置）
    buttons[2] = {x = start_x, y = start_y + btn_h1 + gap, width = btn_w, height = btn_h2, id = "settings"}
    -- 第三个按钮（局外成长）
    buttons[3] = {x = start_x, y = start_y + btn_h1 + btn_h2 + 2*gap, width = btn_w, height = btn_h2, id = "progression"}
    -- 第四个按钮（成就）
    buttons[4] = {x = start_x, y = start_y + btn_h1 + 2*btn_h2 + 3*gap, width = btn_w, height = btn_h2, id = "achievements"}
    -- 第五个按钮（教程）
    buttons[5] = {x = start_x, y = start_y + btn_h1 + 3*btn_h2 + 4*gap, width = btn_w, height = btn_h2, id = "tutorial"}

    pressed_btn = nil
end

function Menu.exit()
    pressed_btn = nil
end

-- 应用局外成长加成并开始新游戏
local function start_new_game()
    -- 获取局外成长加成
    local bonuses = MetaProgression.get_starting_bonuses()

    -- 应用金币加成（设置初始金币）
    local base_gold = 50
    Save.set_coins(base_gold + bonuses.gold_bonus)

    -- 应用牌组加成
    Deck.set_meta_bonuses(bonuses)

    -- 生成地图和重置牌组
    Map.generate()
    Deck.reset()

    -- 重置融合计数
    local FusionSystem = require("systems.fusion")
    FusionSystem.reset_fusion_count()

    -- 场景过渡动画
    Animation.fade_out(0.2, function()
        -- 切换到地图场景
        State.switch("map")
    end)
end

function Menu.update(dt)
    -- 更新动画系统
    Animation.update(dt)
end

function Menu.draw()
    -- 背景
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题（使用 text_title 颜色，增强视觉层次）
    Components.text(I18n.t("title"), win_w / 2, win_h * 0.08, {
        color = "text_title",
        size = 32,
        align = "center",
    })

    -- 副标题（使用 text_secondary）
    Components.text(I18n.t("subtitle"), win_w / 2, win_h * 0.14, {
        color = "text_secondary",
        align = "center",
    })

    -- 快速开始提示框（增强边框和阴影）
    -- 阴影
    Theme.setColor("bg_primary", 0.35)
    love.graphics.rectangle("fill", win_w / 2 - 197, win_h * 0.19 + 3, 400, 35, 8, 8)
    -- 主框
    Theme.setColor("bg_slot", 0.65)
    love.graphics.rectangle("fill", win_w / 2 - 200, win_h * 0.19, 400, 35, 8, 8)
    Theme.setColor("accent_gold", 0.55)
    love.graphics.rectangle("line", win_w / 2 - 200, win_h * 0.19, 400, 35, 8, 8)
    Components.text(I18n.t("quick_start"), win_w / 2, win_h * 0.19 + 10, {
        color = "text_secondary",
        align = "center",
        size = 12,
    })

    -- 核心玩法说明面板（增强阴影和边框）
    -- 阴影层
    Theme.setColor("bg_primary", 0.35)
    love.graphics.rectangle("fill", win_w / 2 - 215, win_h * 0.25 + 5, 440, 180, 10, 10)
    -- 主面板
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", win_w / 2 - 220, win_h * 0.25, 440, 180, 10, 10)
    Theme.setColor("border_gold", 0.4)
    love.graphics.rectangle("line", win_w / 2 - 220, win_h * 0.25, 440, 180, 10, 10)

    -- 面板标题（使用 text_title）
    Components.text(I18n.t("how_to_play_title"), win_w / 2, win_h * 0.265, {
        color = "text_title",
        align = "center",
        size = 16,
    })

    -- 核心玩法说明（增强层次）
    local tips = {
        {I18n.t("tip_deploy"), I18n.t("tip_deploy_desc")},
        {I18n.t("tip_sacrifice"), I18n.t("tip_sacrifice_desc")},
        {I18n.t("tip_battle"), I18n.t("tip_battle_desc")},
        {I18n.t("tip_fusion"), I18n.t("tip_fusion_desc")},
        {I18n.t("tip_progression"), I18n.t("tip_progression_desc")},
    }

    local tip_y = win_h * 0.30
    for _, tip in ipairs(tips) do
        -- 标题（accent_gold 更亮）
        Components.text(tip[1], win_w / 2 - 200, tip_y, {
            color = "accent_gold",
            size = 13,
        })
        -- 描述（text_hint 明显更暗）
        Components.text(tip[2], win_w / 2 - 200, tip_y + 16, {
            color = "text_hint",
            size = 11,
        })
        tip_y = tip_y + 32
    end

    -- 按钮区域（增强 hover/pressed 状态）
    for i, btn in ipairs(buttons) do
        local hover = Layout.mouse_in_button(btn)
        local pressed = pressed_btn == btn.id

        -- 按钮样式：开始按钮用 primary，其他用 default
        local style = (i == 1) and "primary" or "default"

        local btn_labels = {
            "start_game",      -- 按钮1: 开始游戏
            "settings",        -- 按钮2: 设置
            "progression",     -- 按钮3: 局外成长
            "achievements_btn",-- 按钮4: 成就
            "tutorial",        -- 按钮5: 教程
        }

        Components.button(I18n.t(btn_labels[i]), btn.x, btn.y, btn.width, btn.height, {
            hover = hover,
            pressed = pressed,
            style = style,
            radius = 10,
            font_size = i == 1 and 18 or 14,
        })
    end

    -- 快捷键提示（增强面板）
    -- 阴影
    Theme.setColor("bg_primary", 0.25)
    love.graphics.rectangle("fill", win_w / 2 - 177, win_h * 0.86 + 3, 360, 55, 6, 6)
    -- 主框
    Theme.setColor("bg_slot", 0.45)
    love.graphics.rectangle("fill", win_w / 2 - 180, win_h * 0.86, 360, 55, 6, 6)
    Theme.setColor("border_normal", 0.25)
    love.graphics.rectangle("line", win_w / 2 - 180, win_h * 0.86, 360, 55, 6, 6)

    Components.text(I18n.t("keyboard_shortcuts"), win_w / 2, win_h * 0.87, {
        color = "text_secondary",
        align = "center",
        size = 12,
    })
    Components.text(I18n.t("shortcuts_desc"), win_w / 2, win_h * 0.89, {
        color = "text_hint",
        align = "center",
        size = 10,
    })

    -- 当前语言（使用 text_hint）
    Components.text("Language: " .. I18n.get_lang_name(), win_w / 2, win_h * 0.93, {
        color = "text_hint",
        align = "center",
        size = 11,
    })

    -- 绘制过渡动画
    Animation.draw()
end

function Menu.keypressed(key)
    if key == "space" then
        Sound.play("click")
        start_new_game()
    elseif key == "s" then
        Sound.play("click")
        State.push("settings")
    elseif key == "escape" then
        love.event.quit()
    end
end

function Menu.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 检测按钮点击，设置 pressed 状态
    for i, btn in ipairs(buttons) do
        if Layout.mouse_in_button(btn) then
            pressed_btn = btn.id
            Sound.play("click")
            return
        end
    end
end

function Menu.mousereleased(x, y, button)
    if button ~= 1 then return end

    -- 处理按钮点击
    if pressed_btn then
        if pressed_btn == "start" and Layout.mouse_in_button(buttons[1]) then
            start_new_game()
        elseif pressed_btn == "settings" and Layout.mouse_in_button(buttons[2]) then
            State.push("settings")
        elseif pressed_btn == "progression" and Layout.mouse_in_button(buttons[3]) then
            State.switch("progression")
        elseif pressed_btn == "achievements" and Layout.mouse_in_button(buttons[4]) then
            State.switch("achievements")
        elseif pressed_btn == "tutorial" and Layout.mouse_in_button(buttons[5]) then
            -- 切换到教程场景
            State.push("tutorial")
        end
        pressed_btn = nil
    end
end

return Menu