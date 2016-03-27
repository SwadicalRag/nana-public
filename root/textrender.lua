Renderer = {}

-- 45 x 45: steam
function Renderer:NewContext(w,h)
    local Context = {
        w = w,
        h = h,
        screen = { -- [x,y]

        },
        __chars = {
            clear = " ",
            filled = "■"
        },
        _chars = {
            clear = "   ",
            filled = "#"
        },
        chars = {
            clear = "░░",
            filled = "▓▓"
        },
        palette = {
            --" ",
            "░",
            "▒",
            "▓"
        }
    }

    function Context:SetupScreen()
        self:SetFOV(60)
        self:SetPos(0,0,0)
        self:SetAng(0,0,0)
        self:SetScale(1)

        self:Clear()
    end

    function Context:Clear()
        for x=1,self.w do
            self.screen[x] = {}
            for y=1,self.h do
                self.screen[x][y] = self.chars.clear
            end
        end
    end

    function Context:Round(n)
        return math.floor(n + 0.5)
    end

    function Context:Diff(n1,n2)
        return math.abs(n1 - n2)
    end

    function Context:Vector(x,y,z)
        local vec = {
            x = x,
            y = y,
            z = z
        }

        if vec.z == 0 then
            vec.pitch = math.atan(math.huge)
        else
            vec.pitch = math.atan(((vec.x^2 + vec.y^2)^0.5)/vec.z)
        end

        if vec.y == 0 then
            if math.abs(vec.x) == vec.x then
                vec.yaw = math.atan(-math.huge)
            else
                vec.yaw = math.atan(math.huge)
            end
        else
            vec.yaw = math.atan(-vec.x/vec.y)
        end

        vec.pitch = vec.pitch / math.pi * 180
        vec.yaw = vec.yaw / math.pi * 180

        local meta = {}
        meta.__index = meta

        function meta:Ang()
            return self.pitch,self.yaw
        end

        function meta:__tostring()
            return string.format("Vector: %f,%f,%f [%f deg,%f deg]",self.x,self.y,self.z,self.pitch,self.yaw)
        end

        function meta.__add(self2,vec)
            local prod = self:Vector(self2.x + vec.x,self2.y + vec.y,self2.z + vec.z)
            return prod
        end

        function meta.__sub(self2,vec)
            return self:Vector(self2.x - vec.x,self2.y - vec.y,self2.z - vec.z)
        end

        function meta.__mul(self2,num)
            assert(type(num) == "number","Vector x Vector multiplication isn't supported")
            return self:Vector(self2.x * num,self2.y * num,self2.z * num)
        end

        function meta.__div(self2,num)
            assert(type(num) == "number","Vector / Vector division isn't supported")
            return self:Vector(self2.x / num,self2.y / num,self2.z / num)
        end

        return setmetatable(vec,meta)
    end

    function Context:SetScale(scale)
        self.scale = scale
    end

    -- from https://facepunch.com/showthread.php?t=1157649&p=34396068&viewfull=1#post34396068
    function Context:ToScreen(vec)
        local dir = vec - self.pos

        local screenX = ((self:Diff(dir.yaw,self.pos.yaw) - self.ang.yaw) * self.w / self.fov) + self.w / 2
        local screenY = ((self:Diff(dir.pitch,self.pos.pitch) - self.ang.pitch) * self.h / self.fov) + self.h / 2

        -- local screenX = ((dir.yaw - self.pos.yaw - self.ang.yaw) * self.w / self.fov) + self.w / 2
        -- local screenY = ((dir.pitch - self.pos.pitch - self.ang.pitch) * self.h / self.fov) + self.h / 2

        -- local screenX = ((-dir.yaw + self.pos.yaw - self.ang.yaw) * self.w / self.fov) + self.w / 2
        -- local screenY = ((-dir.pitch + self.pos.pitch - self.ang.pitch) * self.h / self.fov) + self.h / 2

        return screenX * self.scale,screenY * self.scale
    end

    function Context:SetFOV(fov)
        self.fov = fov
    end

    function Context:SetPos(x,y,z)
        self.pos = self:Vector(x,y,z)
    end

    function Context:SetAng(p,y)
        -- self.ang = {
        --     pitch = p / 180 * math.pi,
        --     yaw = y / 180 * math.pi,
        --     roll = r / 180 * math.pi
        -- }

        self.ang = {
            pitch = p,
            yaw = y
        }
    end

    function Context:DrawDot(x,y,status)
        if self.screen[x] and self.screen[x][y] then
            if type(status) == "string" then
                self.screen[x][y] = status
            elseif status == false then
                self.screen[x][y] = self.chars.clear
            else
                self.screen[x][y] = self.chars.filled
            end
        end
    end

    function Context:DrawLine(_x1,_y1,_x2,_y2)
        local x1,x2 = self:Round(math.min(_x1,_x2)),self:Round(math.max(_x1,_x2))
        local y1,y2 = self:Round(math.min(_y1,_y2)),self:Round(math.max(_y1,_y2))

        if x2 == x1 then
            for i=y1,y2 do
                self:DrawDot(x1,i)
            end
        else
            local x_dist = x2 - x1
            local gradient = (y2 - y1) / x_dist

            local last_y = y1
            for i=0,x_dist do
                local new_y = self:Round(y1 + gradient * i)
                local x_val = self:Round(x1 + i)

                self:DrawDot(x_val,new_y)

                local y_diff = self:Diff(new_y,last_y)
                if y_diff > 1 then
                    for i=1,y_diff do
                        local y_val = last_y + i

                        self:DrawDot(x_val,y_val)
                    end
                end
                last_y = new_y
            end
        end
    end

    function Context:Draw3DLine(vec1,vec2)
        -- print(vec1,vec2)
        local c1x,c1y = self:ToScreen(vec1)
        local c2x,c2y = self:ToScreen(vec2)

        self:DrawLine(c1x,c1y,c2x,c2y)
        -- print(c1x,c1y,c2x,c2y)
    end

    function Context:DrawBox(origin,size)
        size = size / 2

        self:Draw3DLine(origin + self:Vector(-size,size,size),origin + self:Vector(size,size,size))
        self:Draw3DLine(origin + self:Vector(-size,-size,size),origin + self:Vector(size,-size,size))
        self:Draw3DLine(origin + self:Vector(-size,-size,size),origin + self:Vector(-size,size,size))
        self:Draw3DLine(origin + self:Vector(size,-size,size),origin + self:Vector(size,size,size))
        self:Draw3DLine(origin + self:Vector(-size,size,-size),origin + self:Vector(size,size,-size))
        self:Draw3DLine(origin + self:Vector(-size,-size,-size),origin + self:Vector(size,-size,-size))
        self:Draw3DLine(origin + self:Vector(-size,-size,-size),origin + self:Vector(-size,size,-size))
        self:Draw3DLine(origin + self:Vector(size,-size,-size),origin + self:Vector(size,size,-size))
        self:Draw3DLine(origin + self:Vector(-size,-size,-size),origin + self:Vector(-size,-size,size))
        self:Draw3DLine(origin + self:Vector(size,-size,-size),origin + self:Vector(size,-size,size))
        self:Draw3DLine(origin + self:Vector(size,size,-size),origin + self:Vector(size,size,size))
        self:Draw3DLine(origin + self:Vector(-size,size,-size),origin + self:Vector(-size,size,size))
    end

    function Context:Render()
        local outBuffer = ""

        for y=1,self.h do
            for x=1,self.w do
                outBuffer = outBuffer..self.screen[x][y]
            end
            outBuffer = outBuffer.."\n"
        end

        return outBuffer
    end

    function Context:RenderEx()
        for y=1,self.h do
            for x=1,self.w do
                io.write(self.screen[x][y])
            end
            io.write("\n")
        end
    end

    function Context:ForEachPixel(cb,prog)
        local done = 0
        for x=1,self.w do
            for y=1,self.h do
                done = done + 1
                cb(x,y,self.w,self.h)
                if prog then
                    prog(done/(self.w*self.h))
                end
            end
        end
    end

    function Context:SetDescription(desc)
        self.desc = desc
    end

    Context:SetupScreen()
    return Context
end
