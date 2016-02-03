function include(path)
    local cfile = io.open("user/"..path,"rb")
    if not cfile then return end
    local data = cfile:read("a")
    cfile:close()

    data = "local sandbox = sandbox;"..data

    return (woahroutine.wrap(load(data,path)))()
end

include("classes/user.lua")
