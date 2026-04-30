return {
	keymap = "ze",
	use = function(workspace_obj)
		local one_based_col = vim.api.nvim_win_get_cursor(0)[2] + 1
		local one_based_row = vim.api.nvim_win_get_cursor(0)[1]

		local toolset = workspace_obj.toolset
		local current_tool_state = toolset.state[toolset.current]

		vim.ui.select({ "fg", "bg" }, {
			prompt = "[Eyedropper] Take:",
		}, function(choice)
			local cell_under_cursor = workspace_obj.canvas[one_based_row][one_based_col]

			local cell_color = cell_under_cursor[choice:upper()]
			vim.ui.select({ "fg", "bg" }, {
				prompt = "Set as:",
			}, function(target) current_tool_state[target:upper()].val = cell_color end)
		end)
	end,
}
