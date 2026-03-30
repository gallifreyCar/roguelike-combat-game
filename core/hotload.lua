-- core/hotload.lua - 热重载系统
-- 开发时自动重载修改的模块，无需重启游戏

local Hotload = {}

local enabled = false
local watched_files = {}
local file_timestamps = {}
local module_paths = {}

-- 初始化
function Hotload.init(options)
    options = options or {}
    enabled = options.enabled or false

    if enabled then
        Hotload.log("Hotload enabled - Press F5 to reload all modules")
    end
end

-- 注册需要监控的模块
function Hotload.watch(module_name, file_path)
    watched_files[module_name] = file_path
    module_paths[module_name] = package.loaded[module_name]

    -- 记录文件时间戳
    local info = love.filesystem.getInfo(file_path)
    if info then
        file_timestamps[file_path] = info.modtime
    end
end

-- 检查文件是否有更新
function Hotload.check_changes()
    if not enabled then return {} end

    local changed = {}

    for module_name, file_path in pairs(watched_files) do
        local info = love.filesystem.getInfo(file_path)
        if info then
            if file_timestamps[file_path] ~= info.modtime then
                file_timestamps[file_path] = info.modtime
                table.insert(changed, module_name)
            end
        end
    end

    return changed
end

-- 重载单个模块
function Hotload.reload(module_name)
    local file_path = watched_files[module_name]
    if not file_path then
        Hotload.log("Module not found: " .. module_name, "WARN")
        return false
    end

    -- 清除缓存
    package.loaded[module_name] = nil

    -- 重新加载
    local success, result = pcall(require, module_name)
    if success then
        Hotload.log("Reloaded: " .. module_name)
        return true
    else
        Hotload.log("Failed to reload " .. module_name .. ": " .. tostring(result), "ERROR")
        -- 恢复旧版本
        package.loaded[module_name] = module_paths[module_name]
        return false
    end
end

-- 重载所有模块
function Hotload.reload_all()
    local count = 0
    for module_name, _ in pairs(watched_files) do
        if Hotload.reload(module_name) then
            count = count + 1
        end
    end
    Hotload.log(string.format("Reloaded %d modules", count))
    return count
end

-- 更新（每帧检查）
function Hotload.update(dt)
    if not enabled then return end

    local changed = Hotload.check_changes()
    if #changed > 0 then
        for _, module_name in ipairs(changed) do
            Hotload.reload(module_name)
        end
    end
end

-- 快捷键处理
function Hotload.keypressed(key)
    if not enabled then return end

    if key == "f5" then
        Hotload.reload_all()
    elseif key == "f6" then
        -- 重载当前场景
        local State = require("core.state")
        if State.current and State.current.exit and State.current.enter then
            State.current:exit()
            State.current:enter()
            Hotload.log("Reloaded current scene")
        end
    end
end

-- 日志
function Hotload.log(message, level)
    level = level or "INFO"
    print(string.format("[Hotload][%s] %s", level, message))
end

-- 切换启用状态
function Hotload.toggle()
    enabled = not enabled
    Hotload.log("Hotload " .. (enabled and "enabled" or "disabled"))
end

return Hotload