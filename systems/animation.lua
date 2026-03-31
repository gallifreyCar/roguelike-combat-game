-- systems/animation.lua - 动画系统
-- 管理卡牌动画、战斗特效、UI动画

local Animation = {}

-- 动画队列
local animations = {}

-- 动画类型定义
local ANIMATION_TYPES = {
    -- 卡牌动画
    card_place = { duration = 0.3, easing = "easeOutBack" },
    card_attack = { duration = 0.2, easing = "easeOutQuad" },
    card_hit = { duration = 0.15, easing = "easeOutQuad" },
    card_death = { duration = 0.4, easing = "easeInQuad" },
    card_shake = { duration = 0.15, easing = "linear" },

    -- 特效动画
    damage_number = { duration = 0.8, easing = "easeOutQuad" },
    heal_number = { duration = 0.6, easing = "easeOutQuad" },
    gold_popup = { duration = 1.0, easing = "easeOutQuad" },

    -- UI动画
    button_press = { duration = 0.1, easing = "linear" },
    fade_in = { duration = 0.3, easing = "linear" },
    fade_out = { duration = 0.3, easing = "linear" },
}

-- 缓动函数
local Easing = {
    linear = function(t) return t end,
    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return 1 - (1 - t) * (1 - t) end,
    easeInOutQuad = function(t) return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2 end,
    easeOutBack = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
    end,
    easeOutBounce = function(t)
        local n1 = 7.5625
        local d1 = 2.75
        if t < 1 / d1 then
            return n1 * t * t
        elseif t < 2 / d1 then
            t = t - 1.5 / d1
            return n1 * t * t + 0.75
        elseif t < 2.5 / d1 then
            t = t - 2.25 / d1
            return n1 * t * t + 0.9375
        else
            t = t - 2.625 / d1
            return n1 * t * t + 0.984375
        end
    end,
}

-- 初始化
function Animation.init()
    animations = {}
end

-- 更新所有动画
function Animation.update(dt)
    for i = #animations, 1, -1 do
        local anim = animations[i]
        anim.time = anim.time + dt

        if anim.time >= anim.duration then
            -- 动画完成
            if anim.on_complete then
                anim.on_complete()
            end
            table.remove(animations, i)
        end
    end
end

-- 绘制所有动画
function Animation.draw()
    for _, anim in ipairs(animations) do
        if anim.draw then
            anim.draw(anim)
        end
    end
end

-- 获取动画进度 (0-1)
function Animation.get_progress(anim)
    return math.min(1, anim.time / anim.duration)
end

-- 获取缓动后的进度
function Animation.get_eased_progress(anim)
    local progress = Animation.get_progress(anim)
    local easing_func = Easing[anim.easing] or Easing.linear
    return easing_func(progress)
end

-- ==================== 卡牌动画 ====================

-- 卡牌放置动画
function Animation.card_place(x, y, card_width, card_height, on_complete)
    local anim = {
        type = "card_place",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.3,
        time = 0,
        easing = "easeOutBack",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local scale = 0.5 + progress * 0.5
            local alpha = progress

            love.graphics.push()
            love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
            love.graphics.scale(scale, scale)
            love.graphics.translate(-self.width / 2, -self.height / 2)

            -- 发光效果
            love.graphics.setColor(1, 0.9, 0.5, alpha * 0.3)
            love.graphics.rectangle("fill", -5, -5, self.width + 10, self.height + 10, 8, 8)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌攻击动画
function Animation.card_attack(x, y, card_width, card_height, direction, on_complete)
    direction = direction or 1  -- 1 = 向上攻击, -1 = 向下攻击
    local anim = {
        type = "card_attack",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.2,
        time = 0,
        easing = "easeOutQuad",
        direction = direction,
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local offset = math.sin(progress * math.pi) * 15 * self.direction

            -- 攻击时的闪光
            love.graphics.setColor(1, 1, 0.8, (1 - progress) * 0.5)
            love.graphics.rectangle("fill", self.x - 3, self.y - 3 + offset, self.width + 6, self.height + 6, 8, 8)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌受击抖动动画
function Animation.card_shake(x, y, card_width, card_height, on_complete)
    local anim = {
        type = "card_shake",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.15,
        time = 0,
        easing = "linear",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_progress(self)
            local shake = (1 - progress) * 8
            local offset_x = (love.math.random() - 0.5) * shake * 2
            local offset_y = (love.math.random() - 0.5) * shake * 2

            -- 红色闪烁
            love.graphics.setColor(1, 0.3, 0.3, (1 - progress) * 0.5)
            love.graphics.rectangle("fill", self.x + offset_x - 2, self.y + offset_y - 2, self.width + 4, self.height + 4, 8, 8)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌死亡动画
function Animation.card_death(x, y, card_width, card_height, on_complete)
    local particles = {}
    for i = 1, 12 do
        table.insert(particles, {
            x = x + love.math.random() * card_width,
            y = y + love.math.random() * card_height,
            vx = (love.math.random() - 0.5) * 100,
            vy = love.math.random() * -80 - 20,
            size = love.math.random() * 8 + 4,
        })
    end

    local anim = {
        type = "card_death",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.5,
        time = 0,
        easing = "easeInQuad",
        particles = particles,
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_progress(self)

            -- 卡牌淡出
            love.graphics.setColor(0.5, 0.5, 0.5, 1 - progress)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5, 5)

            -- 粒子散开
            for _, p in ipairs(self.particles) do
                local alpha = 1 - progress
                love.graphics.setColor(0.8, 0.3, 0.3, alpha)
                local size = p.size * (1 - progress * 0.5)
                love.graphics.circle("fill", p.x + p.vx * progress, p.y + p.vy * progress + progress * progress * 200, size)
            end
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- ==================== 数字弹出动画 ====================

-- 伤害数字
function Animation.damage_number(value, x, y, is_heal)
    is_heal = is_heal or false
    local anim = {
        type = "damage_number",
        value = value,
        x = x,
        y = y,
        start_y = y,
        duration = 0.8,
        time = 0,
        easing = "easeOutQuad",
        is_heal = is_heal,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local alpha = progress > 0.5 and 1 - (progress - 0.5) * 2 or 1
            local scale = 1 + (1 - progress) * 0.3
            local y_offset = -progress * 40

            love.graphics.push()
            love.graphics.translate(self.x, self.start_y + y_offset)
            love.graphics.scale(scale, scale)

            if self.is_heal then
                love.graphics.setColor(0.3, 1, 0.3, alpha)
            else
                love.graphics.setColor(1, 0.3, 0.3, alpha)
            end

            local text = self.is_heal and ("+" .. self.value) or ("-" .. self.value)
            love.graphics.setFont(love.graphics.newFont(20))
            love.graphics.print(text, -15, -10)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 金币弹出
function Animation.gold_popup(value, x, y)
    local anim = {
        type = "gold_popup",
        value = value,
        x = x,
        y = y,
        start_y = y,
        duration = 1.0,
        time = 0,
        easing = "easeOutQuad",
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local alpha = progress > 0.6 and 1 - (progress - 0.6) / 0.4 or 1
            local y_offset = -progress * 30

            love.graphics.setColor(1, 0.85, 0.2, alpha)
            love.graphics.setFont(love.graphics.newFont(16))
            love.graphics.print("+" .. self.value .. " G", self.x - 20, self.start_y + y_offset)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- ==================== 便捷函数 ====================

-- 清除所有动画
function Animation.clear()
    animations = {}
end

-- 检查是否有正在播放的动画
function Animation.is_playing()
    return #animations > 0
end

-- 获取动画数量
function Animation.count()
    return #animations
end

return Animation