#!/bin/bash

# Create Neovim config directory (standard is ~/.config/nvim)
mkdir -p ~/.config/nvim

# Check if init.lua exists in current directory, else create a basic one
if [ -f init.lua ]; then
    cp init.lua ~/.config/nvim/
else
    cat > ~/.config/nvim/init.lua << 'EOF'
-- filepath: /home/parinya/workspace/Fedora/init.lua
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.laststatus = 3
vim.opt.cmdheight = 1

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.colorcolumn = "80"

vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", extends = "»", precedes = "«", nbsp = "○" }
vim.opt.fillchars = { eob = " ", fold = " ", vert = "│", horiz = "─", diff = "╱" }

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 240

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 30
vim.g.netrw_liststyle = 3

local palette = {
  bg = "#0f1720", fg = "#cbd5e1", comment = "#6b7280", cursorline = "#0b1220",
  pmenu_bg = "#0b1220", suggest = "#8b949e",
}
vim.api.nvim_set_hl(0, "Normal",       { bg = palette.bg, fg = palette.fg })
vim.api.nvim_set_hl(0, "CursorLine",   { bg = palette.cursorline })
vim.api.nvim_set_hl(0, "LineNr",       { fg = "#566270" })
vim.api.nvim_set_hl(0, "Comment",      { fg = palette.comment, italic = true })
vim.api.nvim_set_hl(0, "Visual",       { bg = "#16324a" })
vim.api.nvim_set_hl(0, "Pmenu",        { bg = palette.pmenu_bg, fg = palette.fg })
vim.api.nvim_set_hl(0, "StatusLine",   { bg = "#071024", fg = palette.fg, bold = true })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#07101a", fg = "#6b7280" })
vim.api.nvim_set_hl(0, "Suggest",      { fg = palette.suggest, italic = true })

vim.diagnostic.config({
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = "always" },
})
for type, icon in pairs({ Error = " ", Warn = " ", Hint = " ", Info = " " }) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local function git_branch()
  local cwd = vim.fn.getcwd()
  if vim.fn.isdirectory(cwd .. "/.git") == 0 then return "" end
  local head = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --abbrev-ref HEAD 2>/dev/null")[1]
  return (head and head ~= "" and (" " .. head)) or ""
end
local function diagnostics_counts()
  local d = vim.diagnostic
  local parts = {}
  local function n(sev) return #d.get(0, { severity = sev }) end
  local e, w, h, i = n(d.severity.ERROR), n(d.severity.WARN), n(d.severity.HINT), n(d.severity.INFO)
  if e > 0 then table.insert(parts, "E:" .. e) end
  if w > 0 then table.insert(parts, "W:" .. w) end
  if h > 0 then table.insert(parts, "H:" .. h) end
  if i > 0 then table.insert(parts, "I:" .. i) end
  return table.concat(parts, " ")
end
_G.init_status = {}
function _G.init_status.mode()
  local m = vim.api.nvim_get_mode().mode
  local map = { n="N", i="I", v="V", V="V-L", [""]="V-B", c="C", R="R" }
  return "[" .. (map[m] or m) .. "]"
end
function _G.init_status.git() return git_branch() end
function _G.init_status.diag() return diagnostics_counts() end
vim.o.statusline = table.concat({
  "%#StatusLine# ","%f %m"," %=","%{v:lua.init_status.mode()}",
  " %{v:lua.init_status.git()}"," %{v:lua.init_status.diag()} ",
})

local km, opts = vim.keymap.set, { noremap = true, silent = true }

km("n", "<leader>w", ":w<CR>", opts)
km("n", "<leader>q", ":q<CR>", opts)
km("n", "<leader>so", ":source $MYVIMRC<CR>", opts)
km("n", "<Esc>", ":nohlsearch<CR>", opts)
km("n", "<S-l>", ":bnext<CR>", opts)
km("n", "<S-h>", ":bprevious<CR>", opts)

local function toggle(opt, on_msg, off_msg)
  vim.opt[opt] = not vim.opt[opt]:get()
  vim.notify((vim.opt[opt]:get() and on_msg) or off_msg, vim.log.levels.INFO)
