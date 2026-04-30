return {
	keymap = "td",
	use = function(workspace_obj)
		local toolset = workspace_obj.toolset

		vim.ui.select({ "fg", "bg" }, {
			prompt = "Set:",
		}, function(choice)
			local color = vim.fn.input { prompt = choice .. " color: " }

			toolset.state[toolset.current][choice:upper()].val = color
		end)
	end,
}
