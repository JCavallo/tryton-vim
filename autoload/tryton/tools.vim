" #############################################################################
" File: autoload/tryton/tools.vim
" Author: Jean Cavallo <jean.cavallo@hotmail.fr>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" #############################################################################

function! tryton#tools#browser_cmd()  " {{{
    for var_def in [['tryton_server_host_name', 'Tryton Server Hostname'],
            \ ['tryton_server_port', 'Tryton Server Port'],
            \ ['tryton_server_database', 'Tryton Server Database'],
            \ ['tryton_server_login', 'Tryton Server Login'],
            \ ['tryton_server_password', 'Tryton Server Password']]
        if !exists('g:' . var_def[0]) || eval('g:' . var_def[0]) ==# ""
            execute 'let g:' . var_def[0] . " = unite#util#input('" .
                \ var_def[1] . " (set g:" . var_def[0] . " to avoid this) : ')"
        endif
    endfor
    return g:tryton_parser_path . ' http://' .
        \ g:tryton_server_login . ':' . g:tryton_server_password .
        \ '@' . g:tryton_server_host_name . ':' .
        \ g:tryton_server_port . '/' . g:tryton_server_database . '/ '
endfunction  " }}}

function! tryton#tools#pad_string(str_to_pad, max_len, ...)  " {{{
    " Optional argument set to 1 to left pad
    if len(a:000) && a:000[0] == 1
        return repeat(' ', a:max_len - len(a:str_to_pad)) .
            \ a:str_to_pad[:a:max_len]
    else
        return a:str_to_pad[:a:max_len - 1] .
            \ repeat(' ', a:max_len - len(a:str_to_pad))
    endif
endfunction  " }}}

function! tryton#tools#extract_from_cmd(cmd, cmd_cache, redraw)  " {{{
    for var_def in [['tryton_server_host_name', 'Tryton Server Hostname'],
            \ ['tryton_server_port', 'Tryton Server Port'],
            \ ['tryton_server_database', 'Tryton Server Database']]
        if !exists('g:' . var_def[0]) || eval('g:' . var_def[0]) ==# ""
            execute 'let g:' . var_def[0] . " = input('" .
                \ var_def[1] . " (set g:" . var_def[0] . " to avoid this) : ')"
        endif
    endfor
    if exists('g:tryton_cache_dir') && !isdirectory(expand(g:tryton_cache_dir))
        call mkdir(expand(g:tryton_cache_dir), 'p')
    endif
    if !a:redraw && a:cmd_cache != '' && exists('g:tryton_cache_dir') &&
            \ exists('g:tryton_server_host_name') &&
            \ exists('g:tryton_server_port') &&
            \ exists('g:tryton_server_database')
        let cache_filename = expand(g:tryton_cache_dir) . '/' .
            \ g:tryton_server_host_name . '-' . g:tryton_server_port . '-' .
            \ g:tryton_server_database . '.' . a:cmd_cache . '.vcache'
        if filereadable(cache_filename)
            let raw_data = readfile(cache_filename)[0]
            let cached = 1
        endif
    endif
    if !exists('raw_data')
        let raw_data = tryton#tools#run_cmd(a:cmd)
    endif
    if has('nvim')
        let return_dict = json_decode(raw_data)
    else
        python import json
        let return_dict = pyeval('json.loads(vim.eval("raw_data"))')
    endif
    if exists('return_dict') && a:cmd_cache != '' &&
            \ exists('g:tryton_cache_dir') && !exists('cached')
        let cache_filename = expand(g:tryton_cache_dir) . '/' .
            \ g:tryton_server_host_name . '-' .  g:tryton_server_port . '-' .
            \ g:tryton_server_database . '.' . a:cmd_cache . '.vcache'
        if isdirectory(expand(g:tryton_cache_dir))
            call writefile([raw_data], cache_filename)
        endif
    endif
    return return_dict
endfunction  " }}}

function! tryton#tools#get_model_cache_path()  " {{{
    return expand(g:tryton_cache_dir) . '/' .
        \ g:tryton_server_host_name . '-' . g:tryton_server_port . '-' .
        \ g:tryton_server_database . '.extract_model.vcache'
endfunction  " }}}

function! tryton#tools#run_cmd(cmd)  " {{{
    return system('python ' . tryton#tools#browser_cmd() . a:cmd)
endfunction  " }}}

function! tryton#tools#get_data_from_path(path)  " {{{
    let data = g:tryton_data_cache
    for path_value in a:path
        if type(data[path_value]) == 4
            let data = data[path_value]
        else
            " Stop as soon as a value is not a dict
            return data[path_value]
        endif
    endfor
    return data
endfunction  " }}}

function! tryton#tools#get_conf_from_path(path)  " {{{
    for [key, values] in g:tryton_path_config
        if len(a:path) != len(key)
            continue
        endif
        let good = 1
        for elem in range(len(key))
            if a:path[elem] !~ key[elem]
                let good = 0
                break
            endif
        endfor
        if good == 1
            return values
        endif
    endfor
    return g:default_path_config
endfunction  " }}}

function! tryton#tools#edit_file(path)  " {{{
    execute ':edit ' . expand(a:path)
endfunction  " }}}

function! tryton#tools#get_current_module()  " {{{
    let path = split(expand('%:p:h'), '/')
    for idx in range(len(path) - 2)
        if filereadable('/' . join(path[:-idx-1], '/') . '/tryton.cfg')
            return path[-idx-1]
        endif
    endfor
    echoerr 'No module found'
    return ''
endfunction  " }}}

function! tryton#tools#get_current_model()  " {{{
    let lnbr = search("^\\s*__name__ = \'.*\'", 'bn')
    if lnbr == -1
        return ""
    endif
    let line = getbufline('', lnbr)[0]
    return matchstr(line, " *__name__ = [\"']\\zs.*\\ze[\"']")
endfunction  " }}}

function! tryton#tools#get_current_method()  " {{{
    let lnbr = search("^\\s*def \\zs[a-zA-Z0-9_-]*\\ze(", 'bn')
    if lnbr == -1
        return ""
    endif
    let line = getbufline('', lnbr)[0]
    return matchstr(line, "^\\s*def \\zs[a-zA-Z0-9_-]*\\ze(")
endfunction  " }}}

function! tryton#tools#convert_path(path)  " {{{
    if type(a:path) == 3
        return a:path
    endif
    return split(a:path, "/")
endfunction  " }}}

function! tryton#tools#GetTrytondPath()  " {{{
    if exists("g:tryton_trytond_path") &&
            \ isdirectory(expand(g:tryton_trytond_path))
        return g:tryton_trytond_path
    elseif isdirectory(expand("$VIRTUAL_ENV/lib/python-2.7/site-packages/trytond"))
        let g:tryton_trytond_path = "$VIRTUAL_ENV/lib/python-2.7/site-packages/trytond"
        return g:tryton_trytond_path
    else
        echoerr "Please set the g:tryton_trytond_path variable to a valid path"
        return 0
    endif
endfunction  " }}}

function! tryton#tools#ValidateXml(view_kind)  " {{{
    call tryton#tools#GetTrytondPath()
    if g:tryton_trytond_path =~ ".*trytond"
        execute ":%w !xmllint --noout --relaxng "
            \ . g:tryton_trytond_path . "/trytond/ir/ui/" . a:view_kind
            \ . ".rng %:p"
    endif
endfunction  " }}}

function! tryton#tools#FormatXml()  " {{{
    execute ':silent 1, $!XMLLINT_INDENT="' . g:tryton_xml_indent
        \ '" xmllint --format --recover - 2>/dev/null'
endfunction  " }}}
