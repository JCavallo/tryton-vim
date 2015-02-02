" #############################################################################
" File: tryton_detail_iterable.vim
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

function! unite#kinds#tryton_detail_iterable#field_function(candidate, key, is_pref)  " {{{
    let data = tryton#tools#get_data_from_path(a:candidate.tryton__path)
    if has_key(data, a:key) && data[a:key] != '0'
        if a:is_pref
            let name = a:key . '_' . a:candidate.tryton__path[2]
        else
            let name = data[a:key]
        endif
        let fullpath = [a:candidate.tryton__path[0], 'methods', name]
        call unite#start_script([['tryton_details', fullpath]], {
                \ 'start_insert': 0}, fullpath,
            \ )
    else
        echom 'Field has no ' . a:key . ' defined'
    endif
endfunction  " }}}

let s:kind.action_table.jump_to_getter = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.jump_to_getter.func(candidates)  " {{{
    call unite#kinds#tryton_detail_iterable#field_function(a:candidates[0],
        \ 'getter', 0)
endfunction  " }}}

let s:kind.action_table.jump_to_setter = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.jump_to_setter.func(candidates)  " {{{
    call unite#kinds#tryton_detail_iterable#field_function(a:candidates[0],
        \ 'setter', 0)
endfunction  " }}}

let s:kind.action_table.jump_to_searcher = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.jump_to_searcher.func(candidates)  " {{{
    call unite#kinds#tryton_detail_iterable#field_function(a:candidates[0],
        \ 'searcher', 0)
endfunction  " }}}

let s:kind.action_table.jump_to_default = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.jump_to_default.func(candidates)  " {{{
    call unite#kinds#tryton_detail_iterable#field_function(a:candidates[0],
        \ 'default', 1)
endfunction  " }}}

let s:kind.action_table.jump_to_on_change = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.jump_to_on_change.func(candidates)  " {{{
    call unite#kinds#tryton_detail_iterable#field_function(a:candidates[0],
        \ 'on_change', 1)
endfunction  " }}}

let s:kind.action_table.jump_to_on_change_with = {
    \ 'is_selectable': 1,
    \ 'is_quit': 1,
    \ }

function! s:kind.action_table.jump_to_on_change_with.func(candidates)  " {{{
    call unite#kinds#tryton_detail_iterable#field_function(a:candidates[0],
        \ 'on_change_with', 1)
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
