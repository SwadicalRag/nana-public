command.Add("restart",function(_,reply)
    reply("Telling nana-kernel to initiate a shutdown...")
    exitInternal();
end,"Restarts nana",nil,true)

command.Add("stop",function(_,reply)
    reply("Stopping.")
    os.exit()
end,"Stops nana",nil,true)
