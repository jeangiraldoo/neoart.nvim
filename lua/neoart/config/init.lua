local dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

return {
	canvas = {
		cols = 100,
		rows = 30,
		fill = {
			char = " ",
			color = {
				fg = "",
				bg = "",
			},
		},
	},
	toolbar = {
		char = {
			tool_active = "↓",
			current_color = {
				fg = "█",
				bg = " ",
			},
		},
	},
	tools = {
		default = "pencil",
		keys = {
			activate = "<Space>",
			deactivate = "<Esc>",
			state_handlers = {
				char = "tp",
				size = "zb",
				color = "ty",
				eyedropper = "tx",
			},
		},
		impls = vim.iter(vim.fs.dir(vim.fs.joinpath(dir, "tools")))
			:fold({}, function(acc, name, type)
				if type == "file" then
					local tool_name = name:gsub("%.lua$", "")
					acc[tool_name] = require("neoart.config.tools." .. tool_name)
				end

				return acc
			end),
	},
	chars = {
		"abcdefghijklmnopqrstuvwxyz",
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ",
		"0123456789",
		".,:;''`~!?-_=+*/\\|",
		"()[]{}<>",
		" ░▒▓█",
		"▀▄▌▐",
		"─│┌┐└┘├┤┬┴┼",
		"╔║╚═╝╗╠╣╦╩╬",
		"╭╮╯╰",
		"■□●○◆◇",
		"↑↓←→",
		"#%&@^$",
	},
}
