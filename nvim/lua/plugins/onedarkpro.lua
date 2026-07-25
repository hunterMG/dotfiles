-- ~/.config/nvim/lua/plugins/onedarkpro.lua
local ok, onedarkpro = pcall(require, "onedarkpro")
if not ok then
  vim.notify("onedarkpro.nvim not found", vim.log.levels.WARN)
  return
end

onedarkpro.setup({
  colors = {
    -- cursorline = "#303040", -- This is optional. The default cursorline color is based on the background
  },
  options = {
    cursorline = true,
  },
  highlights = {
    Comment = { italic = true },
    Directory = { bold = true },
    ErrorMsg = { italic = true, bold = true }
  },
})

-- vim.cmd("colorscheme onedark") -- enable the theme
vim.cmd("colorscheme onedark")

