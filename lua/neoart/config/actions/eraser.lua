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
	use = function(eraser_state)
		local one_based_col = vim.api.nvim_win_get_cursor(0)[2] + 1
		local one_based_row = vim.api.nvim_win_get_cursor(0)[1]

		local dimensions = eraser_state.size.val

		local list = {}
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				table.insert(list, {
					y = one_based_row + i,
					x = one_based_col + j,
					char = " ",
					bg = nil,
					fg = nil,
				})
			end
		end

		return list
	end,
}
