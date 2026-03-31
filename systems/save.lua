-- systems/save.lua - 存档系统
-- 保存/加载游戏进度，支持多存档槽位和完整性校验

local Save = {}

-- ==================== 常量定义 ====================

-- 存档版本（用于版本升级和数据迁移）
local SAVE_VERSION = 3

-- 存档槽位数量
local SLOT_COUNT = 3

-- 存档目录
local SAVE_DIR = "save"

-- ==================== 存档数据结构（默认值） ====================

local default_save_data = {
    version = SAVE_VERSION,
    timestamp = 0,
    checksum = "",  -- 数据校验值

    -- 玩家数据
    player = {
        hp = 20,
        max_hp = 20,
        level = 1,
        coins = 50,
        current_row = 1,
        current_col = 1,
    },

    -- 牌组
    deck = {
        cards = {},      -- 卡牌列表
        squirrel_count = 0,  -- 松鼠牌数量
    },

    -- 地图进度
    map = {
        current_row = 1,
        current_col = 1,
        nodes = {},      -- 地图节点状态
    },

    -- 当前回合统计
    stats = {
        battles_won = 0,
        cards_played = 0,
        enemies_defeated = 0,
        sacrifices = 0,
        cards_fused = 0,
        floors_completed = 0,
        gold_collected = 0,
        time_started = 0,   -- 回合开始时间
    },

    -- 局外成长（持久化）
    progress = {
        -- Currency
        unlock_points = 0,
        total_exp = 0,
        level = 1,

        -- Statistics
        total_runs = 0,
        wins = 0,
        losses = 0,
        best_win_streak = 0,
        current_streak = 0,
        fastest_win = nil,

        -- Upgrades (key = upgrade_id, value = level)
        upgrades = {
            hp_boost = 0,
            gold_boost = 0,
            blood_boost = 0,
            better_squirrel = 0,
            starting_rare = 0,
            gold_bonus = 0,
        },

        -- Unlocks
        unlocked_cards = {},
        unlocked_sigils = {},
        unlocked_features = {},
    },

    -- 成就进度
    achievements = {
        unlocked = {},    -- 已解锁成就ID列表
        stats = {
            battles_won = 0,
            enemies_defeated = 0,
            cards_in_deck = 0,
            cards_fused = 0,
            floors_completed = 0,
            sacrifices = 0,
        },
    },

    -- 游戏设置（可选持久化）
    settings = {
        language = "zh",
        sound_volume = 1.0,
        music_volume = 0.8,
    },
}

-- 当前使用的存档槽位
local current_slot = 1

-- 当前存档数据
local save_data = {}

-- ==================== 辅助函数 ====================

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
    -- 保留额外的字段（向后兼容）
    for k, v in pairs(data) do
        if result[k] == nil then
            result[k] = v
        end
    end
    return result
end

-- 深度复制表
local function deep_copy(t)
    if type(t) ~= "table" then return t end
    local result = {}
    for k, v in pairs(t) do
        result[deep_copy(k)] = deep_copy(v)
    end
    return result
end

-- 计算校验值（简单哈希）
local function calculate_checksum(data)
    -- 使用简单字符串拼接哈希
    local hash = 0
    local function hash_table(t)
        for k, v in pairs(t) do
            if type(k) == "string" then
                for i = 1, #k do
                    hash = (hash * 31 + string.byte(k, i)) % 2147483647
                end
            elseif type(k) == "number" then
                hash = (hash * 31 + k) % 2147483647
            end

            if type(v) == "table" then
                hash_table(v)
            elseif type(v) == "string" then
                for i = 1, #v do
                    hash = (hash * 31 + string.byte(v, i)) % 2147483647
                end
            elseif type(v) == "number" then
                hash = (hash * 31 + v) % 2147483647
            elseif type(v) == "boolean" then
                hash = (hash * 31 + (v and 1 or 0)) % 2147483647
            end
        end
    end
    hash_table(data)
    return tostring(hash)
end

