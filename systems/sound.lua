-- systems/sound.lua - 音效系统
-- 管理游戏音效和音乐（支持动态波形生成）

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

-- ==================== 动态波形生成 ====================

-- 生成正弦波音效
local function generate_sine_wave(duration, frequency, volume)
    local sample_rate = 44100
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        -- 添加衰减包络
        local envelope = math.exp(-t * 3) * volume
        local value = math.sin(2 * math.pi * frequency * t) * envelope
        sound_data:setSample(i, value)
    end

    return love.audio.newSource(sound_data, "static")
end

-- 生成方波音效（更尖锐的声音）
local function generate_square_wave(duration, frequency, volume)
    local sample_rate = 44100
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 4) * volume
        local phase = (2 * math.pi * frequency * t) % (2 * math.pi)
        local value = (phase < math.pi and 1 or -1) * envelope
        sound_data:setSample(i, value)
    end

    return love.audio.newSource(sound_data, "static")
end

-- 生成噪音音效（用于攻击/冲击）
local function generate_noise(duration, volume)
    local sample_rate = 44100
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 6) * volume
        local value = (love.math.random() * 2 - 1) * envelope
        sound_data:setSample(i, value)
    end

    return love.audio.newSource(sound_data, "static")
end

-- 生成和弦音效（用于胜利）
local function generate_chord(duration, frequencies, volume)
    local sample_rate = 44100
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 2) * volume
        local value = 0
        for _, freq in ipairs(frequencies) do
            value = value + math.sin(2 * math.pi * freq * t) / #frequencies
        end
        sound_data:setSample(i, value * envelope)
    end

    return love.audio.newSource(sound_data, "static")
end

-- 生成下降音调（用于失败）
local function generate_descending(duration, start_freq, volume)
    local sample_rate = 44100
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 2) * volume
        -- 频率随时间下降
        local freq = start_freq * (1 - t / duration * 0.5)
        local value = math.sin(2 * math.pi * freq * t) * envelope
        sound_data:setSample(i, value)
    end

    return love.audio.newSource(sound_data, "static")
end

-- 音效定义（使用动态生成）
local SOUND_DEFINITIONS = {
    -- 战斗音效
    attack = { generator = "square", freq = 200, duration = 0.15, volume = 0.6 },
    hit = { generator = "noise", duration = 0.1, volume = 0.5 },
    death = { generator = "sine", freq = 150, duration = 0.3, volume = 0.7 },
    victory = { generator = "chord", frequencies = {523, 659, 784}, duration = 0.5, volume = 0.8 },
    defeat = { generator = "descending", start_freq = 400, duration = 0.4, volume = 0.8 },

    -- UI音效
    click = { generator = "sine", freq = 800, duration = 0.05, volume = 0.4 },
    hover = { generator = "sine", freq = 600, duration = 0.03, volume = 0.2 },
    select = { generator = "sine", freq = 1000, duration = 0.08, volume = 0.5 },

    -- 卡牌音效
    draw_card = { generator = "sine", freq = 500, duration = 0.1, volume = 0.4 },
    play_card = { generator = "square", freq = 350, duration = 0.12, volume = 0.5 },
    sacrifice = { generator = "descending", start_freq = 600, duration = 0.2, volume = 0.6 },
    fuse = { generator = "chord", frequencies = {400, 600}, duration = 0.3, volume = 0.6 },

    -- 其他
    blood_gain = { generator = "sine", freq = 700, duration = 0.15, volume = 0.5 },
    reward = { generator = "chord", frequencies = {440, 550, 660}, duration = 0.25, volume = 0.7 },
    purchase = { generator = "chord", frequencies = {600, 800}, duration = 0.2, volume = 0.6 },
    error = { generator = "noise", duration = 0.15, volume = 0.5 },
}

-- 初始化音效系统
function Sound.init()
    -- 使用动态生成创建音效
    for name, def in pairs(SOUND_DEFINITIONS) do
        local source = nil

        if def.generator == "sine" then
            source = generate_sine_wave(def.duration, def.freq, def.volume)
        elseif def.generator == "square" then
            source = generate_square_wave(def.duration, def.freq, def.volume)
        elseif def.generator == "noise" then
            source = generate_noise(def.duration, def.volume)
        elseif def.generator == "chord" then
            source = generate_chord(def.duration, def.frequencies, def.volume)
        elseif def.generator == "descending" then
            source = generate_descending(def.duration, def.start_freq, def.volume)
        end

        if source then
            sounds[name] = {
                source = source,
                volume = def.volume,
            }
        end
    end

    -- 计算音效数量（使用 table 格式）
    local count = 0
    for _ in pairs(sounds) do count = count + 1 end
    -- 音效系统已初始化（静默模式）
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