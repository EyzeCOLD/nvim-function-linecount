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

	vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
    while (i < last_line) do
        if string.match(lines[i], "^[%w%s_%*]+%s+[%w_%*]+%s*%b()") then
			if not (string.match(lines[i], "{%s*$")) then
				i = i + 1
			end
			if (string.match(lines[i], "{%s*$")) then
				local func_lines = 0
				local open_brackets = 1
				while (open_brackets > 0) do
					i = i + 1
					func_lines = func_lines + 1
					if (i > last_line) then
						return
					end
					if (string.match(lines[i], "{%s*$")) then
						open_brackets = open_brackets + 1
					elseif (string.match(lines[i], "}%s*$")) then
						open_brackets = open_brackets - 1
					end
				end
				func_lines = func_lines - 1;
				if (func_lines < M.line_limit) then
					hl_group = "Nontext"
				elseif (func_lines == M.line_limit) then
					hl_group = "WarningMsg"
				else
					hl_group = "ErrorMsg"
				end
				vim.api.nvim_buf_set_extmark(buffer, namespace, i - 1, 0, {
					virt_text = { { string.format("-- Lines: %d", func_lines), hl_group } },
					virt_text_pos = "eol",
				})
			end
        end
		i = i + 1
	end
end

vim.api.nvim_create_user_command("CountFunctionLines", M.count_function_lines, {})

vim.api.nvim_create_autocmd({"BufReadPost", "TextChanged", "InsertLeave"}, {
    pattern = "*.c",
    callback = function()
		M.count_function_lines()
	end,
})

return M
