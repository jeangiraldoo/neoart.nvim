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

local function create_canvas(cols, rows, fill, buf_id)
	local buf_lines = {}
	for r = 1, rows do
		buf_lines[r] = fill:rep(cols)
	end

	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, buf_lines)

	local canvas = {}
	fill = fill or " "

	for i = 1, rows do
		local row = {}
		for j = 1, cols do
			row[j] = { char = fill }
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
	local buf = self.buf_ids.toolbar
	local ns = self.ns_id

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local first_line, second_line = "", ""
	local is_first = true
	local col_cursor = 0

	local tool_position = (self.toolset.is_active and toolbar_config.tool_active_char or "")
	local current_tool_state = self.toolset.state[self.toolset.current]

	local colours = {}
	if current_tool_state._BG then colours.BG = current_tool_state._BG end
	local data = {
		{ tool = self.toolset.current .. tool_position },
		current_tool_state,
		colours,
	}

	local swatches = {}

	for _, item in ipairs(data) do
		for name, val in pairs(item) do
			if name:sub(1, 1) == "_" then goto skip end

			val = tostring(val)
			local width = math.max(#name, #val)

			local name_centered = center(name, width)
			local val_centered = center(val, width)

			if not is_first then
				first_line = first_line .. "  "
				second_line = second_line .. "  "
				col_cursor = col_cursor + 2
			end

			local start_col = col_cursor
			local end_col = col_cursor + width

			first_line = first_line .. name_centered
			second_line = second_line .. val_centered

			if name == "BG" and current_tool_state._BG then
				local color = current_tool_state._BG
				local hl = "NeoartBG_" .. color:gsub("#", "")

				vim.api.nvim_set_hl(0, hl, { bg = color })

				table.insert(swatches, {
					row = 1,
					start = start_col,
					width = width,
					hl = hl,
				})
			end

			col_cursor = end_col
			is_first = false

			::skip::
		end
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { first_line, second_line })

	for _, s in ipairs(swatches) do
		vim.api.nvim_buf_set_extmark(buf, ns, s.row, s.start, {
			virt_text = { { " ", s.hl } },
			virt_text_pos = "overlay",
		})
	end
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

local function get_bg_hl(bg, fg)
	local name = "NeoArt_"
		.. (bg and bg:gsub("#", "") or "none")
		.. "_"
		.. (fg and fg:gsub("#", "") or "none")

	vim.api.nvim_set_hl(0, name, {
		bg = bg,
		fg = fg,
	})

	return name
end

function Workspace:refresh_canvas()
	local canvas_buf_id = self.buf_ids.canvas
	local ns_id = vim.api.nvim_create_namespace "neoart"
	vim.api.nvim_buf_clear_namespace(canvas_buf_id, ns_id, 0, -1)

	for r = 1, #self.canvas do
		for j = 1, #self.canvas[r] do
			local cell = self.canvas[r][j]

			local hl = (cell.BG and cell.FG) and get_bg_hl(cell.BG, cell.FG) or "Normal"

			cell.mark_id = vim.api.nvim_buf_set_extmark(canvas_buf_id, ns_id, r - 1, j - 1, {
				virt_text = { { cell.char, hl } },
				virt_text_pos = "overlay",
			})
		end
	end

	vim.bo[canvas_buf_id].modifiable = true
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
		ns_id = vim.api.nvim_create_namespace "neoart",
	}, Workspace)

	new_workspace.canvas =
		create_canvas(cols, rows, config.canvas.fill, new_workspace.buf_ids.canvas)

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
