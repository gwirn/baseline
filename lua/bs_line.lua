local path_separator = package.config:sub(1, 1)


local cmp = {}
function _G._statusline_component(name)
    return cmp[name]()
end

function cmp.diagnostic_status()
    local ok = '[%#StatusLineOK# ☯ %*]'
    local ignore = {
        ['c'] = true,
        ['t'] = true
    }

    local mode = vim.api.nvim_get_mode().mode

    if ignore[mode] then
        return ok
    end

    local levels = vim.diagnostic.severity
    local errors = #vim.diagnostic.get(0, { severity = levels.ERROR })
    if errors > 0 then
        return '[%#StatusLineError# ⛍  %*]'
    end

    local warnings = #vim.diagnostic.get(0, { severity = levels.WARN })
    if warnings > 0 then
        return '[%#StatusLineWarning# ⏿ %*]'
    end

    return ok
end

function cmp.position()
    local hi_pattern = '%%#%s#%s%%*'
    return hi_pattern:format('Search', ' %3l:%-2c ')
end

local modes = setmetatable({
    ['n'] = 'NORMAL',
    ['no'] = 'N·PENDING',
    ['v'] = 'VISUAL',
    ['V'] = 'V·LINE',
    [''] = 'V·BLOCK',
    ['s'] = 'SELECT',
    ['S'] = 'S·LINE',
    [''] = 'S·BLOCK',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rv'] = 'V·REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM·EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
}, {
    __index = function()
        return 'UNKNOWN'
    end
})

_G.get_current_mode = function()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(' %s ', modes[current_mode])
end
local isgit = function(max_branch_len)
    local modstring = '%:p:h'
    local hasgit = '%#StatusLineWarning# ☢ %*'
    while true do
        local cpath = vim.fn.expand(modstring)
        if cpath == '' or cpath == path_separator then
            break
        end
        local git_test_path = cpath .. path_separator .. '.git'
        if vim.fn.isdirectory(git_test_path) ~= 0 then
            local f = io.open(git_test_path .. path_separator .. 'HEAD')
            if f == nil then
                goto continue
            end
            local line = f:read("l"):gsub("[\n\r]", " ")
            f:close()
            local git_branch = string.match(line, path_separator .. '(%w+)$'):sub(1, max_branch_len)
            local gb_lower = git_branch:lower()
            if gb_lower == 'master' or gb_lower == 'main' then
                git_branch = '%#StatusLineWarning#' .. git_branch .. '%*'
            end
            hasgit = git_branch
            break
        else
            modstring = modstring .. ':h'
        end
        ::continue::
    end
    return hasgit
end

local M = {}
M.setup = function(opts)
    opts = opts or {}
    local error_color = opts.error_color or "#d90404"
    local warning_color = opts.warning_color or "#f58905"
    local ok_color = opts.ok_color or "#10870e"
    local git_color = opts.git_color or "#7f0e87"
    local filename_color = opts.filename_color or "#2ed9e6"
    local col_color = opts.filename_color or "#abf4f5"
    local row_color = opts.filename_color or "#fad975"
    local mbl = opts.mbl or 10
    vim.api.nvim_set_hl(0, "StatusLineError", { fg = error_color })
    vim.api.nvim_set_hl(0, "StatusLineWarning", { fg = warning_color })
    vim.api.nvim_set_hl(0, "StatusLineOK", { fg = ok_color })
    vim.api.nvim_set_hl(0, "StatusLineGit", { fg = git_color })
    vim.api.nvim_set_hl(0, "StatusLineFileName", { fg = filename_color })
    vim.api.nvim_set_hl(0, "StatusLineCol", { fg = col_color })
    vim.api.nvim_set_hl(0, "StatusLineRow", { fg = row_color })

    local dirpath = ' ' .. vim.fn.expand('%:p:~:h') .. path_separator
    local statusline = {
        '%{%v:lua._statusline_component("diagnostic_status")%}',
        '%#StatusLineGit# ⛕ %*' .. isgit(mbl) .. ' ',
        '[%{%v:lua.get_current_mode()%}]',
        '%=',
        dirpath,
        '%#StatusLineFileName#%t%* ',
        '%r',
        '%m',
        '%=',
        '%{strlen(&fenc)?&fenc:&enc} ',
        '[%{&filetype}] ',
        ' %2p%% ',
        '[ C:%#StatusLineCol#%c%* L:%#StatusLineRow#%l/%L%* ]',
    }
    vim.o.statusline = table.concat(statusline, '')

    vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
        pattern = "*",
        callback = function()
            statusline = {
                '%{%v:lua._statusline_component("diagnostic_status")%}',
                '%#StatusLineGit# ⛕ %*' .. isgit(mbl) .. ' ',
                '[%{%v:lua.get_current_mode()%}]',
                '%=',
                dirpath,
                '%#StatusLineFileName#%t%* ',
                '%r',
                '%m',
                '%=',
                '%{strlen(&fenc)?&fenc:&enc} ',
                '[%{&filetype}] ',
                ' %2p%% ',
                '[ C:%#StatusLineCol#%c%* L:%#StatusLineRow#%l/%L%* ]',
            }
            vim.o.statusline = table.concat(statusline, '')
        end
    }
    )
end
return M
