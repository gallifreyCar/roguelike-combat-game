-- core/state.lua - 游戏状态机
-- 管理：菜单→战斗→奖励→死亡的流程

local State = {
    stack = {},      -- 状态栈（支持叠加）
    current = nil,   -- 当前状态
    states = {},     -- 已注册的状态
}

-- 注册状态
function State.register(name, state_impl)
    State.states[name] = state_impl
end

-- 初始化
function State.init()
    -- 注册各场景
    State.register("menu", require("scenes.menu"))
    State.register("combat", require("scenes.combat"))
    State.register("victory", require("scenes.victory"))
    State.register("reward", require("scenes.reward"))
    State.register("death", require("scenes.death"))
end

-- 直接切换（清空栈）
function State.switch(name)
    if State.current and State.current.exit then
        State.current.exit()
    end
    State.stack = {}
    State.current = State.states[name]
    if State.current and State.current.enter then
        State.current.enter()
    end
end

-- 压栈（暂停当前）
function State.push(name)
    if State.current then
        State.stack[#State.stack + 1] = State.current
        if State.current.pause then State.current.pause() end
    end
    State.current = State.states[name]
    if State.current and State.current.enter then
        State.current.enter()
    end
end

-- 弹栈（恢复上一个）
function State.pop()
    if State.current and State.current.exit then
        State.current.exit()
    end
    if #State.stack > 0 then
        State.current = State.stack[#State.stack]
        State.stack[#State.stack] = nil
        if State.current and State.current.resume then
            State.current.resume()
        end
    else
        State.current = nil
    end
end

-- 更新
function State.update(dt)
    if State.current and State.current.update then
        State.current.update(dt)
    end
end

-- 渲染
function State.draw()
    if State.current and State.current.draw then
        State.current.draw()
    end
end

-- 键盘事件转发
function State.keypressed(key)
    if State.current and State.current.keypressed then
        State.current.keypressed(key)
    end
end

return State