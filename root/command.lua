command = {}
command.commands = {}

function command.Add(name,callback,description,usage,adminOnly)
    command.commands[name] = {
        callback = callback,
        description = description,
        usage = usage,
        adminOnly = adminOnly
    }
end

function command.Remove(name)
    command.commands[name] = nil
end

function command.GetTable()
    return command.commands
end

hook.Add("steamClient.friendMessageEx","commands",function(steamID,msg)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end
    local user = user.GetBySteamID64(steamID)

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        sayEx(steamID,string.format(msg,...))
    end

    if command.commands[cmd] then
        if command.commands[cmd].adminOnly and (not IsAdmin(steamID)) then
            return reply("%s, you do not have enough permissions to run this command.",user:Nick())
        end
        command.commands[cmd].callback(argStr or "",reply,reply,user,false)
    else
        reply("Unknown command '%s'",cmd)
    end
end)

hook.Add("steamClient.chatMessageEx","commands",function(chatRoomID,steamID,msg)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end
    local user = user.GetBySteamID64(steamID)
    local chatRoom = chat.GetBySteamID64(chatRoomID)

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        sayEx(chatRoomID,string.format(msg,...))
    end

    local function replyPersonal(msg,...)
        sayEx(steamID,string.format(msg,...))
    end

    if command.commands[cmd] then
        if command.commands[cmd].adminOnly and (not IsAdmin(steamID)) then
            return reply("%s, you do not have enough permissions to run this command.",user:Nick())
        end
        command.commands[cmd].callback(argStr or "",reply,replyPersonal,user,chatRoom)
    else
        reply("Unknown command '%s'",cmd)
    end
end)
