-- scenes/card_collection.lua - 卡牌图鉴场景
-- 显示所有卡牌（已解锁/未解锁），激励玩家解锁更多

local CardCollection = {}
local State = require("core.state")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local CardData = require("data.cards")
local Family = require("systems.family")
local MetaProgression = require("systems.meta_progression")
local Sound = require("systems.sound")
local I18n = require("core.i18n")

local state = {
    filter_rarity = "all",
    filter_family = "all",
    filter_status = "all",  -- all, unlocked, locked
    scroll_offset = 0,
    hover_card = nil,
    selected_card = nil,  -- 详情展示
    cards_list = {},
}

function CardCollection.enter()
    -- 先初始化MetaProgression（确保is_card_unlocked可用）
    MetaProgression.init()

    state.filter_rarity = "all"
    state.filter_family = "all"
    state.filter_status = "all"
    state.scroll_offset = 0
    state.selected_card = nil

    -- 构建卡牌列表
    state.cards_list = {}
    for card_id, template in pairs(CardData.cards) do
        table.insert(state.cards_list, {
            id = card_id,
            template = template,
            unlocked = MetaProgression.is_card_unlocked(card_id) or template.rarity == "common",
        })
    end

    -- 按稀有度排序
    local rarity_order = {legendary = 1, rare = 2, uncommon = 3, common = 4}
    table.sort(state.cards_list, function(a, b)
        local ra = rarity_order[a.template.rarity] or 5
        local rb = rarity_order[b.template.rarity] or 5
        if ra == rb then
            return a.id < b.id
        end
        return ra < rb
    end)
end

function CardCollection.exit()
end

function CardCollection.update(dt)
end

function CardCollection.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text(I18n.t("card_collection") or "CARD COLLECTION", win_w / 2, 20, {
        color = "accent_gold",
        size = 24,
        align = "center",
    })

    -- 统计
    local unlocked_count = 0
    local total_count = #state.cards_list
    for _, card in ipairs(state.cards_list) do
        if card.unlocked then unlocked_count = unlocked_count + 1 end
    end

    Components.text(I18n.t("cards_unlocked") or "Cards Unlocked: " .. unlocked_count .. "/" .. total_count,
        win_w / 2, 50, {
        color = "text_secondary",
        size = 14,
        align = "center",
    })

    -- 筛选栏
    CardCollection.draw_filters(win_w, win_h)

    -- 卡牌网格
    CardCollection.draw_card_grid(win_w, win_h)

    -- 详情面板（如果有选中的卡牌）
    if state.selected_card then
        CardCollection.draw_card_detail(win_w, win_h)
    end

    -- 返回按钮
    Components.button(I18n.t("back") or "← Back", win_w / 2 - 100, win_h - 50, 200, 35, {
        hover = Layout.mouse_in_rect(win_w / 2 - 100, win_h - 50, 200, 35),
    })
end

function CardCollection.draw_filters(win_w, win_h)
    local filter_y = 75
    local filter_x = 20

    -- 稀有度筛选
    local rarities = {"all", "common", "uncommon", "rare", "legendary"}
    for i, r in ipairs(rarities) do
        local is_active = state.filter_rarity == r
        Theme.setColor(is_active and "accent_gold" or "bg_slot", is_active and 0.6 or 1)
        love.graphics.rectangle("fill", filter_x + (i - 1) * 70, filter_y, 65, 25, 4, 4)
        Components.text(r:upper(), filter_x + (i - 1) * 70 + 5, filter_y + 5, {
            color = is_active and "text_value" or "text_secondary",
            size = 10,
        })
    end

    -- 状态筛选
    filter_x = 380
    local statuses = {"all", "unlocked", "locked"}
    for i, s in ipairs(statuses) do
        local is_active = state.filter_status == s
        Theme.setColor(is_active and "accent_gold" or "bg_slot", is_active and 0.6 or 1)
        love.graphics.rectangle("fill", filter_x + (i - 1) * 80, filter_y, 75, 25, 4, 4)
        Components.text(s:upper(), filter_x + (i - 1) * 80 + 5, filter_y + 5, {
            color = is_active and "text_value" or "text_secondary",
            size = 10,
        })
    end
end

