user = {}
sandbox.env.user = user

local users = {}
local userObjectCache = {}

local function NewUser(steamID64)
    local UserMeta = {}
    local User = setmetatable({},UserMeta)

    User.steamID64 = steamID64

    function User:Nick()
        return users[self.steamID64].player_name or false
    end

    function User:LastLoggedOn()
        return users[steamID64].last_logon or false
    end

    function User:LastLoggedOff()
        return users[steamID64].last_logoff or false
    end

    function User:GetStatus()
        local status = users[steamID64].persona_state
        for statusName,enum in pairs(Steam.EPersonaState) do
            if enum == status then return statusName end
        end
    end

    function User:IsPlayingGame()
        return users[steamID64].game_name ~= ""
    end

    function User:GetGameName()
        if not self:IsPlayingGame() then return false end
        return users[steamID64].game_name
    end

    function User:SteamID()
        local steamID = SteamID(self.steamID64)
        return (sandbox.object:protect(steamID))
    end

    function UserMeta:__tostring()
        return "User ["..self:Nick().."]"
    end

    return (sandbox.object:protect(User))
end

function user.GetBySteamID64(steamID)
    local steamID64 = SteamID(steamID):ID64()
    if not users[steamID64] then
        local userData = steamClient.getUserInfo(steamID64)
        if not userData then return false end

        users[steamID64] = userData
    end

    if not userObjectCache[steamID64] then
        userObjectCache[steamID64] = NewUser(steamID64)
    end

    return userObjectCache[steamID64]
end

function user.GetAudience()
    local chatRoom = steamClient.getChatInfo(sandbox:GetTargetAudience())
    local audience = {}
    if chatRoom then
        for steamid64,_ in pairs(chatRoom.members) do
            audience[#audience + 1] = user.GetBySteamID64(steamid64)
        end
    else
        audience = {user.GetBySteamID64(sandbox:GetTargetAudience())}
    end
    return audience
end
