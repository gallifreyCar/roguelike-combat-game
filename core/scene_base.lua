-- core/scene_base.lua - 场景基类
-- 提供统一的场景生命周期管理

local SceneBase = {}

-- 创建新场景
function SceneBase.new(name)
    local scene = {
        name = name or "unknown",
        initialized = false,
        paused = false,
    }

    -- 默认生命周期方法
    scene.enter = function(self)
        self.initialized = true
        self.paused = false
    end

    scene.exit = function(self)
        self.initialized = false
    end

    scene.pause = function(self)
        self.paused = true
    end

    scene.resume = function(self)
        self.paused = false
    end

    scene.update = function(self, dt)
        -- 子类实现
    end

    scene.draw = function(self)
        -- 子类实现
    end

    scene.keypressed = function(self, key)
        -- 默认 ESC 返回
        if key == "escape" then
            local State = require("core.state")
            State.pop()
        end
    end

    scene.mousepressed = function(self, x, y, button)
        -- 子类实现
    end

    scene.mousemoved = function(self, x, y, dx, dy)
        -- 子类实现
    end

    scene.mousereleased = function(self, x, y, button)
        -- 子类实现
    end

    -- 辅助方法：获取窗口尺寸
    scene.get_size = function(self)
        return love.graphics.getWidth(), love.graphics.getHeight()
    end

    -- 辅助方法：居中
    scene.center = function(self, width, height)
        local w, h = self:get_size()
        return (w - width) / 2, (h - height) / 2
    end

    -- 辅助方法：检测鼠标在矩形内
    scene.mouse_in = function(self, x, y, w, h)
        local mx, my = love.mouse.getPosition()
        return mx >= x and mx <= x + w and my >= y and my <= y + h
    end

    return scene
end

-- 场景注册表
local scenes = {}

-- 注册场景
function SceneBase.register(name, scene)
    scenes[name] = scene
    return scene
end

-- 获取场景
function SceneBase.get(name)
    return scenes[name]
end

return SceneBase