-- 序列化表为JSON格式字符串
local function serialize_to_json(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        if type(t) == "string" then
            return '"' .. t:gsub('"', '\\"') .. '"'
        elseif type(t) == "boolean" then
            return t and "true" or "false"
        elseif type(t) == "number" then
            return tostring(t)
        elseif t == nil then
            return "null"
        else
            return '"' .. tostring(t) .. '"'
        end
    end

    -- 检查是否是数组（连续数字索引）
    local is_array = true
    local max_index = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
            is_array = false
            break
        end
        max_index = math.max(max_index, k)
    end
    if is_array then
        for i = 1, max_index do
            if t[i] == nil then
                is_array = false
                break
            end
        end
    end

    local result
    if is_array then
        result = "[\n"
        for i = 1, max_index do
            result = result .. indent .. "  " .. serialize_to_json(t[i], indent .. "  ")
            if i < max_index then
                result = result .. ","
            end
            result = result .. "\n"
        end
        result = result .. indent .. "]"
    else
        result = "{\n"
        local keys = {}
        for k in pairs(t) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            if type(a) == type(b) then
                return a < b
            else
                return type(a) < type(b)
            end
        end)
        for i, k in ipairs(keys) do
            local v = t[k]
            result = result .. indent .. '  "' .. tostring(k) .. '": ' .. serialize_to_json(v, indent .. "  ")
            if i < #keys then
                result = result .. ","
            end
            result = result .. "\n"
        end
        result = result .. indent .. "}"
    end
    return result
end

-- 从JSON解析（简化版）
local function parse_json(content)
    -- 使用 Lua 原生 load 解析（格式化为 Lua 表）
    local lua_content = content
        :gsub('"([^"]+)"', function(s) return '["' .. s .. '"]' end)
        :gsub(':', '=')
        :gsub('true', 'true')
        :gsub('false', 'false')
        :gsub('null', 'nil')

    -- 安全加载
    local func = load("return " .. lua_content)
    if func then
        return func()
    end
    return nil
end

-- 获取存档文件名
local function get_slot_filename(slot)
    return SAVE_DIR .. "/slot_" .. slot .. ".json"
end

-- ==================== 槽位管理 ====================

-- 设置当前槽位
function Save.set_slot(slot)
    if slot >= 1 and slot <= SLOT_COUNT then
        current_slot = slot
    end
end

-- 获取当前槽位
function Save.get_slot()
    return current_slot
end

-- 获取所有槽位信息
function Save.get_all_slots_info()
    local slots = {}
    for i = 1, SLOT_COUNT do
        slots[i] = Save.get_slot_info(i)
    end
    return slots
end

-- 获取单个槽位信息
function Save.get_slot_info(slot)
    slot = slot or current_slot
    local filename = get_slot_filename(slot)

    if love.filesystem.getInfo(filename) then
        local content = love.filesystem.read(filename)
        if content then
            local data = parse_json(content)
            if data and type(data) == "table" then
                -- 校验完整性
                local valid = Save.verify_integrity(data)

                return {
                    slot = slot,
                    exists = true,
                    valid = valid,
                    timestamp = data.timestamp or 0,
                    level = data.player and data.player.level or 1,
                    hp = data.player and data.player.hp or 20,
                    coins = data.player and data.player.coins or 0,
                    deck_size = data.deck and data.deck.cards and #data.deck.cards or 0,
                    battles_won = data.stats and data.stats.battles_won or 0,
                    current_row = data.map and data.map.current_row or 1,
                    wins = data.progress and data.progress.wins or 0,
                    version = data.version or 1,
                }
            end
        end
    end

    -- 空槽位
    return {
        slot = slot,
        exists = false,
        valid = true,
        timestamp = 0,
        level = 1,
        hp = 20,
        coins = 50,
        deck_size = 0,
        battles_won = 0,
        current_row = 1,
        wins = 0,
        version = SAVE_VERSION,
    }
end

-- ==================== 完整性校验 ====================

