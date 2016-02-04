hook.Add("steamClient.chatMessage","UserMessageHook",function(chatRoom,steamID,msg)
    if IncomingMessageBlacklist[steamID] then return end
    sandbox:CallHook("ChatMessage",sandbox.env.chat.GetBySteamID64(chatRoom),sandbox.env.user.GetBySteamID64(steamID),msg)
end)

hook.Add("steamClient.chatUserJoined","UserJoinHook",function(chatID,steamID)
    sandbox:CallHook("UserJoinedChat",sandbox.env.chat.GetBySteamID64(chatID),sandbox.env.user.GetBySteamID64(steamID))
end)

hook.Add("steamClient.chatUserLeft","UserJoinHook",function(chatID,steamID)
    sandbox:CallHook("UserLeftChat",sandbox.env.chat.GetBySteamID64(chatID),sandbox.env.user.GetBySteamID64(steamID))
end)
