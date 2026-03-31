-- scenes/save_select.lua - 存档槽位选择界面
-- 用于选择存档槽位进行保存/加载/删除操作

local SaveSelect = {}
local State = require("core.state")
local Save = require("systems.save")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local MetaProgression = require("systems.meta_progression")
local Deck = require("systems.deck")
local Map = require("systems.map")

-- 界面状态
local mode = "load"  -- "load" 或 "save"
local selected_slot = 1
local slots_info = {}
local buttons = {}
local show_confirm_delete = false
local delete_target_slot = nil
local message = ""
local message_timer = 0

-- ==================== 初始化 ====================

function SaveSelect.enter(new_mode)
    mode = new_mode or "load"
    selected_slot = Save.get_slot()
    show_confirm_delete = false
    delete_target_slot = nil
    message = ""
    message_timer = 0

    -- 初始化局外成长系统
    MetaProgression.init()

    -- 加载所有槽位信息
    slots_info = Save.get_all_slots_info()

    -- 计算按钮位置
    recalculate_buttons()
end

function SaveSelect.exit()
    show_confirm_delete = false
    delete_target_slot = nil
end

local function recalculate_buttons()
    local win_w, win_h = Layout.get_size()
    local btn_w = 120
    local btn_h = 40
    local gap = 15

    buttons = {}

    -- 底部按钮行
    local bottom_y = win_h - 80
    local bottom_buttons_count = mode == "load" and 2 or 3  -- load: 确认/返回, save: 确认/新存档/返回
    local total_width = bottom_buttons_count * btn_w + (bottom_buttons_count - 1) * gap
    local start_x = (win_w - total_width) / 2

    -- 确认按钮
    buttons.confirm = {x = start_x, y = bottom_y, width = btn_w, height = btn_h}

    -- 新存档按钮（仅保存模式）
    if mode == "save" then
        buttons.new = {x = start_x + btn_w + gap, y = bottom_y, width = btn_w, height = btn_h}
        buttons.back = {x = start_x + 2 * (btn_w + gap), y = bottom_y, width = btn_w, height = btn_h}
    else
        buttons.back = {x = start_x + btn_w + gap, y = bottom_y, width = btn_w, height = btn_h}
    end
end

-- ==================== 存档操作 ====================

local function load_selected_slot()
    local slot = selected_slot
    local info = slots_info[slot]

    if not info.exists then
        message = I18n.t("save_slot_empty")
        message_timer = 2
        return
    end

    if not info.valid then
        message = I18n.t("save_corrupted")
        message_timer = 2
        return
    end

    -- 加载存档
    local data, err = Save.load(slot)
    if data then
        -- 应用局外成长数据
        if data.progress then
            MetaProgression.sync_from_save(data.progress)
        end

        -- 设置当前槽位
        Save.set_slot(slot)

        -- 返回主菜单或地图
        message = I18n.t("save_loaded")
        message_timer = 1

        -- 延迟切换场景
        State.pop()
    else
        message = err == "corrupted" and I18n.t("save_corrupted") or I18n.t("save_load_failed")
        message_timer = 2
    end
end

local function save_to_selected_slot()
    local slot = selected_slot

    -- 设置当前槽位
    Save.set_slot(slot)

    -- 保存当前游戏状态
    local game_state = {
        player = Save.get_player(),
        deck = {
            cards = Deck.get_cards(),
            squirrel_count = Deck.get_squirrel_count(),
        },
        map = Map.get_state(),
        stats = Save.get_stats(),
        progress = MetaProgression.get_data(),
        achievements = {
            unlocked = {},
            stats = Save.get_achievements().stats,
        },
    }

    -- 同步玩家数据
    local player = game_state.player
    player.current_row = game_state.map.current_row
    player.current_col = game_state.map.current_col

    local success = Save.save_full(game_state)

    if success then
        message = I18n.t("save_saved")
        message_timer = 1
        -- 刷新槽位信息
        slots_info = Save.get_all_slots_info()
    else
        message = I18n.t("save_failed")
        message_timer = 2
    end
end

local function create_new_save()
    local slot = selected_slot
    Save.set_slot(slot)
    Save.init_new_slot(slot)

    message = I18n.t("save_created")
    message_timer = 1
    slots_info = Save.get_all_slots_info()
end

local function request_delete_slot(slot)
    delete_target_slot = slot
    show_confirm_delete = true
