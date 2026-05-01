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
	use = function(state, prev)
		local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based column
		local cursor_row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based column

		local moved_horizontally = prev.pos.col ~= cursor_col

		local dimensions = state.size.val
		local list = {}
		local function add(col, row)
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
		end

		if not moved_horizontally then
			local step = cursor_row <= prev.pos.row and -1 or 1

			for row = prev.pos.row, cursor_row, step do
				add(cursor_col, row)
			end
		else
			local step = cursor_col <= prev.pos.col and -1 or 1

			for col = prev.pos.col, cursor_col, step do
				add(col, cursor_row)
			end
		end

		return list
	end,
}
