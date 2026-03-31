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

-- 【性能优化】增强帧率统计
local fps_stats = {
    min_fps = 999,
    max_fps = 0,
    avg_fps = 0,
    sample_count = 0,
    last_reset_time = 0,
}

-- FPS 历史 Max samples
local MAX_FPS_SAMPLES = 60

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
    if not enabled and not show_fps then return end

    -- FPS 计算
    frame_time = dt
    local current_fps = dt > 0 and math.floor(1 / dt) or 0

    -- 【性能优化】使用固定长度数组（避免 table.remove 开销）
    table.insert(fps_history, 1, current_fps)
    if #fps_history > MAX_FPS_SAMPLES then
        fps_history[MAX_FPS_SAMPLES + 1] = nil  -- 直接删除最后一个
    end

    -- 【性能优化】更新帧率统计
    fps_stats.sample_count = fps_stats.sample_count + 1
    if current_fps > 0 then
        fps_stats.min_fps = math.min(fps_stats.min_fps, current_fps)
        fps_stats.max_fps = math.max(fps_stats.max_fps, current_fps)
    end

    -- 每5秒重置 min/max（避免极端值持续影响）
    local now = love.timer.getTime()
    if now - fps_stats.last_reset_time > 5 then
        fps_stats.min_fps = current_fps
        fps_stats.max_fps = current_fps
        fps_stats.last_reset_time = now
    end
end

-- 绘制调试信息
function Debug.draw()
    if not enabled and not show_fps then return end

    local y = 10

    -- FPS 显示（增强版）
    if show_fps or enabled then
        local fps = frame_time > 0 and math.floor(1 / frame_time) or 0
        local avg_fps = 0
        if #fps_history > 0 then
            for _, f in ipairs(fps_history) do
                avg_fps = avg_fps + f
            end
            avg_fps = math.floor(avg_fps / #fps_history)
            fps_stats.avg_fps = avg_fps
        end

        -- 【性能优化】显示帧率范围
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(string.format("FPS: %d | Avg: %d | Min: %d | Max: %d",
            fps, avg_fps, fps_stats.min_fps, fps_stats.max_fps), 10, y)
        y = y + 20

        -- 【性能优化】帧时间显示（微秒）
        local frame_us = math.floor(frame_time * 1000000)
        love.graphics.setColor(0.8, 0.8, 1)
        love.graphics.print(string.format("Frame: %d us (%.2f ms)", frame_us, frame_time * 1000), 10, y)
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