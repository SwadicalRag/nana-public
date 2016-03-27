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
    self.data = {}
    self.ActiveBlock = nil
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

    self.data[#self.data + 1] = {
        x = x,
        y = y,
        block = block
    }

    return self.data[#self.data]
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
    for i=1,#self.data do
        PrintInternal("DRAW BLOCK "..self.data[i].block)
        self:DrawBlock(screen,self.data[i].block,self.data[i].x,self.data[i].y)
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

function Tetris:Tick(screen,render)
    if self.ActiveBlock then
        for i=1,#self.data do
            if (self.data[i] ~= self.ActiveBlock) and self:CheckCollision(self.ActiveBlock,self.data[i],0,1) then
                PrintInternal("HIT ACTIVE BLOCK")
                self.ActiveBlock = nil
                break
            end
        end

        if self.ActiveBlock then
            self.ActiveBlock.y = self.ActiveBlock.y + 1

            self:IteratePixels(self.ActiveBlock.block,self.ActiveBlock.x,self.ActiveBlock.y,function(x,y)
                if y > screen.h then
                    self.ActiveBlock.y = self.ActiveBlock.y - 1
                    self.ActiveBlock = nil

                    return true
                end
            end)
        end
    else
        self.ActiveBlock = self:AddRandomBlock(screen)
    end

    if render then
        self:DrawBoard(screen)
    end
end

Tetris:Reset()

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

local chan_id = "162428115778404352"
hook.Add("ChatMessage","Tetris",function(chatroom,user,_msg)
    if (chatroom.id == chan_id) and Tetris.ActiveBlock and Tetris.Screen then
        for i=1,#_msg do
            msg = _msg:sub(i,i):lower()

            if msg == "d" then
                for i=1,#Tetris.data do
                    if (Tetris.data[i] ~= Tetris.ActiveBlock) and Tetris:CheckCollision(Tetris.ActiveBlock,Tetris.data[i],1,0) then
                        goto next_one
                    end
                end

                local w,h = Tetris:BlockSize(Tetris.ActiveBlock.block)
                Tetris.ActiveBlock.x = math.min(Tetris.ActiveBlock.x + 1,Tetris.Screen.w - w)
            elseif msg == "a" then
                for i=1,#Tetris.data do
                    if (Tetris.data[i] ~= Tetris.ActiveBlock) and Tetris:CheckCollision(Tetris.ActiveBlock,Tetris.data[i],1,0) then
                        goto next_one
                    end
                end

                Tetris.ActiveBlock.x = math.max(1,Tetris.ActiveBlock.x - 1)
            elseif msg == "s" then
                local blockType,ang = Tetris.ActiveBlock.block:match("^(.-)(%d+)$")

                ang = tonumber(ang) + 90
                if ang == 360 then ang = 0 end

                Tetris.ActiveBlock.block = blockType..ang

                for i=1,#Tetris.data do
                    if (Tetris.data[i] ~= Tetris.ActiveBlock) and Tetris:CheckCollision(Tetris.ActiveBlock,Tetris.data[i],1,0) then
                        ang = ang - 90
                        if ang == -90 then ang = 270 end
                        Tetris.ActiveBlock.block = blockType..ang
                        goto next_one
                    end
                end

                Tetris:IteratePixels(Tetris.ActiveBlock.block,Tetris.ActiveBlock.x,Tetris.ActiveBlock.y,function(x,y)
                    if (y > Tetris.Screen.h) or (x > Tetris.Screen.w) then
                        ang = ang - 90
                        if ang == -90 then ang = 270 end
                        Tetris.ActiveBlock.block = blockType..ang

                        return true
                    end
                end)
            elseif msg == "w" then
                Tetris:Tick(Tetris.Screen,false)
            end

            ::next_one::
        end
    end
end)

hook.Add("Render","Tetris",function(screen)
    PrintInternal("TICK")
    Tetris.Screen = screen
    Tetris:Tick(screen,true)
end)
