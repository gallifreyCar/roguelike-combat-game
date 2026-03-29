-- scenes/reward.lua - 奖励选择场景

local Reward = {}

local choices = {}
local selected = 1

function Reward.enter()
    -- 生成奖励选项（临时测试数据）
    choices = {
        {type = "card", name = "打击+", desc = "造成 9 点伤害"},
        {type = "card", name = "防御+", desc = "获得 6 点护盾"},
        {type = "gold", name = "金币", desc = "+30 金币"},
    }
    selected = 1
end

function Reward.exit()
    choices = {}
end

function Reward.update(dt)
end

function Reward.draw()
    love.graphics.clear(0.1, 0.15, 0.1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("选择奖励", 500, 100)

    for i, choice in ipairs(choices) do
        local y = 200 + (i - 1) * 80

        -- 高亮选中项
        if i == selected then
            love.graphics.setColor(0.3, 0.5, 0.3)
            love.graphics.rectangle("fill", 350, y - 10, 300, 60, 5, 5)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(choice.name, 370, y)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print(choice.desc, 370, y + 25)
    end

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("按 1-3 选择，按 ESC 返回", 420, 500)
end

function Reward.keypressed(key)
    if key == "1" then
        selected = 1
        -- TODO: 应用奖励
        local State = require("core.state")
        State.pop()
    elseif key == "2" then
        selected = 2
        local State = require("core.state")
        State.pop()
    elseif key == "3" then
        selected = 3
        local State = require("core.state")
        State.pop()
    elseif key == "escape" then
        local State = require("core.state")
        State.pop()
    end
end

return Reward