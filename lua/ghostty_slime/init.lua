local M = {}

local config = require("ghostty_slime.config")
local terminal = require("ghostty_slime.terminal")
local text = require("ghostty_slime.text")

local SEND_KINDS = { "line", "cell", "selection", "file" }

local function format_terminal(t)
  local label = t.name ~= "" and t.name or "(unnamed)"
  if t.cwd ~= "" then
    label = label .. "  [" .. t.cwd .. "]"
  end
  return label
end

function M.attach()
  local terminals, err = terminal.list_terminals()
  if not terminals then
    vim.notify("ghostty-slime: " .. (err or "could not list terminals"), vim.log.levels.ERROR)
    return
  end

  local self_id = terminal.focused_terminal_id()
  local choices = {}
  for _, t in ipairs(terminals) do
    if t.id ~= self_id then
      table.insert(choices, t)
    end
  end

  if #choices == 0 then
    vim.notify("ghostty-slime: no other Ghostty terminals found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(choices, {
    prompt = "Attach ghostty-slime to:",
    format_item = format_terminal,
  }, function(choice)
    if not choice then
      return
    end
    terminal.set_repl_id(choice.id)
    vim.notify("ghostty-slime: attached to " .. format_terminal(choice), vim.log.levels.INFO)
  end)
end

function M.detach()
  terminal.detach()
  vim.notify("ghostty-slime: detached", vim.log.levels.INFO)
end

function M.send(kind)
  local code = text.get(kind)
  if code == nil then
    vim.notify("ghostty-slime: unsupported send kind: " .. tostring(kind), vim.log.levels.ERROR)
    return
  end
  if code == "" then
    return
  end

  local ok, err = terminal.send(code)
  if ok then
    return
  end

  if err == "no_attachment" then
    vim.notify(
      "ghostty-slime: no terminal attached. Focus your REPL and run :GhosttySlimeAttach.",
      vim.log.levels.WARN
    )
  elseif err == "attachment_gone" then
    vim.notify(
      "ghostty-slime: attached terminal no longer exists. Re-attach with :GhosttySlimeAttach.",
      vim.log.levels.WARN
    )
  elseif err == "no_source" then
    vim.notify("ghostty-slime: could not read focused Ghostty terminal", vim.log.levels.ERROR)
  else
    vim.notify("ghostty-slime: send failed: " .. (err or ""), vim.log.levels.ERROR)
  end
end

function M.focus()
  local id = terminal.get_repl_id()
  if id and terminal.terminal_exists(id) then
    terminal.focus_terminal(id)
  else
    vim.notify("ghostty-slime: no attached terminal", vim.log.levels.WARN)
  end
end

function M.status()
  local id = terminal.get_repl_id()
  if not id then
    vim.notify("ghostty-slime: not attached", vim.log.levels.INFO)
  elseif terminal.terminal_exists(id) then
    vim.notify("ghostty-slime: attached to " .. id, vim.log.levels.INFO)
  else
    vim.notify("ghostty-slime: attached terminal " .. id .. " is gone", vim.log.levels.WARN)
  end
end

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("GhosttySlimeAttach", function()
    M.attach()
  end, { desc = "Attach to the currently focused Ghostty terminal" })

  vim.api.nvim_create_user_command("GhosttySlimeDetach", function()
    M.detach()
  end, { desc = "Detach from the Ghostty terminal" })

  vim.api.nvim_create_user_command("GhosttySlimeSend", function(cmd_opts)
    M.send(cmd_opts.args)
  end, {
    nargs = 1,
    complete = function()
      return SEND_KINDS
    end,
    desc = "Send code to the attached Ghostty terminal",
  })

  vim.api.nvim_create_user_command("GhosttySlimeFocus", function()
    M.focus()
  end, { desc = "Focus the attached Ghostty terminal" })

  vim.api.nvim_create_user_command("GhosttySlimeStatus", function()
    M.status()
  end, { desc = "Show ghostty-slime attachment status" })

  local km = config.options.keymaps
  if km.attach then
    vim.keymap.set("n", km.attach, function()
      M.attach()
    end, { desc = "Ghostty Slime Attach", silent = true })
  end
  if km.detach then
    vim.keymap.set("n", km.detach, function()
      M.detach()
    end, { desc = "Ghostty Slime Detach", silent = true })
  end
  if km.send_line then
    vim.keymap.set("n", km.send_line, function()
      M.send("line")
    end, { desc = "Ghostty Slime Send Line", silent = true })
  end
  if km.send_cell then
    vim.keymap.set("n", km.send_cell, function()
      M.send("cell")
    end, { desc = "Ghostty Slime Send Cell", silent = true })
  end
  if km.send_selection then
    vim.keymap.set(
      "x",
      km.send_selection,
      ":<C-u>lua require('ghostty_slime').send('selection')<CR>",
      { desc = "Ghostty Slime Send Selection", silent = true }
    )
  end
  if km.send_file then
    vim.keymap.set("n", km.send_file, function()
      M.send("file")
    end, { desc = "Ghostty Slime Send File", silent = true })
  end
  if km.focus then
    vim.keymap.set("n", km.focus, function()
      M.focus()
    end, { desc = "Ghostty Slime Focus REPL", silent = true })
  end

  if config.options.clear_state_on_exit then
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        terminal.detach()
      end,
    })
  end
end

return M
