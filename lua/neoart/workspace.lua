local Workspace = {}
Workspace.__index = Workspace

local function center(str, width)
	local len = #str
	if len >= width then return str end

	local total_pad = width - len
	local left_pad = math.floor(total_pad / 2)
	local right_pad = total_pad - left_pad

	return (" "):rep(left_pad) .. str .. (" "):rep(right_pad)
end

local function create_buf()
	local buf_id = vim.api.nvim_create_buf(false, true)

	vim.bo[buf_id].buftype = "nofile"
	vim.bo[buf_id].bufhidden = "hide"
	vim.bo[buf_id].swapfile = false

	vim.api.nvim_win_set_buf(0, buf_id)

	return buf_id
end

local function create_canvas(cols, rows, fill)
	local canvas = {}
	fill = fill or " "

	for i = 1, rows do
		local row = {}
		for j = 1, cols do
			row[j] = fill
		end
		canvas[i] = row
	end

	return canvas
end

function Workspace:set_canvas_keymap(keymap, callback)
	vim.keymap.set("n", keymap, function()
		callback()
		self:refresh_toolbar()
	end)
end

function Workspace:refresh_toolbar()
	local toolbar_config = require("neoart.config").toolbar
	local first_line, second_line = "", ""
	local is_first = true

	local tool_position = (self.toolset.is_active and toolbar_config.tool_active_char or "")

	local data = {
		{ tool = self.toolset.current .. tool_position },
		self.toolset.state[self.toolset.current],
	}

	for _, item in ipairs(data) do
		for state_opt_name, state_opt_val in pairs(item) do
			local should_display_opt = state_opt_name:sub(1, 1) ~= "_"
			if not should_display_opt then goto skip end

			state_opt_val = tostring(state_opt_val)

			local width = math.max(#state_opt_name, #state_opt_val)

			local name_centered = center(state_opt_name, width)
			local val_centered = center(state_opt_val, width)

			if not is_first then
				first_line = first_line .. "  "
				second_line = second_line .. "  "
			end

			first_line = first_line .. name_centered
			second_line = second_line .. val_centered

			is_first = false
		end

		::skip::
	end

	local lines = { first_line, second_line }
	vim.api.nvim_buf_set_lines(self.buf_ids.toolbar, 0, -1, false, lines)
end

function Workspace:use_current_tool()
	local config = require "neoart.config"

	local tool_implementation = config.tools[self.toolset.current]

	if not (tool_implementation and self.toolset.is_active) then return end

	local new_canvas = tool_implementation.use(
		self.canvas,
		self.toolset.state[self.toolset.current]
	) or self.canvas

	self.canvas = new_canvas
	self:refresh_canvas()
end

function Workspace:refresh_canvas()
	local lines = {}

	for r = 1, #self.canvas do
		lines[r] = table.concat(self.canvas[r])
	end

	vim.api.nvim_buf_set_lines(self.buf_ids.canvas, 0, -1, false, lines)

	vim.bo[self.buf_ids.canvas].modifiable = true
	vim.api.nvim_win_set_cursor(0, vim.api.nvim_win_get_cursor(0))
end

function Workspace.new(dimensions)
	vim.validate("dimensions", dimensions, "table", true)

	local config = require "neoart.config"

	local cols = dimensions and dimensions.cols or config.canvas.cols
	local rows = dimensions and dimensions.rows or config.canvas.rows

	local new_workspace = setmetatable({
		toolset = {
			current = config.default_tool,
			is_active = false,
			state = {},
		},
		buf_ids = {
			canvas = create_buf(),
			toolbar = create_buf(),
		},
		canvas = create_canvas(cols, rows, config.canvas.fill),
	}, Workspace)

	---Setups the toolbar
	vim.cmd "topleft split"
	vim.api.nvim_win_set_buf(0, new_workspace.buf_ids.toolbar)
	vim.cmd "resize 4"
	vim.cmd "wincmd j" ---Goes down to the canvas

	vim.api.nvim_win_set_buf(0, new_workspace.buf_ids.canvas)
	vim.api.nvim_set_current_buf(new_workspace.buf_ids.canvas)

	for tool_name, tool_opts in pairs(config.tools) do
		new_workspace.toolset.state[tool_name] = vim.deepcopy(tool_opts.starter_state)

		new_workspace:set_canvas_keymap(tool_opts.keymap, function()
			new_workspace.toolset.current = tool_name
			new_workspace.toolset.is_active = false
		end)
	end

	for keymap, callback in pairs(config.state_ops) do
		new_workspace:set_canvas_keymap(keymap, function() callback(new_workspace) end)
	end

	vim.api.nvim_create_autocmd("CursorMoved", {
		buf = new_workspace.buf_ids.canvas,
		callback = function() new_workspace:use_current_tool() end,
	})

	new_workspace:refresh_canvas()
	new_workspace:refresh_toolbar()

	return new_workspace
end

return Workspace
