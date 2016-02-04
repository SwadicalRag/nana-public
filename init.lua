local sandbox = sandbox

function include(path)
    local cfile = io.open("user/root/"..path,"rb")
    if not cfile then return error("Cannot find user/root/"..path) end
    local data = cfile:read("*all")
    cfile:close()

    data = "local sandbox = sandbox;"..data

    return (woahroutine.wrap(load(data,path)))()
end

function includeSandbox(path)
    local cfile = io.open("user/sandbox/"..path,"rb")
    if not cfile then return error("Cannot find user/sandbox/"..path) end
    local data = cfile:read("*all")
    cfile:close()

    local fn,err = load(data,path,nil,sandbox.env)
    if not fn then error(err) end

    local ret = {pcall(fn)}
    if not ret[1] then error(path..": "..ret[2]) end
    table.remove(ret,1)

    return unpack(ret)
end

function nameFromEnum(name,value)
    for enumName,enum in pairs(Steam[name]) do
        if enum == value then return enumName end
    end
    return "Unknown"
end

include("user.lua")
include("chats.lua")

include("command.lua")
include("commands/basic.lua")
include("commands/usermanagement.lua")

include("hooks.lua")

local function restoreSandbox()
    includeSandbox("garry.lua")
    includeSandbox("fn.lua")
    includeSandbox("sed.lua")
end
sandbox.env.RestoreSandbox = restoreSandbox
sandbox.env.require = function(path)
    return includeSandbox(path..".lua")
end

hook.Add("PostSetupENV","setup",restoreSandbox)
