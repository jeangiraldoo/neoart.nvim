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
	use = function(eraser_state, _, pos)
		if not pos then return end

		print(vim.inspect(pos))
		local dimensions = eraser_state.size.val

		local list = {}
		for i = 0, dimensions - 1, 1 do
			for j = 0, dimensions - 1, 1 do
				table.insert(list, {
					y = pos.row + i,
					x = pos.col + j,
					char = " ",
					bg = nil,
					fg = nil,
				})
			end
		end
		-- print(vim.inspect(list))

		return list
	end,
}
