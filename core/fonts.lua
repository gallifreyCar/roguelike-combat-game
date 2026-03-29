-- core/fonts.lua - 字体管理
-- 支持中文/英文/日文的多语言字体

local Fonts = {}

-- 字体缓存
local font_cache = {}

-- 默认字体大小
local DEFAULT_SIZE = 16

function Fonts.init()
    -- 加载 Noto Sans SC（支持中英日韩）
    local font_path = "assets/fonts/NotoSansSC-Regular.ttf"

    -- 预加载常用字号
    local sizes = {12, 14, 16, 20, 24, 32}

    for _, size in ipairs(sizes) do
        local success, font = pcall(love.graphics.newFont, font_path, size)
        if success then
            font_cache[size] = font
        else
            -- 降级到默认字体
            font_cache[size] = love.graphics.newFont(size)
        end
    end

    -- 设置默认字体
    if font_cache[DEFAULT_SIZE] then
        love.graphics.setFont(font_cache[DEFAULT_SIZE])
    end

    print("Fonts loaded: " .. #sizes .. " sizes")
end

function Fonts.get(size)
    size = size or DEFAULT_SIZE

    if font_cache[size] then
        return font_cache[size]
    end

    -- 动态创建新字号
    local font_path = "assets/fonts/NotoSansSC-Regular.ttf"
    local success, font = pcall(love.graphics.newFont, font_path, size)

    if success then
        font_cache[size] = font
        return font
    end

    -- 降级
    return love.graphics.newFont(size)
end

function Fonts.set(size)
    love.graphics.setFont(Fonts.get(size))
end

-- 绘制多行文本（支持换行）
function Fonts.print(text, x, y, size, color)
    size = size or DEFAULT_SIZE
    color = color or {1, 1, 1}

    love.graphics.setColor(color)
    love.graphics.setFont(Fonts.get(size))
    love.graphics.print(text, x, y)
end

-- 绘制居中文本
function Fonts.printCenter(text, x, y, size, color)
    size = size or DEFAULT_SIZE
    color = color or {1, 1, 1}

    local font = Fonts.get(size)
    local width = font:getWidth(text)

    love.graphics.setColor(color)
    love.graphics.setFont(font)
    love.graphics.print(text, x - width / 2, y)
end

return Fonts