function CardCollection.draw_card_grid(win_w, win_h)
    local filtered = CardCollection.get_filtered_cards()

    local grid_x = 20
    local grid_y = 110
    local grid_w = win_w - 40
    local grid_h = win_h - 170

    -- 面板背景
    Theme.setColor("bg_panel", 0.9)
    love.graphics.rectangle("fill", grid_x, grid_y, grid_w, grid_h, 8, 8)

    -- 卡牌网格
    local card_w = 90
    local card_h = 70
    local gap = 10
    local cols = math.floor((grid_w - 20) / (card_w + gap))
    local start_x = grid_x + 10
    local start_y = grid_y + 10

    state.hover_card = nil

    for i, card in ipairs(filtered) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = start_x + col * (card_w + gap)
        local y = start_y + row * (card_h + gap) - state.scroll_offset

        if y + card_h > grid_y and y < grid_y + grid_h then
            local template = card.template
            local family_info = template.family and Family.FAMILIES[template.family]

            -- 检查悬停
            local mx, my = love.mouse.getPosition()
            local is_hover = mx >= x and mx <= x + card_w and my >= y and my <= y + card_h
            if is_hover then
                state.hover_card = card
            end

            -- 卡牌背景（已解锁 vs 未解锁）
            if card.unlocked then
                if is_hover then
                    Theme.setColor("bg_slot_hover", 0.9)
                else
                    Theme.setColor("bg_slot")
                end
            else
                Theme.setColor("bg_slot", 0.4)
            end
            love.graphics.rectangle("fill", x, y, card_w, card_h, 5, 5)

            -- 边框（体系颜色或默认）
            if card.unlocked and family_info then
                love.graphics.setColor(family_info.color[1], family_info.color[2], family_info.color[3], 0.8)
            elseif card.unlocked then
                Theme.setColor("border_gold", 0.5)
            else
                Theme.setColor("border_normal", 0.2)
            end
            love.graphics.rectangle("line", x, y, card_w, card_h, 5, 5)

            -- 卡牌名称
            Components.text(I18n.card_name(card.id), x + 5, y + 5, {
                color = card.unlocked and "text_primary" or "text_hint",
                size = 11,
            })

            -- 属性
            if card.unlocked then
                Components.text("$" .. template.cost .. " A:" .. template.attack .. " H:" .. template.hp,
                    x + 5, y + 22, {
                    color = "text_secondary",
                    size = 10,
                })
            else
                -- 未解锁显示锁图标
                Components.text("🔒", x + card_w / 2 - 10, y + card_h / 2 - 5, {
                    size = 20,
                })
            end

            -- 稀有度标记
            local rarity_colors = {
                common = "text_secondary",
                uncommon = "accent_green",
                rare = "accent_blue",
                legendary = "accent_gold",
            }
            local rarity_mark = {
                common = "",
                uncommon = "★",
                rare = "★★",
                legendary = "★★★",
            }
            if card.unlocked and rarity_mark[template.rarity] then
                Components.text(rarity_mark[template.rarity], x + card_w - 30, y + 5, {
                    color = rarity_colors[template.rarity],
                    size = 10,
                })
            end

            -- 体系图标
            if card.unlocked and family_info then
                Components.text(family_info.icon, x + card_w - 20, y + card_h - 20, {
                    size = 14,
                })
            end
        end
    end
end

