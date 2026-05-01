local Workspace = {}
Workspace.__index = Workspace
local function center(str, width)
	local display_len = vim.fn.strdisplaywidth(str)
	if display_len >= width then return str end

	local total_pad = width - display_len
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
		buf_lines[r] = string.rep(" ", cols)
	end

	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, buf_lines)

	local canvas = {}

	for i = 1, rows do
		local row = {}
		for j = 1, cols do
			row[j] = {
				char = fill.char or " ",
				bg = fill.color.bg,
				fg = fill.color.fg,
			}
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
	local buf = self.ids.toolbar_buf
	local ns = self.ids.namespace

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local current_tool_state = self.state.current.toolset[self.state.current.action_name]
	local tool_position = (self.state.current.is_active and toolbar_config.char.tool_active or "")

	local first_line, second_line
	do
		local tool = self.state.current.action_name .. tool_position
		local tool_header = "tool"
		local width = math.max(vim.fn.strchars(tool), vim.fn.strchars(tool_header))

		first_line = center(tool_header, width)
		second_line = center(tool, width)
	end

	for item_name, item_data in pairs(current_tool_state) do
		if item_data.display_on_toolbar == false then goto skip end
		if item_name == "bg" or item_name == "fg" then goto skip end

		local val = tostring(item_data.val)
		local width = math.max(vim.fn.strchars(item_name), vim.fn.strchars(val))

		first_line = first_line .. "  " .. center(item_name, width)
		second_line = second_line .. "  " .. center(val, width)

		::skip::
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { first_line, second_line })

	local function append_color(label, color, hl_opts, char)
		local width = vim.fn.strchars(label)

		local line0 = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
		local line1 = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]

		local col0 = #line0
		local col1 = #line1

		vim.api.nvim_buf_set_text(buf, 0, col0, 0, col0, { "  " .. label })
		vim.api.nvim_buf_set_text(buf, 1, col1, 1, col1, { "  " .. string.rep(" ", width) })

		line1 = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]
		local new_col1 = #line1

		local start_col = new_col1 - width

		local hl = "NeoArt_" .. label .. "_" .. color:gsub("#", "")
		vim.api.nvim_set_hl(0, hl, hl_opts)

		vim.api.nvim_buf_set_extmark(buf, ns, 1, start_col, {
			virt_text = { { string.rep(char, width), hl } },
			virt_text_pos = "overlay",
		})
	end

	if current_tool_state.bg then
		append_color(
			"bg",
			current_tool_state.bg.val,
			{ bg = current_tool_state.bg.val },
			toolbar_config.char.current_color.bg
		)
	end

	if current_tool_state.fg then
		append_color(
			"fg",
			current_tool_state.fg.val,
			{ fg = current_tool_state.fg.val },
			toolbar_config.char.current_color.fg
		)
	end
end

function Workspace:use_current_tool()
	local config = require "neoart.config"

	local tool_implementation = config.actions[self.state.current.action_name]

	if not (tool_implementation and self.state.current.is_active) then return end

	local current_state, prev_state = self.state.current, self.state.prev

	local pos = current_state.pos

	local moved_horizontally = prev_state.pos.col ~= pos.col

	local positions = {}

	if prev_state.is_active then
		---If the tool remained active across cursor movement, it should be applied
		---to every cell along the path between the previous and current positions
		if not moved_horizontally then
			local step = pos.row <= prev_state.pos.row and -1 or 1

			for row = prev_state.pos.row, pos.row, step do
				table.insert(positions, { row = row, col = pos.col })
			end
		else
			local step = pos.col <= prev_state.pos.col and -1 or 1

			for col = prev_state.pos.col, pos.col, step do
				table.insert(positions, { row = pos.row, col = col })
			end
		end
	else
		table.insert(positions, pos)
	end

	local cells_to_change = {}

	for _, p in ipairs(positions) do
		vim.list_extend(
			cells_to_change,
			tool_implementation.use(self.state.current.toolset[self.state.current.action_name], p)
		)
	end

	if #cells_to_change > 0 then self:refresh_canvas(cells_to_change) end
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

function Workspace:refresh_canvas(cells_changed)
	local canvas_buf_id = self.ids.canvas_buf

	for _, cell_data in ipairs(cells_changed) do
		local cell = self.canvas[cell_data.y][cell_data.x]

		cell.bg = cell_data.bg
		cell.fg = cell_data.fg
		cell.char = cell_data.char
		local hl = (cell.bg and cell.fg) and get_bg_hl(cell.bg, cell.fg) or "Normal"

		if cell.mark_id then
			vim.api.nvim_buf_del_extmark(canvas_buf_id, self.ids.namespace, cell.mark_id)
		end

		cell.mark_id = vim.api.nvim_buf_set_extmark(
			canvas_buf_id,
			self.ids.namespace,
			cell_data.y - 1,
			cell_data.x - 1,
			{
				virt_text = { { cell.char, hl } },
				virt_text_pos = "overlay",
			}
		)
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
		ids = {
			canvas_buf = create_buf(),
			toolbar_buf = create_buf(),
			namespace = vim.api.nvim_create_namespace "neoart",
		},
		state = {
			prev = {
				pos = {

					col = vim.api.nvim_win_get_cursor(0)[2] + 1,
					row = vim.api.nvim_win_get_cursor(0)[1],
				},
				is_active = false,
			},
			current = {
				pos = {
					col = vim.api.nvim_win_get_cursor(0)[2] + 1,
					row = vim.api.nvim_win_get_cursor(0)[1],
				},
				action_name = config.default_tool,
				toolset = {},
				is_active = false,
			},
		},
	}, Workspace)

	new_workspace.canvas =
		create_canvas(cols, rows, config.canvas.fill, new_workspace.ids.canvas_buf)

	---Setups the toolbar
	vim.cmd "topleft split"
	vim.api.nvim_win_set_buf(0, new_workspace.ids.toolbar_buf)
	vim.cmd "resize 4"
	vim.cmd "wincmd j" ---Goes down to the canvas

	vim.api.nvim_win_set_buf(0, new_workspace.ids.canvas_buf)
	vim.api.nvim_set_current_buf(new_workspace.ids.canvas_buf)

	for action_name, tool_opts in pairs(config.actions) do
		local is_tool = tool_opts.starter_state ~= nil

		if is_tool then
			new_workspace.state.current.toolset[action_name] = vim.deepcopy(tool_opts.starter_state)
			new_workspace:set_canvas_keymap(tool_opts.keymap, function()
				new_workspace.state.current.action_name = action_name
				new_workspace.state.current.is_active = false
				new_workspace.state.prev.is_active = false
			end)
		else
			new_workspace:set_canvas_keymap(
				tool_opts.keymap,
				function() tool_opts.use(new_workspace) end
			)
		end
	end

	vim.api.nvim_create_autocmd("CursorMoved", {
		buf = new_workspace.ids.canvas_buf,
		callback = function()
			local state = new_workspace.state

			state.prev = {
				pos = state.current.pos,
				is_active = state.current.is_active,
			}

			local current_cursor_pos = {
				col = vim.api.nvim_win_get_cursor(0)[2] + 1,
				row = vim.api.nvim_win_get_cursor(0)[1],
			}

			state.current.pos = current_cursor_pos

			new_workspace:use_current_tool()
		end,
	})

	new_workspace:refresh_canvas {}
	new_workspace:refresh_toolbar()

	return new_workspace
end

return Workspace
