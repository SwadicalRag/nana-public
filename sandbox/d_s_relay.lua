--[[

DISCORD <--> STEAM RELAY

V 1.0.0

]]

local targetSteamChat = "103582791439031144" -- new glua
-- local targetSteamChat = "103582791436028776" -- old glua
local targetDiscordChannel = "152162730244177920"

local out = {}

local function LOCK()
    INLINE_EXTERNAL_UNSANDBOXED(function()
        TEXT_ECHO_LOCK = true
    end)
end

local function UNLOCK()
    INLINE_EXTERNAL_UNSANDBOXED(function()
        TEXT_ECHO_LOCK = false
    end)
end

hook.Add("ChatMessage","relay",function(channel,user,msg)
    if channel:IsDiscord() then
        discurdUser.GetAudience() -- CACHE AUDIENCE
        if channel.id == targetDiscordChannel then
            local targetChat = steamChat.GetBySteamID(targetSteamChat)
            if targetChat then
                msg = msg:gsub("<@(%d+)>",function(id)
                    local user = discordUser.GetByID(id)
                    if user then return "@"..user:Nick() else return "<@"..id..">" end
                end)
                local sentMsg = user:Nick()..": "..msg
                -- out[sentMsg] = true
                LOCK()
                targetChat:Say(sentMsg)
                UNLOCK()
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
                LOCK()
                targetChat:Say(sentMsg)
                UNLOCK()
            end
        end
    end
end)

function RELAY_EQUALITY(c1,c2)
    if (c1.id == targetSteamChat) or (c1.id == targetDiscordChannel)
    and (c2.id == targetSteamChat) or (c2.id == targetDiscordChannel) then
        return true
    else
        return false
    end
end

INLINE_EXTERNAL_UNSANDBOXED(function()
    hook.Add("InternalText","d_s_relay",function(id,msg)
        timer.Simple(0.1,function()
            LOCK()
            if id == targetSteamChat then
                handlers.push("discord")
                sayEx(targetDiscordChannel,msg)
                handlers.pop()
            elseif id == targetDiscordChannel then
                handlers.push("steam")
                sayEx(targetSteamChat,msg)
                handlers.pop()
            end
            UNLOCK()
        end)
    end)
end)

INLINE_EXTERNAL_UNSANDBOXED(function()
    hook.Add("steamClient.chatMessage","blacklist_relay",function(chatRoom,steamID,msg)
        if (chatRoom == targetSteamChat) and IsBlacklisted(steamID) then
            local user = steamUser.GetBySteamID(steamID)
            LOCK()
            handlers.push("discord")
            sayEx(targetDiscordChannel,user:Nick()..": "..msg)
            -- out[msg] = true
            handlers.pop()
            UNLOCK()
        end
    end)
end)
