function love.conf(t)
    t.window.width = 1280
    t.window.height = 720
    t.window.title = "Roguelike Combat Game"
    t.window.display = 1
    t.window.vsync = true  -- 启用垂直同步，限制帧率

    -- 开发模式设置
    t.console = true           -- 开启控制台（调试用）
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
end