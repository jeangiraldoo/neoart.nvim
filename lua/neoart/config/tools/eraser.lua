return {
	keymap = "e",
	starter_state = {
		size = 1,
		_size_increment = 1,
	},
	use = function(canvas, eraser_state)
		local one_based_col = vim.api.nvim_win_get_cursor(0)[2] + 1
		local one_based_row = vim.api.nvim_win_get_cursor(0)[1]

		local dimensions = eraser_state.size
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				canvas[one_based_row + i][one_based_col + j] = " "
			end
		end

		return canvas
	end,
}
