# ghostty-slime.nvim

Send code from Neovim to a REPL running in another [Ghostty](https://ghostty.org) terminal. Pick the target REPL from a list of your open Ghostty terminals, then send lines, visual selections, code cells, or whole files to it.

A minimal, macOS-only alternative to [vim-slime](https://github.com/jpalardy/vim-slime) for Ghostty users. Language-agnostic — works with Julia, IPython, R, ghci, your shell, or anything that runs in a terminal. 

## Requirements

- macOS (uses AppleScript via `osascript`)
- [Ghostty](https://ghostty.org)
- Neovim 0.7+

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim) — minimal:

```lua
{
  "rkube/ghostty-slime.nvim",
  enabled = vim.fn.has("mac") == 1,
  event = "VeryLazy",
  opts = {},
}
```

With customization (all defaults shown):

```lua
{
  "rkube/ghostty-slime.nvim",
  enabled = vim.fn.has("mac") == 1,
  event = "VeryLazy",
  opts = {
    -- Cell delimiter for send_cell
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

    -- Forget the attached terminal on VimLeavePre. Never kills the REPL.
    clear_state_on_exit = true,
  },
}
```

## Usage

1. Open Ghostty. Run Neovim in one tab. In another tab (or split), start your REPL — `julia --project=.`, `ipython`, `R`, whatever.
2. From Neovim, run `:GhosttySlimeAttach` (or `<leader>ra`). A picker lists your open Ghostty terminals; choose the REPL.
3. Send code with the keymaps below. Focus returns to Neovim automatically.

If you close the REPL, open a new one and re-attach.

## Default keymaps

| Key          | Mode   | Action                          |
| ------------ | ------ | ------------------------------- |
| `<leader>ra` | Normal | Pick a Ghostty terminal to attach to |
| `<leader>rl` | Normal | Send current line               |
| `<leader>rc` | Normal | Send current cell               |
| `<leader>rs` | Visual | Send selection                  |
| `<leader>rF` | Normal | Send entire file                |
| `<leader>rj` | Normal | Focus the attached REPL         |

## Commands

| Command                                            | Description                                |
| -------------------------------------------------- | ------------------------------------------ |
| `:GhosttySlimeAttach`                              | Pick a Ghostty terminal to attach to       |
| `:GhosttySlimeDetach`                              | Forget the current attachment              |
| `:GhosttySlimeSend {line\|cell\|selection\|file}`  | Send code to the attached terminal         |
| `:GhosttySlimeFocus`                               | Focus the attached terminal                |
| `:GhosttySlimeStatus`                              | Show whether a terminal is attached        |

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

## Tip: nicer attach picker

The attach picker uses `vim.ui.select`. With the default handler it's a numbered list. If you have [fzf-lua](https://github.com/ibhagwan/fzf-lua), [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim), or [dressing.nvim](https://github.com/stevearc/dressing.nvim), the picker becomes fuzzy-searchable — usually a one-liner in their config (e.g. `require("fzf-lua").register_ui_select()`).

## How it works

`:GhosttySlimeAttach` enumerates Ghostty terminals via AppleScript (`name` + `working directory`) and lets you pick one; your current Neovim terminal is excluded so you can't accidentally send to yourself. On send, the plugin extracts text from the buffer and uses Ghostty's `input text` AppleScript command to deliver it to the attached terminal, followed by Enter. Multi-line code is delivered line by line; REPLs with continuation logic (Julia, IPython, ghci) execute the block correctly.

The plugin never launches your REPL, never kills it, and never touches your clipboard. You own the REPL lifecycle.

## Acknowledgments

This plugin started as a rewrite of [stellarjmr/ghostty-repl.nvim](https://github.com/stellarjmr/ghostty-repl.nvim), which pioneered the AppleScript-driven Neovim ↔ Ghostty integration for Python/IPython. The `text.lua` extraction module and the osascript helpers here are direct descendants of that work. Thanks to stellarjmr for figuring out the hard parts first.

## License

MIT