end

local function confirm_delete()
    if delete_target_slot then
        Save.delete(delete_target_slot)
        message = I18n.t("save_deleted")
        message_timer = 1
        slots_info = Save.get_all_slots_info()

        -- 如果删除的是当前选中槽位，清空数据
        if delete_target_slot == selected_slot then
            Save.init_new_slot(selected_slot)
        end
    end
    show_confirm_delete = false
    delete_target_slot = nil
end

local function cancel_delete()
    show_confirm_delete = false
    delete_target_slot = nil
end

-- ==================== 更新 ====================

function SaveSelect.update(dt)
    -- 消息计时器
    if message_timer > 0 then
        message_timer = message_timer - dt
        if message_timer <= 0 then
            message = ""
        end
    end
end

-- ==================== 绘制 ====================

function SaveSelect.draw()
    -- 背景
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    local title = mode == "load" and I18n.t("load_game") or I18n.t("save_game")
    Components.text(title, win_w / 2, win_h * 0.08, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 说明文字
    local subtitle = mode == "load" and I18n.t("select_slot_load") or I18n.t("select_slot_save")
    Components.text(subtitle, win_w / 2, win_h * 0.13, {
        color = "text_secondary",
        size = 14,
        align = "center",
    })

    -- 绘制槽位卡片
    draw_slot_cards(win_w, win_h)

    -- 绘制底部按钮
    draw_bottom_buttons(win_w, win_h)

    -- 绘制消息
    if message ~= "" then
        Theme.setColor("bg_panel", 0.9)
        local msg_w = Fonts.get(14):getWidth(message) + 40
        love.graphics.rectangle("fill", (win_w - msg_w) / 2, win_h * 0.45, msg_w, 30, 6, 6)
        Components.text(message, win_w / 2, win_h * 0.45 + 8, {
            color = "accent_gold",
            size = 14,
            align = "center",
        })
    end

    -- 绘制删除确认对话框
    if show_confirm_delete then
        draw_delete_confirm(win_w, win_h)
    end

    -- 快捷键提示
    Components.text(I18n.t("save_select_hint"), win_w / 2, win_h * 0.92, {
        color = "text_hint",
        size = 11,
        align = "center",
    })
end

local function draw_slot_cards(win_w, win_h)
    local card_w = 280
    local card_h = 180
    local gap = 20
    local total_width = 3 * card_w + 2 * gap
    local start_x = (win_w - total_width) / 2
    local card_y = win_h * 0.2

    for i = 1, 3 do
        local info = slots_info[i]
        local x = start_x + (i - 1) * (card_w + gap)
        local is_selected = i == selected_slot
        local hover = Layout.mouse_in_button({x = x, y = card_y, width = card_w, height = card_h})

        -- 槽位卡片背景
        if is_selected then
            -- 选中状态发光
            love.graphics.setColor(1, 1, 0.8, 0.15)
            love.graphics.rectangle("fill", x - 4, card_y - 4, card_w + 8, card_h + 8, 10, 10)
        end

        Theme.setColor(is_selected and "bg_panel" or "bg_slot")
        love.graphics.rectangle("fill", x, card_y, card_w, card_h, 8, 8)

        -- 边框
        Theme.setColor(is_selected and "border_highlight" or "border_normal")
        love.graphics.rectangle("line", x, card_y, card_w, card_h, 8, 8)

        -- 悬停效果
        if hover and not is_selected then
            Theme.setColor("border_gold", 0.5)
            love.graphics.rectangle("line", x, card_y, card_w, card_h, 8, 8)
        end

        -- 槽位编号
        Components.text(I18n.t("slot_number", {num = i}), x + 15, card_y + 12, {
            color = "accent_gold",
            size = 16,
        })

        -- 存档状态
        if info.exists then
            if not info.valid then
                -- 损坏的存档
                Components.text(I18n.t("save_corrupted_label"), x + card_w / 2, card_y + card_h / 2, {
                    color = "accent_red",
                    size = 16,
                    align = "center",
                })
            else
                -- 正常存档信息
                local y_offset = card_y + 45
                local line_h = 22

                -- 时间
                if info.timestamp > 0 then
                    local time_str = os.date("%Y-%m-%d %H:%M", info.timestamp)
                    Components.text(time_str, x + 15, y_offset, {
                        color = "text_secondary",
                        size = 12,
                    })
                    y_offset = y_offset + line_h
                end

                -- 等级和金币
                Components.text(I18n.t("save_level", {level = info.level}), x + 15, y_offset, {
                    color = "text_primary",
                    size = 14,
                })
                Components.text(I18n.t("save_coins", {coins = info.coins}), x + 150, y_offset, {
                    color = "accent_gold",
                    size = 14,
                })
                y_offset = y_offset + line_h

                -- 牌组大小
                Components.text(I18n.t("save_deck", {count = info.deck_size}), x + 15, y_offset, {
                    color = "text_secondary",
                    size = 12,
                })
                y_offset = y_offset + line_h

                -- 地图进度
                Components.text(I18n.t("save_progress", {row = info.current_row}), x + 15, y_offset, {
                    color = "text_secondary",
                    size = 12,
                })
                y_offset = y_offset + line_h

                -- 战斗统计
                Components.text(I18n.t("save_battles", {count = info.battles_won}), x + 15, y_offset, {
                    color = "text_secondary",
                    size = 12,
                })
                y_offset = y_offset + line_h

                -- 通关次数
                if info.wins > 0 then
                    Components.text(I18n.t("save_wins", {count = info.wins}), x + 15, y_offset, {
                        color = "accent_green",
                        size = 12,
                    })
                end
            end
        else
            -- 空槽位
            Components.text(I18n.t("slot_empty"), x + card_w / 2, card_y + card_h / 2 - 10, {
                color = "text_hint",
                size = 16,
                align = "center",
            })
            Components.text(I18n.t("slot_new_game"), x + card_w / 2, card_y + card_h / 2 + 10, {
                color = "text_hint",
                size = 12,
                align = "center",
            })
        end

        -- 删除按钮（仅对已存在的存档显示）
        if info.exists and info.valid and not show_confirm_delete then
            local del_btn_x = x + card_w - 35
            local del_btn_y = card_y + 10
            local del_btn_w = 25
            local del_btn_h = 25
            local del_hover = Layout.mouse_in_button({x = del_btn_x, y = del_btn_y, width = del_btn_w, height = del_btn_h})

            Theme.setColor(del_hover and "accent_red" or "bg_slot")
            love.graphics.rectangle("fill", del_btn_x, del_btn_y, del_btn_w, del_btn_h, 4, 4)
            Theme.setColor(del_hover and "text_primary" or "text_hint")
            Fonts.print("X", del_btn_x + 8, del_btn_y + 5, 14)
        end
    end
end

local function draw_bottom_buttons(win_w, win_h)
    -- 确认按钮
    local confirm_hover = Layout.mouse_in_button(buttons.confirm)
    local confirm_text = mode == "load" and I18n.t("load") or I18n.t("save")
    Components.button(confirm_text, buttons.confirm.x, buttons.confirm.y,
                      buttons.confirm.width, buttons.confirm.height, {
        hover = confirm_hover,
        style = "primary",
    })

    -- 新存档按钮（仅保存模式）
    if mode == "save" and buttons.new then
        local new_hover = Layout.mouse_in_button(buttons.new)
        Components.button(I18n.t("new_save"), buttons.new.x, buttons.new.y,
                          buttons.new.width, buttons.new.height, {
            hover = new_hover,
        })
    end

    -- 返回按钮
    local back_hover = Layout.mouse_in_button(buttons.back)
    Components.button(I18n.t("back"), buttons.back.x, buttons.back.y,
                      buttons.back.width, buttons.back.height, {
        hover = back_hover,
    })
end

local function draw_delete_confirm(win_w, win_h)
    -- 半透明遮罩
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, win_w, win_h)

    -- 确认对话框
    local dlg_w = 300
    local dlg_h = 150
    local dlg_x = (win_w - dlg_w) / 2
    local dlg_y = (win_h - dlg_h) / 2

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", dlg_x, dlg_y, dlg_w, dlg_h, 8, 8)
    Theme.setColor("accent_red")
    love.graphics.rectangle("line", dlg_x, dlg_y, dlg_w, dlg_h, 8, 8)

    -- 标题
    Components.text(I18n.t("confirm_delete_title"), win_w / 2, dlg_y + 20, {
        color = "accent_red",
        size = 16,
        align = "center",
    })

    -- 内容
    Components.text(I18n.t("confirm_delete_content", {slot = delete_target_slot}), win_w / 2, dlg_y + 50, {
        color = "text_primary",
        size = 14,
        align = "center",
    })

    -- 确认/取消按钮
    local btn_w = 80
    local btn_h = 35
    local gap = 20
    local btn_y = dlg_y + dlg_h - 50

    -- 确认删除按钮
    local yes_x = dlg_x + dlg_w / 2 - btn_w - gap / 2
    local yes_hover = Layout.mouse_in_button({x = yes_x, y = btn_y, width = btn_w, height = btn_h})
    Components.button(I18n.t("confirm"), yes_x, btn_y, btn_w, btn_h, {
        hover = yes_hover,
        style = "danger",
    })

    -- 取消按钮
    local no_x = dlg_x + dlg_w / 2 + gap / 2
    local no_hover = Layout.mouse_in_button({x = no_x, y = btn_y, width = btn_w, height = btn_h})
    Components.button(I18n.t("cancel"), no_x, btn_y, btn_w, btn_h, {
        hover = no_hover,
    })
