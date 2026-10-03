local progress = require("fidget.progress")

local M = {}

function M:init()
  local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequestStarted",
    group = group,
    callback = function(request)
      local handle = M:create_progress_handle(request)
      M:store_progress_handle(request.data.id, handle)
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequestFinished",
    group = group,
    callback = function(request)
      local handle = M:pop_progress_handle(request.data.id)
      if handle then
        M:report_exit_status(handle, request)
        handle:finish()
      end
    end,
  })
end

M.handles = {}

function M:store_progress_handle(id, handle)
  M.handles[id] = handle
end

function M:pop_progress_handle(id)
  local handle = M.handles[id]
  M.handles[id] = nil
  return handle
end

function M:create_progress_handle(request)
  -- Handle nil strategy with fallback
  local strategy = request.data.strategy or "unknown"
  local adapter_name = request.data.adapter and request.data.adapter.formatted_name or "unknown"
  
  return progress.handle.create({
    title = "󰭻 Requesting assistance (" .. strategy .. ")",
    message = "In progress...",
    lsp_client = {
      name = M:llm_role_title(request.data.adapter),
    },
  })
end

function M:llm_role_title(adapter)
  if not adapter then
    return "unknown"
  end
  
  local parts = {}
  table.insert(parts, adapter.formatted_name or "unknown")
  if adapter.model and adapter.model ~= "" then
    table.insert(parts, "(" .. adapter.model .. ")")
  end
  return table.concat(parts, " ")
end

function M:report_exit_status(handle, request)
  if request.data.status == "success" then
    handle.message = "Completed"
  elseif request.data.status == "error" then
    handle.message = "󰅙 Error"
  else
    handle.message = "󰜺 Cancelled"
  end
end

return M
