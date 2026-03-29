-- utils/math.lua - 数学工具函数

local MathUtils = {}

-- 限制值在范围内
function MathUtils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- 线性插值
function MathUtils.lerp(a, b, t)
    return a + (b - a) * t
end

-- 随机范围
function MathUtils.random_range(min, max)
    return min + love.math.random() * (max - min)
end

-- 随机整数范围
function MathUtils.random_int(min, max)
    return love.math.random(min, max)
end

-- 检测点是否在矩形内
function MathUtils.point_in_rect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- 计算两点距离
function MathUtils.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- 角度转弧度
function MathUtils.deg_to_rad(deg)
    return deg * math.pi / 180
end

-- 弧度转角度
function MathUtils.rad_to_deg(rad)
    return rad * 180 / math.pi
end

return MathUtils