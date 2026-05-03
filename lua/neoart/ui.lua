local UI = {}
UI.__index = UI

local function center(str, width)
	local display_len = vim.fn.strdisplaywidth(str)
	if display_len >= width then return str end

	local total_pad = width - display_len
	local left_pad = math.floor(total_pad / 2)
	local right_pad = total_pad - left_pad

	return (" "):rep(left_pad) .. str .. (" "):rep(right_pad)
end

function UI:refresh_toolbar(state)
	local toolbar_config = require("neoart.config").toolbar
	local char_config = toolbar_config.char

	local buf = self.ids.toolbar
	local ns = self.ids.namespace

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local current_tool_state = state.current.toolset[state.current.tool_name]

	local tool_position = (
		state.current.is_active and char_config.tool_active or char_config.tool_inactive
	)

	local first_line, second_line
	do
		local tool = state.current.tool_name .. tool_position
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
function UI:set_canvas_keymap(keymap, callback)
	vim.keymap.set("n", keymap, function() callback() end, { buf = self.ids.canvas })
end
local function create_buf()
	local buf_id = vim.api.nvim_create_buf(false, true)

	vim.bo[buf_id].buftype = "nofile"
	vim.bo[buf_id].bufhidden = "hide"
	vim.bo[buf_id].swapfile = false

	vim.api.nvim_win_set_buf(0, buf_id)

	return buf_id
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

function UI:refresh(cells_changed)
	local canvas_buf_id = self.ids.canvas

	for _, cell_data in ipairs(cells_changed) do
		local cell = self.matrix[cell_data.y][cell_data.x]

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

function UI:is_canvas_pos_valid(pos)
	vim.validate("pos", pos, "table")
	vim.validate("pos.x", pos.x, "number")
	vim.validate("pos.y", pos.y, "number")

	local is_cell_pos_valid = pos.y > #self.canvas or pos.x > #self.canvas[1]

	return not is_cell_pos_valid
end

function UI:refresh_canvas(cells_changed)
	local canvas_buf_id = self.ids.canvas

	for _, cell_data in ipairs(cells_changed) do
		if not self:is_canvas_pos_valid { x = cell_data.x, y = cell_data.y } then goto skip end

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

		::skip::
	end

	vim.bo[canvas_buf_id].modifiable = true
	vim.api.nvim_win_set_cursor(0, vim.api.nvim_win_get_cursor(0))
end

function UI.new(cols, rows, fill)
	local canvas_buf_id = create_buf()
	local toolbar_buf_id = create_buf()

	---Setups the toolbar
	vim.cmd "topleft split"
	vim.api.nvim_win_set_buf(0, toolbar_buf_id)
	vim.cmd "resize 4"
	vim.cmd "wincmd j" ---Goes down to the canvas

	vim.api.nvim_win_set_buf(0, canvas_buf_id)
	vim.api.nvim_set_current_buf(canvas_buf_id)

	return setmetatable({
		ids = {
			canvas = canvas_buf_id,
			toolbar = toolbar_buf_id,
			namespace = vim.api.nvim_create_namespace "neoart",
		},
		canvas = create_canvas(cols, rows, fill, canvas_buf_id),
	}, UI)
end

return UI
