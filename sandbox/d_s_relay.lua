--[[

DISCORD <--> STEAM RELAY

V 1.0.0

]]

local targetSteamChat = "103582791439031144"
local targetDiscordChannel = "152162730244177920"

local LOCK = false

local function sayRaw(tgt,msg)
    if type(tgt) == "table" then tgt = tgt.id end
    INLINE_EXTERNAL_UNSANDBOXED(function()
        sayRaw(tgt,msg)
    end)
end

hook.Add("ChatMessage","relay",function(channel,user,msg)
    if LOCK then return end
    if channel:IsDiscord() then
        if channel.id == targetDiscordChannel then
            local targetChat = steamChat.GetBySteamID(targetSteamChat)
            if targetChat then
                msg = msg:gsub("<@(%d+)>",function(id)
                    local user = discordUser.GetByID(id)
                    if user then return "@"..user:Nick() else return "<@"..id..">" end
                end)
                local sentMsg = user:Nick()..": "..msg
                LOCK = true
                sayRaw(targetChat,sentMsg)
                LOCK = false
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
                LOCK = true
                sayRaw(targetChat,sentMsg)
                LOCK = false
            end
        end
    end
end)

INLINE_EXTERNAL_UNSANDBOXED(function()
    hook.Add("OnMessageDispatch","d_s_relay",function(id,msg)
        if LOCK then return end
        if id == targetSteamChat then
            handlers.push("discord")
            LOCK = true
            sayRaw(targetDiscordChannel,msg)
            LOCK = false
            handlers.pop()
        elseif id == targetDiscordChannel then
            handlers.push("steam")
            LOCK = true
            sayRaw(targetSteamChat,msg)
            LOCK = false
            handlers.pop()
        end
    end)
end)

INLINE_EXTERNAL_UNSANDBOXED(function()
    hook.Add("steamClient.chatMessage","blacklist_relay",function(chatRoom,steamID,msg)
        if LOCK then return end
        if (chatRoom == targetSteamChat) and IsBlacklisted(steamID) then
            handlers.push("discord")
            LOCK = true
            sayRaw(targetDiscordChannel,steamUser.GetBySteamID(steamID):Nick()..": "..msg)
            LOCK = false
            handlers.pop()
        end
    end)
end)
