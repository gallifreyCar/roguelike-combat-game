-- core/events.lua - 事件系统
-- 解耦模块间依赖，支持发布-订阅模式

local Events = {}

-- 事件监听器
local listeners = {}

-- 订阅事件
function Events.on(event_name, callback, priority)
    priority = priority or 0
    if not listeners[event_name] then
        listeners[event_name] = {}
    end
    table.insert(listeners[event_name], {callback = callback, priority = priority})
    -- 按优先级排序
    table.sort(listeners[event_name], function(a, b) return a.priority > b.priority end)
end

-- 取消订阅
function Events.off(event_name, callback)
    if listeners[event_name] then
        for i = #listeners[event_name], 1, -1 do
            if listeners[event_name][i].callback == callback then
                table.remove(listeners[event_name], i)
            end
        end
    end
end

-- 发布事件
function Events.emit(event_name, ...)
    if listeners[event_name] then
        for _, listener in ipairs(listeners[event_name]) do
            local result = listener.callback(...)
            if result == false then
                -- 返回 false 可以阻止后续监听器
                return false
            end
        end
    end
    return true
end

-- 一次性订阅
function Events.once(event_name, callback)
    local wrapper = function(...)
        Events.off(event_name, wrapper)
        return callback(...)
    end
    Events.on(event_name, wrapper)
end

-- 清除所有监听器
function Events.clear(event_name)
    if event_name then
        listeners[event_name] = {}
    else
        listeners = {}
    end
end

-- ==================== 预定义事件 ====================

-- 战斗事件
Events.BATTLE_START = "battle_start"
Events.BATTLE_END = "battle_end"
Events.TURN_START = "turn_start"
Events.TURN_END = "turn_end"
Events.CARD_PLAYED = "card_played"
Events.CARD_DIED = "card_died"
Events.DAMAGE_DEALT = "damage_dealt"
Events.DAMAGE_TAKEN = "damage_taken"
Events.BLOOD_CHANGED = "blood_changed"
Events.HP_CHANGED = "hp_changed"

-- 成就追踪事件
Events.ENEMY_KILLED = "enemy_killed"
Events.SACRIFICE = "sacrifice"
Events.FUSION_COMPLETE = "fusion_complete"
Events.RUN_COMPLETE = "run_complete"
Events.FLOOR_COMPLETE = "floor_complete"
Events.DECK_SIZE_CHANGED = "deck_size_changed"
Events.CARD_ADDED = "card_added"

-- 地图事件
Events.MAP_NODE_SELECTED = "map_node_selected"
Events.MAP_GENERATED = "map_generated"

-- UI事件
Events.SCENE_CHANGE = "scene_change"
Events.BUTTON_CLICK = "button_click"
Events.LANGUAGE_CHANGE = "language_change"

-- 存档事件
Events.SAVE_COMPLETE = "save_complete"
Events.LOAD_COMPLETE = "load_complete"

return Events