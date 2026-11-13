local addonName, ns = ...

ns.name = addonName
MyGuideDebug = ns

function ns.Print(msg)
    print("|cFF33FF99" .. ns.name .. "|r: " .. tostring(msg)) 
end

local eventFrame = CreateFrame("Frame") --#订阅事件
local handlers = {}
function ns.RegisterEvent(event, fn)
    if handlers[event] == nil then
        handlers[event] = {}
        eventFrame:RegisterEvent(event)
    end
    table.insert(handlers[event],fn)
end

eventFrame:SetScript("OnEvent", function(self, event, ...)--#收到事件行为
    local list = handlers[event]
    if list == nil then
        return
    end

    for _, fn in ipairs(list) do
        fn(event, ...)
    end
end)

local listeners = {}--#内部消息通报
function ns.Listen(name, fn)
    if listeners[name] == nil then
        listeners[name] = {}
    end

    table.insert(listeners[name], fn)
end

function ns.Fire(name, ...)
    local list = listeners[name]
    if list == nil then
        return
    end
    for _, fn in ipairs(list) do
        fn(...)

    end
end

local DEFAULTS = {currentStep = 1}--#存档初始化
ns.RegiserEvent("ADDON_LOADED", function(event, name)
    if name ~= addonName then
        return
    end
    if MyGuideCharDB == nil then
        MyGuideCharDB = {}
    end
    for key, value in pairs(DEFAULTS) do
        if MyGuideCharDB[key] == nil then
            MyGuideCharDB[key] = value
        end
    end
    ns.db = MyGuideCharDB
end)

ns.RegisterEvent("PLAYER_LOGIN", function(event)--#region角色进入世界时触发
    ns.Print("已加载，输入 /mg help 查看命令")
end)

function ns.SetStep(n)--#region步骤与订阅示例
    if n <1 then
        n = 1
    end
    ns.db.currentStep = n 
    ns.Fire("STEP_CHANGED",n)
end

ns.Listen("STEP_CHANGED", function(n)
    ns.Print("当前步骤："..n)
end)

ns.RegisterEvent("PLAYER_LEVEL_UP", function(event, newLevel)
    ns.Print("你升到了" .. tostring(newLevel) .. "级")
end)

local commands = {}--#region显示命令
commands.help = function()
    ns.Print("命令：")
    print(" /mg next    下一步")
     print(" /mg prev    上一步")
      print(" /mg step N    跳转到第N步")
       print(" /mg status    查看当前存档")
        print(" /mg reset    回到第1步")
end

commands.next = function() ns.SetStep(ns.db.currentStep + 1) end
commands.prev = function() ns.SetStep(ns.db.currentStep - 1) end
commands.reset = function() ns.SetStep(1) end

commands.step = function(arg)
    local n = tonumber(arg)
    if n then
        ns.SetStep(n)
    else
        ns.Print("用法：/mg step 5")
    end
end

commands.status = function()
    ns.Print("当前步骤" .. ns.db.currentStep)
end

SLASH_MYGUIDE1 = "/myguide"
SLASH_MYGUIDE2 = "/mg"

SlashCmdList["MYGUIDE"] = function(msg)
    local cmd, arg = msg:lower():match("^(%S*)%s*(.-)$")
    local fn = commands[cmd]
    if fn then
        fn(arg)
    else
        commands.help() 
    end
end