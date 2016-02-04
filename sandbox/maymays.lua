PrintInternal "AAA"
cookie.maymays = cookie.maymays or {}
PrintInternal "HHH"
setmetatable(cookie.maymays,{
    __tostring = function()
        return "The Meme Forge"
    end,
    __len = function()
        return 420
    end
})

PrintInternal(cookie.maymays)
