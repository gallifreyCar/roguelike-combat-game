-- systems/save.lua - 存档系统
-- 保存/加载游戏进度

local Save = {}

-- 存档文件路径
local SAVE_FILE = "save/game_save.json"

-- 存档数据结构
local save_data = {
    version = 1,
    timestamp = 0,

    -- 玩家数据
    player = {
        hp = 20,
        max_hp = 20,
        level = 1,
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
    },
}

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

    local file = io.open(SAVE_FILE, "w")
    if file then
        file:write("return " .. serialize(save_data))
        file:close()
        print("Game saved successfully!")
        return true
    end

    print("Failed to save game!")
    return false
end

-- 加载游戏
function Save.load()
    local file = io.open(SAVE_FILE, "r")
    if file then
        local content = file:read("*all")
        file:close()

        local success, data = pcall(load(content))
        if success and type(data) == "table" then
            save_data = data
            print("Game loaded successfully!")
            return save_data
        end
    end

    print("No save file found or corrupted!")
    return nil
end

-- 检查存档是否存在
function Save.exists()
    local file = io.open(SAVE_FILE, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- 删除存档
function Save.delete()
    os.remove(SAVE_FILE)
    save_data = {
        version = 1,
        timestamp = 0,
        player = { hp = 20, max_hp = 20, level = 1 },
        deck = {},
        map = { current_row = 1, current_col = 1 },
        stats = { battles_won = 0, cards_played = 0, enemies_defeated = 0 },
    }
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

return Save