-- 验证存档完整性（静默模式）
function Save.verify_integrity(data)
    if not data then return false end

    -- 检查版本
    if not data.version or data.version > SAVE_VERSION then
        return false
    end

    -- 检查校验值（如果存在）
    if data.checksum and data.checksum ~= "" then
        local stored_checksum = data.checksum
        -- 计算当前数据的校验值（排除 checksum 字段）
        local temp_data = deep_copy(data)
        temp_data.checksum = ""
        local calculated_checksum = calculate_checksum(temp_data)

        if stored_checksum ~= calculated_checksum then
            return false
        end
    end

    -- 检查必要字段
    if not data.player then return false end

    return true
end

-- ==================== 保存/加载 ====================

-- 保存游戏到当前槽位（静默模式）
function Save.save(player_data, deck_data, map_data)
    -- 更新存档数据
    save_data.version = SAVE_VERSION
    save_data.timestamp = os.time()

    -- 更新玩家数据
    if player_data then
        save_data.player = deep_copy(player_data)
    end

    -- 更新牌组数据
    if deck_data then
        save_data.deck = deep_copy(deck_data)
    end

    -- 更新地图数据
    if map_data then
        save_data.map = deep_copy(map_data)
    end

    -- 计算校验值
    local temp_data = deep_copy(save_data)
    temp_data.checksum = ""
    save_data.checksum = calculate_checksum(temp_data)

    -- 序列化并保存
    local filename = get_slot_filename(current_slot)
    local content = serialize_to_json(save_data)

    local success, err = pcall(function()
        love.filesystem.write(filename, content)
    end)

    if success then
        return true
    else
        return false
    end
end

-- 保存完整数据（包含成就和局外成长）
function Save.save_full(game_state)
    save_data.version = SAVE_VERSION
    save_data.timestamp = os.time()

    -- 玩家数据
    if game_state.player then
        save_data.player = deep_copy(game_state.player)
    end

    -- 牌组
    if game_state.deck then
        save_data.deck = deep_copy(game_state.deck)
    end

    -- 地图
    if game_state.map then
        save_data.map = deep_copy(game_state.map)
    end

    -- 回合统计
    if game_state.stats then
        save_data.stats = deep_copy(game_state.stats)
    end

    -- 局外成长（持久化）
    if game_state.progress then
        save_data.progress = deep_copy(game_state.progress)
    end

    -- 成就进度
    if game_state.achievements then
        save_data.achievements = deep_copy(game_state.achievements)
    end

    -- 计算校验值
    local temp_data = deep_copy(save_data)
    temp_data.checksum = ""
    save_data.checksum = calculate_checksum(temp_data)

    -- 保存
    local filename = get_slot_filename(current_slot)
    local content = serialize_to_json(save_data)

    local success, err = pcall(function()
        love.filesystem.write(filename, content)
    end)

    return success
end

-- 从指定槽位加载游戏（静默模式）
function Save.load(slot)
    slot = slot or current_slot
    local filename = get_slot_filename(slot)

    if love.filesystem.getInfo(filename) then
        local content = love.filesystem.read(filename)
        if content then
            local data = parse_json(content)
            if data and type(data) == "table" then
                -- 验证完整性
                if not Save.verify_integrity(data) then
                    return nil, "corrupted"
                end

                -- 合并默认值（处理版本升级时缺失字段）
                save_data = merge_defaults(data, default_save_data)
                current_slot = slot

                return save_data, nil
            end
        end
    end

    return nil, "not_found"
end

-- 初始化空存档
function Save.init_new_slot(slot)
    slot = slot or current_slot
    save_data = deep_copy(default_save_data)
    save_data.timestamp = os.time()
    save_data.stats.time_started = os.time()
    current_slot = slot
    return save_data
end

-- ==================== 存档操作 ====================

-- 检查存档是否存在
function Save.exists(slot)
    slot = slot or current_slot
    local filename = get_slot_filename(slot)
    return love.filesystem.getInfo(filename) ~= nil
end

-- 删除存档（静默模式）
function Save.delete(slot)
    slot = slot or current_slot
    local filename = get_slot_filename(slot)
    love.filesystem.remove(filename)

    if slot == current_slot then
        save_data = deep_copy(default_save_data)
    end
end

