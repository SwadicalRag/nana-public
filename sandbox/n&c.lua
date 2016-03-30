local NC = {}

function NC:GridToScreen(x,y)
    return x * 4 + (x-1) * 2,y * 4 + (y-1) * 2
end

function NC:DrawGrid(screen)
    screen:DrawLine(1,1,1,19)
    screen:DrawLine(7,1,7,19)
    screen:DrawLine(13,1,13,19)
    screen:DrawLine(19,1,19,19)

    screen:DrawLine(1,1,19,1)
    screen:DrawLine(1,7,19,7)
    screen:DrawLine(1,13,19,13)
    screen:DrawLine(1,19,19,19)
end

function NC:Draw(screen)
    self:DrawGrid(screen)

    local x,y = self:GridToScreen(2,2)
    screen:DrawGlyph("X",x,y,"center")
end

local ready = false
hook.Add("Render","Noughts and Crosses",function(screen)
    if not ready then
        ready = true
        local O,X = false,true

        screen:RegisterGlyph("X",{
            {X,O,O,O,X},
            {O,X,O,X,O},
            {O,O,X,O,O},
            {O,X,O,X,O},
            {X,O,O,O,X}
        })

        screen:RegisterGlyph("O",{
            {X,X,X,X,X},
            {X,O,O,O,X},
            {X,O,O,O,X},
            {X,O,O,O,X},
            {X,X,X,X,X}
        })
    end

    NC:Draw(screen)
end)
