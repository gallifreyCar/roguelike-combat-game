-- scenes/fusion.lua - 卡牌融合场景
-- 支持：同卡融合（固定加成）+ 骰子融合（异卡随机融合）+ 自由融合
-- 融合后卡牌获得属性提升和可能的变异效果

local Fusion = {}
local FusionSystem = require("systems.fusion")
local Deck = require("systems.deck")
local State = require("core.state")
local Fonts = require("core.fonts")
local CardData = require("data.cards")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Sound = require("systems.sound")
local I18n = require("core.i18n")

-- 模块私有状态
local selected_cards = {}
local fusible_pairs = {}
local dice_fusion_candidates = {}
local cached_all_cards = {}  -- 缓存卡牌列表，避免 draw 中重复获取
local preview_result = nil
local dice_preview = nil
local free_fuse_preview = nil
local fusion_mode = "same"  -- "same" 或 "dice" 或 "free"
local message = ""
local message_timer = 0
local mutation_result = nil  -- 记录变异结果

function Fusion.enter()
    selected_cards = {}
    preview_result = nil
    dice_preview = nil
    free_fuse_preview = nil
    fusion_mode = "same"
    message = ""
    message_timer = 0
    mutation_result = nil

    -- 缓存卡牌列表
    cached_all_cards = Deck.get_all_cards_for_fusion() or {}

    -- 查找可融合的卡牌对
    fusible_pairs = FusionSystem.find_fusible_pairs(cached_all_cards) or {}

    -- 查找骰子融合候选
    dice_fusion_candidates = Fusion.find_dice_candidates(cached_all_cards) or {}

    -- 检查融合次数
    if not FusionSystem.can_fuse_more() then
        message = I18n.t("fusion_limit_reached") or "Fusion limit reached! (" .. FusionSystem.MAX_FUSIONS .. " per game)"
        message_timer = 3.0
    end
end

function Fusion.exit()
    selected_cards = {}
    fusible_pairs = {}
    dice_fusion_candidates = {}
    preview_result = nil
    dice_preview = nil
    free_fuse_preview = nil
    mutation_result = nil
end

function Fusion.update(dt)
    if message_timer > 0 then
        message_timer = message_timer - dt
        if message_timer <= 0 then
            message = ""
        end
    end
end

function Fusion.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 【新】返回按钮（左上角）
    local back_hover = love.mouse.getX() >= 10 and love.mouse.getX() <= 80 and
                       love.mouse.getY() >= 10 and love.mouse.getY() <= 40
    Theme.setColor(back_hover and "accent_red" or "bg_panel", back_hover and 0.5 or 1)
    love.graphics.rectangle("fill", 10, 10, 70, 30, 4, 4)
    Theme.setColor("text_primary")
    Fonts.print("← ESC", 22, 17, 14)

    -- 标题栏
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", 0, 0, win_w, 50, 0, 0)
    Components.text(I18n.t("fusion_title"), win_w / 2, 12, {
        color = "text_secondary",
        size = 20,
        align = "center",
    })

    -- 融合次数显示
    local remaining = FusionSystem.get_remaining_fusions()
    local count_color = remaining > 2 and "accent_green" or (remaining > 0 and "accent_gold" or "accent_red")
    Components.text("Fusions: " .. remaining .. "/" .. FusionSystem.MAX_FUSIONS, win_w - 100, 15, {
        color = count_color,
        size = 14,
    })

    -- 模式切换按钮（三个模式）
    Fusion.draw_mode_buttons()

    if fusion_mode == "same" then
        Fusion.draw_same_fusion_panel()
    elseif fusion_mode == "dice" then
        Fusion.draw_dice_fusion_panel()
    else
        Fusion.draw_free_fusion_panel()
    end

    -- 消息显示（响应式）
    if message ~= "" then
        local msg_y = win_h * 0.75
        Theme.setColor("bg_panel", 0.8)
        love.graphics.rectangle("fill", win_w / 2 - 200, msg_y, 400, 40, 6, 6)
        Components.text(message, win_w / 2, msg_y + 10, {
            color = "accent_gold",
            align = "center",
        })
    end

    -- 变异结果提示（响应式）
    if mutation_result then
        local mut_y = win_h * 0.80
        Theme.setColor("bg_panel", 0.9)
        local mutation_color = mutation_result.type == "positive" and "accent_green" or
                               (mutation_result.type == "negative" and "accent_red" or "accent_gold")
        love.graphics.rectangle("fill", win_w / 2 - 150, mut_y, 300, 30, 4, 4)
        Components.text("Mutation: " .. mutation_result.desc, win_w / 2, mut_y + 8, {
            color = mutation_color,
            align = "center",
            size = 12,
        })
    end

    -- 返回按钮（响应式）
    local btn_y = win_h * 0.85
    local btn_x = win_w / 2 - 60
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", btn_x, btn_y, 120, 40, 6, 6)
    Theme.setColor("border_gold", 0.5)
    love.graphics.rectangle("line", btn_x, btn_y, 120, 40, 6, 6)
    Components.text(I18n.t("fusion_back"), btn_x + 25, btn_y + 10, {color = "text_secondary"})
