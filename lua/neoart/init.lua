local Neoart = {}

---@param canvas_dimensions { cols: number?, rows: number? }?
function Neoart.create_canvas(canvas_dimensions)
	vim.validate("dimensions", canvas_dimensions, "table", true)
	if canvas_dimensions then
		vim.validate("dimensions.cols", canvas_dimensions.cols, "number", true)
		vim.validate("dimensions.rows", canvas_dimensions.rows, "number", true)
	end

	local config = require "neoart.config"
	local Workspace = require "neoart.workspace"

	Workspace.new(canvas_dimensions or config.default_dimensions)
end

return Neoart
