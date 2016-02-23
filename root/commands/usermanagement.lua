command.Add("rank",function(argStr,reply)
    local steamID64,targetRank = argStr:match("^%s*(%d+)%s*(%S+)")
    if not (steamID64 and targetRank) then
        return reply("Bad arguments! Usage: rank <steamID64/discord ID> <*/moderator/admin>")
    end

    -- not FindByName just in case people change their names to our wanted target
    local targetUser = steamUser.GetBySteamID64(steamID64) or discordUser.GetByID(steamID64)
    if targetRank == "admin" then
        SetAdmin(steamID64,true)
        reply("Set %s's rank to admin",targetUser and targetUser:Nick() or steamID64)
    elseif targetRank == "moderator" then
        SetModerator(steamID64,true)
        reply("Set %s's rank to moderator",targetUser and targetUser:Nick() or steamID64)
    else -- so you can do !rank <id> peasant, lmao
        SetAdmin(steamID64,false)
        SetModerator(steamID64,false)
        reply("Set %s's rank to %s",targetUser and targetUser:Nick() or steamID64,targetRank)
    end
end,"Sets someone's rank","<steamID64/discord ID> <*/moderator/admin>",COMMAND_ADMIN)

command.Add("limit",function(argStr,reply)
    local steamID64,targetState = argStr:match("^%s*(%d+)%s*(%S+)")
    if not (steamID64 and targetState) or ((targetState ~= "true") and (targetState ~= "false")) then
        return reply("Bad arguments! Usage: limit <steamID64/discord ID> <true/false>")
    end

    if IsAdmin(steamID64) then
        return reply("This person is an admin. Request denied.")
    elseif IsModerator(steamID64) then
        return reply("This person is a moderator. Request denied.")
    end

    -- not FindByName just in case people change their names to our wanted target
    local targetUser = steamUser.GetBySteamID64(steamID64) or discordUser.GetByID(steamID64)
    if targetState == "true" then
        SetBlacklist(steamID64,true)
        reply("Blacklisted %s from using the bot",targetUser and targetUser:Nick() or steamID64)
    else -- so you can do !rank <id> peasant, lmao
        SetBlacklist(steamID64,false)
        reply("Pardoned %s.",targetUser and targetUser:Nick() or steamID64)
    end
end,"Blacklists someone from the bot","<steamID64/discord ID> <true/false>",COMMAND_MODERATOR)

command.Add("add",function(argStr,reply,replyPersonal,user,chatroom)
    steamClient.addFriend(user:SteamID():ID64())
    reply("I have sent you a friend request, %s.",user:Nick())
end,"Asks the bot to send you a friend request",nil,nil,"steam")
