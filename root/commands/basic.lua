command.Add("ping",function(_,reply)
    reply("Pong!")
end,"prints 'pong'")

command.Add("me",function(argStr,reply,replyPersonal,user,chat)
    reply("%s %s.",user:Nick(),argStr)
end,"the classic !me command")
