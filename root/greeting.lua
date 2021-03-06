if true then return end

hook.Add("discord.presence","greet",function(user,id,status,gameName)
    timer.Simple(1,function()
        if not CookieLib:GetInternalPrivate(id).greeted then
            discord.sendMessage({
                to = id,
                messsage = sandbox.env.GetHelpMessage(id)
            })
            CookieLib:GetInternalPrivate(id).greeted = true
            CookieLib:Save()
        end
    end)
end)

function sandbox.env.GetHelpMessage(id)
    local user = id and discordUser.GetByID(id) or sandbox.env.Me
    return string.format(
        "Hello <@%s>! Enjoy your stay.\n\n"..
        "I am a lua bot connected to the discord and steam group chat.\n"..
        "You can type lua code into any channel and i'll run it for you and print the output.\n"..
        "You can prepend "..DEBUG_CHAR.." to your code to allow error strings to be printed as well.\n\n"..
        "Type !help for my (and HAL9000's) commands.\n\n"..
        "Feel free introduce yourself by saying hi! Tell us how familiar you are with lua, modelling or any of your hobbies and we'll sort out your role tags.\n\n"..
        "This message is only printed once.",
        user.id
    )
end

function sandbox.env.SetJoinStatus(status)
    CookieLib:GetInternalPrivate(sandbox:GetCurrentOwner()).greeted = status
end
