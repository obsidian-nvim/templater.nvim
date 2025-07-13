local templates = require("obsidian.templates")
local log = require("obsidian.log")
local api = require("obsidian.api")
local Note = require("obsidian.note")
local etlua = require("obsidian.lib.etlua")

---Insert a template at the given location.
---
---@param ctx obsidian.InsertTemplateContext
---
---@return obsidian.Note
local insert_template = function(ctx)
	local buf, win, row, _ = unpack(ctx.location)
	if ctx.partial_note == nil then
		ctx.partial_note = Note.from_buffer(buf)
	end

	local template_path = templates.resolve_template(ctx.template_name, ctx.templates_dir)

	local template_file = io.open(tostring(template_path), "r")
	assert(template_file, string.format("Template file '%s' not found", template_path))

	local str = template_file:read("*a")
	template_file:close()
	local template = vim.F.npcall(etlua.compile, str)
	assert(template, "failed to compile template")
	local compiled = vim.F.npcall(template, {
		tp = {
			date = {
				today = os.date,
			},
			file = setmetatable({}, {
				__index = function(_, k)
					if k == "title" then
						return api.current_note(0).title
					elseif k == "tags" then
						return api.current_note(0).tags
					end
				end,
			}),
		},
	})

	assert(template, "failed to run template")

	---@diagnostic disable-next-line: param-type-mismatch
	local insert_lines = vim.split(compiled, "\n")

	vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, false, insert_lines)
	local new_cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(win))
	vim.api.nvim_win_set_cursor(0, { new_cursor_row, 0 })

	require("obsidian.ui").update(0)

	return Note.from_buffer(buf)
end

---@param data CommandArgs
return function(_, data)
	local templates_dir = api.templates_dir()
	if not templates_dir then
		log.err("Templates folder is not defined or does not exist")
		return
	end

	-- We need to get this upfront before the picker hijacks the current window.
	local insert_location = api.get_active_window_cursor_location()

	local function insert(name)
		insert_template({
			type = "insert_template",
			template_name = name,
			template_opts = Obsidian.opts.templates,
			templates_dir = templates_dir,
			location = insert_location,
		})
	end

	if string.len(data.args) > 0 then
		local template_name = vim.trim(data.args)
		insert(template_name)
		return
	end

	local picker = Obsidian.picker
	if not picker then
		log.err("No picker configured")
		return
	end

	picker:find_templates({
		callback = function(path)
			insert(path)
		end,
	})
end
