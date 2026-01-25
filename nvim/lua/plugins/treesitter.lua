local languages = {
	"bash",
	"diff",
	"html",
	"lua",
	"javascript",
	"typescript",
	"tsx",
	"luadoc",
	"markdown",
	"vim",
	"vimdoc",
	"elixir",
	"heex",
	"eex",
	"json",
}

local filetypes = {
	"bash",
	"diff",
	"html",
	"lua",
	"javascript",
	"typescript",
	"typescriptreact",
	"javascriptreact",
	"markdown",
	"vim",
	"elixir",
	"heex",
	"eex",
	"json",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	opts = {
		ensure_installed = languages,
		auto_install = true,
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

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
