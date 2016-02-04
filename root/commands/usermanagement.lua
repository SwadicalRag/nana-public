command.Add("rank",function(argStr,reply)
    local steamID64,targetRank = argStr:match("^%s*(%d+)%s*(%S+)")
    if not (steamID64 and targetRank) or ((targetRank ~= "admin") and (targetRank ~= "user")) then
        return reply("Bad arguments! Usage: rank <steamID64> <user/admin>")
    end

    -- not FindByName just in case people change their names to our wanted target
    local targetUser = user.GetBySteamID64(steamID64)
    if targetRank == "admin" then
        SetAdmin(steamID64,true)
        reply("Set %s's rank to admin",targetUser and targetUser:Nick() or steamID64)
    else -- so you can do !rank <id> peasant, lmao
        SetAdmin(steamID64,false)
        reply("Set %s's rank to %s",targetUser and targetUser:Nick() or steamID64,targetRank)
    end
end,"Sets someone's rank","<steamID64> <user/admin>",true)

command.Add("limit",function(argStr,reply)
    local steamID64,targetState = argStr:match("^%s*(%d+)%s*(%S+)")
    if not (steamID64 and targetState) or ((targetState ~= "true") and (targetState ~= "false")) then
        return reply("Bad arguments! Usage: limit <steamID64> <true/false>")
    end

    -- not FindByName just in case people change their names to our wanted target
    local targetUser = user.GetBySteamID64(steamID64)
    if targetState == "true" then
        SetBlacklist(steamID64,true)
        reply("Blacklisted %s from using the bot",targetUser and targetUser:Nick() or steamID64)
    else -- so you can do !rank <id> peasant, lmao
        SetBlacklist(steamID64,false)
        reply("Pardoned %s.",targetUser and targetUser:Nick() or steamID64)
    end
end,"Blacklists someone from the bot","<steamID64> <true/false>",true)
