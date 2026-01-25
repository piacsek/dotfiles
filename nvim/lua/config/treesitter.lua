-- Native Neovim treesitter configuration
local parsers = {
	"bash",
	"diff",
	"html",
	"lua",
	"luadoc",
	"javascript",
	"typescript",
	"tsx",
	"markdown",
	"markdown_inline",
	"vim",
	"vimdoc",
	"elixir",
	"heex",
	"eex",
	"json",
}

-- Install parsers if missing
for _, parser in ipairs(parsers) do
	if not vim.treesitter.language.require_language(parser, nil, true) then
		vim.cmd("TSInstall " .. parser)
	end
end

-- Enable treesitter highlighting for specific filetypes
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
