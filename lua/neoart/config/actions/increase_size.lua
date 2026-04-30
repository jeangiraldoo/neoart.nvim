return {
	keymap = "zb",
	use = function(workspace_obj)
		local toolset = workspace_obj.toolset
		local current_tool_state = toolset.state[toolset.current]

		current_tool_state.size.val = current_tool_state.size.val
			+ current_tool_state.size_increment.val
	end,
}
