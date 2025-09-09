-- Close all buffers except the current one
vim.api.nvim_create_user_command('BufOnly', function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
      if buftype ~= 'terminal' then
        vim.api.nvim_buf_delete(buf, { force = false })
      end
    end
  end
end, { desc = 'Close all buffers except current' })