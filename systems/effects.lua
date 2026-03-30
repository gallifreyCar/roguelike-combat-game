-- systems/effects.lua - 特效系统
-- 管理战斗特效：伤害数字、闪光、动画

local Effects = {}

-- 活跃特效列表
local active_effects = {}

-- 特效类型
local EFFECT_TYPES = {
    damage_number = {
        duration = 1.2,
        update = function(effect, dt)
            effect.y = effect.y - 40 * dt  -- 向上飘
            effect.alpha = math.max(0, effect.alpha - dt * 0.8)
        end,
        draw = function(effect)
            if effect.alpha <= 0 then return end
            love.graphics.setColor(1, 0.3, 0.3, effect.alpha)
            love.graphics.setFont(love.graphics.newFont(20))
            love.graphics.print("-" .. effect.value, effect.x, effect.y)
        end,
    },
    heal_number = {
        duration = 1.0,
        update = function(effect, dt)
            effect.y = effect.y - 30 * dt
            effect.alpha = math.max(0, effect.alpha - dt * 0.9)
        end,
        draw = function(effect)
            if effect.alpha <= 0 then return end
            love.graphics.setColor(0.3, 1, 0.3, effect.alpha)
            love.graphics.setFont(love.graphics.newFont(18))
            love.graphics.print("+" .. effect.value, effect.x, effect.y)
        end,
    },
    flash = {
        duration = 0.2,
        update = function(effect, dt)
            effect.timer = effect.timer + dt
            effect.alpha = 1 - (effect.timer / 0.2)
        end,
        draw = function(effect)
            if effect.alpha <= 0 then return end
            love.graphics.setColor(1, 1, 1, effect.alpha * 0.5)
            love.graphics.rectangle("fill", effect.x, effect.y, effect.w, effect.h)
        end,
    },
    attack_flash = {
        duration = 0.15,
        update = function(effect, dt)
            effect.timer = effect.timer + dt
            effect.alpha = 1 - (effect.timer / 0.15)
        end,
        draw = function(effect)
            if effect.alpha <= 0 then return end
            love.graphics.setColor(1, 0.8, 0.2, effect.alpha * 0.7)
            love.graphics.rectangle("fill", effect.x - 5, effect.y - 5, effect.w + 10, effect.h + 10, 8, 8)
        end,
    },
    shake = {
        duration = 0.3,
        update = function(effect, dt)
            effect.timer = effect.timer + dt
            local progress = effect.timer / 0.3
            local intensity = (1 - progress) * 5
            effect.offset_x = (love.math.random() - 0.5) * intensity * 2
            effect.offset_y = (love.math.random() - 0.5) * intensity * 2
        end,
        draw = function(effect)
            -- shake通过修改位置实现，不需要单独绘制
        end,
    },
}

-- 创建伤害数字特效
function Effects.damage(value, x, y)
    local effect = {
        type = "damage_number",
        value = value,
        x = x + love.math.random(-10, 10),
        y = y,
        alpha = 1,
        timer = 0,
    }
    table.insert(active_effects, effect)
end

-- 创建治疗数字特效
function Effects.heal(value, x, y)
    local effect = {
        type = "heal_number",
        value = value,
        x = x,
        y = y,
        alpha = 1,
        timer = 0,
    }
    table.insert(active_effects, effect)
end

-- 创建闪光特效
function Effects.flash(x, y, w, h)
    local effect = {
        type = "flash",
        x = x,
        y = y,
        w = w,
        h = h,
        alpha = 1,
        timer = 0,
    }
    table.insert(active_effects, effect)
end

-- 创建攻击闪光特效
function Effects.attack_flash(x, y, w, h)
    local effect = {
        type = "attack_flash",
        x = x,
        y = y,
        w = w,
        h = h,
        alpha = 1,
        timer = 0,
    }
    table.insert(active_effects, effect)
end

-- 创建震动特效
function Effects.shake(target_ref)
    local effect = {
        type = "shake",
        target = target_ref,
        offset_x = 0,
        offset_y = 0,
        timer = 0,
    }
    table.insert(active_effects, effect)
    return effect
end

-- 更新所有特效
function Effects.update(dt)
    for i = #active_effects, 1, -1 do
        local effect = active_effects[i]
        local effect_type = EFFECT_TYPES[effect.type]

        if effect_type and effect_type.update then
            effect_type.update(effect, dt)
        end

        effect.timer = effect.timer + dt

        -- 检查是否过期
        local duration = effect_type and effect_type.duration or 1.0
        if effect.timer >= duration then
            table.remove(active_effects, i)
        end
    end
end

-- 绘制所有特效
function Effects.draw()
    for _, effect in ipairs(active_effects) do
        local effect_type = EFFECT_TYPES[effect.type]
        if effect_type and effect_type.draw then
            effect_type.draw(effect)
        end
    end
end

-- 清空所有特效
function Effects.clear()
    active_effects = {}
end

-- 获取震动偏移（用于卡牌绘制）
function Effects.get_shake_offset()
    for _, effect in ipairs(active_effects) do
        if effect.type == "shake" then
            return effect.offset_x or 0, effect.offset_y or 0
        end
    end
    return 0, 0
end

return Effects