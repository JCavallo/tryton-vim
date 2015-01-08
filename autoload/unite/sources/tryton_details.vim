" #############################################################################
" File: tryton_details.vim
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

function! unite#sources#tryton_details#define() "{{{
    return s:source
endfunction"}}}

let s:source = {
    \ 'name' : 'tryton_details',
    \ 'description' : 'Candidates from tryton details',
    \ 'is_listed': 0,
    \ }

function! s:source.gather_candidates(args, context) "{{{
    call unite#sources#tryton_model#load_data(a:context)
    let mdata = g:tryton_data_cache[a:args[0]]
    if a:args[1] != ''
        let data = mdata.fields[a:args[1]]
    else
        let data = mdata
    endif
    let candidates = []
    for key in sort(keys(data))
        if index(g:tryton_nested_fields, key) != -1
            continue
        endif
        let key_name = tryton#tools#pad_string(key, 40)
        call add(candidates, {
                \ 'word': key_name . ' ' . copy(data[key]),
                \ 'kind': 'tryton_detail',
                \ })
    endfor
    return candidates
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
