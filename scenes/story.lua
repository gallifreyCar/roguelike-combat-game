-- scenes/story.lua - 剧情/对话场景
-- 显示故事文本、NPC对话

local StoryScene = {}
local State = require("core.state")
local Fonts = require("core.fonts")
local I18n = require("core.i18n")
local Theme = require("config.theme")
local Layout = require("config.layout")
local Components = require("ui.components")
local Sound = require("systems.sound")

local dialogue = {}
local current_index = 1
local on_complete = nil
local char_timer = 0
local displayed_chars = 0
local typing_speed = 0.02  -- 秒/字符

function StoryScene.enter(dialogue_data, callback)
    dialogue = dialogue_data or {}
    current_index = 1
    on_complete = callback
    char_timer = 0
    displayed_chars = 0
end

function StoryScene.exit()
    dialogue = {}
    current_index = 1
    on_complete = nil
end

function StoryScene.update(dt)
    if #dialogue == 0 then return end

    local current = dialogue[current_index]
    if not current then return end

    -- 打字机效果
    char_timer = char_timer + dt
    local text = current.text or ""
    if displayed_chars < #text then
        displayed_chars = math.min(#text, displayed_chars + math.floor(char_timer / typing_speed))
        char_timer = char_timer % typing_speed
    end
end

function StoryScene.draw()
    Theme.setColor("bg_primary")
    love.graphics.clear()

    local win_w, win_h = Layout.get_size()

    if #dialogue == 0 then
        Components.text("No dialogue", win_w / 2, win_h / 2, {
            color = "text_hint",
            align = "center",
        })
        return
    end

    local current = dialogue[current_index]
    if not current then return end

    -- 背景暗化
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, win_w, win_h)

    -- 对话框
    local box_w = win_w * 0.8
    local box_h = 180
    local box_x = (win_w - box_w) / 2
    local box_y = win_h - box_h - 50

    Theme.setColor("bg_panel")
    love.graphics.rectangle("fill", box_x, box_y, box_w, box_h, 8, 8)
    Theme.setColor("border_gold", 0.5)
    love.graphics.rectangle("line", box_x, box_y, box_w, box_h, 8, 8)

    -- 说话者
    local speaker = current.speaker or "narrator"
    local speaker_name = StoryScene.get_speaker_name(speaker)

    if speaker ~= "narrator" then
        Components.text(speaker_name, box_x + 20, box_y + 15, {
            color = "accent_gold",
            size = 18,
        })
    end

    -- 文本（打字机效果）
    local text = current.text or ""
    local display_text = text:sub(1, displayed_chars)

    love.graphics.setColor(1, 1, 1)
    Fonts.print(display_text, box_x + 20, box_y + (speaker ~= "narrator" and 50 or 20), 16)

    -- 继续提示
    local text_complete = displayed_chars >= #text
    if text_complete then
        Components.text("[Click to continue]", win_w / 2, box_y + box_h - 30, {
            color = "text_hint",
            align = "center",
        })
    else
        Components.text("[Click to skip]", win_w / 2, box_y + box_h - 30, {
            color = "text_hint",
            align = "center",
        })
    end

    -- 进度指示
    Components.text(current_index .. "/" .. #dialogue, box_x + box_w - 40, box_y + 15, {
        color = "text_hint",
        size = 14,
    })
end

function StoryScene.get_speaker_name(speaker)
    local names = {
        narrator = "",
        blood_lord = "The Blood Lord",
        mysterious_merchant = "The Merchant",
        fusion_master = "The Alchemist",
        player = "You",
    }
    return names[speaker] or speaker
end

function StoryScene.advance()
    if #dialogue == 0 then
        StoryScene.complete()
        return
    end

    local current = dialogue[current_index]
    local text = current and current.text or ""

    -- 如果文本还没显示完，直接显示完整文本
    if displayed_chars < #text then
        displayed_chars = #text
        return
    end

    -- 前进到下一条
    current_index = current_index + 1
    displayed_chars = 0
    char_timer = 0

    Sound.play("click")

    if current_index > #dialogue then
        StoryScene.complete()
    end
end

function StoryScene.complete()
    local callback = on_complete
    dialogue = {}
    current_index = 1
    on_complete = nil

    if callback then
        callback()
    else
        State.pop()
    end
end

function StoryScene.keypressed(key)
    if key == "space" or key == "return" then
        StoryScene.advance()
    elseif key == "escape" then
        StoryScene.complete()
    end
end

function StoryScene.mousepressed(x, y, button)
    if button == 1 then
        StoryScene.advance()
    end
end

return StoryScene