end
km("n", "<leader>tw", function() toggle("wrap", "Wrap: ON", "Wrap: OFF") end, opts)
km("n", "<leader>tr", function() toggle("relativenumber", "RelNum: ON", "RelNum: OFF") end, opts)
km("n", "<leader>tl", function()
  local cur = vim.o.colorcolumn
  vim.o.colorcolumn = (cur == "" and "80") or ""
  vim.notify("ColorColumn: " .. (vim.o.colorcolumn == "" and "OFF" or "80"), vim.log.levels.INFO)
end, opts)
km("n", "<leader>ts", function()
  vim.o.spell = not vim.o.spell
  vim.o.spelllang = "en_us,th"
  vim.notify("Spell: " .. (vim.o.spell and "ON" or "OFF"), vim.log.levels.INFO)
end, opts)

km("n", "[d", vim.diagnostic.goto_prev, opts)
km("n", "]d", vim.diagnostic.goto_next, opts)
km("n", "<leader>dd", vim.diagnostic.open_float, opts)
km("n", "<leader>dq", function() vim.diagnostic.setloclist(); vim.cmd.copen() end, opts)
km("n", "<leader>td", function()
  local vt = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not vt })
  vim.notify("Diagnostics virtual text: " .. (not vt and "ON" or "OFF"))
end, opts)

km("n", "<leader>e", ":Lexplore<CR>", opts)

