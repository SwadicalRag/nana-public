command.Add("leave",function(_,reply,_,_,room)
    if room then
        reply("Bye bye!")
        steamClient.leaveChat(room:SteamID():ID64())
    else
        reply("Nana is not in a chatroom!")
    end
end,"Leaves the current chatroom",nil,COMMAND_MODERATOR,"steam")

command.Add("join",function(argStr,reply)
    if not argStr:match("^%d+$") then return reply("Not a steamid64") end
    steamClient.joinChat(argStr)
end,"Joins a steam chatroom","<steamid64>",COMMAND_MODERATOR)
