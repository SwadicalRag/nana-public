discordChannel = {}
sandbox.env.discordChannel = discordChannel

local discordChannels = {}
local discordChannelObjectCache = {}

local function NewChannel(id)
    local ChannelMeta = {}
    local Channel = setmetatable({},ChannelMeta)

    Channel.id = id

    function Channel:Name()
        return discordChannels[id].name
    end

    function Channel:IsSteam()
        return false
    end

    function Channel:IsDiscord()
        return true
    end

    function Channel:Say(...)
        sandbox:PushHandler("discord")
        if sandbox:GetCurrentOwner() then
            sandbox:PrintToAudienceWithOwner(id,...)
        else
            sandbox:PrintToAudience(id,...)
        end
        sandbox:PopHandler()
    end

    function Channel:SayRaw(...)
        sandbox:PushHandler("discord")
        if sandbox:GetCurrentOwner() then
            return (sandbox:RawPrintToAudienceWithOwner(id,...))
        else
            return (sandbox:RawPrintToAudience(id,...))
        end
        sandbox:PopHandler()
    end

    function Channel:Members()
        local members = {}

        for i,id in pairs(discord.getAudience(id)) do
            members[#members+1] = sandbox.env.discordUser.GetByID(id)
        end

        return members
    end

    function Channel:ServerName()
        return discordChannels[id].serverName
    end

    function Channel:GetInvite()
        local invite = discord.createInvite({
            server = id,
            type = "text",
            name = "nana invites u! XD"
        })

        if invite then
            return invite.code,string.format("This invite will last for %d seconds",invite.maxAge)
        else
            return false
        end
    end

    function ChannelMeta:__eq(sec)
        return self.id == sec.id
    end

    function ChannelMeta:__tostring()
        return "Discord Channel [#"..self:Name().." in "..self:ServerName().."]"
    end

    return (sandbox.object:protect(Channel))
end

function discordChannel.GetByID(id)
    if not discordChannels[id] then
        local discordChannelData = discord.getChannelData(id)
        if not discordChannelData then return false end

        discordChannels[id] = discordChannelData
    end

    if not discordChannelObjectCache[id] then
        discordChannelObjectCache[id] = NewChannel(id)
    end

    return discordChannelObjectCache[id]
end

function discordChannel.GetByName(search,search_serv)
    for id,discordChannelData in pairs(discordChannels) do
        if discordChannelData.name:lower():match(search:lower()) then
            if not search_serv or search_serv and discordChannelData.serverName:lower():match(search_serv:lower()) then
                return discordChannel.GetByID(id)
            end
        end
    end
end

function discordChannel.GetAll()
    local out = {}
    for id,_ in pairs(discordChannels) do
        out[#out+1] = discordChannel.GetByID(id)
    end
    return out
end

timer.Create("discord.updateUsers",5,0,function()
    for id,_ in pairs(discordChannels) do
        local discordChannelData = discord.getChannelData(id)
        if discordChannelData then
            discordChannels[id] = discordChannelData
        end
    end
end)