end

function Fusion.draw_mode_buttons()
    local win_w = Layout.get_size()
    local btn_width = 120
    local gap = 15
    local start_x = win_w / 2 - btn_width * 1.5 - gap

    -- 同卡融合按钮
    local same_active = fusion_mode == "same"
    Theme.setColor(same_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x, 60, btn_width, 35, 6, 6)
    Theme.setColor(same_active and "accent_gold" or "border_gold", 0.5)
    love.graphics.rectangle("line", start_x, 60, btn_width, 35, 6, 6)
    Components.text(I18n.t("fusion_same_card"), start_x + 20, 68, {
        color = same_active and "accent_gold" or "text_secondary",
        size = 12,
    })

    -- 骰子融合按钮
    local dice_active = fusion_mode == "dice"
    Theme.setColor(dice_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x + btn_width + gap, 60, btn_width, 35, 6, 6)
    Theme.setColor(dice_active and "accent_gold" or "border_gold", 0.5)
    love.graphics.rectangle("line", start_x + btn_width + gap, 60, btn_width, 35, 6, 6)
    Components.text(I18n.t("fusion_dice"), start_x + btn_width + gap + 30, 68, {
        color = dice_active and "accent_gold" or "text_secondary",
        size = 12,
    })

    -- 自由融合按钮（新增）
    local free_active = fusion_mode == "free"
    Theme.setColor(free_active and "bg_slot_hover" or "bg_slot")
    love.graphics.rectangle("fill", start_x + 2 * (btn_width + gap), 60, btn_width, 35, 6, 6)
    Theme.setColor(free_active and "accent_green" or "border_gold", 0.5)
    love.graphics.rectangle("line", start_x + 2 * (btn_width + gap), 60, btn_width, 35, 6, 6)
    Components.text("FREE", start_x + 2 * (btn_width + gap) + 40, 68, {
        color = free_active and "accent_green" or "text_secondary",
        size = 12,
    })

    -- 模式说明
    if fusion_mode == "dice" then
        Components.text(I18n.t("fusion_dice_hint"), win_w / 2, 100, {
            color = "text_hint",
            align = "center",
        })
    elseif fusion_mode == "free" then
        Components.text("Free fusion: Any 2 cards combine with random stats + mutation chance!", win_w / 2, 100, {
            color = "text_hint",
            align = "center",
            size = 11,
        })
    end
end

