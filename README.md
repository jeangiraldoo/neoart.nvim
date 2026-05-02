<!-- markdownlint-disable-next-line MD033 MD041 -->
<div align="center">

![Neoart is built with lua](https://img.shields.io/badge/%20Lua-%23D0B8EB?style=for-the-badge&logo=lua)
![When was the last commit made](https://img.shields.io/github/last-commit/jeangiraldoo/neoart.nvim?style=for-the-badge&labelColor=%232E3A59&color=%23A6D8FF)
![Neovim version 0.12+](https://img.shields.io/badge/v0.12%2B-%238BD5CA?style=for-the-badge&logo=neovim&label=Neovim&labelColor=%232E3A59&color=%238BD5CA)
![Neovim is under the GPL 3.0 License](https://img.shields.io/badge/GPL3.0-%232E3A59?style=for-the-badge&label=License&labelColor=%232E3A59&color=%23F4A6A6)
![Repository size](https://img.shields.io/github/repo-size/jeangiraldoo/neoart.nvim?style=for-the-badge&logo=files&logoColor=yellow&label=SIZE&labelColor=%232E3A59&color=%23A8D8A1)

# neoart.nvim

</div>

> I can't think of anything more rewarding than being able to express yourself to
> others through painting. Exercising the imagination, experimenting with talents,
> being creative; these things, to me, are truly the windows to your soul.
> -- Bob Ross

<!-- markdownlint-disable-next-line MD033 MD041 -->
<div align="center">

A creative environment for painting, making ASCII art, or whiteboard-style drawing.

</div>

## Table of contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)

## Features

- Create canvases with specific dimensions
- Use any character to draw
- Use any of the [available tools](#tools) or define new ones
- Combine tools with the usual vim navigation motions

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
| `pencil` | Draws a `size × size` block of characters | `i`    | `size = 1`, `char = " "` |
| `eraser` | Replaces a `size × size` area with spaces | `e`    | `size = 1`               |

### Working with state

It is possible to modify the current tool’s state through functions triggered
by specific keymaps.

The following keymaps are predefined:

| Keymap | Description                                                                  |
| ------ | ---------------------------------------------------------------------------- |
| `tp`   | Open the character picker and set the selected character for the active tool |
| `zb`   | Increases the tool size (covers a larger area while moving)                  |
| `ty`   | Set the foreground or background color of the active tool                    |
| `tx`   | Eyedropper: sample color under the cursor and reuse it                       |

### Saving the canvas to a file

Press `w` to save the canvas. You will be prompted for a file name, and the file
will created in Neovim's current working directory.

You can save in the following formats:

- Plain text: Writes only the characters from the canvas to the file, discarding
  any color information.

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

        fill = { -- Default values used to initialize each cell
            char = " ", -- Character assigned to every cell on creation
            color = { -- Default colors applied to each cell
                fg = "",
                bg = "",
            },
        },
    },
    toolbar = { -- Toolbar options
        char = {
            tool_active = "↓", -- Character appended to the tool name when active
            current_color = { -- Characters for the current bg and fg blocks
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
            save = "w",
            state_handlers = {
                char = "tp",
                size = "zb",
                color = "ty",
                eyedropper = "tx",
            },
        },
        impls = { -- Maps tool names to their implementation functions
            -- See ./config/tools/ for tool implementations
        }
    },
    chars = {
        -- Each string is a group of related characters
        -- Each group is displayed in a separate line when using the character picker
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
```
