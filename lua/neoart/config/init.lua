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
		},
	},
	actions = vim.iter(vim.fs.dir(vim.fs.joinpath(dir, "actions")))
		:fold({}, function(acc, name, type)
			if type == "file" then
				local action_name = name:gsub("%.lua$", "")
				acc[action_name] = require("neoart.config.actions." .. action_name)
			end

			return acc
		end),
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
