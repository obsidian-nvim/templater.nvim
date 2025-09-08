local M = {}

M.clipboard = function()
	return vim.fn.getreg("+")
end

M.prompt = function(prompt_text, default_value, throw_on_cancel, multiline)
	return require("obsidian.api").input(prompt_text, {
		default = default_value,
	})
end

---HACK: For now because vim.ui.select don't have option to do sync
---@generic T
---@param items T[] Arbitrary items
---@param opts vim.ui.select.Opts Additional options
---@return T?
---@return number?
---               Called once the user made a choice.
---               `idx` is the 1-based index of `item` within `items`.
---               `nil` if the user aborted the dialog.
local function ui_select(items, opts)
	vim.validate("items", items, "table")
	opts = opts or {}
	local choices = { opts.prompt or "Select one of:" }
	local format_item = opts.format_item or tostring
	for i, item in
		ipairs(items --[[@as any[] ]])
	do
		table.insert(choices, string.format("%d: %s", i, format_item(item)))
	end
	local choice = vim.fn.inputlist(choices)
	if choice < 1 or choice > #items then
		return
	else
		return items[choice], choice
	end
end

---@generic T
---@param text_items string[] | fun(item: T): string
---@param items T[]
---@param throw_on_cancel boolean?
---@param placeholder string?
---@param limit number?
M.suggester = function(text_items, items, throw_on_cancel, placeholder, limit)
	local to_select, format_item
	if type(text_items) == "function" then
		format_item = true
		to_select = items
	elseif type(text_items) == "table" then
		to_select = text_items
	end

	local choice = ui_select(to_select, {
		prompt = placeholder,
		---@cast text_items -table
		format_item = format_item and text_items or nil,
	})

	if not choice then
		if throw_on_cancel then
			error("cancelled suggester")
		else
			return ""
		end
	else
		return choice
	end
end

return M
