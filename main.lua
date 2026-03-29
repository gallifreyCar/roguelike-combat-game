-- main.lua - 游戏入口
-- 回合制战斗肉鸽游戏 (Love2D + Lua)

local State = require("core.state")
local Input = require("core.input")
local I18n = require("core.i18n")

function love.load()
    -- 初始化多语言
    I18n.init()

    -- 初始化游戏状态
    State.init()

    -- 进入主菜单
    State.switch("menu")
end

function love.update(dt)
    -- 更新当前状态
    State.update(dt)

    -- 处理输入
    Input.update(dt)
end

function love.draw()
    -- 渲染当前状态
    State.draw()
end

function love.keypressed(key)
    -- 键盘事件
    Input.on_key_press(key)

    -- 转发给当前状态
    if State.current and State.current.keypressed then
        State.current.keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    -- 鼠标事件
    Input.on_mouse_press(x, y, button)

    -- 转发给当前状态
    State.mousepressed(x, y, button)
end