return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff branch vs main" },
    { "<leader>gM", "<cmd>DiffviewFileHistory --range=origin/main...HEAD<cr>", desc = "Branch commits vs main" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
  },
}
