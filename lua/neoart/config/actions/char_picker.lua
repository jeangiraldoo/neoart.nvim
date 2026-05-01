return {
	keymap = "tp",
	use = function(workspace_obj)
		local config = require "neoart.config"

		local buf_id = vim.api.nvim_create_buf(false, true)
		local win_id = vim.api.nvim_open_win(buf_id, true, {
			relative = "cursor",
			width = 40,
			height = 3,
			row = 1,
			col = 0,
		})

		vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, config.chars)

		vim.keymap.set("n", "<CR>", function()
			local line = vim.api.nvim_get_current_line()
			local byte_col = vim.api.nvim_win_get_cursor(0)[2]

			local char_idx = vim.str_utfindex(line, byte_col)

			local toolset = workspace_obj.toolset
			toolset.state[toolset.current].char.val = vim.fn.strcharpart(line, char_idx, 1)

			workspace_obj:refresh_toolbar()
			vim.api.nvim_win_close(win_id, true)
		end, { buf = buf_id })

		vim.keymap.set(
			"n",
			"q",
			function() vim.api.nvim_win_close(win_id, true) end,
			{ buf = buf_id }
		)
	end,
}
