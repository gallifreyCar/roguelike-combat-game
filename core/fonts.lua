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
    end

    for _, size in ipairs(sizes) do
        if use_chinese_font then
            local success, font = pcall(love.graphics.newFont, font_path, size)
            if success and font then
                font_cache[size] = font
            else
                font_cache[size] = love.graphics.newFont(size)
            end
        else
            font_cache[size] = love.graphics.newFont(size)
        end
    end

    -- 设置默认字体
    if font_cache[DEFAULT_SIZE] then
        love.graphics.setFont(font_cache[DEFAULT_SIZE])
    end
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

-- 大字体打印 (20px)
function Fonts.print_large(text, x, y, color)
    if not text then return end
    Fonts.print(text, x, y, 20, color)
end

-- 小字体打印 (12px)
function Fonts.print_small(text, x, y, color)
    if not text then return end
    Fonts.print(text, x, y, 12, color)
end

-- 自动换行打印
function Fonts.print_wrapped(text, x, y, max_width, size, color)
    if not text then return 0 end

    size = size or DEFAULT_SIZE
    color = color or {1, 1, 1}
    max_width = max_width or 300

    local font = Fonts.get(size)
    love.graphics.setColor(color)
    love.graphics.setFont(font)

    -- 按单词分割文本
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local lines = {}
    local current_line = ""

    for _, word in ipairs(words) do
        local test_line = current_line .. (current_line == "" and "" or " ") .. word
        if font:getWidth(test_line) <= max_width then
            current_line = test_line
        else
            if current_line ~= "" then
                table.insert(lines, current_line)
            end
            current_line = word
        end
    end
    if current_line ~= "" then
        table.insert(lines, current_line)
    end

    -- 绘制每一行
    local line_height = size + 4
    for i, line in ipairs(lines) do
        love.graphics.print(line, x, y + (i - 1) * line_height)
    end

    return #lines * line_height  -- 返回总高度
end

return Fonts