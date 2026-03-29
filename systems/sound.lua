-- systems/sound.lua - 音效系统
-- 管理游戏音效和音乐

local Sound = {}

-- 音效状态
local sound_state = {
    master_volume = 1.0,
    music_volume = 0.7,
    sfx_volume = 0.8,
    muted = false,
}

-- 音效缓存
local sounds = {}
local music = nil
local current_music = nil

-- 音效定义（占位符，需要实际音频文件）
local SOUND_DEFINITIONS = {
    -- 战斗音效
    attack = { file = "attack.wav", volume = 0.6 },
    hit = { file = "hit.wav", volume = 0.5 },
    death = { file = "death.wav", volume = 0.7 },
    victory = { file = "victory.wav", volume = 0.8 },
    defeat = { file = "defeat.wav", volume = 0.8 },

    -- UI音效
    click = { file = "click.wav", volume = 0.4 },
    hover = { file = "hover.wav", volume = 0.2 },
    select = { file = "select.wav", volume = 0.5 },

    -- 卡牌音效
    draw_card = { file = "draw.wav", volume = 0.4 },
    play_card = { file = "play.wav", volume = 0.5 },
    sacrifice = { file = "sacrifice.wav", volume = 0.6 },
    fuse = { file = "fuse.wav", volume = 0.6 },

    -- 其他
    blood_gain = { file = "blood.wav", volume = 0.5 },
    reward = { file = "reward.wav", volume = 0.7 },
}

-- 初始化音效系统
function Sound.init()
    -- 尝试加载音效文件
    for name, def in pairs(SOUND_DEFINITIONS) do
        local success, source = pcall(love.audio.newSource, "assets/sounds/" .. def.file, "static")
        if success then
            sounds[name] = {
                source = source,
                volume = def.volume,
            }
        else
            -- 音效文件不存在，创建占位符
            sounds[name] = {
                source = nil,
                volume = def.volume,
            }
        end
    end
end

-- 播放音效
function Sound.play(sound_name)
    if sound_state.muted then return end
    if not sounds[sound_name] then return end

    local sound = sounds[sound_name]
    if sound.source then
        local volume = sound.volume * sound_state.sfx_volume * sound_state.master_volume
        sound.source:setVolume(volume)
        sound.source:stop()
        sound.source:play()
    end
end

-- 播放音乐
function Sound.play_music(music_name)
    if sound_state.muted then return end

    -- 尝试加载音乐
    local success, source = pcall(love.audio.newSource, "assets/music/" .. music_name, "stream")
    if success then
        if current_music then
            current_music:stop()
        end
        current_music = source
        current_music:setLooping(true)
        current_music:setVolume(sound_state.music_volume * sound_state.master_volume)
        current_music:play()
    end
end

-- 停止音乐
function Sound.stop_music()
    if current_music then
        current_music:stop()
        current_music = nil
    end
end

-- 设置主音量
function Sound.set_master_volume(volume)
    sound_state.master_volume = math.max(0, math.min(1, volume))
    Sound.update_volumes()
end

-- 设置音乐音量
function Sound.set_music_volume(volume)
    sound_state.music_volume = math.max(0, math.min(1, volume))
    if current_music then
        current_music:setVolume(sound_state.music_volume * sound_state.master_volume)
    end
end

-- 设置音效音量
function Sound.set_sfx_volume(volume)
    sound_state.sfx_volume = math.max(0, math.min(1, volume))
end

-- 静音切换
function Sound.toggle_mute()
    sound_state.muted = not sound_state.muted
    if sound_state.muted then
        Sound.stop_music()
    end
    return sound_state.muted
end

-- 更新所有音量
function Sound.update_volumes()
    if current_music then
        current_music:setVolume(sound_state.music_volume * sound_state.master_volume)
    end
end

-- 获取音量设置
function Sound.get_volumes()
    return {
        master = sound_state.master_volume,
        music = sound_state.music_volume,
        sfx = sound_state.sfx_volume,
        muted = sound_state.muted,
    }
end

-- 应用设置管理器的音量
function Sound.apply_settings(settings_manager)
    if settings_manager then
        sound_state.master_volume = settings_manager.get("master_volume") or 1.0
        sound_state.music_volume = settings_manager.get("music_volume") or 0.7
        sound_state.sfx_volume = settings_manager.get("sfx_volume") or 0.8
        Sound.update_volumes()
    end
end

return Sound