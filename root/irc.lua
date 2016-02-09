-- irc.freenode.net

while not irc do
    print("IRC FFI uninitialised. Waiting...")
    woahroutine.wait(1) -- wait 1 sec
end
print("IRC lib initialising...")

irc.join("#lua")

hook.Add("irc.message#lua","relay",function(from,msg,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#lua> "..from..": "..msg)
    end
end)

hook.Add("irc.join#lua","relay",function(nick,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        if nick == "nana-bot" then
            chat:Say("<#lua> Connected.")
        else
            chat:Say("<#lua> "..nick.." connected ["..rawMsg.host.."]")
        end
    end
end)

hook.Add("irc.part#lua","relay",function(nick,reason,rawMsg)
    for _,chat in pairs(chat.GetAll()) do
        chat:Say("<#lua> "..nick.." disconnected ["..reason.." | "..rawMsg.host.."]")
    end
end)

hook.Add("irc.quit#lua","relay",function(nick,reason,channels,rawMsg)
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
