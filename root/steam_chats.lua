steamChat = {}
sandbox.env.steamChat = steamChat

local steamChats = {}
local steamChatObjectCache = {}

local function NewChat(steamID64)
    local ChatMeta = {}
    local Chat = setmetatable({},ChatMeta)

    Chat.steamID64 = steamID64

    function Chat:Name()
        return steamChats[steamID64].name or false
    end

    function Chat:IsSteam()
        return true
    end

    function Chat:IsDiscord()
        return false
    end

    function Chat:SteamID()
        local steamID = SteamID(steamID64)
        return (sandbox.object:protect(steamID))
    end

    function Chat:Say(...)
        sandbox:PushHandler("steam")
        if sandbox:GetCurrentOwner() then
            sandbox:PrintToAudienceWithOwner(steamID64,...)
        else
            sandbox:PrintToAudience(steamID64,...)
        end
        sandbox:PopHandler()
    end

    function Chat:SayRaw(...)
        sandbox:PushHandler("steam")
        if sandbox:GetCurrentOwner() then
            sandbox:RawPrintToAudienceWithOwner(steamID64,...)
        else
            sandbox:RawPrintToAudience(steamID64,...)
        end
        sandbox:PopHandler()
    end

    function Chat:Members()
        local members = {}

        for id,member in pairs(steamChats[steamID64].members) do
            members[#members+1] = sandbox.env.steamUser.GetBySteamID64(id)
        end

        return members
    end

    function Chat:GetMemberRank(steamID)
        local steamID = SteamID(steamID)

        if steamChats[steamID64].members[steamID] then
            return nameFromEnum("EClanRank",steamChats[steamID64].members[steamID].rank)
        end

        return "Unknown"
    end

    function ChatMeta:__tostring()
        return "Steam Chat ["..self:Name().."]"
    end

    function ChatMeta:__eq(sec)
        return self.steamID64 == sec.steamID64
    end

    return (sandbox.object:protect(Chat))
end

function steamChat.GetBySteamID(steamID)
    local steamID64 = SteamID(steamID):ID64()
    if not steamChats[steamID64] then
        local steamChatData = steamClient.getChatInfo(steamID64)
        if not steamChatData then return false end

        steamChats[steamID64] = steamChatData
    end

    if not steamChatObjectCache[steamID64] then
        steamChatObjectCache[steamID64] = NewChat(steamID64)
    end

    return steamChatObjectCache[steamID64]
end
steamChat.GetBySteamID64 = steamChat.GetBySteamID

function steamChat.GetByName(search)
    for id,steamChatData in pairs(steamChats) do
        if steamChatData.name:lower():match(search:lower()) then
            return steamChat.GetBySteamID64(id)
        end
    end
end

function steamChat.GetAll()
    local out = {}
    for id,_ in pairs(steamChats) do
        out[#out+1] = steamChat.GetBySteamID(id)
    end
    return out
end

hook.Add("steamClient.chat","update",function(steamID64,newChatData)
    steamChats[steamID64] = newChatData
end)
