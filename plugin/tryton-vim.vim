" #############################################################################
" File: plugin/tryton-vim.vim
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

let g:tryton_xml_indent = "   "
let g:tryton_grep_command = 'Unite grep:.:-inR:'
let g:tryton_grep_options = " -auto-preview -no-split -no-empty"
let g:tryton_parser_path = expand('<sfile>:p:h') . '/tryton_browser.py'
let g:tryton_cache_dir = expand('~/.cache/denite/tryton')

autocmd FileType xml let b:syntastic_xml_xmllint_args =
    \ get(g:, 'syntastic_xml_xmllint_args', '') .
    \ FindXmlRngConfig(expand('<afile>'))

function! FindXmlRngConfig(filename) "{{{
    if get(g:, 'tryton_trytond_path', '') ==# ''
        return ''
    endif
    let rng_file = ''
    if a:filename =~ '.*_form.xml'
        let rng_file = 'form.rng'
    elseif a:filename =~ '.*_list.xml' || a:filename =~ '.*_tree.xml'
        let rng_file = 'tree.rng'
    elseif a:filename =~ '.*_calendar.xml'
        let rng_file = 'calendar.rng'
    elseif a:filename =~ '.*_board.xml'
        let rng_file = 'board.rng'
    endif
    if rng_file ==# ''
        return rng_file
    endif
    return '--relaxng ' . g:tryton_trytond_path . '/trytond/ir/ui/' . rng_file
endfunction " }}}

function! LoadTrytonData() " {{{
    if exists('g:tryton_data_cache')
        return
    endif
    let g:tryton_data_cache = tryton#tools#extract_from_cmd(
        \ 'extract model', 'extract_model', 0)
endfunction " }}}

let g:tryton_path_config = [
    \ [[".*"], {
            \ "word__extract": "format_model",
            \ }],
    \ [[".*", "fields", '.*'], {
            \ "word__extract": "format_field",
            \ "action__extract": "action_fields",
            \ }],
    \ [[".*", "views", '.*'], {
            \ "word__extract": "format_view",
            \ "action__extract": "action_view",
            \ }],
    \ [[".*", "views", '.*', 'inherit', '.*'], {
            \ "word__extract": "format_view",
            \ "action__extract": "action_view",
            \ }],
    \ [[".*", "methods", '.*'], {
            \ "word__extract": "format_method",
            \ }],
    \ [[".*", "methods", '.*', "mro", '.*'], {
            \ "word__extract": "format_method_mro",
            \ "action__extract": "action_method_mro",
            \ }],
    \ [[".*", "mro", '.*'], {
            \ "word__extract": "format_mro",
            \ "action__extract": "action_mro",
            \ }],
    \ ]

if !exists("g:tryton_default_mappings") || g:tryton_default_mappings
    " TODO : investigate why
    "          nnoremap <leader>xf <Plug>(tryton-validate-xmlform)
    " does not work properly, when it works in my vimrc file
    nnoremap <silent><leader>xf
        \ :execute "normal \<Plug>(tryton-validate-xmlform)"<CR>
    nnoremap <silent><leader>xt
        \ :execute "normal \<Plug>(tryton-validate-xmltree)"<CR>
    nnoremap <silent><leader>xg
        \ :execute "normal \<Plug>(tryton-validate-xmlgraph)"<CR>
    nnoremap <silent><leader>xx
        \ :execute "normal \<Plug>(tryton-xml-format)"<CR>
endif

nnoremap <silent><Plug>(tryton-validate-xmlform)
    \ :<C-U>call tryton#tools#ValidateXml('form')<CR>
noremap <silent><Plug>(tryton-validate-xmltree)
    \ :<C-U>call tryton#tools#ValidateXml('tree')<CR>
noremap <silent><Plug>(tryton-validate-xmlgraph)
    \ :<C-U>call tryton#tools#ValidateXml('graph')<CR>
noremap <silent><Plug>(tryton-xml-format)
    \ :<C-U>call tryton#tools#FormatXml()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
