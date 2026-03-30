-- core/input.lua - 输入处理
-- 统一管理键盘、鼠标输入

local Input = {
    keys = {},       -- 按键状态
    mouse = {        -- 鼠标状态
        x = 0, y = 0,
        pressed = false,
    },
    callbacks = {},  -- 输入回调
}

function Input.update(dt)
    -- 更新鼠标位置
    Input.mouse.x, Input.mouse.y = love.mouse.getPosition()
end

function Input.on_key_press(key)
    Input.keys[key] = true

    -- 触发回调
    if Input.callbacks[key] then
        Input.callbacks[key]()
    end

    -- ESC 不再全局处理，由各场景自行处理
end

function Input.on_key_release(key)
    Input.keys[key] = false
end

function Input.on_mouse_press(x, y, button)
    Input.mouse.pressed = true
    Input.mouse.button = button

    -- 触发点击回调
    if Input.callbacks["click"] then
        Input.callbacks["click"](x, y, button)
    end
end

function Input.on_mouse_release(x, y, button)
    Input.mouse.pressed = false
end

-- 注册回调
function Input.bind(key, callback)
    Input.callbacks[key] = callback
end

return Input