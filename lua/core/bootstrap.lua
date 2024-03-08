local M = {}
local fn = vim.fn

M.echo = function(str)
  vim.cmd "redraw"
  vim.api.nvim_echo({ { str, "Bold" } }, true, {})
end

-- Remove the shell_call function since we won't be using it
-- local function shell_call(args)
--     local output = fn.system(args)
--     assert(vim.v.shell_error == 0, "External call failed with error code: " .. vim.v.shell_error .. "\n" .. output)
-- end

M.lazy = function(install_path)
  ------------- base46 ---------------
  local lazy_path = fn.stdpath "data" .. "/lazy/base46"

  M.echo "  Compiling base46 theme to bytecode ..."

  local base46_repo = "https://github.com/NvChad/base46"
  shell_call { "git", "clone", "--depth", "1", "-b", "v2.0", base46_repo, lazy_path }
  vim.opt.rtp:prepend(lazy_path)

  require("base46").compile()

M.echo " Installing lazy.nvim & plugins ..."

local repo = "https://github.com/folke/lazy.nvim.git"
local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Use the :!git clone command instead of shell_call
vim.cmd(string.format("!git clone --filter=blob:none --branch=stable %s %s", repo, install_path))

-- Add the lazy.nvim path to the runtime path
vim.opt.rtp:prepend(install_path)

  -- install plugins
  require "plugins"

  -- mason packages & show post_bootstrap screen
  require "nvchad.post_install"()
end

M.gen_chadrc_template = function()
  local path = fn.stdpath "config" .. "/lua/custom"

  if fn.isdirectory(path) ~= 1 then
    local input = vim.env.NVCHAD_EXAMPLE_CONFIG or fn.input "Do you want to install example custom config? (y/N): "

    if input:lower() == "y" then
      M.echo "Cloning example custom config repo..."
      shell_call { "git", "clone", "--depth", "1", "https://github.com/NvChad/example_config", path }
      fn.delete(path .. "/.git", "rf")
    else
      -- use very minimal chadrc
      fn.mkdir(path, "p")

      local file = io.open(path .. "/chadrc.lua", "w")
      if file then
        file:write "---@type ChadrcConfig\nlocal M = {}\n\nM.ui = { theme = 'onedark' }\n\nreturn M"
        file:close()
      end
    end
  end
end

return M
