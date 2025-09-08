return setmetatable({}, {
	__index = function(_, k)
		local api = require("obsidian.api")
		if k == "title" then
			return api.current_note(0).title
		elseif k == "tags" then
			return api.current_note(0).tags
		end
	end,
})
