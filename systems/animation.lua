-- systems/animation.lua - 动画系统
-- 管理卡牌动画、战斗特效、UI动画、粒子效果、过渡动画

local Animation = {}
local Fonts = require("core.fonts")

-- 动画队列
local animations = {}

-- 粒子系统
local particles = {}

-- 【性能优化】预缓存常用字体（避免每帧创建）
local cached_fonts = {
    small = nil,
    medium = nil,
    large = nil,
}

-- 场景过渡状态
local transition = {
    active = false,
    type = nil,  -- "fade_in", "fade_out", "slide"
    progress = 0,
    duration = 0.3,
    callback = nil,
}

-- 动画类型定义
local ANIMATION_TYPES = {
    -- 卡牌动画
    card_place = { duration = 0.35, easing = "easeOutBack" },
    card_attack = { duration = 0.25, easing = "easeOutQuad" },
    card_hit = { duration = 0.15, easing = "easeOutQuad" },
    card_death = { duration = 0.5, easing = "easeInQuad" },
    card_shake = { duration = 0.2, easing = "linear" },
    card_hover = { duration = 0.15, easing = "easeOutQuad" },
    card_pickup = { duration = 0.2, easing = "easeOutBack" },
    card_drop = { duration = 0.15, easing = "easeInQuad" },

    -- 特效动画
    damage_number = { duration = 0.8, easing = "easeOutQuad" },
    heal_number = { duration = 0.6, easing = "easeOutQuad" },
    gold_popup = { duration = 1.0, easing = "easeOutQuad" },
    spark = { duration = 0.4, easing = "linear" },
    glow = { duration = 0.5, easing = "easeInOutQuad" },

    -- UI动画
    button_press = { duration = 0.1, easing = "linear" },
    button_hover = { duration = 0.08, easing = "easeOutQuad" },
    fade_in = { duration = 0.3, easing = "linear" },
    fade_out = { duration = 0.3, easing = "linear" },
    slide_in = { duration = 0.4, easing = "easeOutQuad" },
    scale_in = { duration = 0.2, easing = "easeOutBack" },
}

-- 缓动函数
local Easing = {
    linear = function(t) return t end,
    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return 1 - (1 - t) * (1 - t) end,
    easeInOutQuad = function(t) return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2 end,
    easeInCubic = function(t) return t * t * t end,
    easeOutCubic = function(t) return 1 - math.pow(1 - t, 3) end,
    easeInOutCubic = function(t) return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2 end,
    easeOutBack = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
    end,
    easeInBack = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return c3 * t * t * t - c1 * t * t
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
    easeOutElastic = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        local c4 = (2 * math.pi) / 3
        return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
    end,
    -- 震动函数
    shake = function(t, intensity)
        intensity = intensity or 5
        return (love.math.random() - 0.5) * intensity * (1 - t)
    end,
    -- 脉冲函数（用于发光效果）
    pulse = function(t)
        return math.sin(t * math.pi * 2) * 0.5 + 0.5
    end,
}

-- 初始化
function Animation.init()
    animations = {}
    particles = {}
    transition = {
        active = false,
        type = nil,
        progress = 0,
        duration = 0.3,
        callback = nil,
    }
    -- 【性能优化】预缓存动画用字体
    cached_fonts.small = Fonts.get(16)
    cached_fonts.medium = Fonts.get(20)
    cached_fonts.large = Fonts.get(24)
end

-- 更新所有动画
function Animation.update(dt)
    -- 更新动画队列
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

    -- 更新粒子系统
    Animation.update_particles(dt)

    -- 更新场景过渡
    Animation.update_transition(dt)

    -- 更新屏幕震动
    Animation.update_screen_shake(dt)
end

-- 更新屏幕震动
function Animation.update_screen_shake(dt)
    if not screen_shake.active then return end

    screen_shake.time = screen_shake.time + dt
    local progress = screen_shake.time / screen_shake.duration

    if progress >= 1 then
        screen_shake.active = false
        screen_shake.offset_x = 0
        screen_shake.offset_y = 0
    else
        local intensity = screen_shake.intensity * (1 - progress)
        -- 使用确定性震动
        local phase = screen_shake.time * 50
        screen_shake.offset_x = math.sin(phase) * intensity
        screen_shake.offset_y = math.cos(phase * 1.3) * intensity * 0.7
    end
