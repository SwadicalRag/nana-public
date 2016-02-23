hook.Add("discord.userStatusChanged","greet",function(id,oldStatus,newStatus)
    timer.Simple(1,function()
        if not CookieLib:GetInternalPrivate(id).greeted then
            if newStatus == "online" then
                discordChannel.GetByName("general"):Say(sandbox.env.GetHelpMessage(id))
                CookieLib:GetInternalPrivate(id).greeted = true
                CookieLib:Save()
            end
        end
    end)
end)

function sandbox.env.GetHelpMessage(id)
    local user = id and discordUser.GetByID(id) or sandbox.env.Me
    return string.format(
        "Hello @%s! Enjoy your stay.\n\n"..
        "I am a lua bot connected to the discord and steam group chat.\n"..
        "You can type lua code into any channel and i'll run it for you and print the output.\n"..
        "You can prepend "..DEBUG_CHAR.." to your code to allow error strings to be printed as well.\n\n"..
        "This message is only printed once.",
        user:Nick()
    )
end
