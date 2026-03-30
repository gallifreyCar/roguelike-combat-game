-- main.lua - 游戏入口

local State = require("core.state")
local Input = require("core.input")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local SettingsManager = require("systems.settings_manager")

function love.load()
    -- 初始化字体（支持中文）
    Fonts.init()

    -- 加载设置并应用
    local settings = SettingsManager.load()

    -- 初始化多语言系统
    I18n.init()

    -- 应用保存的语言设置
    if settings.language then
        I18n.set_lang(settings.language)
    end

    -- 应用音量设置
    SettingsManager.apply_volume()

    -- 应用全屏设置
    if settings.fullscreen then
        love.window.setFullscreen(true)
    end

    -- 初始化状态机
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