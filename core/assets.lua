-- core/assets.lua - 资源管理模块
-- 统一加载和管理游戏图片资源

local Assets = {
    loaded = false,
    cards = {},
    sigils = {},
    frames = {},
    ui = {},
}

-- 加载所有资源
function Assets.load()
    if Assets.loaded then
        return
    end

    -- 加载卡牌图片
    Assets.cards = Assets._loadCards()

    -- 加载印记图标
    Assets.sigils = Assets._loadSigils()

    -- 加载卡框
    Assets.frames = Assets._loadFrames()

    -- 加载UI元素
    Assets.ui = Assets._loadUI()

    Assets.loaded = true
    -- 资源加载完成（日志仅在调试模式输出）

    -- 调试：打印加载结果
    print("[Assets] Loaded: " .. Assets._countTable(Assets.cards) .. " cards, "
        .. Assets._countTable(Assets.sigils) .. " sigils, "
        .. Assets._countTable(Assets.frames) .. " frames")
end

-- 加载卡牌图片
function Assets._loadCards()
    local cards = {}
    local cardData = require("data.cards").cards

    for id, _ in pairs(cardData) do
        local path = "assets/cards/" .. id .. ".png"
        local info = love.filesystem.getInfo(path)

        if info then
            local success, image = pcall(love.graphics.newImage, path)
            if success then
                cards[id] = image
                -- 设置过滤模式为最近邻（像素风格）
                image:setFilter("nearest", "nearest")
            end
        end
    end

    return cards
end

-- 加载印记图标
function Assets._loadSigils()
    local sigils = {}
    local sigilData = require("data.cards").sigils

    for id, _ in pairs(sigilData) do
        local path = "assets/sigils/" .. id .. ".png"
        local info = love.filesystem.getInfo(path)

        if info then
            local success, image = pcall(love.graphics.newImage, path)
            if success then
                sigils[id] = image
                image:setFilter("nearest", "nearest")
            end
        end
    end

    return sigils
end

-- 加载卡框（按稀有度）
function Assets._loadFrames()
    local frames = {}
    local rarities = {"common", "uncommon", "rare", "legendary"}

    for _, rarity in ipairs(rarities) do
        local path = "assets/frames/" .. rarity .. "_frame.png"
        local info = love.filesystem.getInfo(path)

        if info then
            local success, image = pcall(love.graphics.newImage, path)
            if success then
                frames[rarity] = image
                image:setFilter("nearest", "nearest")
            end
        end
    end

    return frames
end

-- 加载UI元素
function Assets._loadUI()
    local ui = {}
    local uiFiles = {
        "blood_icon",
        "bone_icon",
        "attack_icon",
        "hp_icon",
    }

    for _, name in ipairs(uiFiles) do
        local path = "assets/ui/" .. name .. ".png"
        local info = love.filesystem.getInfo(path)

        if info then
            local success, image = pcall(love.graphics.newImage, path)
            if success then
                ui[name] = image
                image:setFilter("nearest", "nearest")
            end
        end
    end

    return ui
end

-- 获取卡牌图片（带回退）
function Assets.getCard(id)
    return Assets.cards[id]
end

-- 获取印记图标（带回退）
function Assets.getSigil(id)
    return Assets.sigils[id]
end

-- 获取卡框
function Assets.getFrame(rarity)
    return Assets.frames[rarity] or Assets.frames["common"]
end

-- 检查资源是否已加载
function Assets.isLoaded()
    return Assets.loaded
end

-- 卸载资源（场景切换时可选）
function Assets.unload()
    Assets.cards = {}
    Assets.sigils = {}
    Assets.frames = {}
    Assets.ui = {}
    Assets.loaded = false
end

-- 辅助函数：计算table元素数量
function Assets._countTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

return Assets