local addonName, ns = ...

ns.name = addonName
MyGuideDebug = ns

function ns.Print(msg)
    print("|cFF33FF99" .. ns.name .. "|r: " .. tostring(msg)) 
end


