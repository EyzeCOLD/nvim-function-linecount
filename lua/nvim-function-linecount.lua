local function count_function_lines()
	local buffer = vim.api.nvim_get_current_buf()
	local last_line = vim.api.nvim_buf_line_count(buffer)
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	local namespace = vim.api.nvim_create_namespace("error_namespace")
	local hl_group = "ErrorMsg"
	local i = 1

	vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
    while (i <= last_line) do
        if string.match(lines[i], "^[%w%s_%*]+%s+[%w_%*]+%s*%b()") then
			i = i + 1
			if (i > last_line) then
				return
			end
			if (string.match(lines[i], "{")) then
				local func_lines = 0
				local open_brackets = 1
				while (open_brackets > 0) do
					i = i + 1
					func_lines = func_lines + 1
					if (i > last_line) then
						return
					end
					if (string.match(lines[i], "{")) then
						open_brackets = open_brackets + 1
					elseif (string.match(lines[i], "}")) then
						open_brackets = open_brackets - 1
					end
				end
				vim.api.nvim_buf_set_extmark(buffer, namespace, i - 1, 0, {
					virt_text = { { string.format("-- Lines: %d", func_lines - 1), hl_group } },
					virt_text_pos = "eol",
				})
			end
        end
		i = i + 1
	end
end

vim.api.nvim_create_user_command("CountFunctionLines", count_function_lines, {})

vim.api.nvim_create_autocmd({"BufReadPost", "TextChanged", "InsertLeave"}, {
    pattern = "*.c",
    callback = function()
		count_function_lines()
	end,
})
