command.Add("help",function(argStr,reply,replyPersonal,user,chatroom)
    replyPersonal("== Nana commands: == \n")
    for commandName,commandData in pairs(command.commands) do
        if (commandData.handler and (sandbox:GetHandler() == commandData.handler)) or (not commandData.handler) then
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
    if chatroom then
        reply("I have PM'd you the commands, %s.\nPlease be sure to %sadd me if you haven't already (if this is on steam).",user:Nick(),COMMAND_PREFIX)
    end
end,"how 2 use bot commands????")

command.Alias("commands","help")
