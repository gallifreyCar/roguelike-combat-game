-- core/debug.lua - 调试工具
-- 运行时 UI 检查、日志、性能监控

local Debug = {}

local enabled = false
local show_fps = false
local show_hitboxes = false
local logs = {}
local max_logs = 20
local fps_history = {}
local frame_time = 0

-- 初始化
function Debug.init(options)
    options = options or {}
    enabled = options.enabled or false
    show_fps = options.show_fps or false
    show_hitboxes = options.show_hitboxes or false
end

-- 切换调试模式
function Debug.toggle()
    enabled = not enabled
    Debug.log("Debug mode: " .. (enabled and "ON" or "OFF"))
end

-- 切换 FPS 显示
function Debug.toggle_fps()
    show_fps = not show_fps
end

-- 切换碰撞盒显示
function Debug.toggle_hitboxes()
    show_hitboxes = not show_hitboxes
end

-- 记录日志
function Debug.log(message, level)
    level = level or "INFO"
    if #logs >= max_logs then
        table.remove(logs, 1)
    end
    table.insert(logs, {
        time = os.date("%H:%M:%S"),
        level = level,
        message = message,
    })
end

-- 更新
function Debug.update(dt)
    if not enabled then return end

    -- FPS 计算
    frame_time = dt
    table.insert(fps_history, 1, 1 / dt)
    if #fps_history > 60 then
        table.remove(fps_history)
    end
end

-- 绘制调试信息
function Debug.draw()
    if not enabled and not show_fps then return end

    local y = 10

    -- FPS 显示
    if show_fps or enabled then
        local fps = math.floor(1 / frame_time)
        local avg_fps = 0
        for _, f in ipairs(fps_history) do
            avg_fps = avg_fps + f
        end
        avg_fps = math.floor(avg_fps / #fps_history)

        love.graphics.setColor(1, 1, 0)
        love.graphics.print(string.format("FPS: %d (avg: %d)", fps, avg_fps), 10, y)
        y = y + 20
    end

    if not enabled then return end

    -- 内存使用
    local mem = collectgarbage("count")
    love.graphics.print(string.format("Memory: %.1f KB", mem), 10, y)
    y = y + 20

    -- 窗口尺寸
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.print(string.format("Window: %dx%d", w, h), 10, y)
    y = y + 20

    -- 鼠标位置
    local mx, my = love.mouse.getPosition()
    love.graphics.print(string.format("Mouse: %d, %d", mx, my), 10, y)
    y = y + 30

    -- 日志
    love.graphics.print("=== Debug Logs ===", 10, y)
    y = y + 20

    for i = #logs, math.max(1, #logs - 10), -1 do
        local log = logs[i]
        local color = {1, 1, 1}
        if log.level == "ERROR" then color = {1, 0.3, 0.3}
        elseif log.level == "WARN" then color = {1, 1, 0.3}
        end
        love.graphics.setColor(color)
        love.graphics.print(string.format("[%s] %s", log.time, log.message), 10, y)
        y = y + 16
    end
end

-- 绘制碰撞盒
function Debug.draw_hitbox(x, y, w, h, label)
    if not show_hitboxes then return end

    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", x, y, w, h)

    if label then
        love.graphics.print(label, x, y - 15)
    end
end

-- 快捷键处理
function Debug.keypressed(key)
    if key == "f1" then
        Debug.toggle()
    elseif key == "f2" then
        Debug.toggle_fps()
    elseif key == "f3" then
        Debug.toggle_hitboxes()
    end
end

-- 获取状态
function Debug.is_enabled()
    return enabled
end

function Debug.showing_fps()
    return show_fps
end

function Debug.showing_hitboxes()
    return show_hitboxes
end

return Debug