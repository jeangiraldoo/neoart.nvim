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
	use = function(state, prev, pos)
		if not pos then return end
		local moved_horizontally = prev.pos.col ~= pos.col

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
			local step = pos.row <= prev.pos.row and -1 or 1

			for row = prev.pos.row, pos.row, step do
				add(pos.col, row)
			end
		else
			local step = pos.col <= prev.pos.col and -1 or 1

			for col = prev.pos.col, pos.col, step do
				add(col, pos.row)
			end
		end

		return list
	end,
}
