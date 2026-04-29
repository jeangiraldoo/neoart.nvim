return {
	keymap = "t",
	starter_state = {
		size = 1,
		char = "a",
		_size_increment = 1,
		_BG = "#F54927",
		_FG = "#27F557",
	},
	use = function(canvas, state)
		local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based column
		local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based column

		local dimensions = state.size
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				canvas[row + i][col + j] = { char = state.char, BG = state._BG, FG = state._FG }
			end
		end

		return canvas
	end,
}