local function list_files_root()
  local cwd = vim.loop.cwd()
  local files = {}
  if vim.fn.executable("fd") == 1 then
    local out = vim.fn.systemlist("fd --hidden --type f --exclude .git . " .. vim.fn.shellescape(cwd))
    for _, f in ipairs(out) do files[#files+1] = f end
  else
    local raw = vim.fn.globpath(cwd, "**/*", false, true)
    for _, f in ipairs(raw) do if vim.fn.isdirectory(f) == 0 then files[#files+1] = f end end
  end
  return files
end
function _G.open_file_picker()
  local files = list_files_root()
  if #files == 0 then vim.notify("No files found", vim.log.levels.INFO); return end
  vim.ui.select(files, { prompt = "Files:" }, function(choice)
    if choice then vim.cmd.edit(vim.fn.fnameescape(choice)) end
  end)
end
km("n", "<leader>ff", function() _G.open_file_picker() end, opts)

function _G.open_recent_picker()
  local list = {}
  for _, f in ipairs(vim.v.oldfiles or {}) do
    if vim.fn.filereadable(f) == 1 then list[#list+1] = f end
  end
  if #list == 0 then vim.notify("No recent files", vim.log.levels.INFO); return end
  vim.ui.select(list, { prompt = "Recent files:" }, function(choice)
    if choice then vim.cmd.edit(vim.fn.fnameescape(choice)) end
  end)
end
km("n", "<leader>fo", function() _G.open_recent_picker() end, opts)

function _G.open_buffer_picker()
  local bufs = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_option(b, "buflisted") then
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":.")
      bufs[#bufs+1] = string.format("%d: %s", b, name ~= "" and name or "[No Name]")
    end
  end
  if #bufs == 0 then vim.notify("No buffers", vim.log.levels.INFO); return end
  vim.ui.select(bufs, { prompt = "Buffers:" }, function(choice)
    if not choice then return end
    local id = tonumber(choice:match("^(%d+):"))
    if id then vim.api.nvim_set_current_buf(id) end
  end)
end
km("n", "<leader>fb", function() _G.open_buffer_picker() end, opts)

local last_grep = nil
local function qf_open_if_any()
  local qf = vim.fn.getqflist()
  if qf and #qf > 0 then vim.cmd("copen") else vim.notify("No results", vim.log.levels.INFO) end
end
function _G.project_grep()
  local q = vim.fn.input("Grep > ")
  if q == "" then return end
  last_grep = q
  if vim.fn.executable("rg") == 1 then
    vim.cmd("cexpr []")
    local cmd = "rg --vimgrep --hidden --no-heading -S " .. vim.fn.shellescape(q)
    local out = vim.fn.systemlist(cmd)
    vim.fn.setqflist({}, " ", { lines = out })
    qf_open_if_any()
  else
    vim.cmd("vimgrep /" .. q .. "/gj **/*")
    qf_open_if_any()
  end
end
function _G.project_grep_repeat()
  if not last_grep then vim.notify("No previous grep", vim.log.levels.INFO); return end
  if vim.fn.executable("rg") == 1 then
    local cmd = "rg --vimgrep --hidden --no-heading -S " .. vim.fn.shellescape(last_grep)
    local out = vim.fn.systemlist(cmd)
    vim.fn.setqflist({}, " ", { lines = out })
    qf_open_if_any()
  else
    vim.cmd("vimgrep /" .. last_grep .. "/gj **/*")
    qf_open_if_any()
  end
end
km("n", "<leader>/", function() _G.project_grep() end, opts)
km("n", "<leader>*", function() _G.project_grep_repeat() end, opts)

local function on_attach(_, bufnr)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  local b = { noremap = true, silent = true, buffer = bufnr }
  km("n", "gd", vim.lsp.buf.definition, b)
  km("n", "gD", vim.lsp.buf.declaration, b)
  km("n", "K",  vim.lsp.buf.hover, b)
  km("n", "gi", vim.lsp.buf.implementation, b)
  km("n", "<leader>rn", vim.lsp.buf.rename, b)
  km("n", "<leader>ca", vim.lsp.buf.code_action, b)
  km("n", "gr", vim.lsp.buf.references, b)
  km("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, b)
  km("i", "<C-k>", vim.lsp.buf.signature_help, b)
end
local function find_root(markers)
  local bufname = vim.api.nvim_buf_get_name(0)
  local start = (bufname ~= "" and vim.fs.dirname(bufname)) or vim.loop.cwd()
  local root = vim.fs.find(markers or { ".git", "pyproject.toml", "package.json" }, { upward = true, path = start })[1]
  return root and vim.fs.dirname(root) or vim.loop.cwd()
end
local function setup_server(s)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = s.filetypes,
    group = vim.api.nvim_create_augroup("BuiltinLsp_" .. s.name, { clear = true }),
    callback = function()
      if vim.fn.executable(s.cmd[1]) ~= 1 then return end
      local root = find_root(s.root_markers)
      vim.lsp.start({
        name = s.name, cmd = s.cmd, root_dir = root, on_attach = on_attach,
        capabilities = vim.lsp.protocol.make_client_capabilities(),
        reuse_client = function(client, conf)
          return client.name == conf.name and client.config.root_dir == conf.root_dir
        end,
      })
    end
  })
end

setup_server({ name="pyright",  cmd={"pyright-langserver","--stdio"}, filetypes={"python"},
  root_markers={".git","pyproject.toml","setup.py","setup.cfg","requirements.txt",".venv"} })
setup_server({ name="tsserver", cmd={"typescript-language-server","--stdio"},
  filetypes={"javascript","javascriptreact","typescript","typescriptreact"},
  root_markers={".git","package.json","tsconfig.json","jsconfig.json"} })
setup_server({ name="lua_ls",   cmd={"lua-language-server"}, filetypes={"lua"},
  root_markers={".git",".luarc.json",".luacheckrc"} })

local function lsp_organize_imports()
  local params = { context = { only = { "source.organizeImports", "source.addMissingImports", "source.sortImports" } } }
  local results = vim.lsp.buf.code_action(params)
  if results == nil or (type(results) == "table" and vim.tbl_isempty(results)) then
    vim.notify("No organizeImports action", vim.log.levels.INFO); return
  end
end
km("n", "<leader>oi", lsp_organize_imports, opts)

vim.g.__format_on_save = false
vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
  vim.g.__format_on_save = not vim.g.__format_on_save
  vim.notify("FormatOnSave: " .. (vim.g.__format_on_save and "ON" or "OFF"))
end, {})
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if vim.g.__format_on_save then pcall(vim.lsp.buf.format, { async = false, timeout_ms = 1500 }) end
  end,
})

local function workspace_symbols()
  local q = vim.fn.input("Workspace symbols > ")
  if q == "" then return end
  vim.lsp.buf_request_all(0, "workspace/symbol", { query = q }, function(resps)
    local all = {}
    for _, resp in pairs(resps or {}) do
      for _, item in ipairs(resp.result or {}) do all[#all+1] = item end
    end
    if #all == 0 then vim.notify("No symbols", vim.log.levels.INFO); return end
    local items = vim.lsp.util.symbols_to_items(all)
    vim.fn.setqflist(items, "r")
    vim.cmd("copen")
  end)
end
km("n", "<leader>ss", workspace_symbols, opts)

local function document_symbols()
  vim.lsp.buf_request(0, "textDocument/documentSymbol", vim.lsp.util.make_text_document_params(), function(_, result)
    if not result or vim.tbl_isempty(result) then vim.notify("No document symbols", vim.log.levels.INFO); return end
    local items = vim.lsp.util.symbols_to_items(result)
    vim.ui.select(items, { prompt = "Document symbols:" }, function(choice)
      if choice then vim.cmd("edit " .. vim.fn.fnameescape(choice.filename)); vim.api.nvim_win_set_cursor(0, { choice.lnum, choice.col - 1 }) end
    end)
  end)
end
km("n", "<leader>sd", document_symbols, opts)

local ns = vim.api.nvim_create_namespace("mini_suggest_ns")
local state = { timer = nil, suggestion = nil, mark = nil }

local function clear_suggestion()
  pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)
  state.suggestion, state.mark = nil, nil
