local PrintInternal = print
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

function Tetris:AddRandomBlock(x,y)
    return self:AddBlock(self.blockTypes[math.random(1,#self.blockTypes)],x,y)
end

function Tetris:DrawBoard(screen)
    for i=1,#self.data do
        PrintInternal("DRAW BLOCK "..self.data[i].block)
        self:DrawBlock(screen,self.data[i].block,self.data[i].x,self.data[i].y)
    end
end

function Tetris:CheckCollision(block1,block2,y_offset_block1)
    local hit = false
    self:IteratePixels(block1.block,block1.x,block1.y + y_offset_block1,function(x1,y1)
        return self:IteratePixels(block2.block,block2.x,block2.y,function(x2,y2)
            if x1 == x2 and y1 == y2 then
                hit = true
                return true
            end
        end)
    end)

    return hit
end

function Tetris:Tick(screen)
    if self.ActiveBlock then
        for i=1,#self.data do
            if (self.data[i] ~= self.ActiveBlock) and self:CheckCollision(self.ActiveBlock,self.data[i],1) then
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
        self.ActiveBlock = self:AddRandomBlock(math.random(1,screen.w),1)
    end

    self:DrawBoard(screen)
end

Tetris:Reset()

Tetris:RegisterBlock("L-1",{
    {X,O,O},
    {X,X,X}
})

hook.Add("Render","Tetris",function(screen)
    PrintInternal("TICK")
    Tetris:Tick(screen)
end)
