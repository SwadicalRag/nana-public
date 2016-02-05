command.Add("leave",function(_,reply,_,_,room)
    if room then
        reply("Bye bye!")
        steamClient.leaveChat(room:SteamID():ID64())
    else
        reply("Nana is not in a chatroom!")
    end
end,"Leaves the current chatroom",nil,true)

command.Add("join",function(argStr,reply)
    if not argStr:match("^%d+$") then return reply("Not a steamid64") end
    steamClient.joinChat(argStr)
end,"Joins a chatroom","<steamid64>",true)
