discordUser = {}
sandbox.env.discordUser = discordUser

local discordUsers = {}
local discordUserObjectCache = {}

local function NewUser(id)
    local UserMeta = {}
    local User = setmetatable({},UserMeta)

    User.id = id

    function User:Nick()
        return discordUsers[id].username
    end

    function User:IsSteam()
        return false
    end

    function User:IsDiscord()
        return true
    end

    function UserMeta:__eq(sec)
        return self.id == sec.id
    end

    function UserMeta:__tostring()
        return "Discord User ["..self:Nick().."]"
    end

    return (sandbox.object:protect(User))
end

function discordUser.GetByID(id)
    if not discordUsers[id] then
        local discordUserData = discord.getUser(id)
        if not discordUserData then return false end

        discordUsers[id] = discordUserData
    end

    if not discordUserObjectCache[id] then
        discordUserObjectCache[id] = NewUser(id)
    end

    return discordUserObjectCache[id]
end

function discordUser.GetAudience()
    assert(sandbox:GetHandler() == "discord","Discord-only!")
    local audience = {}
    for i,id in pairs(discord.getAudience(sandbox:GetTargetAudience())) do
        audience[#audience + 1] = discordUser.GetByID(id)
    end
    return audience
end

function discordUser.GetByName(search)
    for id,discordUserData in pairs(steamUsers) do
        if discordUserData.name:lower():match(search:lower()) then
            return discordUserData.GetByID(id)
        end
    end
end

function discordUser.GetAll()
    local out = {}
    for id,_ in pairs(discordUsers) do
        out[#out+1] = discordUser.GetByID(id)
    end
    return out
end

timer.Create("discord.updateUsers",5,0,function()
    for id,_ in pairs(discordUsers) do
        local discordUserData = discord.getUser(id)
        if discordUserData then
            discordUsers[id] = discordUserData
        end
    end
end)