end

-- 绘制所有动画
function Animation.draw()
    -- 绘制动画队列
    for _, anim in ipairs(animations) do
        if anim.draw then
            anim.draw(anim)
        end
    end

    -- 绘制粒子
    Animation.draw_particles()

    -- 绘制过渡效果（在最上层）
    Animation.draw_transition()
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

-- 卡牌放置动画（带发光和缩放效果）
function Animation.card_place(x, y, card_width, card_height, on_complete)
    -- 创建放置粒子
    Animation.spawn_place_particles(x + card_width / 2, y + card_height / 2)

    local anim = {
        type = "card_place",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.35,
        time = 0,
        easing = "easeOutBack",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            -- 从上方落下效果
            local y_offset = -50 * (1 - progress)
            local scale = 0.3 + progress * 0.7
            local alpha = progress

            love.graphics.push()
            love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2 + y_offset)
            love.graphics.scale(scale, scale)
            love.graphics.translate(-self.width / 2, -self.height / 2)

            -- 发光效果（渐变）
            local glow_alpha = (1 - progress) * 0.6
            love.graphics.setColor(1, 0.9, 0.5, glow_alpha)
            love.graphics.rectangle("fill", -8, -8, self.width + 16, self.height + 16, 12, 12)

            -- 外层光晕
            love.graphics.setColor(1, 1, 0.8, glow_alpha * 0.5)
            love.graphics.rectangle("fill", -15, -15, self.width + 30, self.height + 30, 15, 15)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌攻击动画（带轨迹闪光）
