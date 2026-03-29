-- main.lua - 游戏入口

local State = require("core.state")
local Input = require("core.input")

function love.load()
    State.init()
    State.switch("menu")
end

function love.update(dt)
    State.update(dt)
    Input.update(dt)
end

function love.draw()
    State.draw()
end

function love.keypressed(key)
    Input.on_key_press(key)
    State.keypressed(key)
end

function love.mousepressed(x, y, button)
    Input.on_mouse_press(x, y, button)
    State.mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    State.mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
    State.mousereleased(x, y, button)
end