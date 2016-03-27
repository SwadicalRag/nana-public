local PrintInternal = function()end
local Tetris = {}

Tetris.blocks = {}
Tetris.blockTypes = {}

local O,X = false,true

function Tetris:RegisterBlock(id,data)
    self.blocks[id] = data
    self.blockTypes[#self.blockTypes + 1] = id
end

function Tetris:Reset()
    self.blockData = {}
    self.screenData = {}
    self.ActiveBlock = nil
    self.lastPlayedNick = "No one"
    self.score = 0
    self.GameOver = false
end

function Tetris:IteratePixels(block,x,y,callback)
    for y_amt=1,#self.blocks[block] do
        for x_amt=1,#self.blocks[block][y_amt] do
            if self.blocks[block][y_amt][x_amt] == X then
                if callback(x_amt + x - 1,y_amt + y - 1) then return true end
            end
        end
    end
end

function Tetris:BlockSize(block)
    -- local min_x,max_y = 0,0
    -- local min_y,max_y = 0,0

    local max_x,max_y = 0,0
    self:IteratePixels(block,0,0,function(x,y)
        -- min_x = math.min(min_x,x)
        max_x = math.max(max_x,x)

        -- min_y = math.min(min_y,y)
        max_y = math.max(max_y,y)
    end)

    return max_x,max_y
end

function Tetris:DrawBlock(screen,block,x,y)
    self:IteratePixels(block,x,y,function(x,y)
        PrintInternal("DRAW XY ",x,y)
        screen:DrawDot(x,y)
    end)
end

function Tetris:AddBlock(block,x,y)
    PrintInternal("ADD BLOCK "..block)

    self.blockData[#self.blockData + 1] = {
        x = x,
        y = y,
        block = block
    }

    return self.blockData[#self.blockData]
end

function Tetris:SetScreenPixel(x,y,status)
    self.screenData[x] = self.screenData[x] or {}
    self.screenData[x][y] = status
end

function Tetris:CommitBlockToScreen(block)
    self:IteratePixels(block.block,block.x,block.y,function(x,y)
        self:SetScreenPixel(x,y,true)
    end)
end

function Tetris:DrawScreen(screen)
    for x,x_data in pairs(self.screenData) do
        for y,status in pairs(x_data) do
            if status then
                screen:DrawDot(x,y)
            end
        end
    end
end

function Tetris:AddRandomBlock(screen)
    local block = self.blockTypes[math.random(1,#self.blockTypes)]
    local w,h = self:BlockSize(block)
    return self:AddBlock(
        block,
        math.random(1,screen.w - w),
        1
    )
end

function Tetris:DrawBoard(screen)
    for i=1,#self.blockData do
        PrintInternal("DRAW BLOCK "..self.blockData[i].block)
        self:DrawBlock(screen,self.blockData[i].block,self.blockData[i].x,self.blockData[i].y)
    end
end

function Tetris:CheckCollision(block1,block2,x_offset_block1,y_offset_block1)
    local hit = false
    self:IteratePixels(block1.block,block1.x + x_offset_block1,block1.y + y_offset_block1,function(x1,y1)
        return self:IteratePixels(block2.block,block2.x,block2.y,function(x2,y2)
            if x1 == x2 and y1 == y2 then
                hit = true
                return true
            end
        end)
    end)

    return hit
end

function Tetris:CollisionTestActiveBlock(only_other_blocks)
    if not self.ActiveBlock then return false end

    for i=1,#self.blockData do
        if (self.blockData[i] ~= self.ActiveBlock) and self:CheckCollision(self.ActiveBlock,self.blockData[i],1,0) then
            return true
        end
    end

    local hit = false

    self:IteratePixels(self.ActiveBlock.block,self.ActiveBlock.x,self.ActiveBlock.y,function(x,y)
        if self.screenData[x] and self.screenData[x][y] then
            hit = true
            return true
        end
    end)

    if hit then return true end

    if only_other_blocks then return false end
    if not self.Screen then return false end

    self:IteratePixels(self.ActiveBlock.block,self.ActiveBlock.x,self.ActiveBlock.y,function(x,y)
        if (y > self.Screen.h) or (x > self.Screen.w) then
            hit = true
            return true
        end
    end)

    return hit
end

function Tetris:Tick(screen,render,spawn_block_anyway)
    if self.GameOver then return self:DrawScreen(screen),self:DrawBoard(screen) end

    if self.ActiveBlock then
        self.ActiveBlock.y = self.ActiveBlock.y + 1
        if self:CollisionTestActiveBlock() then
            self.ActiveBlock.y = self.ActiveBlock.y - 1
            self:CommitBlockToScreen(self.ActiveBlock)
            self.ActiveBlock = nil
            self.blockData[#self.blockData] = nil
        end
    elseif render or spawn_block_anyway then
        -- no new blocks while 'skipping' frames
        self.ActiveBlock = self:AddRandomBlock(screen)

        if self:CollisionTestActiveBlock() then
            -- GAME OVER
            self.GameOver = true
        end
    end

    -- ROW CLEARING
    for y=1,screen.h do
        local ok = true
        for x=1,screen.w do
            if not (self.screenData[x] and self.screenData[x][y]) then
                ok = false
                break
            end
        end

        if ok then
            self.score = self.score + 1

            for _x=1,screen.w do
                for _y=y,screen.h do
                    if self.screenData[_x] and self.screenData[_x][_y] then
                        self.screenData[_x][_y] = nil
                        if (_y - 1) >= 1 then
                            self.screenData[_x][_y - 1] = true
                        end
                    end
                end
            end
        end
    end

    if self.GameOver then
        screen:SetDescription("BANANA TETRIS\tROWS CLEARED: "..self.score.."\tLAST PLAYED: "..self.lastPlayedNick.."\nGAME OVER."..self.Controls)
    else
        screen:SetDescription("BANANA TETRIS\tROWS CLEARED: "..self.score.."\tLAST PLAYED: "..self.lastPlayedNick..self.Controls)
    end

    if render then
        self:DrawScreen(screen)
        self:DrawBoard(screen)
    end
end

local chan_id = "162428115778404352"
hook.Add("ChatMessage","Tetris",function(chatroom,user,_msg)
    if (chatroom.id == chan_id) and Tetris.ActiveBlock and Tetris.Screen then
        Tetris.lastPlayedNick = user:Nick() or "No one"
        for i=1,#_msg do
            msg = _msg:sub(i,i):lower()

            if (msg == "d") and Tetris.ActiveBlock then
                local orig_x = Tetris.ActiveBlock.x

                local w,h = Tetris:BlockSize(Tetris.ActiveBlock.block)
                Tetris.ActiveBlock.x = math.min(Tetris.ActiveBlock.x + 1,Tetris.Screen.w - w)

                if Tetris:CollisionTestActiveBlock() then
                    Tetris.ActiveBlock.x = orig_x
                end
            elseif (msg == "a") and Tetris.ActiveBlock then
                local orig_x = Tetris.ActiveBlock.x

                Tetris.ActiveBlock.x = math.max(1,Tetris.ActiveBlock.x - 1)

                if Tetris:CollisionTestActiveBlock() then
                    Tetris.ActiveBlock.x = orig_x
                end
            elseif (msg == "w") and Tetris.ActiveBlock then
                local blockType,ang = Tetris.ActiveBlock.block:match("^(.-)(%d+)$")

                ang = tonumber(ang) + 90
                if ang == 360 then ang = 0 end

                Tetris.ActiveBlock.block = blockType..ang

                if Tetris:CollisionTestActiveBlock() then
                    ang = ang - 90
                    if ang == -90 then ang = 270 end
                    Tetris.ActiveBlock.block = blockType..ang
                end
            elseif msg == "s" then
                Tetris:Tick(Tetris.Screen,false)
            elseif msg == "x" then
                Tetris:Tick(Tetris.Screen,false,true)
            elseif msg == "c" then
                Tetris:Reset()
            end

            ::next_one::
        end
    end
end)

Tetris:RegisterBlock("L-1-0",{
    {X,O,O},
    {X,X,X}
})

Tetris:RegisterBlock("L-1-90",{
    {X,X},
    {X,O},
    {X,O}
})

Tetris:RegisterBlock("L-1-180",{
    {X,X,X},
    {O,O,X}
})

Tetris:RegisterBlock("L-1-270",{
    {O,X},
    {O,X},
    {X,X}
})

Tetris:RegisterBlock("L-2-0",{
    {O,O,X},
    {X,X,X}
})

Tetris:RegisterBlock("L-2-90",{
    {X,O},
    {X,O},
    {X,X}
})

Tetris:RegisterBlock("L-2-180",{
    {X,X,X},
    {X,O,O}
})

Tetris:RegisterBlock("L-2-270",{
    {X,X},
    {O,X},
    {O,X}
})

Tetris:RegisterBlock("Box-0",{
    {X,X},
    {X,X}
})

Tetris:RegisterBlock("Box-90",{
    {X,X},
    {X,X}
})

Tetris:RegisterBlock("Box-180",{
    {X,X},
    {X,X}
})

Tetris:RegisterBlock("Box-270",{
    {X,X},
    {X,X}
})

Tetris:RegisterBlock("Rect-0",{
    {X},
    {X},
    {X},
    {X}
})

Tetris:RegisterBlock("Rect-90",{
    {X,X,X,X}
})

Tetris:RegisterBlock("Rect-180",{
    {X},
    {X},
    {X},
    {X}
})

Tetris:RegisterBlock("Rect-270",{
    {X,X,X,X}
})

Tetris:RegisterBlock("T-0",{
    {O,X,O},
    {X,X,X}
})

Tetris:RegisterBlock("T-90",{
    {X,O},
    {X,X},
    {X,O}
})

Tetris:RegisterBlock("T-180",{
    {X,X,X},
    {O,X,O}
})

Tetris:RegisterBlock("T-270",{
    {O,X},
    {X,X},
    {O,X}
})

Tetris:RegisterBlock("Z-1-0",{
    {O,X},
    {X,X},
    {X,O}
})

Tetris:RegisterBlock("Z-1-90",{
    {X,X,O},
    {O,X,X}
})

Tetris:RegisterBlock("Z-1-180",{
    {O,X},
    {X,X},
    {X,O}
})

Tetris:RegisterBlock("Z-1-270",{
    {X,X,O},
    {O,X,X}
})

Tetris:RegisterBlock("Z-2-0",{
    {X,O},
    {X,X},
    {O,X}
})

Tetris:RegisterBlock("Z-2-90",{
    {O,X,X},
    {X,X,O}
})

Tetris:RegisterBlock("Z-2-180",{
    {X,O},
    {X,X},
    {O,X}
})

Tetris:RegisterBlock("Z-2-270",{
    {O,X,X},
    {X,X,O}
})

Tetris:Reset()

Tetris.Controls = [[

Controls:
W = Rotate 90o clockwise
A = Move block 1 unit left
S = Skip 1 frame without creating new blocks
D = Move block 1 unit right

X = Skip 1 frame and also create new blocks
C = Restart round
]]

hook.Add("Render","Tetris",function(screen)
    PrintInternal("TICK")
    Tetris.Screen = screen
    Tetris:Tick(screen,true)
end)