end
local function accept_suggestion()
  if not state.suggestion or not state.mark then return end
  local s = state.suggestion
  local row, col = state.mark[1], state.mark[2]
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { s })
  vim.api.nvim_win_set_cursor(0, { row, col + #s })
  clear_suggestion()
end
local function in_insert()
  local m = vim.api.nvim_get_mode().mode
  return m:sub(1,1) == "i"
end
local function request_and_show()
  if not in_insert() then return end
  if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 })) then clear_suggestion(); return end
  local pos = vim.api.nvim_win_get_cursor(0)
  local row0, col = pos[1] - 1, pos[2]
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/completion", params, function(err, result)
    if err or not result then clear_suggestion(); return end
    local items = vim.lsp.util.extract_completion_items(result)
    if not items or #items == 0 then clear_suggestion(); return end
    local item = items[1]
    local candidate = item.insertText or item.label or ""
    local line = vim.api.nvim_get_current_line()
    local prefix = line:sub(1, col)
    local word = prefix:match("[%w_]+$") or ""
    local suffix = candidate
    if candidate:sub(1, #word) == word then suffix = candidate:sub(#word + 1) end
    if not suffix or suffix == "" then clear_suggestion(); return end
    clear_suggestion()
    vim.api.nvim_buf_set_extmark(0, ns, row0, col, {
      virt_text = { { suffix, "Suggest" } },
      virt_text_pos = "overlay",
      hl_mode = "combine",
    })
    state.suggestion = suffix
    state.mark = { row0 + 1, col }
  end)
end
local function debounce(fn, delay)
  return function()
    if state.timer then state.timer:stop(); state.timer:close(); state.timer = nil end
    local t = vim.loop.new_timer()
    state.timer = t
    t:start(delay, 0, vim.schedule_wrap(function()
      fn()
      if state.timer then state.timer:stop(); state.timer:close(); state.timer = nil end
    end))
  end
end
local request_debounced = debounce(request_and_show, 160)
local aug = vim.api.nvim_create_augroup("MiniSuggestGroup", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter", "TextChangedI", "CursorMovedI", "InsertCharPre" }, {
  group = aug, callback = request_debounced,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, { group = aug, callback = clear_suggestion })
vim.keymap.set("i", "<Tab>", function()
  if state.suggestion and state.mark then accept_suggestion(); return "" end
  return string.rep(" ", vim.o.shiftwidth)
end, { expr = true, noremap = true, silent = true })
vim.keymap.set("i", "<C-l>", accept_suggestion, { noremap = true, silent = true })

local function guess_comment_prefix()
  local cs = vim.bo.commentstring
  if cs and cs:find("%%s") then
    return cs:gsub("%%s", ""):gsub("^%s+", ""):gsub("%s+$", "")
  end

  local ft = vim.bo.filetype
  if ft == "lua" or ft == "python" or ft == "sh" or ft == "bash" then return "#"
  elseif ft:match("javascript") or ft:match("typescript") or ft=="c" or ft=="cpp" or ft=="java" then return "//"
  else return "#" end
end
local function toggle_comment_lines(sline, eline)
  local prefix = guess_comment_prefix()
  local lines = vim.api.nvim_buf_get_lines(0, sline-1, eline, false)
  local all_commented = true
  for _, ln in ipairs(lines) do
    if not ln:match("^%s*" .. vim.pesc(prefix)) then all_commented = false break end
  end
  for i, ln in ipairs(lines) do
    if all_commented then
      lines[i] = ln:gsub("^(%s*)" .. vim.pesc(prefix) .. "%s?", "%1")
    else
      lines[i] = (ln:match("^(%s*)") or "") .. prefix .. " " .. ln:gsub("^%s*", "")
    end
  end
  vim.api.nvim_buf_set_lines(0, sline-1, eline, false, lines)