end

-- ==================== 输入处理 ====================

function SaveSelect.keypressed(key)
    if show_confirm_delete then
        if key == "y" or key == "return" then
            confirm_delete()
        elseif key == "n" or key == "escape" then
            cancel_delete()
        end
        return
    end

    -- 槽位选择（1-3数字键）
    if key == "1" then
        selected_slot = 1
    elseif key == "2" then
        selected_slot = 2
    elseif key == "3" then
        selected_slot = 3
    elseif key == "left" then
        selected_slot = math.max(1, selected_slot - 1)
    elseif key == "right" then
        selected_slot = math.min(3, selected_slot + 1)
    elseif key == "return" then
        if mode == "load" then
            load_selected_slot()
        else
            save_to_selected_slot()
        end
    elseif key == "n" and mode == "save" then
        create_new_save()
    elseif key == "escape" then
        State.pop()
    elseif key == "d" then
        -- 删除快捷键
        if slots_info[selected_slot].exists then
            request_delete_slot(selected_slot)
        end
    end
end

function SaveSelect.mousepressed(x, y, button)
    if button ~= 1 then return end

    if show_confirm_delete then
        -- 处理删除确认对话框
        local win_w, win_h = Layout.get_size()
        local dlg_w = 300
        local dlg_h = 150
        local dlg_x = (win_w - dlg_w) / 2
        local dlg_y = (win_h - dlg_h) / 2
        local btn_w = 80
        local btn_h = 35
        local btn_y = dlg_y + dlg_h - 50
        local gap = 20

        local yes_x = dlg_x + dlg_w / 2 - btn_w - gap / 2
        local no_x = dlg_x + dlg_w / 2 + gap / 2

        if Layout.mouse_in_button({x = yes_x, y = btn_y, width = btn_w, height = btn_h}) then
            confirm_delete()
        elseif Layout.mouse_in_button({x = no_x, y = btn_y, width = btn_w, height = btn_h}) then
            cancel_delete()
        end
        return
    end

    local win_w, win_h = Layout.get_size()
    local card_w = 280
    local card_h = 180
    local gap = 20
    local total_width = 3 * card_w + 2 * gap
    local start_x = (win_w - total_width) / 2
    local card_y = win_h * 0.2

    -- 检查槽位卡片点击
    for i = 1, 3 do
        local x_pos = start_x + (i - 1) * (card_w + gap)
        local info = slots_info[i]

        -- 检查删除按钮
        if info.exists and info.valid then
            local del_btn_x = x_pos + card_w - 35
            local del_btn_y = card_y + 10
            if Layout.mouse_in_button({x = del_btn_x, y = del_btn_y, width = 25, height = 25}) then
                request_delete_slot(i)
                return
            end
        end

        -- 检查槽位选择
        if Layout.mouse_in_button({x = x_pos, y = card_y, width = card_w, height = card_h}) then
            selected_slot = i
            return
        end
    end

    -- 检查底部按钮
    if Layout.mouse_in_button(buttons.confirm) then
        if mode == "load" then
            load_selected_slot()
        else
            save_to_selected_slot()
        end
    elseif mode == "save" and buttons.new and Layout.mouse_in_button(buttons.new) then
        create_new_save()
    elseif Layout.mouse_in_button(buttons.back) then
        State.pop()
    end
end

return SaveSelect