-- scenes/achievements.lua - 成就展示场景
-- 显示所有成就、进度、分类浏览

local AchievementsScene = {}
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config/layout")
local Components = require("ui.components")
local Achievements = require("systems.achievements")
local Sound = require("systems.sound")

local buttons = {}
local selected_category = "all"
local scroll_offset = 0
local max_scroll = 0
local achievement_list = {}
local show_hidden = false  -- 是否显示隐藏成就

function AchievementsScene.enter()
    -- 计算按钮位置
    local win_w, win_h = Layout.get_size()
    local btn_w = 200
    local btn_h = 40
    local btn_x = win_w / 2 - btn_w / 2

    buttons = {
        back = {x = btn_x, y = win_h - 60, width = btn_w, height = btn_h},
    }

    selected_category = "all"
    scroll_offset = 0
    show_hidden = false

    -- 构建成就列表
    AchievementsScene.build_achievement_list()
end

function AchievementsScene.exit()
end

function AchievementsScene.update(dt)
    -- 更新成就通知
    Achievements.update_notification(dt)
end

-- 构建成就列表（按当前筛选）
function AchievementsScene.build_achievement_list()
    achievement_list = {}
    local all_achievements = Achievements.get_all() or {}

    for id, ach in pairs(all_achievements) do
        if ach then  -- 防护：确保 ach 不为 nil
            -- 筛选条件
            if selected_category == "all" or ach.category == selected_category then
                -- 隐藏成就筛选
                if not ach.hidden or show_hidden or ach.unlocked then
                    table.insert(achievement_list, ach)
                end
            end
        end
    end

    -- 排序：已解锁在前，未解锁在后
    table.sort(achievement_list, function(a, b)
        if not a or not b then return false end
        if a.unlocked ~= b.unlocked then
            return a.unlocked
        end
        return (a.name or "") < (b.name or "")
    end)

    -- 计算最大滚动
    local item_height = 50
    local visible_height = 300
    max_scroll = math.max(0, #achievement_list * item_height - visible_height)
end

function AchievementsScene.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text("ACHIEVEMENTS", win_w / 2, 25, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 统计显示
    local unlocked_count = Achievements.get_unlocked_count()
    local total_count = Achievements.get_total_count(false)  -- 不含隐藏
    local percentage = total_count > 0 and math.floor(unlocked_count / total_count * 100) or 0

    Components.text(string.format("Progress: %d / %d (%d%%)", unlocked_count, total_count, percentage),
                    win_w / 2, 55, {
        color = "accent_green",
        align = "center",
    })

    -- 绘制分类按钮
    AchievementsScene.draw_category_buttons(win_w)

    -- 绘制成就列表
    AchievementsScene.draw_achievement_list(win_w, win_h)

    -- 绘制返回按钮
    local back_hover = Layout.mouse_in_button(buttons.back)
    Components.button(I18n.t("back"), buttons.back.x, buttons.back.y,
                      buttons.back.width, buttons.back.height, {
        hover = back_hover,
    })

    -- 操作提示
    Components.text("Scroll with mouse wheel | Click category to filter | ESC to return",
                    win_w / 2, win_h - 30, {
        color = "text_hint",
        align = "center",
        size = 11,
    })

    -- 绘制成就通知
    Achievements.draw_notification()
end

function AchievementsScene.draw_category_buttons(win_w)
    local categories = Achievements.get_categories()
    local btn_width = 90
    local gap = 8
    local start_x = win_w / 2 - (#categories + 1) * (btn_width + gap) / 2 - 20
    local btn_y = 85

    -- "All" 按钮
    local all_active = selected_category == "all"
    Theme.setColor(all_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x, btn_y, btn_width, 30, 6, 6)
    Theme.setColor(all_active and "accent_gold" or "border_gold", 0.5)
    love.graphics.rectangle("line", start_x, btn_y, btn_width, 30, 6, 6)
    Components.text("ALL", start_x + btn_width / 2, btn_y + 8, {
        color = all_active and "accent_gold" or "text_secondary",
        align = "center",
        size = 12,
    })

    buttons["cat_all"] = {x = start_x, y = btn_y, width = btn_width, height = 30}

    -- 分类按钮
    for i, cat in ipairs(categories) do
        local btn_x = start_x + (btn_width + gap) * i
        local active = selected_category == cat.id

        Theme.setColor(active and "bg_slot_hover" or "bg_slot")
        love.graphics.rectangle("fill", btn_x, btn_y, btn_width, 30, 6, 6)
        Theme.setColor(active and "accent_gold" or "border_gold", 0.5)
        love.graphics.rectangle("line", btn_x, btn_y, btn_width, 30, 6, 6)

        Components.text(cat.name, btn_x + btn_width / 2, btn_y + 8, {
            color = active and "accent_gold" or "text_secondary",
            align = "center",
            size = 12,
        })

        buttons["cat_" .. cat.id] = {x = btn_x, y = btn_y, width = btn_width, height = 30}
    end

    -- 显示隐藏按钮（右上角）
    local hidden_btn_x = win_w - 130
    local hidden_btn_y = btn_y
    local hidden_hover = Layout.mouse_in_rect(hidden_btn_x, hidden_btn_y, 120, 30)

    Theme.setColor(show_hidden and "accent_gold" or "bg_slot", hidden_hover and 0.8 or 1)
    love.graphics.rectangle("fill", hidden_btn_x, hidden_btn_y, 120, 30, 6, 6)

    Components.text(show_hidden and "Hide Hidden" or "Show Hidden",
                    hidden_btn_x + 60, hidden_btn_y + 8, {
        color = show_hidden and "text_primary" or "text_hint",
        align = "center",
        size = 11,
    })

    buttons["hidden"] = {x = hidden_btn_x, y = hidden_btn_y, width = 120, height = 30}
end

function AchievementsScene.draw_achievement_list(win_w, win_h)
    local panel_x = 40
    local panel_y = 130
    local panel_w = win_w - 80
    local panel_h = 320

    -- 面板背景
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    -- 边框
    Theme.setColor("border_gold", 0.3)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 8, 8)

    -- 裁剪区域
    love.graphics.setScissor(panel_x + 5, panel_y + 5, panel_w - 10, panel_h - 10)

    local item_height = 50
    local item_y = panel_y + 10 - scroll_offset

    for i, ach in ipairs(achievement_list) do
        if item_y >= panel_y - item_height and item_y <= panel_y + panel_h then
            AchievementsScene.draw_achievement_item(ach, panel_x + 10, item_y, panel_w - 20)
        end
        item_y = item_y + item_height
    end

    love.graphics.setScissor()

    -- 滚动条
    if max_scroll > 0 and #achievement_list > 0 then
        local scrollbar_y = panel_y + 10
        local scrollbar_h = panel_h - 20
        local total_height = #achievement_list * item_height
        local scrollbar_thumb_h = total_height > 0 and math.max(20, scrollbar_h * (320 / total_height)) or scrollbar_h
        local scrollbar_thumb_y = scrollbar_y + (scroll_offset / max_scroll) * (scrollbar_h - scrollbar_thumb_h)

        Theme.setColor("bg_slot")
        love.graphics.rectangle("fill", panel_x + panel_w - 15, scrollbar_y, 10, scrollbar_h, 3, 3)

        Theme.setColor("accent_gold", 0.5)
        love.graphics.rectangle("fill", panel_x + panel_w - 15, scrollbar_thumb_y, 10, scrollbar_thumb_h, 3, 3)
    end
end

function AchievementsScene.draw_achievement_item(ach, x, y, width)
    local item_height = 45

    -- 背景（已解锁/未解锁不同颜色）
    if ach.unlocked then
        Theme.setColor("accent_green", 0.15)
    else
        Theme.setColor("bg_slot", 0.5)
    end
    love.graphics.rectangle("fill", x, y, width, item_height, 6, 6)

    -- 边框
    Theme.setColor(ach.unlocked and "accent_green" or "border_gold", 0.3)
    love.graphics.rectangle("line", x, y, width, item_height, 6, 6)

    -- 成就图标
    local icon_bg_color = ach.unlocked and {0.2, 0.5, 0.3} or {0.15, 0.15, 0.15}
    love.graphics.setColor(icon_bg_color[1], icon_bg_color[2], icon_bg_color[3])
    love.graphics.rectangle("fill", x + 8, y + 8, 30, 30, 4, 4)

    local icon_color = ach.unlocked and {1, 0.9, 0.6} or {0.5, 0.5, 0.5}
    love.graphics.setColor(icon_color[1], icon_color[2], icon_color[3])
    Fonts.print(ach.icon, x + 12, y + 14, 18)

    -- 成就名称
    local name_color = ach.unlocked and "accent_gold" or "text_secondary"
    Components.text(ach.name, x + 50, y + 8, {
        color = name_color,
        size = 14,
    })

    -- 成就描述
    Components.text(ach.desc, x + 50, y + 26, {
        color = ach.unlocked and "text_primary" or "text_hint",
        size = 11,
    })

    -- 隐藏成就标记
    if ach.hidden and not ach.unlocked then
        Components.text("[HIDDEN]", x + width - 70, y + 18, {
            color = "text_hint",
            size = 10,
        })
    end

    -- 进度显示
    if not ach.unlocked then
        local progress = Achievements.get_progress(ach.id)
        if progress and progress.target and progress.target > 0 then
            -- 进度条
            local progress_bar_x = x + width - 120
            local progress_bar_w = 80
            local progress_bar_h = 10

            Theme.setColor("bg_slot")
            love.graphics.rectangle("fill", progress_bar_x, y + 15, progress_bar_w, progress_bar_h, 2, 2)

            Theme.setColor("accent_gold", 0.5)
            local current = progress.current or 0
            local progress_fill_w = progress_bar_w * math.min(1, current / progress.target)
            love.graphics.rectangle("fill", progress_bar_x, y + 15, progress_fill_w, progress_bar_h, 2, 2)

            -- 进度文本
            Components.text(string.format("%d/%d", current, progress.target),
                            progress_bar_x + progress_bar_w / 2, y + 17, {
                color = "text_value",
                size = 9,
                align = "center",
            })
        else
            -- 非进度型成就显示 "?"
            Components.text("?", x + width - 60, y + 18, {
                color = "text_hint",
                size = 14,
            })
        end
    else
        -- 已解锁显示勾选
        Components.text("[OK]", x + width - 50, y + 18, {
            color = "accent_green",
            size = 12,
        })
    end
end

function AchievementsScene.keypressed(key)
    if key == "escape" then
        Sound.play("click")
        State.pop()
    elseif key == "h" then
        -- H键切换显示隐藏成就
        show_hidden = not show_hidden
        AchievementsScene.build_achievement_list()
    elseif key == "up" then
        scroll_offset = math.max(0, scroll_offset - 50)
    elseif key == "down" then
        scroll_offset = math.min(max_scroll, scroll_offset + 50)
    end
end

function AchievementsScene.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 返回按钮
    if Layout.mouse_in_button(buttons.back) then
        Sound.play("click")
        State.pop()
        return
    end

    -- 分类按钮
    if buttons["cat_all"] and Layout.mouse_in_rect(buttons["cat_all"].x, buttons["cat_all"].y,
                                                    buttons["cat_all"].width, buttons["cat_all"].height) then
        selected_category = "all"
        scroll_offset = 0
        AchievementsScene.build_achievement_list()
        Sound.play("click")
        return
    end

    local categories = Achievements.get_categories()
    for _, cat in ipairs(categories) do
        local btn = buttons["cat_" .. cat.id]
        if btn and Layout.mouse_in_rect(btn.x, btn.y, btn.width, btn.height) then
            selected_category = cat.id
            scroll_offset = 0
            AchievementsScene.build_achievement_list()
            Sound.play("click")
            return
        end
    end

    -- 显示隐藏按钮
    if buttons["hidden"] and Layout.mouse_in_rect(buttons["hidden"].x, buttons["hidden"].y,
                                                   buttons["hidden"].width, buttons["hidden"].height) then
        show_hidden = not show_hidden
        AchievementsScene.build_achievement_list()
        Sound.play("click")
        return
    end
end

function AchievementsScene.mousemoved(x, y, dx, dy)
end

function AchievementsScene.wheelmoved(x, y)
    scroll_offset = math.max(0, math.min(max_scroll, scroll_offset - y * 30))
end

return AchievementsScene