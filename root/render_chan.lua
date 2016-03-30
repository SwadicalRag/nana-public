-- local Screen = Renderer:NewContext(82,24);
local Screen = Renderer:NewContext(41,20);

local chan_id = "162428115778404352"

hook.Add("discord.ready","render",function()
    discord.clearChannel(chan_id)
    local msg_id = discord.replyEx(chan_id,"```loading...```")

    if not msg_id then return print("unable to load this shit") end

    local lastScreen = ""
    hook.Call("RenderscapeReady",Screen)
    timer.Create("rendering",1,0,function()
        discord.clearExcept(chan_id,msg_id)

        Screen:Clear()
        sandbox:CallHook("Render",Screen)
        local curScreen = "```"..Screen:Render().."```\n```"..(Screen.desc or "No description").."```"

        if curScreen ~= lastScreen then
            lastScreen = curScreen

            discord.edit(chan_id,msg_id,curScreen)
        end
    end)
end)
