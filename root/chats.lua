chat = {}
sandbox.env.chat = chat

local chats = {}
local chatObjectCache = {}

local function NewChat(steamID64)
    local ChatMeta = {}
    local Chat = setmetatable({},ChatMeta)

    Chat.steamID64 = steamID64

    function Chat:Name()
        return chats[steamID64].name or false
    end

    function Chat:SteamID()
        local steamID = SteamID(steamID64)
        return (sandbox.object:protect(steamID))
    end

    function Chat:Say(...)
        return (sandbox:PrintToAudience(steamID64,...))
    end

    function Chat:SayRaw(...)
        return (sandbox:RawPrintToAudience(steamID64,...))
    end

    function Chat:Members()
        local members = {}

        for id,member in pairs(chats[steamID64].members) do
            members[#members+1] = sandbox.env.user.GetBySteamID64(id)
        end

        return members
    end

    function Chat:GetMemberRank(steamID)
        local steamID = SteamID(steamID)

        if chats[steamID64].members[steamID] then
            return nameFromEnum("EClanRank",chats[steamID64].members[steamID].rank)
        end

        return "Unknown"
    end

    function ChatMeta:__tostring()
        return "Chat ["..self:Name().."]"
    end

    function ChatMeta:__eq(sec)
        return self.steamID64 == sec.steamID64
    end

    return (sandbox.object:protect(Chat))
end

function chat.GetBySteamID(steamID)
    local steamID64 = SteamID(steamID):ID64()
    if not chats[steamID64] then
        local chatData = steamClient.getChatInfo(steamID64)
        if not chatData then return false end

        chats[steamID64] = chatData
    end

    if not chatObjectCache[steamID64] then
        chatObjectCache[steamID64] = NewChat(steamID64)
    end

    return chatObjectCache[steamID64]
end
chat.GetBySteamID64 = chat.GetBySteamID

function chat.GetByName(search)
    for id,chatData in pairs(chats) do
        if chatData.name:lower():match(search:lower()) then
            return chat.GetBySteamID64(id)
        end
    end
end

function chat.GetAll()
    local out = {}
    for id,_ in pairs(chats) do
        out[#out+1] = chat.GetBySteamID(id)
    end
    return out
end

hook.Add("steamClient.chat","update",function(steamID64,newChatData)
    chats[steamID64] = newChatData
end)
