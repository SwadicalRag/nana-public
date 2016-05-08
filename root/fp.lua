local function isThreadBeingWatched(name)
    for i,match in ipairs(CookieLib:GetInternal().fpthreads) do
        if string.find(name,match,1,true) then
            return true,i,match
        end
    end

    return false
end

hook.Add("fp.ThreadUpdate","OnNewFPThread",function(threadName,threadID,isFirst)
    if isFirst then return end

    if isThreadBeingWatched(threadName) then
        if #threadName > 60 then threadName = threadName:sub(1,57).."..." end
        broadcast(threadName.." - http://facepunch.com/showthread.php?p="..threadID.."#post="..threadID)
    end
end)

command.Add("fplist",function(_,reply,replyPersonal,user,chatroom)
    reply("== Facepunch thread watcher ==")
    for i,match in ipairs(CookieLib:GetInternal().fpthreads) do
        reply("%d. %s",i,match)
    end
end)

command.Add("fpadd",function(newMatch,reply,replyPersonal,user,chatroom)
    if #newMatch == 0 then return end
    local isWatched,id,match = isThreadBeingWatched(newMatch)

    if isWatched then
        return reply("%s already matches with %s (id: %d)",newMatch,match,id)
    end

    CookieLib:GetInternal().fpthreads[#CookieLib:GetInternal().fpthreads + 1] = newMatch

    reply("Now listening for %s (id: %d)",newMatch,#CookieLib:GetInternal().fpthreads)
end)

command.Add("fpremove",function(id,reply,replyPersonal,user,chatroom)
    id = tonumber(id)
    if not (id and (id == id)) then return end

    if CookieLib:GetInternal().fpthreads[id] then
        reply("No longer listening for '%s'",CookieLib:GetInternal().fpthreads[id])
        CookieLib:GetInternal().fpthreads[id] = nil
    else
        reply("Such an ID does not exist in the listen array!")
    end
end)
