" #############################################################################
" File: tools.vim
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
        \ g:tryton_server_port . '/' . g:tryton_server_database . ' '
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

function! tryton#tools#run_cmd(cmd)  " {{{
    return system(tryton#tools#browser_cmd() . a:cmd)
endfunction  " }}}

function! tryton#tools#get_data_from_path(path)  " {{{
    let data = g:tryton_data_cache
    for path_value in a:path
        let data = data[path_value]
    endfor
    return data
endfunction  " }}}

function! tryton#tools#get_conf_from_path(path)  " {{{
    if len(a:path) < 2
        " Model
        let config = g:tryton_path_config
    elseif has_key(g:tryton_path_config, a:path[-2])
        let config = g:tryton_path_config[a:path[-2]]
    else
        let config = {}
    endif
    return config
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
        return
    elseif isdirectory(expand("$VIRTUAL_ENV/lib/python-2.7/site-packages/trytond"))
        let g:tryton_trytond_path = "$VIRTUAL_ENV/lib/python-2.7/site-packages/trytond"
        return
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
