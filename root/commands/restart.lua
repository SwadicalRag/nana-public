command.Add("restart",function(_,reply)
    reply("Telling nana-kernel to initiate a shutdown...")
    exitInternal();
end,"Restarts nana",nil,COMMAND_MODERATOR)

command.Add("stop",function(_,reply)
    reply("Stopping.")
    os.exit()
end,"Stops nana",nil,COMMAND_ADMIN)

command.Add("update",function(_,reply)
    reply("Telling nana-kernel to update and restart...")
    updateInternal();
end,"Restarts nana",nil,COMMAND_MODERATOR)
