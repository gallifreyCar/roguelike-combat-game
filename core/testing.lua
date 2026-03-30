-- core/testing.lua - 测试框架
-- 简单的测试框架，支持单元测试和集成测试

local Testing = {}

local tests = {}
local results = {
    passed = 0,
    failed = 0,
    errors = {},
}

-- 注册测试
function Testing.test(name, func)
    table.insert(tests, {name = name, func = func})
end

-- 断言
function Testing.assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

function Testing.assert_equal(expected, actual, message)
    if expected ~= actual then
        error(message or string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
    end
end

function Testing.assert_type(value, expected_type, message)
    if type(value) ~= expected_type then
        error(message or string.format("Expected type %s, got %s", expected_type, type(value)))
    end
end

function Testing.assert_not_nil(value, message)
    if value == nil then
        error(message or "Expected non-nil value")
    end
end

-- 运行所有测试
function Testing.run_all()
    results = {passed = 0, failed = 0, errors = {}}

    print("\n========== Running Tests ==========")

    for _, test in ipairs(tests) do
        local success, err = pcall(test.func)
        if success then
            results.passed = results.passed + 1
            print(string.format("  ✓ %s", test.name))
        else
            results.failed = results.failed + 1
            table.insert(results.errors, {name = test.name, error = err})
            print(string.format("  ✗ %s: %s", test.name, err))
        end
    end

    print("\n===================================")
    print(string.format("Results: %d passed, %d failed", results.passed, results.failed))

    return results.failed == 0
end

-- 运行匹配名称的测试
function Testing.run_pattern(pattern)
    local matched = {}
    for _, test in ipairs(tests) do
        if test.name:match(pattern) then
            table.insert(matched, test)
        end
    end

    results = {passed = 0, failed = 0, errors = {}}

    for _, test in ipairs(matched) do
        local success, err = pcall(test.func)
        if success then
            results.passed = results.passed + 1
            print(string.format("  ✓ %s", test.name))
        else
            results.failed = results.failed + 1
            table.insert(results.errors, {name = test.name, error = err})
            print(string.format("  ✗ %s: %s", test.name, err))
        end
    end

    return results.failed == 0
end

-- 获取结果
function Testing.get_results()
    return results
end

-- 清除所有测试
function Testing.clear()
    tests = {}
    results = {passed = 0, failed = 0, errors = {}}
end

-- ==================== 预定义测试 ====================

-- 测试 Settings 模块
Testing.test("Settings: has required fields", function()
    local Settings = require("config.settings")
    Testing.assert_not_nil(Settings.screen_width)
    Testing.assert_not_nil(Settings.board_slots)
    Testing.assert_not_nil(Settings.card_width)
end)

-- 测试 Theme 模块
Testing.test("Theme: returns valid colors", function()
    local Theme = require("config.theme")
    local color = Theme.color("text_primary")
    Testing.assert_type(color, "table")
    Testing.assert_equal(3, #color)
end)

-- 测试 Layout 模块
Testing.test("Layout: returns valid dimensions", function()
    local Layout = require("config.layout")
    local w, h = Layout.get_size()
    Testing.assert_type(w, "number")
    Testing.assert_type(h, "number")
end)

-- 测试 I18n 模块
Testing.test("I18n: translates keys", function()
    local I18n = require("core.i18n")
    I18n.set_lang("en")
    local text = I18n.t("title")
    Testing.assert_not_nil(text)
    Testing.assert_type(text, "string")
end)

return Testing