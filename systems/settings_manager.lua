-- systems/settings_manager.lua - 游戏设置管理
-- 持久化设置：音量、语言、游戏选项

local SettingsManager = {}

-- 默认设置
local default_settings = {
    -- 音频
    master_volume = 1.0,
    music_volume = 0.7,
    sfx_volume = 0.8,

    -- 显示
    fullscreen = false,
    vsync = true,

    -- 游戏
    language = "en",
    show_tutorial = true,
    auto_end_turn = false,

    -- 存档相关
    save_slot = 1,
}

-- 当前设置
local current_settings = {}

-- 设置文件路径
local settings_file = "settings.json"

-- 加载设置
function SettingsManager.load()
    -- 使用love.filesystem读取
    if love.filesystem.getInfo(settings_file) then
        local content = love.filesystem.read(settings_file)
        if content then
            -- 解析Lua表格式（保存时就是Lua格式）
            local success, settings = pcall(function()
                return load(content)()  -- content 已经是 "return {...}" 格式
            end)

            if success and type(settings) == "table" then
                current_settings = settings
                -- 填充缺失的默认值
                for key, value in pairs(default_settings) do
                    if current_settings[key] == nil then
                        current_settings[key] = value
                    end
                end
            else
                current_settings = SettingsManager.reset()
            end
        else
            current_settings = SettingsManager.reset()
        end
    else
        current_settings = SettingsManager.reset()
    end

    return current_settings
end

-- 保存设置
function SettingsManager.save()
    -- 简单JSON序列化
    local function serialize(t, indent)
        indent = indent or ""
        local result = "{\n"
        for k, v in pairs(t) do
            result = result .. indent .. "  "
            if type(k) == "string" then
                result = result .. '["' .. k .. '"] = '
            end
            if type(v) == "string" then
                result = result .. '"' .. v .. '"'
            elseif type(v) == "number" then
                result = result .. tostring(v)
            elseif type(v) == "boolean" then
                result = result .. tostring(v)
            elseif type(v) == "table" then
                result = result .. serialize(v, indent .. "  ")
            end
            result = result .. ",\n"
        end
        result = result .. indent .. "}"
        return result
    end

    local content = "return " .. serialize(current_settings)
    love.filesystem.write(settings_file, content)
    return true
end

-- 获取设置值
function SettingsManager.get(key)
    return current_settings[key] or default_settings[key]
end

-- 设置值
function SettingsManager.set(key, value)
    current_settings[key] = value
    SettingsManager.save()
end

-- 重置为默认
function SettingsManager.reset()
    current_settings = {}
    for key, value in pairs(default_settings) do
        current_settings[key] = value
    end
    SettingsManager.save()
    return current_settings
end

-- 获取所有设置
function SettingsManager.get_all()
    return current_settings
end

-- 应用音量设置
function SettingsManager.apply_volume()
    local master = current_settings.master_volume or 1.0
    local music = current_settings.music_volume or 0.7
    local sfx = current_settings.sfx_volume or 0.8

    -- Love2D音量设置
    if love.audio then
        love.audio.setVolume(master)
    end

    return {
        music = music * master,
        sfx = sfx * master,
    }
end

-- 切换全屏
function SettingsManager.toggle_fullscreen()
    current_settings.fullscreen = not current_settings.fullscreen
    if love.window then
        love.window.setFullscreen(current_settings.fullscreen)
    end
    SettingsManager.save()
    return current_settings.fullscreen
end

-- 切换语言
function SettingsManager.set_language(lang)
    current_settings.language = lang
    SettingsManager.save()
end

return SettingsManager