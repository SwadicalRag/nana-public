function learnFromMeepsDatabase(nid)
    if not nid then print("[meepDBRaper] No nid! Start at 1407?") end
    http.Fetch("http://reversedby.me/logs/markov.node.js?n="..nid,function(d,_)
        if _ ~= 200 then
            print("HTTP "..tostring(_).."!")
            lastMarkovErr = {code = _,data=d}
            return learnFromMeepsDatabase(nid + 150)
        end

        local suc,err = pcall(function()
            local data = json.decode(d)
            if data.nid then
                sandbox.env.cookie.nextNID = data.nid
            else
                print("Complete!")
            end

            if LEARN_DEBUG then
                timer.Simple(0.05,function()
                    print("Learnt "..tostring(#data.post).." submissions from nid "..tostring(nid).."; current nid="..tostring(data.nid))
                end)
            end

            for _,submission in ipairs(data.post) do
                sandbox.env.Markov:Learn("glua",submission)
            end

            timer.Simple(0.1,function()
                learnFromMeepsDatabase(data.nid)
            end)
        end)

        if not suc then
            lastMarkovErr = {err = err}
            print("[meepDBRaper] err: "..tostring(err or suc))
        end
    end)
end

debugLearn = function()
    LEARN_DEBUG = true
    timer.Simple(3,function() LEARN_DEBUG = false end)
end

-- timer.Simple(5,function()
--     learnFromMeepsDatabase(sandbox.env.cookie.nextNID or 1407)
--     debugLearn()
-- end)
--
-- timer.Create("saveMarkov",20,0,function() sandbox.env.Markov:Save() end)
