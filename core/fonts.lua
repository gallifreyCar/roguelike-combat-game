-- core/fonts.lua - 字体管理
-- 支持中文/英文/日文的多语言字体

local Fonts = {}

-- 字体缓存
local font_cache = {}

-- 默认字体大小
local DEFAULT_SIZE = 16

function Fonts.init()
    -- 预加载常用字号
    local sizes = {12, 14, 16, 20, 24, 32}
    local chinese_font_path = "assets/fonts/STHeiti Light.ttc"
    local fallback_font_path = "assets/fonts/NotoSansSC-Regular.otf"

    -- 检查字体文件是否存在
    local use_chinese_font = false
    local font_source = nil

    -- 优先使用 STHeiti (TTC)
    if love.filesystem.getInfo(chinese_font_path) then
        font_source = chinese_font_path
        use_chinese_font = true
        print("Found Chinese font: " .. chinese_font_path)
    elseif love.filesystem.getInfo(fallback_font_path) then
        font_source = fallback_font_path
        use_chinese_font = true
        print("Found fallback font: " .. fallback_font_path)
    else
        print("No Chinese font found, using default")
    end

    for _, size in ipairs(sizes) do
        if use_chinese_font and font_source then
            -- 尝试加载中文字体
            local success, font = pcall(love.graphics.newFont, font_source, size)
            if success and font then
                font_cache[size] = font
            else
                -- 降级到默认字体
                font_cache[size] = love.graphics.newFont(size)
                print("Failed to load Chinese font at size " .. size .. ", using default")
            end
        else
            font_cache[size] = love.graphics.newFont(size)
        end
    end

    -- 设置默认字体
    if font_cache[DEFAULT_SIZE] then
        love.graphics.setFont(font_cache[DEFAULT_SIZE])
    end

    print("Fonts initialized: " .. #sizes .. " sizes")
end

function Fonts.get(size)
    size = size or DEFAULT_SIZE

    if font_cache[size] then
        return font_cache[size]
    end

    -- 动态创建新字号
    local font_source = "assets/fonts/STHeiti Light.ttc"
    if love.filesystem.getInfo(font_source) then
        local success, font = pcall(love.graphics.newFont, font_source, size)
        if success and font then
            font_cache[size] = font
            return font
        end
    end

    -- 降级到默认字体
    font_cache[size] = love.graphics.newFont(size)
    return font_cache[size]
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