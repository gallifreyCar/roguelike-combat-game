-- core/state.lua - 游戏状态机

local State = {
    stack = {},
    current = nil,
    states = {},
}

function State.register(name, state_impl)
    State.states[name] = state_impl
end

function State.init()
    State.register("menu", require("scenes.menu"))
    State.register("combat", require("scenes.combat"))
    State.register("victory", require("scenes.victory"))
    State.register("death", require("scenes.death"))
    State.register("reward", require("scenes.reward"))
    State.register("fusion", require("scenes.fusion"))
    State.register("map", require("scenes.map"))
end

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

function State.update(dt)
    if State.current and State.current.update then
        State.current.update(dt)
    end
end

function State.draw()
    if State.current and State.current.draw then
        State.current.draw()
    end
end

function State.keypressed(key)
    if State.current and State.current.keypressed then
        State.current.keypressed(key)
    end
end

function State.mousepressed(x, y, button)
    if State.current and State.current.mousepressed then
        State.current.mousepressed(x, y, button)
    end
end

function State.mousemoved(x, y, dx, dy)
    if State.current and State.current.mousemoved then
        State.current.mousemoved(x, y, dx, dy)
    end
end

function State.mousereleased(x, y, button)
    if State.current and State.current.mousereleased then
        State.current.mousereleased(x, y, button)
    end
end

return State