function Animation.card_attack(x, y, card_width, card_height, direction, on_complete)
    direction = direction or 1  -- 1 = 向上攻击, -1 = 向下攻击

    -- 创建攻击粒子
    local target_y = direction == 1 and y - 50 or y + card_height + 50
    Animation.spawn_attack_particles(x + card_width / 2, y + card_height / 2, target_y)

    local anim = {
        type = "card_attack",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.25,
        time = 0,
        easing = "easeOutQuad",
        direction = direction,
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local offset = math.sin(progress * math.pi) * 20 * self.direction

            -- 攻击轨迹闪光
            love.graphics.setColor(1, 1, 0.8, (1 - progress) * 0.7)
            love.graphics.rectangle("fill", self.x - 5, self.y - 5 + offset, self.width + 10, self.height + 10, 10, 10)

            -- 冲击波纹
            local wave_size = progress * 30
            love.graphics.setColor(1, 0.9, 0.6, (1 - progress) * 0.3)
            love.graphics.circle("fill", self.x + self.width / 2, self.y + self.height / 2 + offset, wave_size)

            -- 内层高亮
            love.graphics.setColor(1, 1, 1, (1 - progress) * 0.5)
            love.graphics.rectangle("fill", self.x, self.y + offset, self.width, self.height, 8, 8)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌悬停效果（放大和发光）
function Animation.card_hover(x, y, card_width, card_height, intensity, on_complete)
    intensity = intensity or 1
    local anim = {
        type = "card_hover",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        intensity = intensity,
        duration = 0.15,
        time = 0,
        easing = "easeOutQuad",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local scale = 1 + progress * 0.08 * self.intensity
            local glow = progress * 0.3 * self.intensity

            love.graphics.push()
            love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
            love.graphics.scale(scale, scale)

            -- 发光边框
            love.graphics.setColor(1, 1, 0.9, glow)
            love.graphics.rectangle("fill", -self.width / 2 - 3, -self.height / 2 - 3, self.width + 6, self.height + 6, 8, 8)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌拾取动画（从手牌拖起）
function Animation.card_pickup(x, y, card_width, card_height, on_complete)
    local anim = {
        type = "card_pickup",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.2,
        time = 0,
        easing = "easeOutBack",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local scale = 1 + progress * 0.1
            local y_lift = -10 * progress

            love.graphics.push()
            love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2 + y_lift)
            love.graphics.scale(scale, scale)

            -- 拾取时的光晕
            love.graphics.setColor(0.8, 1, 0.8, progress * 0.3)
            love.graphics.rectangle("fill", -self.width / 2 - 5, -self.height / 2 - 5, self.width + 10, self.height + 10, 8, 8)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌受击抖动动画（增强版）
-- 【性能优化】使用确定性抖动而非随机数
function Animation.card_shake(x, y, card_width, card_height, on_complete)
    local anim = {
        type = "card_shake",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.2,
        time = 0,
        easing = "linear",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_progress(self)
            local shake = (1 - progress) * 10
            -- 【性能优化】使用确定性抖动（基于时间和固定种子）
            local shake_phase = self.time * 30
            local offset_x = math.sin(shake_phase) * shake
            local offset_y = math.cos(shake_phase * 1.3) * shake * 0.7

            -- 红色闪烁边框
            love.graphics.setColor(1, 0.2, 0.2, (1 - progress) * 0.8)
            love.graphics.rectangle("fill", self.x + offset_x - 4, self.y + offset_y - 4, self.width + 8, self.height + 8, 8, 8)

            -- 内层红色高亮
            love.graphics.setColor(1, 0.4, 0.4, (1 - progress) * 0.5)
            love.graphics.rectangle("fill", self.x + offset_x, self.y + offset_y, self.width, self.height, 6, 6)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 卡牌死亡动画（增强粒子效果）
function Animation.card_death(x, y, card_width, card_height, on_complete)
    -- 创建更多死亡粒子
    Animation.spawn_death_particles(x + card_width / 2, y + card_height / 2, card_width, card_height)

    local particles = {}
    for i = 1, 20 do
        table.insert(particles, {
            x = x + love.math.random() * card_width,
            y = y + love.math.random() * card_height,
            vx = (love.math.random() - 0.5) * 150,
            vy = love.math.random() * -100 - 30,
            size = love.math.random() * 10 + 5,
            color = love.math.random() < 0.5 and {0.8, 0.3, 0.3} or {0.5, 0.2, 0.2},
        })
    end

    local anim = {
        type = "card_death",
        x = x,
        y = y,
        width = card_width,
        height = card_height,
        duration = 0.6,
        time = 0,
        easing = "easeInQuad",
        particles = particles,
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_progress(self)

            -- 卡牌淡出收缩
            local scale = 1 - progress * 0.3
            love.graphics.push()
            love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
            love.graphics.scale(scale, scale)

            love.graphics.setColor(0.5, 0.5, 0.5, 1 - progress)
            love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height, 5, 5)

            love.graphics.pop()

            -- 粒子散开
            for _, p in ipairs(self.particles) do
                local alpha = 1 - progress
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
                local size = p.size * (1 - progress * 0.7)
                local px = p.x + p.vx * progress
                local py = p.y + p.vy * progress + progress * progress * 250
                love.graphics.circle("fill", px, py, size)
            end
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- ==================== 数字弹出动画 ====================

-- 伤害数字（增强版 - Balatro风格）
function Animation.damage_number(value, x, y, is_heal)
    is_heal = is_heal or false

    -- 先创建冲击粒子
    if not is_heal then
        for i = 1, 5 do
            local angle = love.math.random() * math.pi * 2
            local speed = love.math.random() * 30 + 10
            local vx = math.cos(angle) * speed
            local vy = math.sin(angle) * speed
            local color = {1, 0.3, 0.3}
            Animation.create_particle(x, y, vx, vy, 3, color, 0.3, "spark")
        end
    else
        Animation.spawn_heal_particles(x, y)
    end

    local anim = {
        type = "damage_number",
        value = value,
        x = x,
        y = y,
        start_y = y,
        duration = 1.0,  -- 增加持续时间
        time = 0,
        easing = "easeOutQuad",
        is_heal = is_heal,
        shake_intensity = value > 10 and 5 or 2,  -- 大伤害更强震动
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local alpha = progress > 0.6 and 1 - (progress - 0.6) / 0.4 or 1

            -- 弹跳效果
            local bounce = math.sin(progress * math.pi) * 10
            local y_offset = -progress * 50 + bounce * (1 - progress)

            -- 缩放效果（先放大再缩小）
            local scale
            if progress < 0.2 then
                scale = 1.5 - progress * 2.5  -- 从1.5缩小到1
            else
                scale = 1 + (1 - progress) * 0.3
            end

            love.graphics.push()
            love.graphics.translate(self.x, self.start_y + y_offset)
            love.graphics.scale(scale, scale)

            -- 阴影效果
            love.graphics.setColor(0, 0, 0, alpha * 0.5)
            love.graphics.setFont(cached_fonts.medium)
            local text = self.is_heal and ("+" .. self.value) or ("-" .. self.value)
            love.graphics.print(text, -14, -8)

            -- 主文字
            if self.is_heal then
                love.graphics.setColor(0.3, 1, 0.3, alpha)
            else
                -- 大伤害用更亮的红色
                local r = math.min(1, 0.5 + self.value / 30)
                love.graphics.setColor(r, 0.2, 0.2, alpha)
            end
            love.graphics.print(text, -15, -10)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 金币弹出（增强版 - Balatro风格）
function Animation.gold_popup(value, x, y)
    -- 创建金币粒子
    for i = 1, 8 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random() * 40 + 20
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed - 30
        local color = {1, 0.85, 0.2}
        Animation.create_particle(x, y, vx, vy, 4, color, 0.5, "star")
    end

    local anim = {
        type = "gold_popup",
        value = value,
        x = x,
        y = y,
        start_y = y,
        duration = 1.2,
        time = 0,
        easing = "easeOutBack",
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local alpha = progress > 0.7 and 1 - (progress - 0.7) / 0.3 or 1

            -- 弹跳效果
            local bounce = math.sin(progress * math.pi * 2) * (1 - progress) * 8
            local y_offset = -progress * 40 + bounce

            -- 缩放
            local scale
            if progress < 0.15 then
                scale = 1.8 - progress * 5
            else
                scale = 1 + (1 - progress) * 0.4
            end

            love.graphics.push()
            love.graphics.translate(self.x, self.start_y + y_offset)
            love.graphics.scale(scale, scale)

            -- 金币图标 + 数字
            love.graphics.setFont(cached_fonts.medium)

            -- 外发光
            love.graphics.setColor(1, 0.9, 0.4, alpha * 0.4)
            love.graphics.print("+" .. self.value .. " G", -22, -12)

            -- 主文字
            love.graphics.setColor(1, 0.85, 0.2, alpha)
            love.graphics.print("+" .. self.value .. " G", -23, -13)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- ==================== 便捷函数 ====================

-- 屏幕震动状态
local screen_shake = {
    active = false,
    intensity = 0,
    duration = 0,
    time = 0,
    offset_x = 0,
    offset_y = 0,
}

-- 触发屏幕震动
function Animation.screen_shake(intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.2
    screen_shake.active = true
    screen_shake.intensity = intensity
    screen_shake.duration = duration
    screen_shake.time = 0
end

-- 获取屏幕震动偏移
function Animation.get_screen_shake()
    if not screen_shake.active then
        return 0, 0
    end
    return screen_shake.offset_x, screen_shake.offset_y
end

-- 清除所有动画
function Animation.clear()
    animations = {}
    particles = {}
end

-- 检查是否有正在播放的动画
function Animation.is_playing()
    return #animations > 0 or #particles > 0 or transition.active
end

-- 获取动画数量
function Animation.count()
    return #animations + #particles
end

-- ==================== 粒子系统 ====================

-- 创建单个粒子
function Animation.create_particle(x, y, vx, vy, size, color, life, type)
    local p = {
        x = x,
        y = y,
        vx = vx or 0,
        vy = vy or 0,
        size = size or 5,
        color = color or {1, 1, 1, 1},
        life = life or 0.5,
        max_life = life or 0.5,
        type = type or "circle",  -- "circle", "spark", "star", "trail"
        rotation = love.math.random() * math.pi * 2,
        rotation_speed = (love.math.random() - 0.5) * 5,
    }
    table.insert(particles, p)
    return p
end

-- 放置卡牌时的粒子
function Animation.spawn_place_particles(cx, cy)
    for i = 1, 15 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random() * 60 + 30
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        local size = love.math.random() * 4 + 2
        local color = {1, 0.9 + love.math.random() * 0.1, 0.5 + love.math.random() * 0.3}
        Animation.create_particle(cx, cy, vx, vy, size, color, 0.4, "spark")
    end
end

-- 攻击粒子（沿攻击方向）
function Animation.spawn_attack_particles(cx, cy, target_y)
    local direction = target_y < cy and -1 or 1
    for i = 1, 10 do
        local angle = (love.math.random() - 0.5) * math.pi / 3
        local speed = love.math.random() * 100 + 50
        local vx = math.cos(angle) * speed * 0.3
        local vy = direction * math.sin(angle + math.pi / 2) * speed
        local size = love.math.random() * 3 + 1
        local color = {1, 0.9, 0.6}
        Animation.create_particle(cx, cy, vx, vy, size, color, 0.3, "trail")
    end
end

-- 死亡粒子（爆炸效果）
function Animation.spawn_death_particles(cx, cy, width, height)
    -- 中心爆炸粒子
    for i = 1, 25 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random() * 120 + 40
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed - 50
        local size = love.math.random() * 8 + 3
        local color = love.math.random() < 0.3 and {1, 0.5, 0.2} or {0.8, 0.3, 0.3}
        Animation.create_particle(cx, cy, vx, vy, size, color, 0.5, "spark")
    end

    -- 边缘碎片粒子
    for i = 1, 15 do
        local px = cx + (love.math.random() - 0.5) * width
        local py = cy + (love.math.random() - 0.5) * height
        local vx = (love.math.random() - 0.5) * 80
        local vy = love.math.random() * -60 - 20
        local size = love.math.random() * 5 + 2
        local color = {0.5, 0.2, 0.2}
        Animation.create_particle(px, py, vx, vy, size, color, 0.6, "circle")
    end
end

-- 治疗粒子（上升的绿色粒子）
function Animation.spawn_heal_particles(x, y)
    for i = 1, 12 do
        local px = x + (love.math.random() - 0.5) * 30
        local py = y + love.math.random() * 20
        local vx = (love.math.random() - 0.5) * 20
        local vy = -love.math.random() * 40 - 20
        local size = love.math.random() * 4 + 2
        local color = {0.3, 1, 0.5}
        Animation.create_particle(px, py, vx, vy, size, color, 0.6, "spark")
    end
end

-- 伤害粒子（红色碎片）
function Animation.spawn_damage_particles(x, y)
    for i = 1, 8 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random() * 50 + 20
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        local size = love.math.random() * 3 + 1
        local color = {1, 0.3, 0.3}
        Animation.create_particle(x, y, vx, vy, size, color, 0.3, "trail")
    end
end

-- 胜利粒子（金色爆炸）
function Animation.spawn_victory_particles(cx, cy)
    for i = 1, 30 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random() * 150 + 50
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed - 30
        local size = love.math.random() * 6 + 2
        local color = {1, 0.85 + love.math.random() * 0.15, 0.2 + love.math.random() * 0.2}
        Animation.create_particle(cx, cy, vx, vy, size, color, 0.8, "star")
    end
end

-- 更新粒子
function Animation.update_particles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 150 * dt  -- 重力
        p.life = p.life - dt
        p.rotation = p.rotation + p.rotation_speed * dt

        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
end

-- 绘制粒子
function Animation.draw_particles()
    for _, p in ipairs(particles) do
        local alpha = p.life / p.max_life
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)

        if p.type == "circle" then
            local size = p.size * alpha
            love.graphics.circle("fill", p.x, p.y, size)
        elseif p.type == "spark" then
            -- 绘制菱形闪光
            local size = p.size * alpha
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation)
            love.graphics.polygon("fill", 0, -size * 2, size, 0, 0, size * 2, -size, 0)
            love.graphics.pop()
        elseif p.type == "star" then
            -- 绘制星形
            local size = p.size * alpha
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation)
            for j = 0, 3 do
                love.graphics.rotate(math.pi / 4)
                love.graphics.polygon("fill", 0, -size * 1.5, size * 0.3, 0, 0, size * 1.5, -size * 0.3, 0)
            end
            love.graphics.pop()
        elseif p.type == "trail" then
            -- 绘制拖尾
            local size = p.size * alpha
            love.graphics.circle("fill", p.x, p.y, size)
            -- 添加尾迹
            local trail_alpha = alpha * 0.3
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], trail_alpha)
            love.graphics.circle("fill", p.x - p.vx * 0.02, p.y - p.vy * 0.02, size * 0.7)
        end
    end
end

-- ==================== 场景过渡动画 ====================

-- 开始淡入
function Animation.fade_in(duration, callback)
    transition = {
        active = true,
        type = "fade_in",
        progress = 1,  -- 从黑色开始
        duration = duration or 0.3,
        callback = callback,
    }
end

-- 开始淡出
function Animation.fade_out(duration, callback)
    transition = {
        active = true,
        type = "fade_out",
        progress = 0,  -- 从透明开始
        duration = duration or 0.3,
        callback = callback,
    }
end

-- 滑入效果
function Animation.slide_in(direction, duration, callback)
    direction = direction or "left"
    transition = {
        active = true,
        type = "slide_in",
        direction = direction,
        progress = 1,  -- 从屏幕外开始
        duration = duration or 0.4,
        callback = callback,
    }
end

-- 更新过渡
function Animation.update_transition(dt)
    if not transition.active then return end

    if transition.type == "fade_in" then
        transition.progress = transition.progress - dt / transition.duration
        if transition.progress <= 0 then
            transition.progress = 0
            transition.active = false
            if transition.callback then transition.callback() end
        end
    elseif transition.type == "fade_out" then
        transition.progress = transition.progress + dt / transition.duration
        if transition.progress >= 1 then
            transition.progress = 1
            transition.active = false
            if transition.callback then transition.callback() end
        end
    elseif transition.type == "slide_in" then
        transition.progress = transition.progress - dt / transition.duration
        if transition.progress <= 0 then
            transition.progress = 0
            transition.active = false
            if transition.callback then transition.callback() end
        end
    end
end

-- 绘制过渡
function Animation.draw_transition()
    if not transition.active then return end

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    if transition.type == "fade_in" or transition.type == "fade_out" then
        love.graphics.setColor(0, 0, 0, transition.progress)
        love.graphics.rectangle("fill", 0, 0, w, h)
    elseif transition.type == "slide_in" then
        local offset
        if transition.direction == "left" then
            offset = -w * transition.progress
        elseif transition.direction == "right" then
            offset = w * transition.progress
        elseif transition.direction == "up" then
            offset = -h * transition.progress
        elseif transition.direction == "down" then
            offset = h * transition.progress
        end
        love.graphics.setColor(0.08, 0.06, 0.05, transition.progress * 0.5)
        if transition.direction == "left" or transition.direction == "right" then
            love.graphics.rectangle("fill", offset, 0, w, h)
        else
            love.graphics.rectangle("fill", 0, offset, w, h)
        end
    end
end

-- 检查过渡是否激活
function Animation.is_transitioning()
    return transition.active
end

-- ==================== UI按钮动画 ====================

-- 按钮点击效果（按下缩放）
function Animation.button_press(x, y, width, height, on_complete)
    local anim = {
        type = "button_press",
        x = x,
        y = y,
        width = width,
        height = height,
        duration = 0.1,
        time = 0,
        easing = "linear",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_progress(self)
            local scale = 1 - progress * 0.05
            local brightness = 0.15 * (1 - progress)

            love.graphics.push()
            love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
            love.graphics.scale(scale, scale)

            -- 点击时的白色闪光
            love.graphics.setColor(1, 1, 1, brightness)
            love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height, 6, 6)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 按钮悬停发光
function Animation.button_hover(x, y, width, height, intensity, on_complete)
    intensity = intensity or 1
    local anim = {
        type = "button_hover",
        x = x,
        y = y,
        width = width,
        height = height,
        intensity = intensity,
        duration = 0.15,
        time = 0,
        easing = "easeOutQuad",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local glow = progress * 0.2 * self.intensity

            -- 外发光边框
            love.graphics.setColor(1, 1, 0.9, glow)
            love.graphics.rectangle("fill", self.x - 2, self.y - 2, self.width + 4, self.height + 4, 8, 8)

            -- 内发光
            love.graphics.setColor(1, 1, 1, glow * 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 6, 6)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- UI元素缩放出现
function Animation.scale_in(x, y, width, height, on_complete)
    local anim = {
        type = "scale_in",
        x = x,
        y = y,
        width = width,
        height = height,
        duration = 0.2,
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

            -- 出现时的光晕
            love.graphics.setColor(1, 0.9, 0.7, alpha * 0.3)
            love.graphics.rectangle("fill", -self.width / 2 - 5, -self.height / 2 - 5, self.width + 10, self.height + 10, 8, 8)

            love.graphics.pop()
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- ==================== 战斗特效动画 ====================

-- 闪光效果
function Animation.flash(x, y, width, height, color, on_complete)
    color = color or {1, 1, 1}
    local anim = {
        type = "flash",
        x = x,
        y = y,
        width = width,
        height = height,
        color = color,
        duration = 0.2,
        time = 0,
        easing = "linear",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_progress(self)
            local alpha = 1 - progress

            love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha * 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 6, 6)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 持续发光效果
function Animation.glow(x, y, width, height, color, duration, on_complete)
    color = color or {1, 0.9, 0.5}
    duration = duration or 0.5
    local anim = {
        type = "glow",
        x = x,
        y = y,
        width = width,
        height = height,
        color = color,
        duration = duration,
        time = 0,
        easing = "easeInOutQuad",
        on_complete = on_complete,
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local pulse = math.sin(progress * math.pi * 2) * 0.3 + 0.5

            -- 发光边框
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], pulse * 0.4)
            love.graphics.rectangle("fill", self.x - 4, self.y - 4, self.width + 8, self.height + 8, 8, 8)

            -- 内层发光
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], pulse * 0.2)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 6, 6)
        end,
    }
    table.insert(animations, anim)
    return anim
