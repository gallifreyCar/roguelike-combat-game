-- utils/table.lua - 表工具函数

local TableUtils = {}

-- 深拷贝表
function TableUtils.deep_copy(t)
    if type(t) ~= "table" then return t end

    local copy = {}
    for k, v in pairs(t) do
        copy[TableUtils.deep_copy(k)] = TableUtils.deep_copy(v)
    end
    return copy
end

-- 浅拷贝表
function TableUtils.shallow_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

-- 合并表（不覆盖原表）
function TableUtils.merge(t1, t2)
    local result = TableUtils.shallow_copy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- 表是否包含值
function TableUtils.contains(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end
    return false
end

-- 查找值在表中的索引
function TableUtils.index_of(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

-- 移除表中的值
function TableUtils.remove_value(t, value)
    local index = TableUtils.index_of(t, value)
    if index then
        table.remove(t, index)
        return true
    end
    return false
end

-- Fisher-Yates 洗牌
function TableUtils.shuffle(t)
    for i = #t, 2, -1 do
        local j = love.math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

-- 表长度（支持非数组表）
function TableUtils.size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- 过滤表
function TableUtils.filter(t, predicate)
    local result = {}
    for k, v in pairs(t) do
        if predicate(v, k) then
            result[#result + 1] = v
        end
    end
    return result
end

-- 映射表
function TableUtils.map(t, transform)
    local result = {}
    for k, v in pairs(t) do
        result[k] = transform(v, k)
    end
    return result
end

return TableUtils