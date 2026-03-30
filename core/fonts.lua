-- core/fonts.lua - 字体管理
-- 使用思源黑体 (Noto Sans SC) - 开源免费可商用

local Fonts = {}

-- 字体缓存
local font_cache = {}

-- 默认字体大小
local DEFAULT_SIZE = 16

function Fonts.init()
    -- 预加载常用字号
    local sizes = {12, 14, 16, 20, 24, 32}
    local font_path = "assets/fonts/NotoSansSC-Regular.otf"

    -- 检查字体文件是否存在
    local use_chinese_font = false
    if love.filesystem.getInfo(font_path) then
        use_chinese_font = true
        print("Found Chinese font: " .. font_path)
    else
        print("Chinese font not found at " .. font_path)
        print("Please download Noto Sans SC (free, open source):")
        print("  https://fonts.google.com/noto/specimen/Noto+Sans+SC")
    end

    for _, size in ipairs(sizes) do
        if use_chinese_font then
            local success, font = pcall(love.graphics.newFont, font_path, size)
            if success and font then
                font_cache[size] = font
            else
                font_cache[size] = love.graphics.newFont(size)
                print("Failed to load font at size " .. size)
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
    local font_path = "assets/fonts/NotoSansSC-Regular.otf"
    if love.filesystem.getInfo(font_path) then
        local success, font = pcall(love.graphics.newFont, font_path, size)
        if success and font then
            font_cache[size] = font
            return font
        end
    end

    font_cache[size] = love.graphics.newFont(size)
    return font_cache[size]
end

function Fonts.set(size)
    love.graphics.setFont(Fonts.get(size))
end

function Fonts.print(text, x, y, size, color)
    size = size or DEFAULT_SIZE
    color = color or {1, 1, 1}

    love.graphics.setColor(color)
    love.graphics.setFont(Fonts.get(size))
    love.graphics.print(text, x, y)
end

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