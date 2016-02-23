command.Add("help",function(argStr,reply,replyPersonal,user,chatroom)
    replyPersonal("== Nana commands: == \n")
    for commandName,commandData in pairs(command.commands) do
        if not (commandData.handler and (commandData.handler == "steam") and not chatroom:IsSteam()) then
            replyPersonal(
                "    %s%s - %s%s (usage: %s)\n",
                COMMAND_PREFIX,
                commandName,
                commandData.getRankFlag(),
                commandData.description or "no description available",
                commandData.usage or "call as is"
            )
        end
    end
    replyPersonal("== END ==\n")
    if chatroom and chatroom:IsSteam() then
        reply("I have PM'd you the commands, %s.\nPlease be sure to %sadd me if you haven't already.",user:Nick(),COMMAND_PREFIX)
    end
end,"how 2 use bot commands????")

command.Alias("commands","help")
