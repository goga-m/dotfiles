-- load a prompt file as a single string
local function read_prompt(name)
  local path = vim.fn.stdpath("config") .. "/lua/config/codecompanion/prompts/" .. name .. ".txt"
  local content = vim.fn.readfile(path)
  return table.concat(content, "\n")
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  keys = {
    { "<leader>ai", ":CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "AI actions" },
    { "<leader>ac", ":CodeCompanionChat<CR>",    desc = "Open chat" },
  },
  opts = {
    adapters = {
      http = {
        ["llama.cpp"] = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://127.0.0.1:8080", -- remove the trailing space
              -- Remove api_key or set it to nil for local llama.cpp
              -- api_key = "TERM", -- Remove this line
              chat_url = "/v1/chat/completions",
            },
            handlers = {
              parse_message_meta = function(self, data)
                local extra = data.extra
                if extra and extra.reasoning_content then
                  data.output.reasoning = { content = extra.reasoning_content }
                  if data.output.content == "" then
                    data.output.content = nil
                  end
                end
                return data
              end,
            },
          })
        end,
      },
    },
    strategies = {
      chat = {
        adapter = "llama.cpp",
      },
      inline = {
        adapter = "llama.cpp",
      },
      cmd = {
        adapter = "llama.cpp",
      },
    },
    prompt_library = {
      ["Add JSDoc"] = {
        strategy = "inline",
        description = "Add JSDoc documentation to the selected function",
        opts = {
          index = 1,
          is_slash_cmd = true,
          auto_submit = true,
          short_name = "jsdoc",
          placement = "replace",
        },
        prompts = {
          { role = "system", content = read_prompt("add_jsdoc") },
          { role = "user",   content = "Add JSDoc to this function:\n\n#{selection}" },
        },
      },
    },
  },
  init = function()
      -- Make sure the path matches your file structure
      require("plugins.codecompanion.fidget-spinner"):init()
    end,
}
