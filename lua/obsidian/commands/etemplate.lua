local log = require("obsidian.log")
local api = require("obsidian.api")
local etlua = require("obsidian.lib.etlua")

---Insert a template at the given location.
---
---@param template_path string
local insert_template = function(template_path)
	local template_file = io.open(tostring(template_path), "r")
	assert(template_file, string.format("Template file '%s' not found", template_path))

	local str = template_file:read("*a")
	template_file:close()

	local ok, compiled = pcall(etlua.render, str, { tp = require("obsidian.templater") })

	if not ok then
		---@diagnostic disable-next-line: param-type-mismatch
		return log.err(compiled)
	end

	assert(compiled, "failed to run template")

	local insert_lines = vim.split(compiled, "\n")
	vim.api.nvim_put(insert_lines, "l", true, true)
end

---@param data CommandArgs
return function(_, data)
	local templates_dir = api.templates_dir()

	if string.len(data.args) > 0 then
		local template_name = vim.trim(data.args)
		insert_template((api.templates_dir() / template_name):with_suffix(".md"))
		return
	end

	local picker = Obsidian.picker
	if not picker then
		log.err("No picker configured")
		return
	end

	picker:find_files({
		prompt_title = "Templater",
		callback = function(path)
			insert_template(path)
		end,
		dir = templates_dir,
		no_default_mappings = true,
	})
end
