local filetypes = {
	"bash",
	"diff",
	"html",
	"lua",
	"javascript",
	"typescript",
	"markdown",
	"vim",
	"elixir",
	"heex",
	"eex",
	"json",
}

local languages = vim.list_extend(vim.deepcopy(filetypes), {
	"tsx",
	"luadoc",
	"vimdoc",
})

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(languages)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function(args)
				local bufnr = args.buf
				local filetype = vim.bo[bufnr].filetype
				if filetype ~= "oil" and filetype ~= "notify" then
					vim.treesitter.start(bufnr)
				end
			end,
		})
	end,
}
