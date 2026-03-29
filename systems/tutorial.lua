-- systems/tutorial.lua - 教程系统
-- 新手引导和操作提示

local Tutorial = {}

-- 教程步骤
local TUTORIAL_STEPS = {
    {
        id = "welcome",
        title = "Welcome to Blood Cards!",
        text = "A roguelike auto-battler card game.\nLet's learn the basics!",
        highlight = nil,
    },
    {
        id = "hand",
        title = "Your Hand",
        text = "Cards on the right panel are your hand.\nDrag them to the board to play.",
        highlight = {x = 1070, y = 50, w = 180, h = 500},
    },
    {
        id = "blood",
        title = "Blood System",
        text = "Each card has a cost in Blood.\nYou start with 1 Blood per turn.",
        highlight = {x = 220, y = 510, w = 140, h = 30},
    },
    {
        id = "sacrifice",
        title = "Sacrifice",
        text = "Right-click a card on the board\nto sacrifice it for +1 Blood!",
        highlight = {x = 150, y = 270, w = 520, h = 140},
    },
    {
        id = "battle",
        title = "Battle!",
        text = "Click the BATTLE button\nwhen you're ready to fight!",
        highlight = {x = 600, y = 440, w = 160, h = 55},
    },
    {
        id = "auto_attack",
        title = "Auto Battle",
        text = "Cards attack automatically each turn.\nReduce enemy HP to 0 to win!",
        highlight = nil,
    },
}

-- 教程状态
local tutorial_state = {
    enabled = true,
    current_step = 1,
    seen_tutorials = {},
}

-- 开始教程
function Tutorial.start()
    if not tutorial_state.enabled then return end
    tutorial_state.current_step = 1
end

-- 下一步
function Tutorial.next()
    tutorial_state.current_step = tutorial_state.current_step + 1
    if tutorial_state.current_step > #TUTORIAL_STEPS then
        Tutorial.complete()
        return false
    end
    return true
end

-- 跳过教程
function Tutorial.skip()
    tutorial_state.current_step = #TUTORIAL_STEPS + 1
    Tutorial.complete()
end

-- 完成教程
function Tutorial.complete()
    tutorial_state.enabled = false
    -- 标记已完成
    local SettingsManager = require("systems.settings_manager")
    SettingsManager.set("show_tutorial", false)
end

-- 重置教程
function Tutorial.reset()
    tutorial_state.enabled = true
    tutorial_state.current_step = 1
    tutorial_state.seen_tutorials = {}
end

-- 是否显示教程
function Tutorial.should_show()
    return tutorial_state.enabled and tutorial_state.current_step <= #TUTORIAL_STEPS
end

-- 获取当前步骤
function Tutorial.get_current_step()
    if not Tutorial.should_show() then return nil end
    return TUTORIAL_STEPS[tutorial_state.current_step]
end

-- 获取当前步骤索引
function Tutorial.get_step_index()
    return tutorial_state.current_step
end

-- 获取总步骤数
function Tutorial.get_total_steps()
    return #TUTORIAL_STEPS
end

-- 绘制教程覆盖层
function Tutorial.draw_overlay()
    if not Tutorial.should_show() then return end

    local step = TUTORIAL_STEPS[tutorial_state.current_step]
    if not step then return end

    -- 半透明背景
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 1280, 720)

    -- 高亮区域
    if step.highlight then
        local h = step.highlight
        love.graphics.setColor(1, 1, 0.5, 0.3)
        love.graphics.rectangle("fill", h.x, h.y, h.w, h.h)
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.rectangle("line", h.x, h.y, h.w, h.h)
    end

    -- 教程框
    local box_w, box_h = 400, 180
    local box_x = (1280 - box_w) / 2
    local box_y = 250

    love.graphics.setColor(0.15, 0.18, 0.22)
    love.graphics.rectangle("fill", box_x, box_y, box_w, box_h, 10, 10)
    love.graphics.setColor(0.5, 0.6, 0.7)
    love.graphics.rectangle("line", box_x, box_y, box_w, box_h, 10, 10)

    -- 标题
    local Fonts = require("core.fonts")
    love.graphics.setColor(1, 0.9, 0.7)
    Fonts.print(step.title, box_x + 20, box_y + 15, 18)

    -- 内容
    love.graphics.setColor(0.9, 0.85, 0.8)
    local lines = {}
    for line in step.text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    for i, line in ipairs(lines) do
        Fonts.print(line, box_x + 20, box_y + 50 + (i - 1) * 22, 14)
    end

    -- 进度
    love.graphics.setColor(0.6, 0.6, 0.6)
    Fonts.print("Step " .. tutorial_state.current_step .. "/" .. #TUTORIAL_STEPS,
                box_x + 150, box_y + box_h - 35, 12)

    -- 按钮
    love.graphics.setColor(0.3, 0.5, 0.4)
    love.graphics.rectangle("fill", box_x + 30, box_y + box_h - 45, 100, 30, 5, 5)
    love.graphics.setColor(1, 1, 1)
    Fonts.print("Skip", box_x + 60, box_y + box_h - 37, 14)

    love.graphics.setColor(0.4, 0.5, 0.6)
    love.graphics.rectangle("fill", box_x + box_w - 130, box_y + box_h - 45, 100, 30, 5, 5)
    love.graphics.setColor(1, 1, 1)
    Fonts.print("Next", box_x + box_w - 100, box_y + box_h - 37, 14)
end

-- 处理教程点击
function Tutorial.handle_click(x, y)
    if not Tutorial.should_show() then return false end

    local box_w, box_h = 400, 180
    local box_x = (1280 - box_w) / 2
    local box_y = 250

    -- Skip按钮
    if x >= box_x + 30 and x <= box_x + 130 and
       y >= box_y + box_h - 45 and y <= box_y + box_h - 15 then
        Tutorial.skip()
        return true
    end

    -- Next按钮
    if x >= box_x + box_w - 130 and x <= box_x + box_w - 30 and
       y >= box_y + box_h - 45 and y <= box_y + box_h - 15 then
        Tutorial.next()
        return true
    end

    return true  -- 拦截其他点击
end

-- 检查教程是否启用
function Tutorial.is_enabled()
    return tutorial_state.enabled
end

-- 设置教程启用状态
function Tutorial.set_enabled(enabled)
    tutorial_state.enabled = enabled
end

return Tutorial