end

-- 连击特效
function Animation.combo_effect(x, y, combo_count)
    combo_count = combo_count or 2
    local anim = {
        type = "combo",
        x = x,
        y = y,
        combo = combo_count,
        duration = 0.8,
        time = 0,
        easing = "easeOutElastic",
        draw = function(self)
            local progress = Animation.get_eased_progress(self)
            local alpha = progress > 0.6 and 1 - (progress - 0.6) / 0.4 or 1
            local scale = 1 + progress * 0.3

            love.graphics.push()
            love.graphics.translate(self.x, self.y)
            love.graphics.scale(scale, scale)

            -- 连击文字
            love.graphics.setColor(1, 0.8, 0.2, alpha)
            -- 【性能优化】使用缓存的字体
            love.graphics.setFont(cached_fonts.large)
            love.graphics.print("COMBO x" .. self.combo, -40, -12)

            love.graphics.pop()

            -- 连击粒子（【性能优化】减少每帧循环次数）
            if progress < 0.5 then
                local particle_alpha = (1 - progress * 2) * 0.5
                love.graphics.setColor(1, 0.85, 0.3, particle_alpha)
                for i = 1, 3 do
                    local angle = (i - 1) * (math.pi * 2 / 3) + progress * math.pi
                    local dist = 30 * progress
                    local px = self.x + math.cos(angle) * dist
                    local py = self.y + math.sin(angle) * dist
                    love.graphics.circle("fill", px, py, 3)
                end
            end
        end,
    }
    table.insert(animations, anim)
    return anim
end

return Animation