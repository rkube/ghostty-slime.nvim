# ghostty-slime.nvim

Send code from Neovim to a REPL running in a [Ghostty](https://ghostty.org) terminal. Language-agnostic: works with any interactive process (Julia, IPython, R, ghci, the shell, …) — you start the REPL however you like, then attach Neovim to it.

A minimal, zero-dependency alternative to [vim-slime](https://github.com/jpalardy/vim-slime) for Ghostty users on macOS.

## Features

- Attach to any Ghostty terminal you've already opened (tab or split, your choice of flags and working directory)
- Send current line, visual selection, code cell (`# %%` delimited), or entire file
- Multiline code is delivered via Ghostty's `input text` AppleScript command; REPLs that handle line continuation (Julia, IPython, ghci, …) see it as a coherent block
- Focus returns to Neovim automatically after each send
- Configurable keymaps; disable any binding by setting it to `false`
- No interpreter detection, no clipboard interference, no auto-launch

## Requirements

- **macOS** (uses AppleScript via `osascript`)
- **[Ghostty](https://ghostty.org)** terminal emulator

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ralphkube/ghostty-slime.nvim",
  enabled = vim.fn.has("mac") == 1,
  opts = {},
}
```

## Usage

1. Open Ghostty. In one tab, run Neovim. In another tab (or split), start whatever REPL you want — `julia --project=.`, `ipython`, `R`, `ghci`, `bash`, anything.
2. In Neovim, run `:GhosttySlimeAttach` (or `<leader>ra`). A picker lists all your Ghostty terminals by name and working directory. Choose the REPL.
3. Mark code and send it with the keymaps below.

If you close the REPL, just reopen one and re-attach.

## Default keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>ra` | Normal | Attach to focused Ghostty terminal |
| `<leader>rl` | Normal | Send current line |
| `<leader>rc` | Normal | Send current cell |
| `<leader>rs` | Visual | Send selection |
| `<leader>rF` | Normal | Send entire file |
| `<leader>rj` | Normal | Jump to (focus) the attached REPL |

All keymaps are customizable; set any to `false` to disable it.

## Commands

| Command | Description |
|---|---|
| `:GhosttySlimeAttach` | Attach to the currently focused Ghostty terminal |
| `:GhosttySlimeDetach` | Forget the current attachment |
| `:GhosttySlimeSend {line\|cell\|selection\|file}` | Send code to the attached terminal |
| `:GhosttySlimeFocus` | Focus the attached terminal |
| `:GhosttySlimeStatus` | Show whether a terminal is attached and whether it still exists |

## Configuration

All options with their defaults:

```lua
require("ghostty_slime").setup({
  -- Cell delimiter used by send_cell to find the surrounding block
  cell_delimiter = "# %%",

  -- Keymaps. Set any value to `false` to disable that binding.
  keymaps = {
    attach         = "<leader>ra",
    detach         = false,
    send_line      = "<leader>rl",
    send_cell      = "<leader>rc",
    send_selection = "<leader>rs",
    send_file      = "<leader>rF",
    focus          = "<leader>rj",
  },

  -- Forget the attached terminal on VimLeavePre. Never kills the REPL itself.
  clear_state_on_exit = true,
})
```

## Code cells

Cells are delimited by `# %%` comments (configurable via `cell_delimiter`):

```julia
# %% Setup
using DataFrames
df = DataFrame(x = 1:10)

# %% Analysis
describe(df)
```

Put the cursor anywhere in a cell and press `<leader>rc` to send just that cell.

## How it works

1. `:GhosttySlimeAttach` enumerates all Ghostty terminals via AppleScript (`name` + `working directory`) and lets you pick one. The current terminal (running Neovim) is excluded.
2. On send, the plugin extracts text from the buffer and uses Ghostty's `input text` AppleScript command to deliver it to the attached terminal, followed by an Enter keystroke. Multi-line code is delivered line by line; REPLs with line-continuation logic (Julia, IPython, etc.) buffer and execute the block correctly.
3. Focus returns to the terminal you sent from.

The plugin never launches or kills your REPL, and never touches your clipboard. You own both.

## License

MIT
