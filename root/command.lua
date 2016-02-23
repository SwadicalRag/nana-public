command = {}
command.commands = {}

COMMAND_ALL,COMMAND_MODERATOR,COMMAND_ADMIN = 0,1,2

function command.Add(name,callback,description,usage,cmdflag,handler)
    command.commands[name] = {
        callback = callback,
        description = description,
        usage = usage,
        cmdflag = cmdflag or COMMAND_ALL,
        handler = handler or false,
        getRankFlag = function()
            if cmdflag == COMMAND_ADMIN then
                return "[ADMIN] "
            elseif cmdflag == COMMAND_MODERATOR then
                return "[MODERATOR] "
            else
                return ""
            end
        end,
        canUse = function(steamID)
            if cmdflag == COMMAND_ADMIN then
                return IsAdmin(steamID)
            elseif cmdflag == COMMAND_MODERATOR then
                return IsModerator(steamID) or IsAdmin(steamID)
            else
                return true
            end
        end
    }
end

function command.Alias(name1,name2)
    command.commands[name1] = command.commands[name2]
end

function command.Remove(name)
    command.commands[name] = nil
end

function command.GetTable()
    return command.commands
end

hook.Add("steamClient.friendMessageEx","commands",function(steamID,msg)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end
    local user = steamUser.GetBySteamID64(steamID)

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        handlers.push("steam")
        sayEx(steamID,string.format(msg,...))
        handlers.pop()
    end

    if command.commands[cmd] then
        if commands.commands[cmd].handler and (commands.commands[cmd].handler ~= "steam") then return end
        if not command.commands[cmd].canUse(steamID) then
            return reply("%s, you do not have enough permissions to run this command.",user:Nick())
        end
        sandbox:PushOwner(steamID)
        sandbox:PushTargetAudience(steamID)
        sandbox:PushHandler("steam")
        xpcall(command.commands[cmd].callback,function(err)
            print("error in command "..cmd)
            print(err)
            print(debug.traceback())
        end,argStr or "",reply,reply,user,false)
        sandbox:PopHandler()
        sandbox:PopTargetAudience()
        sandbox:PopOwner()
    else
        reply("Unknown command '%s'",cmd)
    end
end)

hook.Add("steamClient.chatMessageEx","commands",function(chatRoomID,steamID,msg)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end
    local user = steamUser.GetBySteamID64(steamID)
    local chatRoom = steamChat.GetBySteamID64(chatRoomID)

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        handlers.push("steam")
        sayEx(chatRoomID,string.format(msg,...))
        handlers.pop()
    end

    local function replyPersonal(msg,...)
        handlers.push("steam")
        sayEx(steamID,string.format(msg,...))
        handlers.pop()
    end

    if command.commands[cmd] then
        if commands.commands[cmd].handler and commands.commands[cmd].handler ~= "steam" then return end
        if not command.commands[cmd].canUse(steamID) then
            return reply("%s, you do not have enough permissions to run this command.",user:Nick())
        end
        sandbox:PushOwner(steamID)
        sandbox:PushTargetAudience(chatRoomID)
        sandbox:PushHandler("steam")
        xpcall(command.commands[cmd].callback,function(err)
            print("error in command "..cmd)
            print(err)
            print(debug.traceback())
        end,argStr or "",reply,replyPersonal,user,chatRoom)
        sandbox:PopHandler()
        sandbox:PopTargetAudience()
        sandbox:PopOwner()
    else
        reply("Unknown command '%s'",cmd)
    end
end)

hook.Add("discord.message","commands",function(username,id,msg,chanID)
    if msg:sub(1,1) ~= COMMAND_PREFIX then return end
    local user = discordUser.GetByID(id)
    local chatRoom = discordChannel.GetByID(chanID)

    local cmd,argStr = msg:match("^.(%S+)%s*(.*)")

    if not cmd then return end

    local function reply(msg,...)
        handlers.push("discord")
        sayEx(chatRoomID,string.format(msg,...))
        handlers.pop()
    end

    local function replyPersonal(msg,...)
        handlers.push("discord")
        sayEx(chatRoomID,string.format(msg,...))
        handlers.pop()
    end

    if command.commands[cmd] then
        if commands.commands[cmd].handler and commands.commands[cmd].handler ~= "discord" then return end
        if not command.commands[cmd].canUse(steamID) then
            return reply("%s, you do not have enough permissions to run this command.",user:Nick())
        end
        protector:PushTargetAudience(chanID)
        protector:PushOwner(id)
        protector:PushHandler("discord")
        xpcall(command.commands[cmd].callback,function(err)
            print("error in command "..cmd)
            print(err)
            print(debug.traceback())
        end,argStr or "",reply,replyPersonal,user,chatRoom)
        sandbox:PopHandler()
        sandbox:PopTargetAudience()
        sandbox:PopOwner()
    else
        reply("Unknown command '%s'",cmd)
    end
end)

hook.Call("CommandModuleReady",command)
