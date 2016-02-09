local function levenshtein(a,b)local c=string.len(a)local d=string.len(b)local e={}local f=0;if c==0 then return d elseif d==0 then return c elseif a==b then return 0 end;for g=0,c,1 do e[g]={}e[g][0]=g end;for h=0,d,1 do e[0][h]=h end;for g=1,c,1 do for h=1,d,1 do if a:byte(g)==b:byte(h)then f=0 else f=1 end;e[g][h]=math.min(e[g-1][h]+1,e[g][h-1]+1,e[g-1][h-1]+f)end end;return e[c][d]end

hook.Add("ChatMessage","Thanks",function(chatroom,user,msg)
    local dist = levenshtein(msg:lower():sub(1,11),"thanks nana")
    if dist <= 2 then
        local out = {"Y","o","u","'","r","e"," ","w","e","l","c","o","m","e"}

        local _,outLetters = table.concat(out,""):gsub("[A-Za-z]","")
        local _,inLetters = msg:gsub("[A-Za-z]","")


        local _,caps = msg:gsub("[A-Z]","")
        local fin = msg:match("([^A-Za-z]+)$")

        caps = caps/inLetters * outLetters
        if caps == outLetters then
            for i,char in ipairs(out) do out[i] = char:upper() end
        else
            for i=1,caps-1 do
                local retries = 0
                ::retry::
                local rand = math.random(1,#out)

                if out[rand]:match("[a-z]") then
                    out[rand] = out[rand]:upper()
                elseif retries < 3 then
                    retries = retries + 1
                    goto retry
                end
            end
        end

        for i=1,dist do
            table.remove(out,math.random(1,#out))
        end

        chatroom:Say(table.concat(out,"")..(fin or ""))
    end
end)