function Fusion.draw_same_fusion_panel()
    local win_w = Layout.get_size()

    if #fusible_pairs == 0 then
        Components.text(I18n.t("fusion_no_pairs"), win_w / 2, 200, {
            color = "text_secondary",
            align = "center",
        })
        Components.text(I18n.t("fusion_need_two"), win_w / 2, 230, {
            color = "text_hint",
            align = "center",
        })
    else
        Components.text(I18n.t("fusion_select_pair"), win_w / 2 - 150, 110, {
            color = "text_secondary",
        })

        for i, pair in ipairs(fusible_pairs) do
            local y = 150 + (i - 1) * 80
            local template = CardData.cards[pair.card_id]

            if template then
                -- 卡牌背景
                Theme.setColor("bg_slot")
                love.graphics.rectangle("fill", win_w / 2 - 250, y, 500, 70, 6, 6)
                Theme.setColor("border_gold", 0.3)
                love.graphics.rectangle("line", win_w / 2 - 250, y, 500, 70, 6, 6)

                -- 卡牌名称和数量（使用翻译）
                Components.text(I18n.card_name(template.id) .. " x" .. pair.count, win_w / 2 - 230, y + 10, {
                    color = "text_primary",
                    size = 16,
                })

                -- 属性预览
                local preview = FusionSystem.preview(template, template)
                if preview then
                    Theme.setColor("accent_gold")
                    Components.text(I18n.t("fusion_atk") .. ": " .. template.attack .. " -> " .. preview.attack, win_w / 2 - 230, y + 35, {
                        size = 12,
                    })
                    Theme.setColor("accent_green")
                    Components.text(I18n.t("fusion_hp") .. ": " .. template.hp .. " -> " .. preview.hp, win_w / 2 - 100, y + 35, {
                        size = 12,
                    })
                end

                -- 融合按钮
                Theme.setColor("accent_green", 0.3)
                love.graphics.rectangle("fill", win_w / 2 + 100, y + 15, 100, 40, 4, 4)
                Theme.setColor("accent_green")
                love.graphics.rectangle("line", win_w / 2 + 100, y + 15, 100, 40, 4, 4)
                Components.text("[FUSE]", win_w / 2 + 125, y + 25, {
                    color = "text_value",
                })
            end
        end
    end
end

