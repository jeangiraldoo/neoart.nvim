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
	actions = vim.iter(vim.fs.dir(vim.fs.joinpath(dir, "actions")))
		:fold({}, function(acc, name, type)
			if type == "file" then
				local action_name = name:gsub("%.lua$", "")
				acc[action_name] = require("neoart.config.actions." .. action_name)
			end

			return acc
		end),
	chars = {
		"a",
		"b",
		"c",
	},
}
