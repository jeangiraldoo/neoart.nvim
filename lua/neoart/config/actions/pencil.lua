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
	use = function(state, pos)
		if not pos then return end

		local dimensions = state.size.val

		local list = {}
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				table.insert(list, {
					y = pos.row + i,
					x = pos.col + j,
					char = state.char.val,
					bg = state.bg.val,
					fg = state.fg.val,
				})
			end
		end

		return list
	end,
}
