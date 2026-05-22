local M = {}

local state = {
  repl_id = nil,
}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function run_osascript(script, args)
  local cmd = { "osascript", "-" }
  for _, arg in ipairs(args or {}) do
    table.insert(cmd, arg)
  end
  local output = vim.fn.system(cmd, script)
  local ok = vim.v.shell_error == 0
  return ok, trim(output)
end

function M.focused_terminal_id()
  local ok, output = run_osascript([[
tell application "Ghostty"
  return id of focused terminal of selected tab of front window
end tell
]])
  if not ok or output == "" then
    return nil
  end
  return output
end

function M.terminal_exists(terminal_id)
  if not terminal_id or terminal_id == "" then
    return false
  end

  local ok, output = run_osascript([[
on run argv
  set targetId to item 1 of argv
  tell application "Ghostty"
    try
      set targetTerm to first terminal whose id is targetId
      return "1"
    on error
      return "0"
    end try
  end tell
end run
]], { terminal_id })
  return ok and output == "1"
end

function M.focus_terminal(terminal_id)
  if not terminal_id or terminal_id == "" then
    return false
  end
  return run_osascript([[
on run argv
  set targetId to item 1 of argv
  tell application "Ghostty"
    focus (first terminal whose id is targetId)
  end tell
end run
]], { terminal_id })
end

function M.list_terminals()
  local ok, output = run_osascript([[
set sepChar to (ASCII character 9)
tell application "Ghostty"
  set out to ""
  repeat with t in terminals
    set out to out & (id of t) & sepChar & (name of t) & sepChar & (working directory of t) & linefeed
  end repeat
  return out
end tell
]])
  if not ok then
    return nil, output
  end

  local terminals = {}
  for line in (output .. "\n"):gmatch("([^\n]+)\n") do
    local id, name, cwd = line:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then
      table.insert(terminals, { id = id, name = name or "", cwd = cwd or "" })
    end
  end
  return terminals
end

function M.set_repl_id(id)
  state.repl_id = id
end

function M.detach()
  state.repl_id = nil
end

function M.get_repl_id()
  return state.repl_id
end

function M.is_attached()
  return state.repl_id ~= nil and M.terminal_exists(state.repl_id)
end

local function send_to_terminal(source_id, repl_id, payload)
  return run_osascript([[
on run argv
  set sourceId to item 1 of argv
  set replId to item 2 of argv
  set payload to item 3 of argv
  tell application "Ghostty"
    set replTerm to first terminal whose id is replId
    input text payload to replTerm
    send key "enter" to replTerm
    focus (first terminal whose id is sourceId)
  end tell
end run
]], { source_id, repl_id, payload })
end

function M.send(text)
  if not state.repl_id then
    return false, "no_attachment"
  end

  if not M.terminal_exists(state.repl_id) then
    state.repl_id = nil
    return false, "attachment_gone"
  end

  local source_id = M.focused_terminal_id()
  if not source_id then
    return false, "no_source"
  end

  local payload = text
  if payload:sub(-1) == "\n" then
    payload = payload:sub(1, -2)
  end

  local ok, err = send_to_terminal(source_id, state.repl_id, payload)
  if not ok then
    return false, err
  end
  return true
end

return M
