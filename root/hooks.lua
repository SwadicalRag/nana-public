hook.Add("steamClient.chatMessageEx","UserMessageHook",function(chatRoom,steamID,msg)
    sandbox:PushHandler("steam")
    sandbox:CallHook("ChatMessage",sandbox.env.steamChat.GetBySteamID64(chatRoom),sandbox.env.steamUser.GetBySteamID64(steamID),msg)
    sandbox:PopHandler()
end)

hook.Add("steamClient.chatUserJoined","UserJoinHook",function(chatID,steamID)
    sandbox:PushHandler("steam")
    sandbox:CallHook("UserJoinedChat",sandbox.env.steamChat.GetBySteamID64(chatID),sandbox.env.steamUser.GetBySteamID64(steamID))
    sandbox:PopHandler()
end)

hook.Add("steamClient.chatUserLeft","UserJoinHook",function(chatID,steamID)
    sandbox:PushHandler("steam")
    sandbox:CallHook("UserLeftChat",sandbox.env.steamChat.GetBySteamID64(chatID),sandbox.env.steamUser.GetBySteamID64(steamID))
    sandbox:PopHandler()
end)

hook.Add("discord.messageEx","UserMessageHook",function(username,userID,msg,channelID)
    sandbox:PushHandler("discord")
    sandbox:CallHook("ChatMessage",sandbox.env.discordChannel.GetByID(channelID),sandbox.env.discordUser.GetByID(userID),msg)
    sandbox:PopHandler()
end)

hook.Add("fp.ThreadUpdate","OnNewFPThread",function(...)
    sandbox:CallHook("OnNewFPThread",...);
end)
