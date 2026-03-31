-- scenes/tutorial.lua - 教程场景
-- 完整的新手引导面板

local Tutorial = {}
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local TutorialSystem = require("systems.tutorial")
local Animation = require("systems.animation")

-- 教程页面
local PAGES = {
    {
        title_key = "tutorial_welcome",
        desc_key = "tutorial_welcome_desc",
        content_keys = {"tutorial_goal", "tutorial_goal_desc"},
    },
    {
        title_key = "tutorial_hand_title",
        desc_key = "tutorial_hand_desc",
        highlight = "hand",
    },
    {
        title_key = "tutorial_blood_title",
        desc_key = "tutorial_blood_desc",
        highlight = "blood",
    },
    {
        title_key = "tutorial_sacrifice_title",
        desc_key = "tutorial_sacrifice_desc",
        highlight = "sacrifice",
    },
    {
        title_key = "tutorial_battle_title",
        desc_key = "tutorial_battle_desc",
        highlight = "battle",
    },
    {
        title_key = "tutorial_tips_title",
        desc_keys = {"tutorial_tips_1", "tutorial_tips_2", "tutorial_tips_3", "tutorial_tips_4"},
    },
}

local current_page = 1

function Tutorial.enter()
    current_page = 1
    Animation.fade_in(0.2)
end

function Tutorial.exit()
end

function Tutorial.update(dt)
end

function Tutorial.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 背景遮罩
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, win_w, win_h)

    -- 教程面板
    local panel_w = math.min(500, win_w * 0.85)
    local panel_h = math.min(400, win_h * 0.7)
    local panel_x = (win_w - panel_w) / 2
    local panel_y = (win_h - panel_h) / 2

    -- 面板阴影
    Theme.setColor("bg_primary", 0.5)
    love.graphics.rectangle("fill", panel_x + 5, panel_y + 5, panel_w, panel_h, 12, 12)

    -- 面板背景
    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 12, 12)
    Theme.setColor("border_gold", 0.6)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 12, 12)

    -- 标题
    local page = PAGES[current_page]
    if page then
        Components.text(I18n.t(page.title_key), win_w / 2, panel_y + 30, {
            color = "accent_gold",
            align = "center",
            size = 22,
        })

        -- 描述
        if page.desc_key then
            Components.text(I18n.t(page.desc_key), win_w / 2, panel_y + 70, {
                color = "text_secondary",
                align = "center",
                size = 14,
            })
        end

        -- 内容区域
        local content_y = panel_y + 110
        if page.content_keys then
            for i, key in ipairs(page.content_keys) do
                local color = (i % 2 == 1) and "text_secondary" or "text_hint"
                Components.text(I18n.t(key), win_w / 2, content_y, {
                    color = color,
                    align = "center",
                    size = 14,
                })
                content_y = content_y + 25
            end
        end

        -- 高亮说明
        if page.highlight then
            Theme.setColor("bg_slot")
            love.graphics.rectangle("fill", panel_x + 30, content_y, panel_w - 60, 60, 8, 8)

            local hint = ""
            if page.highlight == "hand" then
                hint = "Cards appear on the RIGHT side. Drag them to board slots."
            elseif page.highlight == "blood" then
                hint = "Blood = Card Cost (red number). You start with 1 each turn."
            elseif page.highlight == "sacrifice" then
                hint = "RIGHT-click a card on board to sacrifice it for +1 Blood!"
            elseif page.highlight == "battle" then
                hint = "Press SPACE or click BATTLE button when ready to fight!"
            end
            Components.text(hint, win_w / 2, content_y + 25, {
                color = "text_secondary",
                align = "center",
                size = 13,
            })
        end

        -- 技巧列表
        if page.desc_keys then
            for i, key in ipairs(page.desc_keys) do
                Components.text(I18n.t(key), panel_x + 50, content_y + (i - 1) * 30, {
                    color = "text_secondary",
                    size = 13,
                })
            end
        end
    end

    -- 页码
    Components.text(current_page .. " / " .. #PAGES, win_w / 2, panel_y + panel_h - 60, {
        color = "text_hint",
        align = "center",
        size = 12,
    })

    -- 按钮
    local btn_y = panel_y + panel_h - 45

    -- Skip按钮
    local skip_x = panel_x + 30
    Theme.setColor("bg_slot")
    love.graphics.rectangle("fill", skip_x, btn_y, 100, 35, 8, 8)
    Components.text(I18n.t("tutorial_skip"), skip_x + 50, btn_y + 10, {
        color = "text_secondary",
        align = "center",
    })

    -- Next/Back按钮
    if current_page < #PAGES then
        local next_x = panel_x + panel_w - 130
        Theme.setColor("accent_gold", 0.7)
        love.graphics.rectangle("fill", next_x, btn_y, 100, 35, 8, 8)
        Components.text(I18n.t("tutorial_next"), next_x + 50, btn_y + 10, {
            color = "text_primary",
            align = "center",
        })
    else
        -- 最后一页显示Close
        local close_x = panel_x + panel_w - 130
        Theme.setColor("accent_gold", 0.7)
        love.graphics.rectangle("fill", close_x, btn_y, 100, 35, 8, 8)
        Components.text(I18n.t("ok"), close_x + 50, btn_y + 10, {
            color = "text_primary",
            align = "center",
        })
    end

    -- 绘制过渡动画
    Animation.draw()
end

function Tutorial.keypressed(key)
    if key == "escape" then
        State.pop()
    elseif key == "space" or key == "return" then
        if current_page < #PAGES then
            current_page = current_page + 1
        else
            State.pop()
        end
    elseif key == "left" or key == "a" then
        if current_page > 1 then
            current_page = current_page - 1
        end
    elseif key == "right" or key == "d" then
        if current_page < #PAGES then
            current_page = current_page + 1
        end
    end
end

function Tutorial.mousepressed(x, y, button)
    if button ~= 1 then return end

    local win_w, win_h = Layout.get_size()
    local panel_w = math.min(500, win_w * 0.85)
    local panel_h = math.min(400, win_h * 0.7)
    local panel_x = (win_w - panel_w) / 2
    local panel_y = (win_h - panel_h) / 2
    local btn_y = panel_y + panel_h - 45

    -- Skip按钮
    if x >= panel_x + 30 and x <= panel_x + 130 and y >= btn_y and y <= btn_y + 35 then
        State.pop()
        return
    end

    -- Next/Close按钮
    local btn_x = panel_x + panel_w - 130
    if x >= btn_x and x <= btn_x + 100 and y >= btn_y and y <= btn_y + 35 then
        if current_page < #PAGES then
            current_page = current_page + 1
        else
            State.pop()
        end
    end
end

return Tutorial