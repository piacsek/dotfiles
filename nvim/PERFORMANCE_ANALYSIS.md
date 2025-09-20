# Neovim Performance Analysis & Recommendations

*Analysis performed on 2025-09-19*

## Issue
Neovim instance occasionally freezes for a few seconds, causing disruption during editing.

## Root Causes Identified

### 1. LSP Document Highlighting (lua/plugins/lsp.lua:51-61)
- `CursorHold`/`CursorHoldI` autocmds trigger document highlighting on every cursor pause
- Can cause freezing with large files or slow language servers
- Currently runs for ALL files without size restrictions

### 2. ElixirLS Configuration Issues
- `dialyzerEnabled = false` is good, but current settings might still be resource-intensive
- `suggestSpecs = true` can cause additional processing overhead
- ElixirLS is known to be resource-intensive for large Elixir projects

### 3. Telescope Performance in Large Repositories
- Multiple telescope pickers without performance limits
- `hidden = true` searches can be slow in large codebases
- No file ignore patterns or result limits configured

### 4. Aggressive updatetime Setting (lua/core/options.lua:27)
- `updatetime = 250` is very aggressive
- Triggers CursorHold events every 250ms
- Can overwhelm LSP servers and autocmds

## Performance Improvements

### 1. Optimize LSP Settings
```lua
-- In lua/plugins/lsp.lua, modify the ElixirLS config:
elixirls = {
    root_dir = require("lspconfig.util").root_pattern("mix.exs"),
    settings = {
        elixirLS = {
            dialyzerEnabled = false,
            fetchDeps = false,
            enableTestLenses = false,
            suggestSpecs = false,  -- Change from true
            mixEnv = "dev",
            incrementalDialyzer = false,  -- Add this
        },
    },
},
```

### 2. Increase updatetime
```lua
-- In lua/core/options.lua:
vim.opt.updatetime = 500  -- Change from 250
```

### 3. Add Conditional Document Highlighting
```lua
-- In LSP config, replace the document highlighting section:
if client and client.server_capabilities.documentHighlightProvider then
    -- Only enable for smaller files
    local file_size = vim.fn.getfsize(vim.fn.expand('%'))
    if file_size < 50000 then  -- 50KB limit
        local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
            end,
        })
    end
end
```

### 4. Optimize Telescope Configuration
```lua
-- In lua/plugins/telescope.lua, add to the setup:
require("telescope").setup({
    defaults = {
        file_ignore_patterns = { "node_modules", ".git/", "*.beam", "_build/", "deps/" },
        vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--max-count=1000"
        },
    },
    -- existing pickers config
})
```

### 5. Ensure Heavy Plugins are Lazy Loaded
```lua
-- In lua/plugins/neotest.lua, add cmd loading:
return {
    "nvim-neotest/neotest",
    cmd = { "Neotest" },  -- Add this line
    dependencies = {
        -- existing dependencies
    },
    -- rest of config
}
```

## Priority Recommendations

1. **High Impact**: Increase `updatetime` to 500ms
2. **High Impact**: Add file size check for document highlighting
3. **Medium Impact**: Optimize ElixirLS settings
4. **Medium Impact**: Add Telescope file ignore patterns
5. **Low Impact**: Ensure neotest lazy loading

## Current Configuration Strengths

- Good plugin lazy loading setup with Lazy.nvim
- Reasonable LSP configuration structure
- Proper use of autocmd groups
- Sensible keybinding organization

## Additional Monitoring

Consider adding performance monitoring:
```lua
-- Add to init.lua for startup time tracking
vim.defer_fn(function()
    print("Neovim startup time: " .. vim.fn.reltimestr(vim.fn.reltime(vim.g.start_time)) .. "s")
end, 0)
```

The most impactful changes will be increasing `updatetime` and adding conditional document highlighting based on file size.