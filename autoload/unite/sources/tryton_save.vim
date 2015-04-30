" #############################################################################
" File: autoload/unite/sources/tryton_save.vim
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

function! unite#sources#tryton_save#define() "{{{
    return s:source
endfunction"}}}

let s:source = {
    \ 'name' : 'tryton_save',
    \ 'description' : 'Get data from server',
    \ 'start_insert': 0,
    \ }

function! s:new_candidate_from_data(data) "{{{
    echo a:data
    let candidate = {
        \ 'kind': 'tryton_save',
        \ 'is_cached': 1,
        \ 'host_name': a:data[0],
        \ 'port': a:data[1],
        \ 'database': split(a:data[2], '\.')[0],
        \ }
    let candidate['word'] = tryton#tools#pad_string(a:data[0], 20) .
        \ tryton#tools#pad_string(a:data[1], 6) . split(a:data[2], '\.')[0]
    return candidate
endfunction  " }}}

function! s:source.gather_candidates(args, context) "{{{
    let candidates = []
    if exists('g:tryton_cache_dir')
        for cache_file in split(globpath(expand(g:tryton_cache_dir),
                    \ '*extract_model.vcache'), '\n')
            let connexion_data = split(fnamemodify(cache_file, ':t:r'), '-')
            call add(candidates, s:new_candidate_from_data(connexion_data))
        endfor
    endif
    call add(candidates, {
            \ 'word': 'New',
            \ 'kind': 'tryton_save',
            \ 'is_cached': 0,
            \ 'host_name': '',
            \ 'port': '',
            \ 'database': '',
            \ })
    return candidates
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
