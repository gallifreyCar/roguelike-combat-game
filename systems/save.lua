-- systems/save.lua - 存档系统
-- 保存/加载游戏进度

local Save = {}

-- 存档文件路径
local SAVE_FILE = "game_save.lua"

-- 存档数据结构（默认值）
local default_save_data = {
    version = 2,  -- 版本升级
    timestamp = 0,

    -- 玩家数据
    player = {
        hp = 20,
        max_hp = 20,
        level = 1,
        coins = 50,  -- 初始金币
    },

    -- 牌组
    deck = {},

    -- 地图进度
    map = {
        current_row = 1,
        current_col = 1,
    },

    -- 统计
    stats = {
        battles_won = 0,
        cards_played = 0,
        enemies_defeated = 0,
        total_runs = 0,  -- 总游戏次数
    },

    -- 局外成长（新增）
    progress = {
        total_runs = 0,      -- 总通关次数
        total_exp = 0,       -- 累计经验
        level = 1,           -- 玩家等级
        unlock_points = 0,   -- 解锁点数
        unlocks = {},        -- 已解锁内容
    },
}

-- 当前存档数据
local save_data = {}

-- 深度合并默认值
local function merge_defaults(data, defaults)
    local result = {}
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            result[k] = merge_defaults(data[k] or {}, v)
        else
            result[k] = data[k] ~= nil and data[k] or v
        end
    end
    return result
end

-- 序列化表为字符串
local function serialize(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        if type(t) == "string" then
            return '"' .. t .. '"'
        elseif type(t) == "boolean" then
            return t and "true" or "false"
        else
            return tostring(t)
        end
    end

    local result = "{\n"
    for k, v in pairs(t) do
        result = result .. indent .. "  "
        if type(k) == "string" then
            result = result .. '["' .. k .. '"] = '
        else
            result = result .. "[" .. tostring(k) .. "] = "
        end
        result = result .. serialize(v, indent .. "  ") .. ",\n"
    end
    result = result .. indent .. "}"
    return result
end

-- 保存游戏
function Save.save(player_data, deck_data, map_data)
    save_data.timestamp = os.time()
    save_data.player = player_data or save_data.player
    save_data.deck = deck_data or save_data.deck
    save_data.map = map_data or save_data.map

    local content = "return " .. serialize(save_data)
    local success, err = pcall(function()
        love.filesystem.write(SAVE_FILE, content)
    end)

    if success then
        print("Game saved successfully!")
        return true
    else
        print("Failed to save game: " .. tostring(err))
        return false
    end
end

-- 加载游戏
function Save.load()
    if love.filesystem.getInfo(SAVE_FILE) then
        local content = love.filesystem.read(SAVE_FILE)
        if content then
            -- [BUG FIX] 安全加载：确保 load() 返回有效函数
            local load_func = load(content)
            if load_func then
                local success, data = pcall(load_func)
                if success and type(data) == "table" then
                    -- 合并默认值（处理版本升级时缺失字段）
                    save_data = merge_defaults(data, default_save_data)
                    print("Game loaded successfully!")
                    return save_data
                end
            end
        end
    end

    print("No save file found or corrupted!")
    return nil
end

-- 检查存档是否存在
function Save.exists()
    return love.filesystem.getInfo(SAVE_FILE) ~= nil
end

-- 删除存档
function Save.delete()
    love.filesystem.remove(SAVE_FILE)
    save_data = {}
    for k, v in pairs(default_save_data) do
        save_data[k] = v
    end
    print("Save deleted!")
end

-- 获取存档信息
function Save.get_info()
    if not Save.exists() then
        return nil
    end

    local data = Save.load()
    if data then
        return {
            timestamp = data.timestamp or 0,
            level = data.player and data.player.level or 1,
            deck_size = data.deck and #data.deck or 0,
            battles_won = data.stats and data.stats.battles_won or 0,
        }
    end
    return nil
end

-- 更新统计
function Save.update_stat(stat_name, value)
    if save_data.stats then
        save_data.stats[stat_name] = (save_data.stats[stat_name] or 0) + value
    end
end

-- 获取存档数据
function Save.get_data()
    return save_data
end

-- ==================== 金币系统 ====================

-- 获取当前金币
function Save.get_coins()
    return save_data.player and save_data.player.coins or 0
end

-- 增加金币
function Save.add_coins(amount)
    if save_data.player then
        save_data.player.coins = (save_data.player.coins or 0) + amount
        -- 同步保存
        Save.save(save_data.player, save_data.deck, save_data.map)
    end
    return Save.get_coins()
end

-- 消费金币（返回是否成功）
function Save.spend_coins(amount)
    local current = Save.get_coins()
    if current >= amount then
        save_data.player.coins = current - amount
        -- 同步保存
        Save.save(save_data.player, save_data.deck, save_data.map)
        return true
    end
    return false
end

-- 设置金币（用于初始化或重置）
function Save.set_coins(amount)
    if save_data.player then
        save_data.player.coins = amount
    end
end

return Save