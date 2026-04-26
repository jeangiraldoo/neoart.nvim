local function get_raw_args_list(cmd_line)
	local cmd_line_without_plugin_name = cmd_line:gsub("^Neoart%s*", "")
	local args = vim.split(cmd_line_without_plugin_name, "%s+")
	return args
end

vim.api.nvim_create_user_command("Neoart", function(opts)
	local Neoart = require "neoart"

	local args = get_raw_args_list(opts.args)

	local cmd = args[1]

	if cmd == "new" then
		Neoart.create_canvas {
			cols = tonumber(args[2]),
			rows = tonumber(args[3]),
		}
	end
end, {
	nargs = "?",
	desc = "Create project from template",
	complete = function(_, cmd_line)
		local args = get_raw_args_list(cmd_line)

		if #args == 1 then -- :Neoart <cursor>
			local valid_cmds = { "new" }
			return valid_cmds
		end

		return {}
	end,
})