function CardCollection.draw_card_detail(win_w, win_h)
    local card = state.selected_card
    if not card then return end

    local panel_x = win_w - 220
    local panel_y = 110
    local panel_w = 200
    local panel_h = win_h - 170

    -- 详情面板
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8, 8)

    local template = card.template
    local family_info = template.family and Family.FAMILIES[template.family]

    -- 卡牌名称
    Components.text(I18n.card_name(card.id), panel_x + panel_w / 2, panel_y + 20, {
        color = card.unlocked and "accent_gold" or "text_hint",
        size = 16,
        align = "center",
    })

    -- 状态标签
    if card.unlocked then
        Components.text("UNLOCKED ✓", panel_x + panel_w / 2, panel_y + 45, {
            color = "accent_green",
            size = 12,
            align = "center",
        })
    else
        Components.text("LOCKED 🔒", panel_x + panel_w / 2, panel_y + 45, {
            color = "accent_red",
            size = 12,
            align = "center",
        })
    end

    -- 属性
    if card.unlocked then
        Components.text("Cost: $" .. template.cost, panel_x + 20, panel_y + 70, {
            color = "text_primary",
        })
        Components.text("Attack: " .. template.attack, panel_x + 20, panel_y + 90, {
            color = "accent_red",
        })
        Components.text("HP: " .. template.hp, panel_x + 20, panel_y + 110, {
            color = "accent_green",
        })

        -- 稀有度
        local rarity_names = {
            common = "Common",
            uncommon = "Uncommon ★",
            rare = "Rare ★★",
            legendary = "Legendary ★★★",
        }
        Components.text("Rarity: " .. rarity_names[template.rarity], panel_x + 20, panel_y + 130, {
            color = "text_secondary",
        })

        -- 体系
        if family_info then
            Components.text("Family: " .. family_info.icon .. " " .. family_info.name, panel_x + 20, panel_y + 150, {
                color = "accent_blue",
            })
        end

        -- 印记
        if template.sigils and #template.sigils > 0 then
            Components.text("Sigils:", panel_x + 20, panel_y + 170, {
                color = "text_secondary",
            })
            for i, sigil in ipairs(template.sigils) do
                Components.text("• " .. sigil, panel_x + 20, panel_y + 190 + i * 15, {
                    color = "text_hint",
                    size = 10,
                })
            end
        end
    else
        -- 解锁提示
        Components.text("Unlock by defeating:", panel_x + 20, panel_y + 70, {
            color = "text_hint",
            size = 11,
        })
        Components.text("Chapter Boss", panel_x + 20, panel_y + 90, {
            color = "accent_gold",
        })
    end
end

function CardCollection.get_filtered_cards()
    local filtered = {}

    for _, card in ipairs(state.cards_list) do
        -- 稀有度筛选
        if state.filter_rarity ~= "all" and card.template.rarity ~= state.filter_rarity then
            goto continue
        end

        -- 状态筛选
        if state.filter_status == "unlocked" and not card.unlocked then
            goto continue
        end
        if state.filter_status == "locked" and card.unlocked then
            goto continue
        end

        table.insert(filtered, card)
        ::continue::
    end

    return filtered
end

function CardCollection.keypressed(key)
    if key == "escape" then
        Sound.play("click")
        State.pop()
    end
end

function CardCollection.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = Layout.get_size()

    -- 返回按钮
    if Layout.mouse_in_rect(win_w / 2 - 100, win_h - 50, 200, 35) then
        Sound.play("click")
        State.pop()
        return
    end

    -- 稀有度筛选
    local filter_y = 75
    local filter_x = 20
    local rarities = {"all", "common", "uncommon", "rare", "legendary"}
    for i, r in ipairs(rarities) do
        if Layout.mouse_in_rect(filter_x + (i - 1) * 70, filter_y, 65, 25) then
            state.filter_rarity = r
            Sound.play("click")
            return
        end
    end

    -- 状态筛选
    filter_x = 380
    local statuses = {"all", "unlocked", "locked"}
    for i, s in ipairs(statuses) do
        if Layout.mouse_in_rect(filter_x + (i - 1) * 80, filter_y, 75, 25) then
            state.filter_status = s
            Sound.play("click")
            return
        end
    end

    -- 点击卡牌查看详情
    if state.hover_card then
        state.selected_card = state.hover_card
        Sound.play("click")
        return
    end

    -- 点击详情面板外关闭详情
    if state.selected_card then
        local panel_x = win_w - 220
        local panel_y = 110
        local panel_w = 200
        local panel_h = win_h - 170
        if not Layout.mouse_in_rect(panel_x, panel_y, panel_w, panel_h) then
            state.selected_card = nil
        end
    end
end

function CardCollection.mousemoved(x, y, dx, dy)
    -- 可以添加滚动逻辑
end

function CardCollection.wheelmoved(x, y)
    -- 滚动卡牌网格
    state.scroll_offset = state.scroll_offset - y * 20
    state.scroll_offset = math.max(0, state.scroll_offset)
end

return CardCollection