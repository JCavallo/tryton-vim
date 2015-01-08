" #############################################################################
" File: tryton_model.vim
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

function! unite#kinds#tryton_model#define()
    return s:kind
endfunction

let s:kind  =  {
    \ 'name': 'tryton_model',
    \ 'default_action': 'view_fields',
    \ 'action_table': {},
    \ 'parents': [],
    \ }

let s:kind.action_table.view_fields = {
    \ 'is_selectable': 1,
    \ 'is_quit': 0,
    \ }

function! s:kind.action_table.view_fields.func(candidates)
    call unite#start_temporary([['tryton_field',
                \ a:candidates[0].source__info.model_name]], {
            \ 'start_insert': 0})
endfunction

let s:kind.action_table.view_details = {
    \ 'is_selectable': 1,
    \ 'is_quit': 0,
    \ }

function! s:kind.action_table.view_details.func(candidates)
    call unite#start_temporary([['tryton_details',
                \ a:candidates[0].source__info.model_name, '']], {
            \ 'start_insert': 0},
        \ 'Data for model ' . a:candidates[0].source__info.model_name)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
