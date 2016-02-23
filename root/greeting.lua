hook.Add("discord.userStatusChanged","greet",function(id,oldStatus,newStatus)
    if not CookieLib:GetInternalPrivate(id).greeted then
        if newStatus == "online" then
            discordChannel.GetByName("general"):Say(string.format(
                "Hello %s! Enjoy your stay.\nI am a lua bot connected to the steam group chat.",
                discordUser.GetByID(id):Nick()
            ))
            CookieLib:GetInternalPrivate(id).greeted = true
            CookieLib:Save()
        end
    end
end)
