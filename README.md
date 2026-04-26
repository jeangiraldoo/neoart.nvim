# neoart.nvim

## Table of contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)

## Features

- Create canvases with specific dimensions
- Use any of the [available tools](#tools) or define new ones
- Use any character to draw

## Installation

> [!WARNING]
> Development is done using [Trunk Based Development](https://trunkbaseddevelopment.com),
> meaning all new changes are merged into `main`, making it the equivalent of `nightly`;
> versions are done through Git tags.
>
> All changes are thoroughly tested before merging, but it is still recommended
> to pin to a specific tag unless you wish to be constantly up to date.

Use the snippet for your plugin manager:

### [vim.pack](https://neovim.io/doc/user/pack.html#vim.pack)

```lua
vim.pack.add({
    { src = "https://github.com/jeangiraldoo/neoart.nvim" }
})
```

### [lazy.nvim](http://www.lazyvim.org/)

```lua
{
    "jeangiraldoo/neoart.nvim",
}
```

### [mini.deps](https://github.com/echasnovski/mini.deps)

```lua
require("mini.deps").add({
    source = "jeangiraldoo/neoart.nvim",
})
```

## Usage

### Command

The plugin providess the `:Neoart` command, which accepts the following
arguments:

#### new

Creates a new art workspace consisting of a canvas and a toolbar. The new argument
accepts two optional numeric parameters: the number of columns and rows, respectively.

### Tools

A tool is specific functionality you can access at any moment by pressing a normal
mode keymap.

When a tool is active, its effect is applied to the canvas as you move; otherwise,
movement has no effect. Press `<Space>` to activate it and `<Esc>` to deactivate
it.

The plugin comes with the following built-in tools:

| Name     | Description                               | Keymap | Options (default values) |
| -------- | ----------------------------------------- | ------ | ------------------------ |
| `pencil` | Draws a `size × size` block of characters | `i`    | `size = 1`, `char = "a"` |
| `eraser` | Replaces a `size × size` area with spaces | `e`    | `size = 1`               |

### Working with state

It is possible to modify the workspace state or the current tool’s state through
functions triggered by specific keymaps.

The following keymaps are predefined:

| Keymap    | Description                                                             |
| --------- | ----------------------------------------------------------------------- |
| `<Space>` | Activates the current tool                                              |
| `<Esc>`   | Deactivates the current tool                                            |
| `tp`      | Opens the character picker and sets the selected character for the tool |
| `zb`      | Increases the tool size (covers a larger area while moving)             |

## Configuration

### Defaults

All options can be customized using the setup function. Here are most of the
default options:

```lua
return {
    canvas = { -- Canvas options
        -- Canvas dimensions
        cols = 100,
        rows = 30,

        fill = " ", -- Character to initialize each cell when the canvas is created
    },
    toolbar = { -- Toolbar options
        tool_down_char = "↓", -- Character appended to the tool name when active
    },
    chars = {
        -- See ./config/init.lua for the list of characters
    },
    tools = {
        default = "pencil",
        actions = { -- Maps keymap keys to functions },
        implementations = { -- Maps tool names to their implementation functions
            -- See ./config/tools/ for tool implementations
        }
    },
}
```

## Creating tools
