--[[

DISCORD <--> STEAM RELAY

V 1.0.0

]]

local targetSteamChat = "Garry's Mod Lua"
local targetDiscordChannel = "steam"
local targetDiscordServer = "Garry's Mod"

hook.Add("ChatMessage","relay",function(channel,user,msg)
    if channel:IsDiscord() then
        if (channel:Name() == targetDiscordChannel) and (channel:ServerName() == targetDiscordServer) then
            local targetChat = steamChat.GetByName(targetSteamChat)
            if targetChat then
                targetChat:Say(user:Nick()..": "..msg)
            end
        end
    elseif channel:IsSteam() then
        if channel:Name() == targetSteamChat then
            local targetChat = discordChannel.GetByName(targetDiscordChannel,targetDiscordServer)
            if targetChat then
                targetChat:Say(user:Nick()..": "..msg)
            end
        end
    end
end)
