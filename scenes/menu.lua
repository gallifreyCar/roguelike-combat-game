-- scenes/menu.lua - 主菜单场景

local Menu = {}
local I18n = require("core.i18n")

function Menu.enter()
    -- 进入菜单时初始化
end

function Menu.exit()
    -- 退出菜单时清理
end

function Menu.update(dt)
    -- 菜单更新逻辑
end

function Menu.draw()
    -- 渲染菜单
    love.graphics.clear(0.1, 0.1, 0.15)

    -- 标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(I18n.t("title"), 400, 200)

    -- 语言指示
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("[" .. I18n.get_lang_name() .. "]", 520, 240)

    -- 提示
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(I18n.t("press_start"), 450, 350)
    love.graphics.print(I18n.t("press_quit"), 450, 400)
    love.graphics.print(I18n.t("language"), 450, 450)
end

function Menu.keypressed(key)
    if key == "space" then
        -- 开始游戏
        local State = require("core.state")
        State.switch("combat")
    elseif key == "l" then
        -- 切换语言
        I18n.toggle_lang()
    end
end

return Menu