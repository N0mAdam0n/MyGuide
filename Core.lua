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

local DEFAULTS = {currentSttep = 1}--#存档初始化
ns.RegiserEvent("ADDON_LOADED", function(event. name)
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

ns.RegisterEvent("PLAYER_LOGIN", function(event)--#region角色进入世界是触发
    ns.Print("已加载，输入 /mg help 查看命令")
end)
