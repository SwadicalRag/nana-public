-- irc.freenode.net

while not irc_freenode do
    print("Freenode IRC FFI uninitialised. Waiting...")
    woahroutine.wait(1) -- wait 1 sec
end

while not irc_gamesurge do
    print("Gamesurge IRC FFI uninitialised. Waiting...")
    woahroutine.wait(1) -- wait 1 sec
end
print("IRC lib initialising...")

-- FREENODE

irc_freenode.join("#lua")

hook.Add("irc_freenode.message#lua","relay",function(from,msg,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#lua> "..from..": "..msg)
    end
end)

hook.Add("irc_freenode.join#lua","relay",function(nick,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        if nick == "nana-bot" then
            chat:Say("<#lua> Connected.")
        else
            chat:Say("<#lua> "..nick.." connected ["..rawMsg.host.."]")
        end
    end
end)

hook.Add("irc_freenode.part#lua","relay",function(nick,reason,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#lua> "..nick.." disconnected ["..reason.." | "..rawMsg.host.."]")
    end
end)

hook.Add("irc_freenode.quit","relay",function(nick,reason,channels,rawMsg)
    local ok = false
    for _,chan in pairs(channels) do
        if chan == "#lua" then
            ok = true
        else
            print("not ok chan "..chan)
        end
    end

    if not ok then return end

    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#lua> "..nick.." quit ["..reason.." | "..rawMsg.host.."]")
    end
end)

-- GAMESURGE

irc_gamesurge.join("#gmod")

hook.Add("irc_gamesurge.message#gmod","relay",function(from,msg,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#gmod> "..from..": "..msg)
    end
end)

hook.Add("irc_gamesurge.join#gmod","relay",function(nick,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        if nick == "nana-bot" then
            chat:Say("<#gmod> Connected.")
        else
            chat:Say("<#gmod> "..nick.." connected ["..rawMsg.host.."]")
        end
    end
end)

hook.Add("irc_gamesurge.part#gmod","relay",function(nick,reason,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#gmod> "..nick.." disconnected ["..reason.." | "..rawMsg.host.."]")
    end
end)

hook.Add("irc_gamesurge.quit","relay",function(nick,reason,channels,rawMsg)
    local ok = false
    for _,chan in pairs(channels) do
        if chan == "#gmod" then
            ok = true
        else
            print("not ok chan "..chan)
        end
    end

    if not ok then return end

    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#gmod> "..nick.." quit ["..reason.." | "..rawMsg.host.."]")
    end
end)
