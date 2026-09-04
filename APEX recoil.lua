-- =========================================================
-- APEX 纯抖枪宏（无向下压枪 / G HUB 稳定版）
-- =========================================================

-- 1. 用户参数设置
local LMD = 1.0               -- 游戏内鼠标灵敏度
local ADS = 1.0               -- 游戏内开镜灵敏度倍率
local Level = 3               -- 抖枪幅度（建议 1 - 3）
local Press_Key = "Scrolllock"-- 宏开关按键（ScrollLock 点亮时生效）
local YJHJ = 5                -- 一键换甲绑定的侧键（5号键）
local Kai_Jing = 2            -- 开镜模式：1 = 长按开镜（右键+左键），2 = 切换开镜（仅左键）

-- 2. 核心计算与 API 局部化缓存
local Frequency = 4
local range = math.floor(6 / (LMD * ADS)) + Level - 2

local position = {
    {20100, 33000},
    {20100, 43000},
    {20100, 47000},
    {20100, 51000},
    {20100, 55000},
}

-- 缓存高频 API 接口
local GetRunningTime = GetRunningTime
local MoveMouseRelative = MoveMouseRelative
local IsMouseButtonPressed = IsMouseButtonPressed
local Sleep = Sleep

EnablePrimaryMouseButtonEvents(true)

-- 高精度忙等延迟
local function BetterSleep(t)
    local start_time = GetRunningTime()
    repeat
    until (GetRunningTime() - start_time >= t)
end

-- 纯抖枪逻辑（对称对角线移动，总位移完全抵消，不产生向下拉枪）
local function PressAndRecoil()
    for i = 1, 130 do
        if not IsMouseButtonPressed(1) then
            break
        end
        MoveMouseRelative(-range, -range)
        BetterSleep(Frequency)

        MoveMouseRelative(range, range)
        BetterSleep(Frequency)
    end
end

-- 事件响应与换甲
function OnEvent(event, arg)
    -- 按下侧键 5 自动换甲
    if event == "MOUSE_BUTTON_PRESSED" and arg == YJHJ then
        PressKey("e")
        Sleep(120)
        PressAndReleaseKey(57)
        Sleep(380)
        ReleaseKey("e")
        for _, p in ipairs(position) do
            Sleep(5)
            MoveMouseTo(p[1], p[2])
            Sleep(5)
            PressAndReleaseMouseButton(1)
        end
        PressAndReleaseKey("escape")
        return
    end

    -- 抖枪触发判断：仅当按下左键 (arg == 1) 时生效
    --if event == "MOUSE_BUTTON_PRESSED" and arg == 1 then
        if Kai_Jing == 1 then
            if IsMouseButtonPressed(3) and IsKeyLockOn(Press_Key) then
                PressAndRecoil()
            end
        elseif Kai_Jing == 2 then
            if IsKeyLockOn(Press_Key) then
                PressAndRecoil()
            end
        end
    --end
end
-- =========================================================
-- 3. 底层主动轮询（极简通用版）
-- =========================================================
local G = {false, false, false, false, false}

while true do
    for i = 1, 5 do
        local pressed = IsMouseButtonPressed(i)
        if pressed ~= G[i] then
            G[i] = pressed
            OnEvent(pressed and "MOUSE_BUTTON_PRESSED" or "MOUSE_BUTTON_RELEASED", i)
        end
    end
    Sleep(1)
end