return {
	keymap = "tf",
	use = function(workspace_obj)
		local fg_color = vim.fn.input { prompt = "FG color: " }

		local toolset = workspace_obj.toolset
		toolset.state[toolset.current].FG.val = fg_color
	end,
}
