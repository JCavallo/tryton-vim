" #############################################################################
" File: autoload/unite/sources/tryton_field.vim
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

function! unite#sources#tryton_field#define() "{{{
    return s:source
endfunction"}}}

let s:source = {
    \ 'name' : 'tryton_field',
    \ 'description' : 'Candidates from tryton fields',
    \ 'is_quit': 1,
    \ }

function! s:source.gather_candidates(args, context) "{{{
    call unite#sources#tryton_details#load_data(a:context)
    let models = keys(g:tryton_data_cache)
    let candidates = []
    for model_name in sort(models)
        let mdata = g:tryton_data_cache[model_name]
        for fname in sort(keys(mdata.fields))
            let path = [model_name, 'fields', fname]
            call add(candidates,
                \ unite#sources#tryton_details#new_candidate(path))
        endfor
    endfor
    return candidates
endfunction  "}}}

let &cpo = s:save_cpo
unlet s:save_cpo