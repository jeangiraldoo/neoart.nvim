return {
	keymap = "e",
	starter_state = {
		size = {
			val = 1,
			display_on_toolbar = true,
		},
		size_increment = {
			val = 1,
			display_on_toolbar = false,
		},
	},
	use = function(canvas, eraser_state)
		local one_based_col = vim.api.nvim_win_get_cursor(0)[2] + 1
		local one_based_row = vim.api.nvim_win_get_cursor(0)[1]

		local dimensions = eraser_state.size.val

		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				canvas[one_based_row + i][one_based_col + j] = { char = " ", _BG = nil, _FG = nil }
			end
		end

		return canvas
	end,
}
