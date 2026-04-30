return {
	keymap = "td",
	use = function(workspace_obj)
		local bg_color = vim.fn.input { prompt = "BG color: " }

		local toolset = workspace_obj.toolset
		toolset.state[toolset.current].BG.val = bg_color
	end,
}
