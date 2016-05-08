local sandbox = sandbox

function include(path)
    local cfile = io.open("user/root/"..path,"rb")
    if not cfile then return error("Cannot find user/root/"..path) end
    local data = cfile:read("*all")
    cfile:close()

    data = "local sandbox = sandbox;"..data

    return (woahroutine.wrap(load(data,path)))()
end

function includeExt(path)
    local cfile = io.open(path,"rb")
    if not cfile then return error("Cannot find "..path) end
    local data = cfile:read("*all")
    cfile:close()

    return (woahroutine.wrap(load(data,path)))()
end

function includeSandbox(path)
    local cfile = io.open("user/sandbox/"..path,"rb")
    if not cfile then return error("Cannot find user/sandbox/"..path) end
    local data = cfile:read("*all")
    cfile:close()

    local fn,err = load(data,path,nil,sandbox.env)
    if not fn then error(err) end

    local lastIsInitialising = sandbox.isInitialising
    sandbox.isInitialising = true
    local ret = {pcall(fn)}
    sandbox.isInitialising = lastIsInitialising
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

include("superstring.lua")

include("relay.lua")

include("steam_user.lua")
include("steam_chats.lua")

include("discord_user.lua")
include("discord_chats.lua")

include("greeting.lua")

-- include("irc.lua")

include("command.lua")
include("commands/basic.lua")
include("commands/usermanagement.lua")
include("commands/restart.lua")
include("commands/leave.lua")
include("commands/help.lua")

include("discord_music.lua")

include("fp.lua")

include("hooks.lua")
include("markov_exp.lua")
-- include("learn.lua")

include("textrender.lua")
include("render_chan.lua")

local function restoreSandbox()
    includeSandbox("init.lua")
end
sandbox.env.RestoreSandbox = restoreSandbox
sandbox.env.require = function(path)
    if path:match("[%.%:]") then return error("no can do, pal") end
    return includeSandbox(path..".lua")
end

hook.Add("PostSetupENV","setup",restoreSandbox)
hook.Add("PostSetupENV","garry",function()
    -- includeExt("user/sandbox/garry.lua")
end)
