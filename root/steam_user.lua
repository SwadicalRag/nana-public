steamUser = {}
sandbox.env.steamUser = steamUser

local steamUsers = {}
local steamUserObjectCache = {}

local function getServerIP(data)
    local hostip = data.game_server_ip
    local ip = {}
    ip[1] = ((hostip & 0xFF000000) >> 24)
    ip[2] = ((hostip & 0x00FF0000)  >> 16)
    ip[3] = ((hostip & 0x0000FF00) >> 8)
    ip[4] = (hostip & 0x000000FF)

    return table.concat(ip,".")..":"..data.game_server_port
end

local function NewUser(steamID64)
    local UserMeta = {}
    local User = setmetatable({},UserMeta)

    User.steamID64 = steamID64

    function User:Nick()
        return steamUsers[steamID64].player_name or false
    end

    function User:IsSteam()
        return true
    end

    function User:IsDiscord()
        return false
    end

    function User:LastLoggedOn()
        return steamUsers[steamID64].last_logon or false
    end

    function User:LastLoggedOff()
        return steamUsers[steamID64].last_logoff or false
    end

    function User:GetStatus()
        return nameFromEnum("EPersonaState",steamUsers[steamID64].persona_state)
    end

    function User:IsPlayingGame()
        return steamUsers[steamID64].game_name ~= ""
    end

    function User:GetGameName()
        if not self:IsPlayingGame() then return false end
        return steamUsers[steamID64].game_name
    end

    function User:SteamID()
        local steamID = SteamID(steamID64)
        return (sandbox.object:protect(steamID))
    end

    function User:SteamLevel()
        local levels = steamClient.getSteamLevels({steamID64})
        return levels[steamID64]
    end

    function User:GetIP()
        return getServerIP(steamUsers[steamID64])
    end

    function UserMeta:__eq(sec)
        return self.steamID64 == sec.steamID64
    end

    function UserMeta:__tostring()
        return "Steam User ["..self:Nick().."]"
    end

    return (sandbox.object:protect(User))
end

function steamUser.GetBySteamID(steamID)
    local steamID64 = SteamID(steamID):ID64()
    if not steamUsers[steamID64] then
        local steamUserData = steamClient.getUserInfo(steamID64)
        if not steamUserData then return false end

        steamUsers[steamID64] = steamUserData
    end

    if not steamUserObjectCache[steamID64] then
        steamUserObjectCache[steamID64] = NewUser(steamID64)
    end

    return steamUserObjectCache[steamID64]
end
-- compatibility
steamUser.GetBySteamID64 = steamUser.GetBySteamID

local function refreshInternalDatabase()
    local _steamUsers = steamClient.getAllUserInfo()
    for k,v in pairs(_steamUsers) do
        steamUsers[k] = v
    end
end

function steamUser.GetByName(search)
    -- refreshInternalDatabase() -- to cache everyone that's nearby
    -- no need for ^ now

    for id,steamUserData in pairs(steamUsers) do
        if steamUserData.player_name:lower():match(search:lower()) then
            return steamUser.GetBySteamID64(id)
        end
    end
end

function steamUser.GetAudience()
    assert(sandbox:GetHandler() == "steam","Steam-only!")
    local chatRoom = steamClient.getChatInfo(sandbox:GetTargetAudience())
    local audience = {}
    if chatRoom then
        for steamid64,_ in pairs(chatRoom.members) do
            audience[#audience + 1] = steamUser.GetBySteamID64(steamid64)
        end
    else
        audience = {steamUser.GetBySteamID64(sandbox:GetTargetAudience())}
    end
    return audience
end

function steamUser.GetAll()
    local out = {}
    for id,_ in pairs(steamUsers) do
        out[#out+1] = steamUser.GetBySteamID(id)
    end
    return out
end

hook.Add("steamClient.user","update",function(steamID64,newUserData)
    local steamUser = steamUser.GetBySteamID64(steamID64)
    local oldUserData = steamUsers[steamID64]

    if oldUserData.persona_state ~= newUserData.persona_state then
        sandbox:CallHook(
            "UserStatusChanged",
            steamUser,
            nameFromEnum("EPersonaState",oldUserData.persona_state),
            nameFromEnum("EPersonaState",newUserData.persona_state)
        )
    end

    if oldUserData.game_name ~= newUserData.game_name then
        sandbox:CallHook(
            "UserPlayingGame",
            steamUser,
            oldUserData.game_name,
            newUserData.game_name
        )
    end

    if getServerIP(oldUserData) ~= getServerIP(newUserData) then
        sandbox:CallHook(
            "UserJoinedServer",
            steamUser,
            getServerIP(oldUserData),
            getServerIP(newUserData)
        )
    end

    steamUsers[steamID64] = newUserData
end)
