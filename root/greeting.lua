hook.Add("discord.userStatusChanged","greet",function(id,oldStatus,newStatus)
    if not CookieLib:GetInternalPrivate(id).greeted then
        if newStatus == "online" then
            discordChannel.GetByName("general"):Say("Hello!")
            CookieLib:GetInternalPrivate(id).greeted = true
            CookieLib:Save()
        end
    end
end)
