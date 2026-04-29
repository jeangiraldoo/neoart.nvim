return {
	keymap = "t",
	starter_state = {
		size = {
			val = 1,
			display_on_toolbar = true,
		},
		char = {
			val = "a",
			display_on_toolbar = true,
		},
		size_increment = {
			val = 1,
			display_on_toolbar = false,
		},
		BG = {
			val = "#F54927",
			display_on_toolbar = false,
		},
		FG = {
			val = "#27F557",
			display_on_toolbar = false,
		},
	},
	use = function(canvas, state)
		local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based column
		local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based column

		local dimensions = state.size.val
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				canvas[row + i][col + j] = {
					char = state.char.val,
					BG = state.BG.val,
					FG = state.FG.val,
				}
			end
		end

		return canvas
	end,
}
