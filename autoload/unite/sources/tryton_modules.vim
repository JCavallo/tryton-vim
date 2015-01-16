" #############################################################################
" File: tryton_modules.vim
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

function! unite#sources#tryton_modules#define() "{{{
    return s:source
endfunction"}}}

let s:source = {
    \ 'name' : 'tryton_modules',
    \ 'description' : 'Browse tryton modules',
    \ 'start_insert': 0,
    \ }

function! unite#sources#tryton_modules#load_data(context)  " {{{
    if exists('g:tryton_modules_cache') && !a:context.is_redraw
        return
    endif
    if exists('g:tryton_modules_cache')
        unlet g:tryton_modules_cache
    endif
    let model_raw_data = tryton#tools#run_cmd('extract modules')
    python import json
    let g:tryton_modules_cache =
        \ pyeval('json.loads(vim.eval("model_raw_data"))')
endfunction  " }}}

function! s:source.gather_candidates(args, context) "{{{
    call tryton#tools#GetTrytondPath()
    call unite#sources#tryton_modules#load_data(a:context)
    let values = g:tryton_modules_cache
    let candidates = []
    for key in sort(keys(values))
        let word = tryton#tools#pad_string(key, 40) . ' ' .
            \ tryton#tools#pad_string('[' . values[key]['state'] . ']' , 20) .
            \ ' children: ' . join(values[key]['childs'], ', ')
        let path = expand(g:tryton_trytond_path) . '/trytond/modules/' .
            \ key
        call add(candidates, {
                \ 'word': word,
                \ 'kind': 'directory',
                \ 'action__path': path,
                \ })
    endfor
    return candidates
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
