local Health = {}

local NEOVIM_VERSION = {
	MINIMUM = "0.12",
	ACTUAL = vim.version(),
}

local function _check_neovim_version()
	vim.health.start "Neovim version"

	local version_str = string.format(
		"%d.%d.%d (Minimum: %s)",
		NEOVIM_VERSION.ACTUAL.major,
		NEOVIM_VERSION.ACTUAL.minor,
		NEOVIM_VERSION.ACTUAL.patch,
		NEOVIM_VERSION.MINIMUM
	)

	if vim.fn.has("nvim-" .. NEOVIM_VERSION.MINIMUM) == 0 then
		vim.health.error(version_str)
		return
	end

	vim.health.ok(version_str)
end

function Health.check() _check_neovim_version() end

return Health
