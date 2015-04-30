" #############################################################################
" File: tryton_save.vim
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
let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#tryton_save#define()  " {{{
    return s:kind
endfunction  " }}}

let s:kind = {
    \ 'name': 'tryton_save',
    \ 'default_action': 'open',
    \ 'action_table': {},
    \ 'parents': ['common'],
    \ }

let s:kind.action_table.open = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.open.func(candidates)  " {{{
    if a:candidates[0].is_cached
        let g:tryton_server_host_name = a:candidates[0].host_name
        let g:tryton_server_port = a:candidates[0].port
        let g:tryton_server_database = a:candidates[0].database
        let force_redraw = 0
    else
        if exists('g:tryton_server_host_name')
            unlet g:tryton_server_host_name
        endif
        if exists('g:tryton_server_port')
            unlet g:tryton_server_port
        endif
        if exists('g:tryton_server_database')
            unlet g:tryton_server_database
        endif
        let force_redraw = 1
    endif
    call unite#start_script([['tryton_details']],
        \ {'start_insert': 0, 'is_redraw': force_redraw}
        \ )
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
