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

function! unite#sources#tryton_model#define() "{{{
    return s:source
endfunction"}}}

let s:source = {
    \ 'name': 'tryton_model',
    \ 'description': 'Candidates from tryton models',
    \ }


function! unite#sources#tryton_model#load_data(context)  " {{{
    if exists('g:tryton_data_cache') && !a:context.is_redraw
        return
    endif
    if exists('g:tryton_data_cache')
        unlet g:tryton_data_cache
    endif
    let g:tryton_data_cache = {}
    let model_raw_data = tryton#tools#run_cmd('extract all')
    for model_data in split(model_raw_data, '\n')
        let [model_name, model_data] = split(model_data, ';;')
        let g:tryton_data_cache[model_name] = {}
        let mdata = g:tryton_data_cache[model_name]
        for model_field_data in split(model_data, '\t\t\t')
            let [model_field, model_field_data] = split(model_field_data, ':::')
            if index(g:tryton_nested_fields, model_field) == -1
                let mdata[model_field] = copy(model_field_data)
            else
                let fdata = {}
                for model_field_data in split(model_field_data, '\t\t')
                    let [fname, finfo_values] = split(model_field_data, '::')
                    let fdata[fname] = {}
                    for finfo_value in split(finfo_values, '\t')
                        let vals = split(finfo_value, ':')
                        let fdata[fname][vals[0]] = get(vals, 1, '')
                    endfor
                endfor
                let mdata[model_field] = copy(fdata)
            endif
        endfor
    endfor
endfunction  " }}}

function! s:source.gather_candidates(args, context) "{{{
    call unite#sources#tryton_model#load_data(a:context)
    let candidates = []
    for model_name in sort(keys(g:tryton_data_cache))
        let mdata = g:tryton_data_cache[model_name]
        call add(candidates, {
                \ 'word': tryton#tools#pad_string(mdata.string, 60) . ' ' .
                    \ model_name,
                \ 'kind': 'tryton_model',
                \ 'source__info': {'model_name': model_name},
                \ })
    endfor
    return candidates
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
