# Repository Guidelines

## Project Structure & Module Organization
- Core logic lives in `lua/ghostty_slime/`:
  - `init.lua` wires user commands, keymaps, and the VimLeavePre autocmd.
  - `terminal.lua` holds all AppleScript/Ghostty interaction and the attached-terminal state machine.
  - `text.lua` extracts code from buffers (line / visual selection / cell / file). Pure — no system calls.
  - `config.lua` merges user options with defaults.
- Neovim plugin entrypoint is `plugin/ghostty_slime.lua`; load guard only.
- macOS only. Zero external dependencies.

## Design Principles
- **Manual attach, no auto-launch.** The user starts the REPL themselves (any command, any flags, any tab). The plugin never spawns or kills a REPL.
- **Language-agnostic.** No interpreter detection, no per-language config. Sends bytes via bracketed paste; the REPL handles the rest.
- **Side effects isolated.** `text.lua` stays pure. `osascript` calls and autocmds live in `terminal.lua` and `init.lua`.

## Development
- No compile step. Neovim loads `plugin/ghostty_slime.lua` automatically when the plugin is on the `runtimepath`.
- Manual test loop: open Ghostty, start a REPL in one tab/split, run nvim in another, `:GhosttySlimeAttach`, then test each send kind (line / cell / selection / file).
- Test edge cases: empty cell, cursor on delimiter line, single-line vs multiline visual selection, attached terminal closed mid-session.
- Run `stylua` if available; otherwise mirror surrounding formatting (2-space indent, snake_case).

## Commit & Pull Request Guidelines
- Conventional Commit style (`feat:`, `fix:`, `refactor:`, `docs:`).
- Update `README.md` when commands, defaults, or keymaps change.
- Note macOS / Ghostty version in PRs that touch AppleScript templates.
