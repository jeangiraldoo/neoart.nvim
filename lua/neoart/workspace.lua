local Workspace = {}
Workspace.__index = Workspace

function Workspace:use_current_tool()
	local config = require "neoart.config"

	local tool_implementation = config.tools.impls[self.state.current.tool_name]

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
			tool_implementation.use(self.state.current.toolset[self.state.current.tool_name], p)
		)
	end

	if #cells_to_change > 0 then self.ui:refresh_canvas(cells_to_change) end
end

function Workspace:activate_current_tool()
	self.state.current.is_active = true

	---Applies the tool to the current cell; otherwise it runs only after the next cursor movement
	self:use_current_tool()
end

function Workspace.new(dimensions)
	vim.validate("dimensions", dimensions, "table", true)

	local config = require "neoart.config"

	local canvas_config = config.canvas
	local tools_config = config.tools

	local cols = dimensions and dimensions.cols or canvas_config.cols
	local rows = dimensions and dimensions.rows or canvas_config.rows

	local ui = require("neoart.ui").new(cols, rows, canvas_config.fill)
	local new_workspace = setmetatable({
		ui = ui,
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
				tool_name = tools_config.default,
				toolset = {},
				is_active = false,
			},
		},
	}, Workspace)

	local KEYS = {
		activate = function() new_workspace:activate_current_tool() end,
		deactivate = function() new_workspace.state.current.is_active = false end,
	}

	for key, value in pairs(tools_config.keys) do
		if KEYS[key] and type(value) == "string" then
			new_workspace.ui:set_canvas_keymap(value, function()
				KEYS[key]()
				new_workspace.ui:refresh_toolbar(new_workspace.state)
			end)
		end
	end

	for name, keymap in pairs(tools_config.keys.state_handlers) do
		new_workspace.ui:set_canvas_keymap(keymap, function()
			local thing = tools_config.impls[new_workspace.state.current.tool_name]
			local state_handlers = thing.state_handlers

			if state_handlers[name] then
				state_handlers[name](
					new_workspace.state.current.toolset[new_workspace.state.current.tool_name],
					function() new_workspace.ui:refresh_toolbar(new_workspace.state) end,
					new_workspace.ui.canvas
				)
			end
		end)
	end

	for key, value in pairs(tools_config.impls) do
		new_workspace.state.current.toolset[key] = vim.deepcopy(value.starter_state)
		new_workspace.ui:set_canvas_keymap(value.keymap, function()
			new_workspace.state.current.tool_name = key
			new_workspace.ui:refresh_toolbar(new_workspace.state)
		end)
	end

	vim.api.nvim_create_autocmd("CursorMoved", {
		buf = new_workspace.ui.ids.canvas,
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

	new_workspace.ui:refresh_canvas {}
	new_workspace.ui:refresh_toolbar(new_workspace.state)

	return new_workspace
end

return Workspace