-- 复制存档到另一个槽位
function Save.copy(from_slot, to_slot)
    if from_slot < 1 or from_slot > SLOT_COUNT or to_slot < 1 or to_slot > SLOT_COUNT then
        return false
    end

    local from_file = get_slot_filename(from_slot)
    local to_file = get_slot_filename(to_slot)

    if love.filesystem.getInfo(from_file) then
        local content = love.filesystem.read(from_file)
        if content then
            love.filesystem.write(to_file, content)
            return true
        end
    end

    return false
end

-- ==================== 数据获取 ====================

-- 获取存档数据
function Save.get_data()
    return save_data
end

-- 获取玩家数据
function Save.get_player()
    return save_data.player or default_save_data.player
end

-- 获取牌组数据
function Save.get_deck()
    return save_data.deck or default_save_data.deck
end

-- 获取地图数据
function Save.get_map()
    return save_data.map or default_save_data.map
end

-- 获取统计数据
function Save.get_stats()
    return save_data.stats or default_save_data.stats
end

-- 获取局外成长数据
function Save.get_progress()
    return save_data.progress or default_save_data.progress
end

-- 获取成就数据
function Save.get_achievements()
    return save_data.achievements or default_save_data.achievements
end

-- ==================== 金币系统 ====================

-- 获取当前金币
function Save.get_coins()
    return save_data.player and save_data.player.coins or 50
end

-- 增加金币
function Save.add_coins(amount)
    if save_data.player then
        save_data.player.coins = (save_data.player.coins or 50) + amount
        save_data.stats.gold_collected = (save_data.stats.gold_collected or 0) + amount
        Save.save(save_data.player, save_data.deck, save_data.map)
    end
    return Save.get_coins()
end

-- 消费金币（返回是否成功）
function Save.spend_coins(amount)
    local current = Save.get_coins()
    if current >= amount then
        save_data.player.coins = current - amount
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

-- ==================== 统计更新 ====================

-- 更新统计
function Save.update_stat(stat_name, value)
    if save_data.stats then
        save_data.stats[stat_name] = (save_data.stats[stat_name] or 0) + value
    end
end

-- 设置统计值
function Save.set_stat(stat_name, value)
    if save_data.stats then
        save_data.stats[stat_name] = value
    end
end

-- 更新成就统计
function Save.update_achievement_stat(stat_name, value)
    if save_data.achievements and save_data.achievements.stats then
        save_data.achievements.stats[stat_name] = (save_data.achievements.stats[stat_name] or 0) + value
    end
end

-- ==================== 成就同步 ====================

-- 同步成就数据
function Save.sync_achievements(achievements_data)
    if achievements_data then
        save_data.achievements = deep_copy(achievements_data)
    end
end

-- ==================== 局外成长同步 ====================

-- 同步局外成长数据
function Save.sync_progress(progress_data)
    if progress_data then
        save_data.progress = deep_copy(progress_data)
    end
end

-- ==================== 导出/导入 ====================

-- 导出存档为字符串（用于备份）
function Save.export(slot)
    slot = slot or current_slot
    local filename = get_slot_filename(slot)

    if love.filesystem.getInfo(filename) then
        return love.filesystem.read(filename)
    end
    return nil
end

-- 导入存档（用于恢复备份）
function Save.import(slot, content)
    slot = slot or current_slot
    local filename = get_slot_filename(slot)

    -- 验证内容
    local data = parse_json(content)
    if not data or not Save.verify_integrity(data) then
        return false, "Invalid or corrupted save data"
    end

    love.filesystem.write(filename, content)
    return true, nil
end

-- ==================== 调试工具 ====================

-- 打印存档信息
function Save.print_info()
    print("=== Save System Info ===")
    print("Current Slot: " .. current_slot)
    print("Save Version: " .. SAVE_VERSION)
    print("Slots Info:")
    for i = 1, SLOT_COUNT do
        local info = Save.get_slot_info(i)
        print("  Slot " .. i .. ": " .. (info.exists and "EXISTS" or "EMPTY") ..
              " | Level: " .. info.level ..
              " | Coins: " .. info.coins ..
              " | Deck: " .. info.deck_size)
    end
    print("========================")
end

return Save