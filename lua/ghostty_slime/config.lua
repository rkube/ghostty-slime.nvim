local M = {}

M.defaults = {
  cell_delimiter = "# %%",

  keymaps = {
    attach         = "<leader>ra",
    detach         = false,
    send_line      = "<leader>rl",
    send_cell      = "<leader>rc",
    send_selection = "<leader>rs",
    send_file      = "<leader>rF",
    focus          = "<leader>rj",
  },

  clear_state_on_exit = true,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
