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
    \ 'start_insert': 0,
    \ }

function! unite#sources#tryton_details#load_data(context)  " {{{
    if exists('g:tryton_data_cache') && !a:context.is_redraw
        return
    endif
    if exists('g:tryton_data_cache')
        unlet g:tryton_data_cache
    endif
    let model_raw_data = tryton#tools#run_cmd('extract all')
    python import json
    let g:tryton_data_cache = pyeval('json.loads(vim.eval("model_raw_data"))')
endfunction  " }}}

function! s:get_candidate_word(path) " {{{
    let path_config = tryton#tools#get_conf_from_path(a:path)
    let data = tryton#tools#get_data_from_path(a:path)
    execute "return unite#sources#tryton_details#" .
        \ get(path_config, 'word__extract', 'format_default')
        \ . "(a:path, data)"
endfunction  " }}}

function! unite#sources#tryton_details#format_default(path, data)  " {{{
    return a:path[-1]
endfunction  " }}}

function! unite#sources#tryton_details#format_model(path, data)  " {{{
    return tryton#tools#pad_string(a:data['string'], 60) . ' ' . a:path[-1]
endfunction  " }}}

function! unite#sources#tryton_details#format_field(path, data)  " {{{
    let word = tryton#tools#pad_string(a:data['string'], 40) . ' '
    if a:data['is_function']
        let word = word . "(F) "
    else
        let word = word . "    "
    endif
    return word . tryton#tools#pad_string('(' . a:data['kind'] . ')', 20) .
        \ ' ' . tryton#tools#pad_string(a:path[-1], 40) . ' ' . a:path[0]
endfunction  " }}}

function! unite#sources#tryton_details#format_mro(path, data)  " {{{
    let word = tryton#tools#pad_string(a:path[-1], 4) . ' ' .
        \ tryton#tools#pad_string(a:data['path'], 40) . ' '
    let word = word . tryton#tools#pad_string(a:data['module'], 30) . ' '
    if a:data['override']
        let word = word . "[O] "
    elseif a:data['initial']
        let word = word . "[I] "
    else
        let word = word . "    "
    endif
    let word = word . a:data['base_name']
    return word
endfunction  " }}}

function! s:get_candidate_actions(path) " {{{
    let path_config = tryton#tools#get_conf_from_path(a:path)
    let data = tryton#tools#get_data_from_path(a:path)
    execute "return unite#sources#tryton_details#" .
        \ get(path_config, 'action__extract', 'action_default')
        \ . "(a:path, data)"
endfunction  " }}}

function! unite#sources#tryton_details#action_default(path, data)  " {{{
    return [['tryton_detail_iterable'], {'tryton__path': a:path}]
endfunction  " }}}

function! unite#sources#tryton_details#action_mro(path, data)  " {{{
    call tryton#tools#GetTrytondPath()
    let [candidate_kind, candidate_data] =
        \ unite#sources#tryton_details#action_default(a:path, a:data)
    let candidate_kind = ['file_base', 'jump_list'] + candidate_kind
    let candidate_data['action__path'] = expand(g:tryton_trytond_path) . "/" .
        \ substitute(a:data['path'], "\\.", "/", "g") . ".py"
    if a:data['override'] || a:data['initial']
        let candidate_data['action__pattern'] = "^ *__name__ = '" .
            \ a:data['base_name'] . "'"
    else
        let candidate_data['action__pattern'] = "^ *class " .
            \ a:data['base_name']
    endif
    return [candidate_kind, candidate_data]
endfunction  " }}}

function! unite#sources#tryton_details#new_candidate(path)  " {{{
    let word = s:get_candidate_word(a:path)
    let [kind, data] = s:get_candidate_actions(a:path)
    let data['word'] = word
    let data['kind'] = kind
    return data
endfunction  " }}}

function! s:source.gather_candidates(args, context) "{{{
    call unite#sources#tryton_details#load_data(a:context)
    let tr_path = tryton#tools#convert_path(get(a:args, 0, ""))
    let mdata = g:tryton_data_cache
    for path_value in tr_path[:-2]
        let mdata = mdata[path_value]
    endfor
    if len(tr_path) >= 1
        let values = mdata[tr_path[-1]]
    else
        let values = mdata
    endif
    let candidates = []
    for key in sort(keys(values))
        let key_name = tryton#tools#pad_string(key, 40)
        let value = values[key]
        if type(value) == 4
            let path = copy(tr_path) + [key]
            call add(candidates,
                \ unite#sources#tryton_details#new_candidate(path))
        else
            call add(candidates, {
                    \ 'word': key_name . ' ' . value,
                    \ 'kind': 'common',
                    \ })
        endif
        unlet value
    endfor
    return candidates
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
