-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 200
opt.undofile = true
opt.confirm = true
opt.cursorline = true
opt.wrap = false
opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
opt.pumheight = 12
opt.pumborder = "rounded"
opt.winborder = "rounded"
opt.autocomplete = true

-- Diagnostics
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})

-- Plugins
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/rmagatti/logger.nvim" },
  { src = "https://github.com/rmagatti/goto-preview" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

-- Telescope
local telescope_ok, telescope = pcall(require, "telescope")
local telescope_builtin_ok, telescope_builtin = pcall(require, "telescope.builtin")

if telescope_ok then
  telescope.setup({
    defaults = {
      layout_strategy = "horizontal",
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
    },
  })
end

local function with_telescope(callback)
  if not telescope_builtin_ok then
    vim.notify("Telescope is not available", vim.log.levels.WARN)
    return
  end

  callback(telescope_builtin)
end

local function find_hidden_files()
  with_telescope(function(builtin)
    local opts = { hidden = true }

    if vim.fn.executable("fd") == 1 then
      opts.find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
    else
      opts.no_ignore = true
      opts.file_ignore_patterns = { "^.git/" }
    end

    builtin.find_files(opts)
  end)
end

local function live_grep_hidden()
  with_telescope(function(builtin)
    builtin.live_grep({
      additional_args = function()
        return { "--hidden", "--glob=!.git/*" }
      end,
    })
  end)
end

-- Explorer
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

local function toggle_explorer()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  vim.cmd("Lexplore")
end

-- Terminal
local terminal = {
  buf = nil,
  win = nil,
  height = 12,
}

local function toggle_terminal()
  if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
    vim.api.nvim_win_close(terminal.win, true)
    terminal.win = nil
    return
  end

  vim.cmd("botright split")
  vim.cmd("resize " .. terminal.height)
  terminal.win = vim.api.nvim_get_current_win()

  if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
    vim.api.nvim_win_set_buf(terminal.win, terminal.buf)
  else
    vim.cmd("terminal")
    terminal.buf = vim.api.nvim_get_current_buf()
    vim.bo[terminal.buf].buflisted = false
  end

  vim.cmd("startinsert")
end

-- LSP
local lsp_group = vim.api.nvim_create_augroup("studobrain-lsp", { clear = true })

local function toggle_inlay_hints(bufnr)
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client then
      return
    end

    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end

    map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    map("n", "grr", vim.lsp.buf.references, "References")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>la", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>ld", vim.lsp.buf.definition, "Goto definition")
    map("n", "<leader>lh", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>li", function()
      toggle_inlay_hints(event.buf)
    end, "Toggle inlay hints")
    map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>lR", vim.lsp.buf.references, "References")
    map("n", "<leader>ls", function()
      with_telescope(function(builtin)
        builtin.lsp_document_symbols()
      end)
    end, "Document symbols")
    map("n", "<leader>lS", vim.lsp.buf.signature_help, "Signature help")
    map("n", "<leader>lo", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        },
      })
    end, "Organize imports")
  end,
})

vim.lsp.config("vtsls", {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = true,
        functionLikeReturnTypes = true,
        parameterNames = { enabled = "literals" },
        parameterTypes = true,
        propertyDeclarationTypes = true,
        variableTypes = false,
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = true,
        functionLikeReturnTypes = true,
        parameterNames = { enabled = "literals" },
        parameterTypes = true,
        propertyDeclarationTypes = true,
        variableTypes = false,
      },
    },
  },
})
vim.lsp.enable("vtsls")

local which_key_ok, which_key = pcall(require, "which-key")
if which_key_ok then
  which_key.setup({
    preset = "modern",
  })

  which_key.add({
    { "<leader>b", group = "Buffers" },
    { "<leader>d", group = "Diagnostics" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Grep" },
    { "<leader>l", group = "LSP" },
    { "<leader>t", group = "Terminal" },
  })
end

local bufferline_ok, bufferline = pcall(require, "bufferline")
if bufferline_ok then
  opt.showtabline = 2
  bufferline.setup({
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      separator_style = "slant",
    },
  })
end

local goto_preview_ok, goto_preview = pcall(require, "goto-preview")
if goto_preview_ok then
  goto_preview.setup({
    default_mappings = false,
    preview_window_title = {
      enable = true,
      position = "left",
    },
  })
end

-- Keymaps
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>ff", function()
  with_telescope(function(builtin)
    builtin.find_files()
  end)
end, { desc = "Find files" })
map("n", "<leader>f.", find_hidden_files, { desc = "Find hidden files" })
map("n", "<leader>fe", toggle_explorer, { desc = "Explorer" })
map("n", "<leader>fg", function()
  with_telescope(function(builtin)
    builtin.live_grep()
  end)
end, { desc = "Live grep" })
map("n", "<leader>g.", live_grep_hidden, { desc = "Live grep hidden" })
map("n", "<leader>fb", function()
  with_telescope(function(builtin)
    builtin.buffers()
  end)
end, { desc = "Buffers" })
map("n", "<leader>fh", function()
  with_telescope(function(builtin)
    builtin.help_tags()
  end)
end, { desc = "Help" })
map("n", "<leader>fd", function()
  with_telescope(function(builtin)
    builtin.diagnostics()
  end)
end, { desc = "Diagnostics" })
map("n", "<leader>j", function()
  with_telescope(function(builtin)
    builtin.jumplist()
  end)
end, { desc = "Jump history" })
map("n", "<leader>bb", function()
  with_telescope(function(builtin)
    builtin.buffers()
  end)
end, { desc = "Pick buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "gpd", function()
  if goto_preview_ok then
    goto_preview.goto_preview_definition()
  end
end, { desc = "Preview definition" })
map("n", "gpi", function()
  if goto_preview_ok then
    goto_preview.goto_preview_implementation()
  end
end, { desc = "Preview implementation" })
map("n", "gpr", function()
  if goto_preview_ok then
    goto_preview.goto_preview_references()
  end
end, { desc = "Preview references" })
map("n", "gP", function()
  if goto_preview_ok then
    goto_preview.close_all_win()
  end
end, { desc = "Close previews" })
map("n", "<leader>tt", toggle_terminal, { desc = "Toggle terminal" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<C-h>", "<C-w>h", { desc = "Left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right window" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })

-- Autocmds
local misc_group = vim.api.nvim_create_augroup("studobrain-misc", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = misc_group,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = misc_group,
  callback = function()
    if vim.bo.buftype == "terminal" then
      terminal.buf = vim.api.nvim_get_current_buf()
      terminal.win = vim.api.nvim_get_current_win()
    end
  end,
})

local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
  gitsigns.setup()
end
