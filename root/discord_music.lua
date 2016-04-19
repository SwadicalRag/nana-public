--bits and pieces from wyozi's medialib

local soundcloudURLs = {
    "^https?://www.soundcloud.com/([A-Za-z0-9_%-]+/[A-Za-z0-9_%-]+)/?$",
    "^https?://soundcloud.com/([A-Za-z0-9_%-]+/[A-Za-z0-9_%-]+)/?$",
}

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

local function play_SC_URL(url)
    resolveSoundCloudURL(url,function(bass_url)
        discord.playURL(bass_url,0.75)
        print(bass_url)
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
        play_SC_URL(url)
        queryURL(url,function(err,data)
            if err then
                reply("Error retrieving metadata: "..err)
            else
                reply("Now Playing: \""..data.title.."\"")
            end
        end)
    else
        reply("Unacceptable URL [Code: 1]")
    end
end,"play music","url",COMMAND_MODERATOR,"discord")

command.Add("playurl",function(url,reply,replyPersonal,user,chatroom)
    discord.playURL(url)
end,"play music","url",COMMAND_MODERATOR,"discord")

command.Add("youtube",function(url,reply,replyPersonal,user,chatroom)
    discord.playYoutube(url)
end,"play music","url",COMMAND_MODERATOR,"discord")

command.Add("stopmusic",function(url,reply,replyPersonal,user,chatroom)
    discord.stopMusic()
end,"play music",nil,COMMAND_MODERATOR,"discord")
