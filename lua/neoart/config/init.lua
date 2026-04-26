local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

return {
	canvas = {
		cols = 100,
		rows = 30,
		fill = " ",
	},
	toolbar = {
		tool_active_char = "↓",
	},
	default_tool = "pencil",
	tools = vim.iter(vim.fs.dir(vim.fs.joinpath(dir, "tools"))):fold({}, function(acc, name, type)
		if type == "file" then
			local tool_name = name:gsub("%.lua$", "")
			acc[tool_name] = require("neoart.config.tools." .. tool_name)
		end

		return acc
	end),
	chars = {
		"a",
		"b",
		"c",
	},
	state_ops = {
		["<Esc>"] = function(workspace_obj) workspace_obj.toolset.is_active = false end,
		["<Space>"] = function(workspace_obj)
			workspace_obj.toolset.is_active = true

			---Applies the tool to the current cell; otherwise it runs only after the next cursor movement
			workspace_obj:use_current_tool()
		end,
		["tp"] = function(workspace_obj)
			local config = require "neoart.config"

			local buf_id = vim.api.nvim_create_buf(false, true)
			local win_id = vim.api.nvim_open_win(buf_id, true, {
				relative = "cursor",
				width = 20,
				height = 1,
				row = 1,
				col = 0,
			})

			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, {
				table.concat(config.chars),
			})

			vim.keymap.set("n", "<CR>", function()
				local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based column

				local toolset = workspace_obj.toolset
				toolset.state[toolset.current].char = vim.api.nvim_get_current_line():sub(col, col)

				workspace_obj:refresh_toolbar()
				vim.api.nvim_win_close(win_id, true)
			end, { buf = buf_id })
		end,
		["zb"] = function(workspace_obj)
			local toolset = workspace_obj.toolset
			local current_tool_state = toolset.state[toolset.current]

			current_tool_state.size = current_tool_state.size + current_tool_state._size_increment
		end,
	},
}
