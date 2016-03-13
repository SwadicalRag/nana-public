--[[

DISCORD <--> STEAM RELAY

V 1.0.0

]]

local targetSteamChat = "103582791439031144"
local targetDiscordChannel = "152162730244177920"

local out = {}

hook.Add("ChatMessage","relay",function(channel,user,msg)
    if channel:IsDiscord() then
        if channel.id == targetDiscordChannel then
            local targetChat = steamChat.GetBySteamID(targetSteamChat)
            if targetChat then
                local sentMsg = user:Nick()..": "..msg
                -- out[sentMsg] = true
                targetChat:Say(sentMsg)
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
                local sentMsg = user:Nick()..": "..msg
                -- out[sentMsg] = true
                targetChat:Say(sentMsg)
            end
        end
    end
end)

-- INLINE_EXTERNAL_UNSANDBOXED(function()
--     hook.Add("OnMessageDispatch","d_s_relay",function(id,msg)
--         if out[msg] then out[msg] = nil return end
--         if id == targetSteamChat then
--             handlers.push("discord")
--             sayEx(targetDiscordChannel,msg)
--             out[msg] = true
--             handlers.pop()
--         elseif id == targetDiscordChannel then
--             handlers.push("steam")
--             sayEx(targetSteamChat,msg)
--             out[msg] = true
--             handlers.pop()
--         end
--     end)
-- end)

INLINE_EXTERNAL_UNSANDBOXED(function()
    hook.Add("steamClient.chatMessage","blacklist_relay",function(chatRoom,steamID,msg)
        if (chatRoom == targetSteamChat) IsBlacklisted(steamID) then
            handlers.push("discord")
            sayEx(targetDiscordChannel,steamUser.GetBySteamID(steamID):Nick()..": "..msg)
            -- out[msg] = true
            handlers.pop()
        end
    end)
end)