function Fusion.draw_dice_fusion_panel()
    local win_w = Layout.get_size()

    -- 使用缓存的卡牌列表
    local all_cards = cached_all_cards

    if not all_cards or #all_cards < 2 then
        Components.text(I18n.t("fusion_need_two_cards"), win_w / 2, 200, {
            color = "text_secondary",
            align = "center",
        })
        return
    end

    -- 显示卡牌供选择
    Components.text(I18n.t("fusion_click_select"), win_w / 2, 120, {
        color = "text_secondary",
        align = "center",
    })

    local card_width = 90
    local card_height = 120
    local gap = 15
    local start_x = win_w / 2 - (#all_cards * (card_width + gap)) / 2

    for i, card in ipairs(all_cards) do
        local x = start_x + (i - 1) * (card_width + gap)
        local y = 150

        -- 检查是否已选中
        local is_selected = false
        for _, idx in ipairs(selected_cards) do
            if idx == i then
                is_selected = true
                break
            end
        end

        -- 卡牌背景
        Theme.setColor(is_selected and "bg_slot_hover" or "bg_slot")
        love.graphics.rectangle("fill", x, y, card_width, card_height, 5, 5)
        Theme.setColor(is_selected and "accent_gold" or "border_gold", 0.5)
        love.graphics.rectangle("line", x, y, card_width, card_height, 5, 5)

        -- 卡牌信息（使用翻译）
        Components.text(I18n.card_name(card.id), x + 5, y + 5, {color = "text_primary", size = 12})
        Components.text("$" .. card.cost, x + 5, y + 25, {color = "accent_red"})
        Components.text("A:" .. card.attack, x + 5, y + 45, {color = "accent_gold"})
        Components.text("H:" .. card.hp, x + 5, y + 65, {color = "accent_green"})

        -- 选中标记
        if is_selected then
            Components.text("[SELECTED]", x + 10, y + 100, {
                color = "accent_gold",
                size = 10,
            })
        end
    end

    -- 如果选中了两张卡，显示融合预览
    if #selected_cards == 2 then
        local card1 = all_cards[selected_cards[1]]
        local card2 = all_cards[selected_cards[2]]

        if card1 and card2 then
            local previews = FusionSystem.dice_fuse_preview(card1, card2)

            if previews and #previews > 0 then
                dice_preview = previews

                -- 显示融合配方
                Components.text(I18n.t("fusion_recipes"), win_w / 2, 290, {
                    color = "text_secondary",
                    align = "center",
                })

                for i, preview in ipairs(previews) do
                    local y = 320 + (i - 1) * 60

                    Theme.setColor("bg_slot")
                    love.graphics.rectangle("fill", win_w / 2 - 200, y, 400, 50, 6, 6)

                    -- 配方信息
                    Components.text(preview.result_name or I18n.t("fusion_enhanced"), win_w / 2 - 180, y + 5, {
                        color = "accent_gold",
                        size = 14,
                    })
                    Components.text(preview.description, win_w / 2 - 180, y + 25, {
                        color = "text_secondary",
                        size = 11,
                    })

                    -- 成功率和风险指示
                    local rate_color = preview.risk == "high" and "accent_red" or
                                       (preview.risk == "medium" and "accent_gold" or "accent_green")
                    Components.text(I18n.t("fusion_success_rate") .. ": " .. preview.success_rate, win_w / 2 + 50, y + 5, {
                        color = rate_color,
                    })

                    -- 融合按钮
                    Theme.setColor("accent_green", 0.3)
                    love.graphics.rectangle("fill", win_w / 2 + 120, y + 8, 60, 35, 4, 4)
                    Components.text("[GO]", win_w / 2 + 135, y + 18, {
                        color = "text_value",
                    })
                end
            else
                Components.text(I18n.t("fusion_no_recipe"), win_w / 2, 290, {
                    color = "text_hint",
                    align = "center",
                })
            end
        end
    elseif #selected_cards == 1 then
        Components.text(I18n.t("fusion_select_another"), win_w / 2, 290, {
            color = "text_hint",
            align = "center",
        })
    end
end

-- 【新】自由融合面板
function Fusion.draw_free_fusion_panel()
    local win_w = Layout.get_size()
    local all_cards = cached_all_cards

    if not all_cards or #all_cards < 2 then
        Components.text("Need at least 2 cards to fuse!", win_w / 2, 200, {
            color = "text_secondary",
            align = "center",
        })
        return
    end

    -- 显示卡牌供选择
    Components.text("Click to select 2 cards (any cards can fuse)", win_w / 2, 120, {
        color = "text_secondary",
        align = "center",
    })

    -- 变异提示
    Components.text("40% chance of mutation (positive/neutral/negative effects)", win_w / 2, 140, {
        color = "text_hint",
        align = "center",
        size = 11,
    })

    local card_width = 80
    local card_height = 100
    local gap = 12
    local cards_per_row = math.min(6, #all_cards)
    local start_x = win_w / 2 - (cards_per_row * (card_width + gap)) / 2

    for i, card in ipairs(all_cards) do
        local row = math.floor((i - 1) / cards_per_row)
        local col = (i - 1) % cards_per_row
        local x = start_x + col * (card_width + gap)
        local y = 160 + row * (card_height + 15)

        -- 检查是否已选中
        local is_selected = false
        for _, idx in ipairs(selected_cards) do
            if idx == i then
                is_selected = true
                break
            end
        end

        -- 卡牌背景
        Theme.setColor(is_selected and "bg_slot_hover" or "bg_slot")
        love.graphics.rectangle("fill", x, y, card_width, card_height, 5, 5)
        Theme.setColor(is_selected and "accent_green" or "border_gold", 0.5)
        love.graphics.rectangle("line", x, y, card_width, card_height, 5, 5)

        -- 卡牌信息
        Components.text(I18n.card_name(card.id), x + 5, y + 5, {color = "text_primary", size = 11})
        Components.text("$" .. card.cost, x + 5, y + 22, {color = "accent_red", size = 10})
        Components.text("A:" .. card.attack, x + 5, y + 40, {color = "accent_gold", size = 10})
        Components.text("H:" .. card.hp, x + 40, y + 40, {color = "accent_green", size = 10})

        -- 印记数量
        if card.sigils and #card.sigils > 0 then
            Components.text("*" .. #card.sigils, x + 60, y + 80, {color = "accent_gold", size = 9})
        end

        -- 选中标记
        if is_selected then
            Components.text("[SEL]", x + 25, y + 85, {
                color = "accent_green",
                size = 9,
            })
        end
    end

    -- 如果选中了两张卡，显示自由融合预览
    if #selected_cards == 2 then
        local card1 = all_cards[selected_cards[1]]
        local card2 = all_cards[selected_cards[2]]

        if card1 and card2 then
            -- 计算预览属性
            local avg_atk = math.floor((card1.attack + card2.attack) / 2)
            local avg_hp = math.floor((card1.hp + card2.hp) / 2)
            local avg_cost = math.floor((card1.cost + card2.cost) / 2)

            -- 显示预览面板
            Theme.setColor("bg_slot")
            love.graphics.rectangle("fill", win_w / 2 - 180, 380, 360, 60, 6, 6)
            Theme.setColor("accent_green", 0.5)
            love.graphics.rectangle("line", win_w / 2 - 180, 380, 360, 60, 6, 6)

            Components.text("Result: " .. card1.name:sub(1,4) .. "-" .. card2.name:sub(1,4) .. " Hybrid", win_w / 2 - 160, 385, {
                color = "accent_gold",
                size = 14,
            })

            Components.text("ATK: " .. avg_atk - 1 .. "~" .. avg_atk + 1, win_w / 2 - 160, 405, {
                color = "accent_gold",
                size = 11,
            })
            Components.text("HP: " .. avg_hp - 1 .. "~" .. avg_hp + 1, win_w / 2 - 80, 405, {
                color = "accent_green",
                size = 11,
            })
            Components.text("Cost: " .. avg_cost, win_w / 2, 405, {
                color = "accent_red",
                size = 11,
            })

            -- 融合按钮
            Theme.setColor("accent_green", 0.5)
            love.graphics.rectangle("fill", win_w / 2 + 100, 395, 60, 35, 4, 4)
            Components.text("[FUSE]", win_w / 2 + 110, 403, {
                color = "text_value",
                size = 12,
            })

            -- 变异可能提示
            Components.text("Possible mutation effects:", win_w / 2, 450, {
                color = "text_hint",
                align = "center",
                size = 10,
            })
            local mutation_examples = {"+2 ATK", "+2 HP", "Cost -1", "Stats swap", "Glass cannon", "-1 ATK"}
            local example_x = win_w / 2 - 150
            for i, ex in ipairs(mutation_examples) do
                Components.text(ex, example_x + (i - 1) * 55, 470, {
                    color = i <= 4 and "accent_green" or "accent_red",
                    size = 9,
                })
            end
        end
    elseif #selected_cards == 1 then
        Components.text("Select another card...", win_w / 2, 380, {
            color = "text_hint",
            align = "center",
        })
    end
end

-- 查找可骰子融合的候选组合
function Fusion.find_dice_candidates(hand)
    hand = hand or {}
    local candidates = {}
    local checked_pairs = {}

    for i = 1, #hand do
        for j = i + 1, #hand do
            local card1 = hand[i]
            local card2 = hand[j]

            if card1 and card2 then
                -- 检查是否可以骰子融合
                local can_fuse = FusionSystem.can_dice_fuse and FusionSystem.can_dice_fuse(card1, card2)
                if can_fuse then
                    local pair_key = card1.id .. "_" .. card2.id
                    if not checked_pairs[pair_key] then
                        checked_pairs[pair_key] = true
                        table.insert(candidates, {
                            indices = {i, j},
                            card1 = card1,
                            card2 = card2,
                            recipes = FusionSystem.find_dice_fusion_recipes(card1, card2) or {},
                        })
                    end
                end
            end
        end
    end

    return candidates
end

function Fusion.keypressed(key)
    if key == "escape" then
        State.pop()
    elseif key == "tab" then
        -- 切换模式（三个模式循环）
        if fusion_mode == "same" then
            fusion_mode = "dice"
        elseif fusion_mode == "dice" then
            fusion_mode = "free"
        else
            fusion_mode = "same"
        end
        selected_cards = {}
        dice_preview = nil
        free_fuse_preview = nil
        mutation_result = nil
    end
end

function Fusion.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- 【新】返回按钮点击检测
    if x >= 10 and x <= 80 and y >= 10 and y <= 40 then
        State.pop()
        return
    end

    local win_w, win_h = Layout.get_size()

    -- 模式切换按钮（三个模式）
    local btn_width = 120
    local gap = 15
    local start_x = win_w / 2 - btn_width * 1.5 - gap

    if y >= 60 and y <= 95 then
        -- 同卡融合按钮
        if x >= start_x and x <= start_x + btn_width then
            fusion_mode = "same"
            selected_cards = {}
            dice_preview = nil
            free_fuse_preview = nil
            mutation_result = nil
            return
        -- 骰子融合按钮
        elseif x >= start_x + btn_width + gap and x <= start_x + 2 * btn_width + gap then
            fusion_mode = "dice"
            selected_cards = {}
            preview_result = nil
            free_fuse_preview = nil
            mutation_result = nil
            return
        -- 自由融合按钮
        elseif x >= start_x + 2 * (btn_width + gap) and x <= start_x + 3 * btn_width + 2 * gap then
            fusion_mode = "free"
            selected_cards = {}
            preview_result = nil
            dice_preview = nil
            mutation_result = nil
            return
        end
    end

    if fusion_mode == "same" then
        -- 同卡融合
        for i, pair in ipairs(fusible_pairs) do
            local btn_y = 150 + (i - 1) * 80 + 15
            if x >= win_w / 2 + 100 and x <= win_w / 2 + 200 and y >= btn_y and y <= btn_y + 40 then
                Fusion.execute_same_fusion(pair)
                return
            end
        end
    elseif fusion_mode == "dice" then
        -- 骰子融合：选择卡牌（使用缓存）
        local all_cards = cached_all_cards
        local card_width = 90
        local card_gap = 15
        local cards_start_x = win_w / 2 - (#all_cards * (card_width + card_gap)) / 2

        for i, card in ipairs(all_cards) do
            local card_x = cards_start_x + (i - 1) * (card_width + card_gap)
            if x >= card_x and x <= card_x + card_width and y >= 150 and y <= 270 then
                -- 检查是否已选中
                local already_selected = false
                for j, idx in ipairs(selected_cards) do
                    if idx == i then
                        already_selected = true
                        table.remove(selected_cards, j)
                        break
                    end
                end

                if not already_selected then
                    if #selected_cards < 2 then
                        table.insert(selected_cards, i)
                    end
                end
                return
            end
        end

        -- 骰子融合配方按钮
        if #selected_cards == 2 and dice_preview then
            for i, preview in ipairs(dice_preview) do
                local btn_y = 320 + (i - 1) * 60 + 8
                if x >= win_w / 2 + 120 and x <= win_w / 2 + 180 and y >= btn_y and y <= btn_y + 35 then
                    Fusion.execute_dice_fusion(i)
                    return
                end
            end
        end
    elseif fusion_mode == "free" then
        -- 自由融合：选择卡牌
        local all_cards = cached_all_cards
        local card_width = 80
        local card_height = 100
        local card_gap = 12
        local cards_per_row = math.min(6, #all_cards)
        local start_card_x = win_w / 2 - (cards_per_row * (card_width + card_gap)) / 2

        for i, card in ipairs(all_cards) do
            local row = math.floor((i - 1) / cards_per_row)
            local col = (i - 1) % cards_per_row
            local card_x = start_card_x + col * (card_width + card_gap)
            local card_y = 160 + row * (card_height + 15)

            if x >= card_x and x <= card_x + card_width and y >= card_y and y <= card_y + card_height then
                -- 检查是否已选中
                local already_selected = false
                for j, idx in ipairs(selected_cards) do
                    if idx == i then
                        already_selected = true
                        table.remove(selected_cards, j)
                        break
                    end
                end

                if not already_selected then
                    if #selected_cards < 2 then
                        table.insert(selected_cards, i)
                    end
                end
                return
            end
        end

        -- 自由融合按钮
        if #selected_cards == 2 then
            if x >= win_w / 2 + 100 and x <= win_w / 2 + 160 and y >= 395 and y <= 430 then
                Fusion.execute_free_fusion()
                return
            end
        end
    end

    -- 返回按钮（响应式）
    local btn_y = win_h * 0.85
    if x >= win_w / 2 - 60 and x <= win_w / 2 + 60 and y >= btn_y and y <= btn_y + 40 then
        State.pop()
    end
end

function Fusion.execute_same_fusion(pair)
    -- 检查融合次数限制
    if not FusionSystem.can_fuse_more() then
        message = "Fusion limit reached! (" .. FusionSystem.MAX_FUSIONS .. " per game)"
        message_timer = 2.0
        Sound.play("click")
        return
    end

    local all_cards = cached_all_cards
    local indices = pair.indices

    if #indices >= 2 then
        local card1 = all_cards[indices[1]]
        local card2 = all_cards[indices[2]]

        if not card1 or not card2 then return end

        local result = FusionSystem.fuse(card1, card2)

        if result then
            -- 增加融合计数
            FusionSystem.increment_fusion_count()

            -- 从牌库中移除两张原卡牌
            Deck.remove_from_deck_by_id(card1.id, 2)

            -- 添加融合卡牌到牌库
            Deck.add_fused_card(result)

            -- 播放融合音效
            Sound.play("fuse")

            message = I18n.tf("fusion_success", result.name)
            message_timer = 2.0

            -- 刷新缓存和可融合列表
            cached_all_cards = Deck.get_all_cards_for_fusion() or {}
            fusible_pairs = FusionSystem.find_fusible_pairs(cached_all_cards) or {}
        end
    end
end

function Fusion.execute_dice_fusion(recipe_index)
    -- 检查融合次数限制
    if not FusionSystem.can_fuse_more() then
        message = "Fusion limit reached! (" .. FusionSystem.MAX_FUSIONS .. " per game)"
        message_timer = 2.0
        Sound.play("click")
        selected_cards = {}
        dice_preview = nil
        return
    end

    if #selected_cards ~= 2 then return end

    local all_cards = cached_all_cards
    local card1 = all_cards[selected_cards[1]]
    local card2 = all_cards[selected_cards[2]]

    if not card1 or not card2 then return end

    local recipes = FusionSystem.find_dice_fusion_recipes(card1, card2)
    if not recipes or #recipes < recipe_index then return end

    local recipe = recipes[recipe_index]

    -- 执行骰子融合
    local success, result_card, result_msg = FusionSystem.dice_fuse(card1, card2, recipe)

    -- 增加融合计数（无论成功失败）
    FusionSystem.increment_fusion_count()

    -- 从牌库中移除两张原卡牌
    Deck.remove_from_deck_by_id(card1.id, 1)
    Deck.remove_from_deck_by_id(card2.id, 1)

    -- 如果成功，添加融合卡牌到牌库
    if success and result_card then
        Deck.add_fused_card(result_card)
        Sound.play("fuse")
    elseif result_card then
        -- 失败但有返还卡牌
        Deck.add_fused_card(result_card)
        Sound.play("click")
    else
        Sound.play("click")
    end

    message = result_msg
    message_timer = 2.5

    -- 重置选择
    selected_cards = {}
    dice_preview = nil

    -- 刷新缓存和候选列表
    cached_all_cards = Deck.get_all_cards_for_fusion() or {}
    dice_fusion_candidates = Fusion.find_dice_candidates(cached_all_cards) or {}
end

-- 【新】执行自由融合
function Fusion.execute_free_fusion()
    -- 检查融合次数限制
    if not FusionSystem.can_fuse_more() then
        message = "Fusion limit reached! (" .. FusionSystem.MAX_FUSIONS .. " per game)"
        message_timer = 2.0
        Sound.play("click")
        selected_cards = {}
        free_fuse_preview = nil
        return
    end

    if #selected_cards ~= 2 then return end

    local all_cards = cached_all_cards
    local card1 = all_cards[selected_cards[1]]
    local card2 = all_cards[selected_cards[2]]

    if not card1 or not card2 then return end

    -- 执行自由融合
    local result_card = FusionSystem.free_fuse(card1, card2)

    -- 增加融合计数
    FusionSystem.increment_fusion_count()

    if result_card then
        -- 从牌库中移除两张原卡牌
        Deck.remove_from_deck_by_id(card1.id, 1)
        Deck.remove_from_deck_by_id(card2.id, 1)

        -- 添加融合卡牌到牌库
        Deck.add_fused_card(result_card)

        -- 播放融合音效
        Sound.play("fuse")

        -- 显示结果和变异信息
        message = "Created " .. result_card.name .. "! Rarity: " .. result_card.rarity
        message_timer = 2.5

        -- 记录变异结果
        if result_card.mutation then
            mutation_result = {
                name = result_card.mutation,
                desc = result_card.mutation_desc,
                type = result_card.mutation_type,
            }
        else
            mutation_result = nil
        end
    else
        message = "Free fusion failed!"
        message_timer = 1.5
        Sound.play("click")
    end

    -- 重置选择
    selected_cards = {}
    free_fuse_preview = nil

    -- 刷新缓存
    cached_all_cards = Deck.get_all_cards_for_fusion() or {}
end

return Fusion