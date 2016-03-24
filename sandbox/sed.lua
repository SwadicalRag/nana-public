-- sed
-- from https://github.com/willox/hash.js/blob/master/plugins/lua/user_modules/sed.lua
-- (modified to be nana compatible)

local CircularBuffer = require ("circularbuffer")
local RELAY_EQUALITY = RELAY_EQUALITY

local sed = {}
sed.messages = CircularBuffer (20)

hook.Add ("ChatMessage", "sed",
	function (chatRoom, user, message)
		local a, b = string.match (message, "^s/(.*)/(.*)/$")
		if a then
			for i = 1, sed.messages:getSize () do
				local message = sed.messages:get (-i)
				if not message then break end

				if chatRoom == message.chatRoom or (RELAY_EQUALITY(chatRoom,message.chatRoom)) then
					if string.find (message.message, a) then
						local newMessage = string.gsub (message.message, a, b)
						chatRoom:Say (message.user:Nick() .. ": " .. newMessage)
						sed.messages:add ({ chatRoom = message.chatRoom, user = message.user, message = newMessage })
						break
					end
				end
			end
		else
			sed.messages:add ({ chatRoom = chatRoom, user = user, message = message })
		end
	end
)
