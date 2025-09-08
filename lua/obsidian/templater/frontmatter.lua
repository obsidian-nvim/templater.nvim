return setmetatable({}, {
	__index = function(_, k)
		local api = require("obsidian.api")
		return api.current_note(0):frontmatter()[k] -- TODO: when in note creation??
	end,
})
