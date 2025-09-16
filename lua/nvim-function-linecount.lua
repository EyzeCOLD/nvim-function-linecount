local M = {}

-- Default value
M.line_limit = 25

function M.setup(opts)
	opts = opts or {}
	if type(opts.line_limit) == "number" then
		M.line_limit = opts.line_limit
	end
end

function M.count_function_lines()
	local buffer = vim.api.nvim_get_current_buf()
	local last_line = vim.api.nvim_buf_line_count(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	local namespace = vim.api.nvim_create_namespace("error_namespace")
	local hl_group
	local i = 1
	local func_lines

	vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
	while i <= last_line do
		local line = lines[i]

		if string.match(line, "^.-%b()") then
			func_lines = 0
			local brace_line = i
			local brace_on_same_line = string.match(lines[brace_line], "{")
			while brace_line < last_line and not brace_on_same_line do
				brace_line = brace_line + 1
				brace_on_same_line = string.match(lines[brace_line], "{")
			end
			if brace_line > last_line then
				break
			end

			-- Catch code on the same line as the opening brace
			if string.match(line, "{%s*%S+") and not string.find(line, "}") then
				func_lines = func_lines + 1
			end

			local open_brackets = 0
			for j = brace_line, last_line do
				local current_line = lines[j]
				local opens, closes = select(2, current_line:gsub("{", "{")), select(2, current_line:gsub("}", "}"))
				open_brackets = open_brackets + opens - closes

				func_lines = func_lines + 1

				if open_brackets == 0 then
					i = j
					break
				end
			end

			-- Catch code on the same line as the closing brace
			if string.match(lines[i], "%s*%S+%s*};?%s*$") and not string.match(lines[i], "^.-%b()") then
				func_lines = func_lines + 1
			end

			if string.match(lines[i], "^.-%b()") and string.match(lines[i], "{%s*%S.-}") then
				func_lines = func_lines + 1
			end

			if not string.match(lines[brace_line], "%b{}") then
				func_lines = func_lines - 1
			end

			if func_lines < M.line_limit then
				hl_group = "Nontext"
			elseif func_lines == M.line_limit then
				hl_group = "WarningMsg"
			else
				hl_group = "ErrorMsg"
			end

			vim.api.nvim_buf_set_extmark(buffer, namespace, i - 1, 0, {
				virt_text = { { string.format("-- Lines: %d", func_lines - 1), hl_group } },
				virt_text_pos = "eol",
			})
		end

		i = i + 1
	end
end

vim.api.nvim_create_user_command("CountFunctionLines", M.count_function_lines, {})

vim.api.nvim_create_autocmd({"BufReadPost", "TextChanged", "InsertLeave"}, {
    pattern = { "*.c", "*.h", "*.cpp", "*.hpp" },
    callback = function()
		M.count_function_lines()
	end,
})

return M
