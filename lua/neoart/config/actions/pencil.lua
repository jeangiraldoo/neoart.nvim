return {
	keymap = "t",
	starter_state = {
		size = {
			val = 1,
			display_on_toolbar = true,
		},
		char = {
			val = " ",
			display_on_toolbar = true,
		},
		size_increment = {
			val = 1,
			display_on_toolbar = false,
		},
		bg = {
			val = "#F54927",
			display_on_toolbar = false,
		},
		fg = {
			val = "#27F557",
			display_on_toolbar = false,
		},
	},
	use = function(state)
		local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based column
		local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based column

		local list = {}
		local dimensions = state.size.val
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				table.insert(list, {
					y = row + i,
					x = col + j,
					char = state.char.val,
					bg = state.bg.val,
					fg = state.fg.val,
				})
			end
		end

		return list
	end,
}
