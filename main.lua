-- main.lua - 游戏入口
-- 集成所有核心系统：Theme、Layout、Events、Debug、Hotload、Testing

local State = require("core.state")
local Input = require("core.input")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local SettingsManager = require("systems.settings_manager")
local Debug = require("core.debug")
local Events = require("core.events")
local Hotload = require("core.hotload")
local Sound = require("systems.sound")

-- 配置
local DEBUG_MODE = false  -- 设置为 true 开启调试
local HOTLOAD_MODE = false  -- 设置为 true 开发热重载

function love.load()
    -- 初始化调试系统
    Debug.init({
        enabled = DEBUG_MODE,
        show_fps = DEBUG_MODE,
        show_hitboxes = false,
    })

    -- 初始化热重载（开发模式）
    Hotload.init({enabled = HOTLOAD_MODE})

    -- 初始化字体（支持中文）
    Fonts.init()

    -- 初始化音效系统（动态波形生成）
    Sound.init()

    -- 加载设置并应用
    local settings = SettingsManager.load()

    -- 初始化多语言系统
    I18n.init()

    -- 应用保存的语言设置
    if settings.language then
        I18n.set_lang(settings.language)
        Events.emit(Events.LANGUAGE_CHANGE, settings.language)
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

    -- 触发场景切换事件
    Events.emit(Events.SCENE_CHANGE, "menu")

    Debug.log("Game loaded successfully")
end

function love.update(dt)
    -- 调试更新
    Debug.update(dt)

    -- 热重载检查
    Hotload.update(dt)

    -- 状态更新
    State.update(dt)
    Input.update(dt)
end

function love.draw()
    -- 绘制游戏场景
    State.draw()

    -- 绘制调试信息（在所有内容之上）
    Debug.draw()
end

function love.keypressed(key)
    -- 调试快捷键
    Debug.keypressed(key)
    Hotload.keypressed(key)

    -- 测试快捷键（F10 运行测试）
    if key == "f10" then
        local Testing = require("core.testing")
        Testing.run_all()
        return
    end

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
    Input.on_mouse_release(x, y, button)
    State.mousereleased(x, y, button)
end

-- 错误处理
function love.errorhandler(msg)
    Debug.log("Fatal error: " .. tostring(msg), "ERROR")
    return love.errorhandler(msg)
end