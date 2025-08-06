-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Completely disable LSP didSave handlers - this is the main culprit
vim.lsp.handlers["textDocument/didSave"] = function() end

-- Monitor and clean up LSP save handlers after every save
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    -- Get all autocmds
    local autocmds = vim.api.nvim_get_autocmds({ event = "BufWritePost" })

    -- Find and delete ALL LSP save handlers
    for _, autocmd in ipairs(autocmds) do
      if autocmd.group_name and autocmd.group_name:match("^nvim_lsp_b_%d+_save$") then
        pcall(vim.api.nvim_del_augroup_by_name, autocmd.group_name)
      end
    end
  end,
})

-- Prevent LSP save handlers from being created at all
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      -- Disable save synchronization entirely
      if client.server_capabilities.textDocumentSync then
        if type(client.server_capabilities.textDocumentSync) == "table" then
          client.server_capabilities.textDocumentSync.save = false
        end
      end
    end

    -- Schedule deletion of any save handlers that might have been created
    local bufnr = args.buf
    vim.defer_fn(function()
      pcall(vim.api.nvim_del_augroup_by_name, "nvim_lsp_b_" .. bufnr .. "_save")
    end, 100)
  end,
})

-- Optional: Monitor autocmd count
vim.api.nvim_create_user_command("CheckAutocmds", function()
  local autocmds = vim.api.nvim_get_autocmds({ event = "BufWritePost" })
  local lsp_count = 0
  for _, autocmd in ipairs(autocmds) do
    if autocmd.group_name and autocmd.group_name:match("^nvim_lsp_b_%d+_save$") then
      lsp_count = lsp_count + 1
    end
  end
  print("Total BufWritePost autocmds:", #autocmds)
  print("LSP save handlers:", lsp_count)
end, {})
