-- config/version.lua - 版本管理模块
-- 单一真相来源，用于存档兼容性和显示

local Version = {
    major = 1,
    minor = 0,
    patch = 0,
    name = "Blood Cards",
    release_name = "Round 10 Release",
    build_date = "2026-03-31",
}

-- 获取完整版本字符串
function Version.get_full()
    return string.format("%d.%d.%d", Version.major, Version.minor, Version.patch)
end

-- 获取带名称的版本字符串
function Version.get_display()
    return string.format("%s v%s", Version.name, Version.get_full())
end

-- 检查存档兼容性
function Version.is_compatible(save_version)
    if not save_version then return false end
    -- 主版本号必须匹配
    return save_version.major == Version.major
end

-- 获取版本信息表
function Version.get_info()
    return {
        version = Version.get_full(),
        name = Version.name,
        release = Version.release_name,
        date = Version.build_date,
    }
end

return Version