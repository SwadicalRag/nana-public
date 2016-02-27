--[[

DISCORD <--> STEAM RELAY

V 1.0.0

]]

local targetSteamChat = "103582791439031144"
local targetDiscordChannel = "152162730244177920"

hook.Add("ChatMessage","relay",function(channel,user,msg)
    if channel:IsDiscord() then
        if channel.id == targetDiscordChannel then
            local targetChat = steamChat.GetBySteamID(targetSteamChat)
            if targetChat then
                targetChat:Say(user:Nick()..": "..msg)
            end
        end
    elseif channel:IsSteam() then
        if channel:SteamID():ID64() == targetSteamChat then
            local targetChat = discordChannel.GetByID(targetDiscordChannel)
            if targetChat then
                msg = msg:gsub("@(%S+)",function(nick)
                    local user = discordUser.GetByName(nick)
                    if user then return "<@"..user.id..">" else return "@"..nick end
                end)
                targetChat:Say(user:Nick()..": "..msg)
            end
        end
    end
end)

INLINE_EXTERNAL_UNSANDBOXED(function()
    hook.Add("OnMessageDispatch","d_s_relay",function(id,msg)
        if id == targetSteamChat then
            handlers.push("discord")
            sayEx(targetDiscordChannel,msg)
            handlers.pop()
        elseif id == targetDiscordChannel then
            handlers.push("steam")
            sayEx(targetSteamChat,msg)
            handlers.pop()
        end
    end)
end)
