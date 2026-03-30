-- scenes/death.lua - 死亡场景
-- 使用 Theme 和 Components 重构

local Death = {}
local State = require("core.state")
local Map = require("systems.map")
local Deck = require("systems.deck")  -- [BUG FIX] 添加 Deck 模块导入
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")

local buttons = {}

function Death.enter()
    -- 计算按钮位置
    local btn_w, btn_h = 200, 40
    local btn_x = Layout.center_x(btn_w)
    buttons = {
        retry = {x = btn_x, y = 340, width = btn_w, height = btn_h},
        menu = {x = btn_x, y = 400, width = btn_w, height = btn_h},
    }
end

function Death.exit()
end

function Death.update(dt)
end

function Death.draw()
    -- 背景
    Theme.setColor("accent_red", 0.3)
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    -- 标题
    Components.text(I18n.t("defeated"), win_w / 2, 200, {
        color = "accent_red",
        size = 24,
        align = "center",
    })

    -- 副标题
    Components.text(I18n.t("fallen"), win_w / 2, 280, {
        color = "text_secondary",
        align = "center",
    })

    -- 重试按钮
    local retry_hover = Layout.mouse_in_button(buttons.retry)
    Components.button(I18n.t("retry"), buttons.retry.x, buttons.retry.y,
                      buttons.retry.width, buttons.retry.height, {
        hover = retry_hover,
        style = "danger",
    })

    -- 菜单按钮
    local menu_hover = Layout.mouse_in_button(buttons.menu)
    Components.button(I18n.t("menu_btn"), buttons.menu.x, buttons.menu.y,
                      buttons.menu.width, buttons.menu.height, {
        hover = menu_hover,
    })

    -- 操作提示
    Components.text(I18n.t("death_hint"), win_w / 2, 480, {
        color = "text_hint",
        align = "center",
    })
end

function Death.keypressed(key)
    if key == "space" then
        Map.reset()
        Map.generate()
        Deck.reset()  -- [BUG FIX] 重试时重置牌组
        State.switch("map")
    elseif key == "escape" then
        Map.reset()
        Deck.reset()  -- [BUG FIX] 返回菜单时重置牌组
        State.switch("menu")
    end
end

function Death.mousepressed(x, y, button)
    if button ~= 1 then return end

    if Layout.mouse_in_button(buttons.retry) then
        Map.reset()
        Map.generate()
        Deck.reset()  -- [BUG FIX] 重试时重置牌组
        State.switch("map")
    elseif Layout.mouse_in_button(buttons.menu) then
        Map.reset()
        Deck.reset()  -- [BUG FIX] 返回菜单时重置牌组
        State.switch("menu")
    end
end

return Death