local function color_picker(state, refresh_toolbar)
	vim.ui.select({ "fg", "bg" }, {
		prompt = "Set:",
	}, function(choice)
		local color = vim.fn.input { prompt = choice .. " color: " }

		state[choice].val = color
		refresh_toolbar()
	end)
end

return {
	keymap = "i",
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
	state_handlers = {
		size = function(state, refresh_toolbar)
			state.size.val = state.size.val + state.size_increment.val
			refresh_toolbar()
		end,
		color = function(state, refresh_toolbar) color_picker(state, refresh_toolbar) end,
		char = function(state, refresh_toolbar)
			local config = require "neoart.config"

			local buf_id = vim.api.nvim_create_buf(false, true)
			local win_id = vim.api.nvim_open_win(buf_id, true, {
				relative = "cursor",
				width = 40,
				height = 3,
				row = 1,
				col = 0,
			})

			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, config.chars)

			vim.keymap.set("n", "<CR>", function()
				local line = vim.api.nvim_get_current_line()
				local byte_col = vim.api.nvim_win_get_cursor(0)[2]

				local char_idx = vim.str_utfindex(line, byte_col)

				state.char.val = vim.fn.strcharpart(line, char_idx, 1)

				refresh_toolbar()
				vim.api.nvim_win_close(win_id, true)
			end, { buf = buf_id })

			vim.keymap.set(
				"n",
				"q",
				function() vim.api.nvim_win_close(win_id, true) end,
				{ buf = buf_id }
			)
		end,
		eyedropper = function(state, refresh_toolbar, canvas)
			local one_based_col = vim.api.nvim_win_get_cursor(0)[2] + 1
			local one_based_row = vim.api.nvim_win_get_cursor(0)[1]

			vim.ui.select({ "fg", "bg" }, {
				prompt = "[Eyedropper] Take:",
			}, function(choice)
				local cell_under_cursor = canvas[one_based_row][one_based_col]

				local cell_color = cell_under_cursor[choice]
				vim.ui.select({ "fg", "bg" }, {
					prompt = "Set as:",
				}, function(target)
					state[target].val = cell_color
					refresh_toolbar()
				end)
			end)
		end,
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
