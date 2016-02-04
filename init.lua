function include(path)
    local cfile = io.open("user/"..path,"rb")
    if not cfile then return end
    local data = cfile:read("a")
    cfile:close()

    data = "local sandbox = sandbox;"..data

    return (woahroutine.wrap(load(data,path)))()
end

function nameFromEnum(name,value)
    for enumName,enum in pairs(Steam[name]) do
        if enum == value then return enumName end
    end
    return "Unknown"
end

include("user.lua")
include("chats.lua")

include("hooks.lua")
