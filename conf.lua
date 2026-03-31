-- Blood Cards - 回合制卡牌肉鸽游戏
-- Version: 1.0.0 (Round 10 Release)
-- LÖVE 11.5

function love.conf(t)
    -- 窗口配置
    t.window.width = 1280
    t.window.height = 720
    t.window.title = "Blood Cards"
    t.window.display = 1

    -- 发布模式设置
    t.console = false          -- 关闭控制台（发布版本）
    t.version = "11.5"         -- LÖVE 版本要求

    -- 模块启用
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false  -- 暂不需要
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false   -- 不需要物理引擎
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
    t.modules.video = false     -- 暂不需要

    -- 版本标识（用于存档兼容性检查）
    t.identity = "blood_cards"
end