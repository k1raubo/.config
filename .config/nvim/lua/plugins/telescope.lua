return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = { preview_width = 0.55 },
        },
      },
    })

    -- Skróty klawiszowe
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep w plikach" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Otwarte bufory" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Pomoc / dokumentacja" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Ostatnio otwierane" })
  end,
}
