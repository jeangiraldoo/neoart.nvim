return {
	keymap = "<Space>",
	use = function(workspace_obj)
		workspace_obj.toolset.is_active = true

		---Applies the tool to the current cell; otherwise it runs only after the next cursor movement
		workspace_obj:use_current_tool()
	end,
}
