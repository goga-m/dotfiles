-- Fixes issues with indent-blankline error throwing when opening files
-- https://github.com/lukas-reineke/indent-blankline.nvim/discussions/692
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  commit = "29be0919b91fb59eca9e90690d76014233392bef",
}