end
vim.keymap.set("n", "gcc", function()
  local l = vim.api.nvim_win_get_cursor(0)[1]
  toggle_comment_lines(l, l)
end, opts)
vim.keymap.set("v", "gc", function()
  local sline = vim.fn.getpos("v")[2]
  local eline = vim.fn.getpos(".")[2]
  if sline > eline then sline, eline = eline, sline end
  toggle_comment_lines(sline, eline)
end, opts)

local term = { win = nil, buf = nil }
local function term_toggle()
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_close(term.win, true); term.win, term.buf = nil, nil; return
  end
  term.buf = vim.api.nvim_create_buf(false, true)
  local W, H = math.floor(vim.o.columns*0.7), math.floor(vim.o.lines*0.7)
  local row = math.floor((vim.o.lines - H)/2 - 1)
  local col = math.floor((vim.o.columns - W)/2)
  term.win = vim.api.nvim_open_win(term.buf, true, {
    relative="editor", style="minimal", border="rounded",
    width=W, height=H, row=row, col=col
  })
  vim.fn.termopen(vim.o.shell)
  vim.cmd("startinsert")
end
km("n", "<leader>tt", term_toggle, opts)

local function sessions_dir()
  local p = vim.fn.stdpath("state") .. "/sessions"
  vim.fn.mkdir(p, "p")
  return p
end
local function session_path()
  local name = vim.fn.fnamemodify(vim.loop.cwd(), ":t")
  return sessions_dir() .. "/" .. name .. ".vim"
end
vim.api.nvim_create_user_command("SessionSave", function()
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_path()))
  vim.notify("Session saved: " .. session_path())
end, {})
vim.api.nvim_create_user_command("SessionLoad", function()
  local p = session_path()
  if vim.fn.filereadable(p) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(p))
    vim.notify("Session loaded: " .. p)
  else
    vim.notify("No session for this folder", vim.log.levels.WARN)
  end
end, {})
km("n", "<leader>SS", ":SessionSave<CR>", opts)
km("n", "<leader>SL", ":SessionLoad<CR>", opts)

local function palette()
  local actions = {
    { "Find file", function() _G.open_file_picker() end },
    { "Grep in project", function() _G.project_grep() end },
    { "Recent files", function() _G.open_recent_picker() end },
    { "Buffers", function() _G.open_buffer_picker() end },
    { "Workspace symbols", workspace_symbols },
    { "Document symbols", document_symbols },
    { "Toggle wrap", function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>tw", true, false, true), "n", false) end },
    { "Toggle relativenumber", function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>tr", true, false, true), "n", false) end },
    { "Toggle diagnostics VT", function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>td", true, false, true), "n", false) end },
    { "Toggle spell", function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>ts", true, false, true), "n", false) end },
    { "Organize imports", lsp_organize_imports },
    { "Format (LSP)", function() vim.lsp.buf.format({ async = true }) end },
    { "Floating terminal", term_toggle },
    { "Session save", function() vim.cmd("SessionSave") end },
    { "Session load", function() vim.cmd("SessionLoad") end },
  }
  local labels = {}
  for i, a in ipairs(actions) do labels[i] = a[1] end
  vim.ui.select(labels, { prompt = "Command Palette:" }, function(choice)
    if not choice then return end
    for _, a in ipairs(actions) do if a[1] == choice then a[2](); break end end
  end)
end
km("n", "<leader><leader>", palette, opts)

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank({ timeout = 180 }) end })

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(ev)
    local file = vim.fn.expand(ev.match)
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", { command = "%s/\\s\\+$//e" })

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "qf" },
  callback = function(ev) vim.bo[ev.buf].buflisted = false; vim.keymap.set("n","q","<cmd>close<cr>",{buffer=ev.buf,silent=true}) end,
})

vim.defer_fn(function()
  print("🚀 Minimal work-ready Neovim — no plugins, fast, with LSP ghost suggestions, grep, MRU, symbols, terminal & palette.")
end, 80)
EOF
    echo "Created basic init.lua in ~/.config/nvim/"
fi

echo "Neovim config setup complete. Run 'nvim' to start."
