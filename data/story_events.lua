-- data/story_events.lua - 剧情事件数据
-- 包含NPC对话、选择分支、风险收益

local StoryEvents = {}

-- 事件类型
StoryEvents.TYPES = {
    merchant = "merchant",     -- 商人：购买/交易
    encounter = "encounter",   -- 遭遇：NPC对话
    mystery = "mystery",       -- 神秘：风险选择
    blessing = "blessing",     -- 祝福：免费增益
    curse = "curse",           -- 诅咒：负面效果（可选）
}

-- 所有剧情事件
StoryEvents.events = {
    -- ==================== 商人事件 ====================
    {
        id = "mysterious_merchant",
        type = "merchant",
        title = "神秘商人",
        title_cn = "神秘商人",
        description = "一位戴着面具的商人从迷雾中走出...",
        description_cn = "一位戴着面具的商人从迷雾中走出...",
        emoji = "🧙",
        choices = {
            {
                text = "Buy a rare card (50 gold)",
                text_cn = "购买稀有卡牌 (50金币)",
                condition = function(player) return player.gold >= 50 end,
                effect = function(player, deck)
                    player.gold = player.gold - 50
                    return {
                        success = true,
                        message = "The merchant smiles and hands you a glowing card.",
                        message_cn = "商人微笑着递给你一张发光的卡牌。",
                        reward_type = "card",
                        card_rarity = "rare",
                    }
                end,
            },
            {
                text = "Sell a card (+25 gold)",
                text_cn = "出售一张卡牌 (+25金币)",
                condition = function(player, deck) return #deck > 3 end,
                effect = function(player, deck)
                    player.gold = player.gold + 25
                    return {
                        success = true,
                        message = "You sold a card. The merchant disappears into the fog.",
                        message_cn = "你出售了一张卡牌。商人消失在迷雾中。",
                        reward_type = "gold",
                        gold = 25,
                        remove_card = true,
                    }
                end,
            },
            {
                text = "Leave",
                text_cn = "离开",
                condition = nil,  -- 无条件
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "The merchant bows and vanishes.",
                        message_cn = "商人鞠躬后消失。",
                        reward_type = "none",
                    }
                end,
            },
        },
    },

    -- ==================== 遭遇事件 ====================
    {
        id = "wounded_traveler",
        type = "encounter",
        title = "Wounded Traveler",
        title_cn = "受伤的旅人",
        description = "A traveler lies on the ground, bleeding. They need help.",
        description_cn = "一个旅人躺在地上，正在流血。他需要帮助。",
        emoji = "🧑",
        choices = {
            {
                text = "Give 20 gold to help",
                text_cn = "给20金币帮助他",
                condition = function(player) return player.gold >= 20 end,
                effect = function(player, deck)
                    player.gold = player.gold - 20
                    return {
                        success = true,
                        message = "The traveler thanks you and gives you a blessing!",
                        message_cn = "旅人感谢你，给了你一个祝福！",
                        reward_type = "blessing",
                        blessing = "hp_boost",
                        blessing_value = 5,
                    }
                end,
            },
            {
                text = "Give a card to help",
                text_cn = "给一张卡牌帮助他",
                condition = function(player, deck) return #deck > 3 end,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "The traveler takes your card and reveals a secret path!",
                        message_cn = "旅人收下你的卡牌，指出了一条秘密通道！",
                        reward_type = "card",
                        card_rarity = "uncommon",
                        remove_card = true,
                    }
                end,
            },
            {
                text = "Walk away",
                text_cn = "走开",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You walk away, leaving the traveler behind.",
                        message_cn = "你走开了，把旅人留在身后。",
                        reward_type = "none",
                    }
                end,
            },
        },
    },

    {
        id = "old_sage",
        type = "encounter",
        title = "Old Sage",
        title_cn = "老贤者",
        description = "An old sage sits by the path, studying ancient texts.",
        description_cn = "一位老贤者坐在路边，研究着古老的文献。",
        emoji = "👴",
        choices = {
            {
                text = "Ask for wisdom",
                text_cn = "请教智慧",
                condition = nil,
                effect = function(player, deck)
                    local roll = love and love.math and love.math.random() or math.random()
                    if roll < 0.5 then
                        return {
                            success = true,
                            message = "The sage teaches you a powerful technique!",
                            message_cn = "贤者教会了你一种强大的技巧！",
                            reward_type = "sigil",
                            sigil = "double_strike",
                        }
                    else
                        return {
                            success = true,
                            message = "The sage gives you some gold for your journey.",
                            message_cn = "贤者给了你一些金币作为旅途资助。",
                            reward_type = "gold",
                            gold = 30,
                        }
                    end
                end,
            },
            {
                text = "Offer a donation (10 gold)",
                text_cn = "捐赠 (10金币)",
                condition = function(player) return player.gold >= 10 end,
                effect = function(player, deck)
                    player.gold = player.gold - 10
                    return {
                        success = true,
                        message = "The sage blesses you with good fortune!",
                        message_cn = "贤者祝福你好运！",
                        reward_type = "blessing",
                        blessing = "luck",
                        blessing_value = 1,
                    }
                end,
            },
            {
                text = "Leave",
                text_cn = "离开",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You leave the sage to his studies.",
                        message_cn = "你让贤者继续他的研究。",
                        reward_type = "none",
                    }
                end,
            },
        },
    },

    -- ==================== 神秘事件 ====================
    {
        id = "cursed_shrine",
        type = "mystery",
        title = "Cursed Shrine",
        title_cn = "被诅咒的神殿",
        description = "A dark shrine pulses with ominous energy. Something valuable might be inside...",
        description_cn = "一座黑暗的神殿散发着不祥的能量。里面可能有珍贵的东西...",
        emoji = "🏛️",
        choices = {
            {
                text = "Enter the shrine (Risk!)",
                text_cn = "进入神殿 (风险！)",
                condition = nil,
                effect = function(player, deck)
                    local roll = love and love.math and love.math.random() or math.random()
                    if roll < 0.4 then
                        -- 40% 好结果
                        return {
                            success = true,
                            message = "You found a legendary artifact!",
                            message_cn = "你找到了一件传说神器！",
                            reward_type = "card",
                            card_rarity = "legendary",
                        }
                    elseif roll < 0.7 then
                        -- 30% 中等结果
                        return {
                            success = true,
                            message = "You found some treasure, but the curse weakens you.",
                            message_cn = "你找到了一些宝藏，但诅咒削弱了你。",
                            reward_type = "mixed",
                            gold = 50,
                            hp_penalty = 3,
                        }
                    else
                        -- 30% 坏结果
                        return {
                            success = true,
                            message = "The curse strikes! You barely escape with your life.",
                            message_cn = "诅咒发动！你勉强逃出生天。",
                            reward_type = "curse",
                            hp_penalty = 5,
                        }
                    end
                end,
            },
            {
                text = "Destroy the shrine",
                text_cn = "摧毁神殿",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You destroy the shrine and feel blessed for your courage.",
                        message_cn = "你摧毁了神殿，为你的勇气感到祝福。",
                        reward_type = "blessing",
                        blessing = "courage",
                        blessing_value = 2,
                    }
                end,
            },
            {
                text = "Walk away",
                text_cn = "走开",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You wisely avoid the dark shrine.",
                        message_cn = "你明智地避开了黑暗神殿。",
                        reward_type = "none",
                    }
                end,
            },
        },
    },

    {
        id = "sacrificial_altar",
        type = "mystery",
        title = "Sacrificial Altar",
        title_cn = "献祭祭坛",
        description = "An ancient altar demands sacrifice. What will you offer?",
        description_cn = "一座古老的祭坛要求献祭。你会献上什么？",
        emoji = "⚡",
        choices = {
            {
                text = "Sacrifice 30 gold",
                text_cn = "献祭30金币",
                condition = function(player) return player.gold >= 30 end,
                effect = function(player, deck)
                    player.gold = player.gold - 30
                    return {
                        success = true,
                        message = "The altar accepts your offering and grants power!",
                        message_cn = "祭坛接受你的祭品，赐予力量！",
                        reward_type = "card",
                        card_rarity = "rare",
                    }
                end,
            },
            {
                text = "Sacrifice a card",
                text_cn = "献祭一张卡牌",
                condition = function(player, deck) return #deck > 3 end,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "The altar consumes your card and transforms it!",
                        message_cn = "祭坛吞噬你的卡牌并转化它！",
                        reward_type = "upgrade",
                        remove_card = true,
                        upgrade_random = true,
                    }
                end,
            },
            {
                text = "Sacrifice HP (risky)",
                text_cn = "献祭生命 (危险)",
                condition = function(player) return player.hp > 5 end,
                effect = function(player, deck)
                    player.hp = player.hp - 3
                    return {
                        success = true,
                        message = "Blood flows... The altar grants immense power!",
                        message_cn = "鲜血流淌... 祭坛赐予巨大的力量！",
                        reward_type = "card",
                        card_rarity = "legendary",
                    }
                end,
            },
            {
                text = "Leave",
                text_cn = "离开",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You refuse to make a sacrifice.",
                        message_cn = "你拒绝献祭。",
                        reward_type = "none",
                    }
                end,
            },
        },
    },

    -- ==================== 祝福事件 ====================
    {
        id = "healing_spring",
        type = "blessing",
        title = "Healing Spring",
        title_cn = "治愈之泉",
        description = "A magical spring bubbles with healing water.",
        description_cn = "神奇的泉水涌动着治愈之水。",
        emoji = "💧",
        choices = {
            {
                text = "Drink from the spring",
                text_cn = "饮用泉水",
                condition = nil,
                effect = function(player, deck)
                    player.hp = math.min(player.max_hp, player.hp + 5)
                    return {
                        success = true,
                        message = "You feel refreshed! HP restored.",
                        message_cn = "你感到神清气爽！生命恢复。",
                        reward_type = "heal",
                        heal = 5,
                    }
                end,
            },
            {
                text = "Fill a bottle (+20 gold)",
                text_cn = "装一瓶 (+20金币)",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You collect the magical water and find a buyer.",
                        message_cn = "你收集了神奇的水并找到了买家。",
                        reward_type = "gold",
                        gold = 20,
                    }
                end,
            },
        },
    },

    {
        id = "lucky_coin",
        type = "blessing",
        title = "Lucky Coin",
        title_cn = "幸运硬币",
        description = "You find a shiny coin on the ground. It seems magical.",
        description_cn = "你在地上发现了一枚闪亮的硬币。它似乎有魔力。",
        emoji = "🪙",
        choices = {
            {
                text = "Pick it up",
                text_cn = "捡起来",
                condition = nil,
                effect = function(player, deck)
                    local roll = love and love.math and love.math.random() or math.random()
                    if roll < 0.6 then
                        player.gold = player.gold + 30
                        return {
                            success = true,
                            message = "It's real gold! +30 gold",
                            message_cn = "是真金！+30金币",
                            reward_type = "gold",
                            gold = 30,
                        }
                    else
                        return {
                            success = true,
                            message = "The coin transforms into a card!",
                            message_cn = "硬币变成了一张卡牌！",
                            reward_type = "card",
                            card_rarity = "uncommon",
                        }
                    end
                end,
            },
            {
                text = "Leave it (superstitious)",
                text_cn = "留下 (迷信)",
                condition = nil,
                effect = function(player, deck)
                    return {
                        success = true,
                        message = "You leave the coin. Sometimes caution is wisdom.",
                        message_cn = "你留下了硬币。有时谨慎就是智慧。",
                        reward_type = "none",
                    }
                end,
            },
        },
    },
}

-- 根据ID获取事件
function StoryEvents.getById(id)
    for _, event in ipairs(StoryEvents.events) do
        if event.id == id then
            return event
        end
    end
    return nil
end

-- 获取随机事件
function StoryEvents.getRandom()
    local roll = love and love.math and love.math.random or math.random
    local index = roll(1, #StoryEvents.events)
    return StoryEvents.events[index]
end

-- 根据类型获取随机事件
function StoryEvents.getRandomByType(eventType)
    local filtered = {}
    for _, event in ipairs(StoryEvents.events) do
        if event.type == eventType then
            table.insert(filtered, event)
        end
    end

    if #filtered == 0 then
        return StoryEvents.getRandom()
    end

    local roll = love and love.math and love.math.random or math.random
    return filtered[roll(1, #filtered)]
end

return StoryEvents