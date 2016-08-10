--bits and pieces from wyozi's medialib

local soundcloudURLs = {
    "^https?://www.soundcloud.com/([A-Za-z0-9_%-]+/[A-Za-z0-9_%-]+)/?$",
    "^https?://soundcloud.com/([A-Za-z0-9_%-]+/[A-Za-z0-9_%-]+)/?$",
}

local queue = {}

local function update()
    local data = queue[#queue]
    
    if data.url then
        data.channel:Say("Now Playing: \""..data.name.."\"")
        
        if url.source == "youtube" then
            discord.playYoutube(data.url)
        else
            discord.playURL(data.url,0.75)
        end
    end
end

local function add(url,source,name,user,channel)
    queue[#queue + 1] = {
        url = url,
        source = source,
        name = name,
        user = user,
        channel = channel,
    }
    if #queue == 1 then update() end
end

local function parseUrl(url)
    for _,pattern in pairs(soundcloudURLs) do
        local id = string.match(url,pattern)
        if id then
            return {id = id}
        end
    end
    return false
end

local function resolveSoundCloudURL(url,callback)
    local urlData = parseUrl(url)
    http.Fetch(string.format("http://api.soundcloud.com/resolve.json?url=http://soundcloud.com/%s&client_id="..secondaryConfig.soundcloud.clientID,urlData.id),function(data,...)
        local sound_id = json.decode(data).id
        callback(string.format("http://api.soundcloud.com/tracks/%s/stream?client_id="..secondaryConfig.soundcloud.clientID,sound_id))
    end)
end

function queryURL(url,callback)
    local urlData = parseUrl(url)
    local metaurl = string.format("http://api.soundcloud.com/resolve.json?url=http://soundcloud.com/%s&client_id="..secondaryConfig.soundcloud.clientID, urlData.id)

    http.Fetch(metaurl, function(result, code)
        local entry = json.decode(result)

        if entry.errors then
            local msg = entry.errors[1].error_message or "error"

            local translated = msg
            if string.StartWith(msg, "404") then
                translated = "Invalid id"
            end

            callback(translated)
            return
        end

        callback(nil, {
            title = entry.title,
            duration = tonumber(entry.duration) / 1000
        })

    end)
end

hook.Add("discord.ready","music",function()
    local suc,chanID = discord.joinVoiceChannel("Music");

    if suc then
        print("OK!")
    else
        print("Can't join music channel!")
    end
end)

command.Add("soundcloud",function(url,reply,replyPersonal,user,chatroom)
    if(parseUrl(url)) then
        queryURL(url,function(err,data)
            if err then
                reply("Error retrieving metadata: "..err)
            else
                -- reply("Now Playing: \""..data.title.."\"")
            end
            
            resolveSoundCloudURL(url,function(bass_url)
                add(bass_url,"soundcloud",data and data.title or bass_url,user,chatroom)
            end)
        end)
    else
        reply("Unacceptable URL [Code: 1]")
    end
end,"play music","url",COMMAND_ALL,"discord")

command.Add("playurl",function(url,reply,replyPersonal,user,chatroom)
    add(url,"url",url,user,chatroom)
end,"play raw url","url",COMMAND_ALL,"discord")

command.Add("youtube",function(url,reply,replyPersonal,user,chatroom)
    add(url,"youtube",url,user,chatroom)
end,"play youtube","url",COMMAND_ALL,"discord")

command.Add("skip",function(url,reply,replyPersonal,user,chatroom)
    discord.stopMusic()
    table.remove(queue,1)
    update()
end,"skip music",nil,COMMAND_MODERATOR,"discord")

command.Add("queue",function(_,reply,replyPersonal,user,chatroom)
    for i,data in ipairs(queue) do
        reply("%d - (%s) %s (requested by %s)\n",i,data.source,data.name,data.user:Nick())
    end
end,"play music",nil,COMMAND_ALL,"discord")

command.Add("queue_update",function(_,reply,replyPersonal,user,chatroom)
    discord.stopMusic()
    table.remove(queue,1)
    update()
end,"play music",nil,COMMAND_MODERATOR,"discord")

command.Add("queue_remove",function(n,reply,replyPersonal,user,chatroom)
    n = tonumber(n)
    
    if n and (n == n) and queue[n] then
        if n == 1 then discord.stopMusic() end
        table.remove(queue,n)
    end
end,"play music",nil,COMMAND_MODERATOR,"discord")
