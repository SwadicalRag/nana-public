command = {}
command.commands = {}

function command.Add(name,callback)
    command.commands[name] = callback
end

function command.Remove(name)
    command.commands[name] = nil
end

function command.GetTable()
    return command.commands
end

hook.Add("steamClient.friendMessage","commands",function(steamID,msg)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        sayEx(steamID,string.format(msg,...))
    end

    if command.commands[cmd] then
        command.commands[cmd](argStr or "",reply,reply,steamID)
    else
        reply("Unknown command '%s'",cmd)
    end
end)

hook.Add("steamClient.chatMessage","commands",function(chatRoom,steamID,msg)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        sayEx(chatRoom,string.format(msg,...))
    end

    local function replyPersonal(msg,...)
        sayEx(steamID,string.format(msg,...))
    end

    if command.commands[cmd] then
        command.commands[cmd](argStr or "",reply,replyPersonal,steamID,chatRoom)
    else
        reply("Unknown command '%s'",cmd)
    end
end)
