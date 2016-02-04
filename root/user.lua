user = {}
sandbox.env.user = user

local users = {}
local userObjectCache = {}

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
        return users[steamID64].player_name or false
    end

    function User:LastLoggedOn()
        return users[steamID64].last_logon or false
    end

    function User:LastLoggedOff()
        return users[steamID64].last_logoff or false
    end

    function User:GetStatus()
        return nameFromEnum("EPersonaState",users[steamID64].persona_state)
    end

    function User:IsPlayingGame()
        return users[steamID64].game_name ~= ""
    end

    function User:GetGameName()
        if not self:IsPlayingGame() then return false end
        return users[steamID64].game_name
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
        return getServerIP(users[steamID64])
    end

    function UserMeta:__eq(sec)
        return self.steamID64 == sec.steamID64
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

local function refreshInternalDatabase()
    local _users = steamClient.getAllUserInfo()
    for k,v in pairs(_users) do
        users[k] = v
    end
end

function user.GetByName(search)
    -- refreshInternalDatabase() -- to cache everyone that's nearby
    -- no need for ^ now

    for id,userData in pairs(users) do
        if userData.player_name:match(search) then
            return user.GetBySteamID64(id)
        end
    end
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

hook.Add("steamClient.user","update",function(steamID64,newUserData)
    local user = user.GetBySteamID64(steamID64)
    local oldUserData = users[steamID64]

    if oldUserData.persona_state ~= newUserData.persona_state then
        sandbox:CallHook(
            "UserStatusChanged",
            user,
            nameFromEnum("EPersonaState",oldUserData.persona_state),
            nameFromEnum("EPersonaState",newUserData.persona_state)
        )
    end

    if oldUserData.game_name ~= newUserData.game_name then
        sandbox:CallHook(
            "UserPlayingGame",
            user,
            oldUserData.game_name,
            newUserData.game_name
        )
    end

    if getServerIP(oldUserData) ~= getServerIP(newUserData) then
        sandbox:CallHook(
            "UserJoinedServer",
            user,
            getServerIP(oldUserData),
            getServerIP(newUserData)
        )
    end

    users[steamID64] = newUserData
end)
