local M = {}

local api = require("obsidian.api")
local Path = require("obsidian.path")

---@param abosulte boolean
---@return string
M.folder = function(abosulte)
	local parent = api.current_note(0).path:parent()
	assert(parent, "can not find folder for current note")
	if abosulte then
		return tostring(parent)
	else
		if Path.new(Obsidian.workspace.root) == parent then
			return ""
		end
		return assert(parent:vault_relative_path({ strict = true }))
	end
end

---@param relative boolean
---@return string
M.path = function(relative)
	local path = api.current_note(0).path
	assert(path, "can not find path for current note")
	if relative then
		return assert(path:vault_relative_path({ strict = true }))
	else
		return tostring(path)
	end
end

return setmetatable(M, {
	__index = function(t, k)
		if k == "title" then
			return api.current_note(0).title
		elseif k == "tags" then
			return api.current_note(0).tags
		else
			return rawget(t, k)
		end
	end,
})
