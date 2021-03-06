relay = {}
relay.clients = {}

function relay.Connect(chatRoomID,clientID)
    relay.clients[clientID] = chatRoomID
end

function relay.Disconnect(clientID)
    relay.clients[clientID] = nil
end

hook.Add("steamClient.friendMessageInternalSwitch","Relay",function(steamID,msg)
    if relay.clients[steamID] then return true end
end)

hook.Add("steamClient.friendMessage","Relay",function(steamID,msg)
    if relay.clients[steamID] then
        handlers.push("steam")
        sayRaw(relay.clients[steamID],steamUser.GetBySteamID(steamID):Nick()..": "..msg)
        hook.Call("steamClient.chatMessage",relay.clients[steamID],steamID,msg)
        handlers.pop()
    end
end)

hook.Add("steamClient.chatMessage","Relay",function(steamID,userID,msg)
    for clientID,listenID in pairs(relay.clients) do
        if (steamID == listenID) and (userID ~= clientID) then
            handlers.push("steam")
            sayRaw(clientID,steamUser.GetBySteamID(userID):Nick()..": "..msg)
            handlers.pop()
        end
    end
end)

hook.Add("OnMessageDispatch","Relay",function(steamID,msg)
    for clientID,listenID in pairs(relay.clients) do
        if steamID == listenID then
            handlers.push("steam")
            sayRaw(clientID,msg)
            handlers.pop()
        end
    end
end)

-- cough cough
-- to follow hash.jsspec
local randomIntSeed = 0
function randomInt(min,max)
    max = max or 1;
    min = min or 0;

    randomIntSeed = (randomIntSeed * 9301 + 49297) % 233280;
    local rnd = randomIntSeed / 233280;

    return math.floor(0.5 + min + rnd * (max - min))
end

hook.Add("CommandModuleReady","Relay",function(command)
    command.Add("chat",function(targetChat,reply,_,user)
        handlers.push("steam")
        local userID = user:SteamID():ID64()
        if relay.clients[userID] then
            local lastConnected = relay.clients[userID]
            relay.Disconnect(userID)
            sayEx(lastConnected,user:Nick().." disconnected.")
            sayEx(userID,user:Nick().." disconnected.")
        else
            if targetChat == "" then return reply("Bad arguments! Usage: chat [name of chatroom]"),handlers.pop() end
            local chat = steamChat.GetByName(targetChat)
            if chat then
                local chatID = chat:SteamID():ID64()
                reply("Relaying %s...",chat:Name())
                local randomIntSeed = math.tointeger(userID) & 2^31
                local ip = randomInt(20,240).."."..randomInt(20,240).."."..randomInt(20,240).."."..randomInt(20,240)
                sayEx(chatID,user:Nick().." entered steamChat. (IP: "..ip..")")
                relay.Connect(chatID,userID)
            else
                reply("Cannot find a chatroom with %s in its name.",targetChat)
            end
            handlers.pop()
        end
    end,"Joins a chatroom with nana as a relay.","[name of chatroom]",nil,"steam")
end)
