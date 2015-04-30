" #############################################################################
" File: autoload/unite/kinds/tryton_detail_iterable.vim
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

function! unite#kinds#tryton_detail_iterable#define()  " {{{
    return s:kind
endfunction  " }}}

let s:kind = {
    \ 'name': 'tryton_detail_iterable',
    \ 'default_action': 'go_down',
    \ 'action_table': {},
    \ 'parents': ['common'],
    \ }

let s:kind.action_table.go_down = {
    \ 'is_selectable': 1,
    \ 'is_quit': 0,
    \ }

function! s:kind.action_table.go_down.func(candidates)  " {{{
    call unite#start#temporary([['tryton_details',
                \ a:candidates[0].tryton__path]],
        \ {'start_insert': 0},
        \ join(a:candidates[0].tryton__path, '/'),
        \ )
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
