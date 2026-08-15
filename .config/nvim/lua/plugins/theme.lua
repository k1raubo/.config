return {
  "nyoom-engineering/oxocarbon.nvim",
  build = false,
  config = function()
    vim.opt.background = "dark"
    vim.cmd("colorscheme oxocarbon")
  end,
}