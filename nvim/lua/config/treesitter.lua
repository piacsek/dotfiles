-- Native Neovim treesitter configuration
-- Enable treesitter highlighting automatically
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"bash", "diff", "html", "lua", "javascript", "typescript",
		"markdown", "vim", "elixir", "heex", "eex", "json", "tsx"
	},
	callback = function(args)
		local bufnr = args.buf
		local filetype = vim.bo[bufnr].filetype
		if filetype ~= "oil" and filetype ~= "notify" then
			vim.treesitter.start(bufnr)
		end
	end,
})
