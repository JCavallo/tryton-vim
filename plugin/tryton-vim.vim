" #############################################################################
" File: tryton-vim.vim
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

let g:tryton_path_config = {
    \ "word__extract": "format_model",
    \ "fields": {
        \ "word__extract": "format_field",
        \ "action__extract": "action_field",
        \ },
    \ "mro": {
        \ "word__extract": "format_mro",
        \ "action__extract": "action_mro",
        \ },
    \ }

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
    nnoremap <silent><leader>ac
        \ :execute "normal \<Plug>(tryton-search-class)"<CR>
    nnoremap <silent><leader>an
        \ :execute "normal \<Plug>(tryton-search-model)"<CR>
    nnoremap <silent><leader>ad
        \ :execute "normal \<Plug>(tryton-search-function)"<CR>
    nnoremap <silent><leader>af
        \ :execute "normal \<Plug>(tryton-search-field)"<CR>
    nnoremap <silent><leader>arm
        \ :execute "normal \<Plug>(tryton-search-many2one)"<CR>
    nnoremap <silent><leader>aro
        \ :execute "normal \<Plug>(tryton-search-one2many)"<CR>
    nnoremap <silent><leader>arfm
        \ :execute "normal \<Plug>(tryton-searchall-many2one)"<CR>
    nnoremap <silent><leader>arfo
        \ :execute "normal \<Plug>(tryton-searchall-one2many)"<CR>
    nnoremap <silent><leader>bcm
        \ :execute "normal \<Plug>(tryton-browse-current-model)"<CR>
endif

nnoremap <silent><Plug>(tryton-validate-xmlform)
    \ :<C-U>call tryton#tools#ValidateXml('form')<CR>
noremap <silent><Plug>(tryton-validate-xmltree)
    \ :<C-U>call tryton#tools#ValidateXml('tree')<CR>
noremap <silent><Plug>(tryton-validate-xmlgraph)
    \ :<C-U>call tryton#tools#ValidateXml('graph')<CR>
noremap <silent><Plug>(tryton-xml-format)
    \ :<C-U>call tryton#tools#FormatXml()<CR>
noremap <silent><Plug>(tryton-search-class)
    \ :<C-U>call tryton#search#SearchClass()<CR>
noremap <silent><Plug>(tryton-search-model)
    \ :<C-U>call tryton#search#SearchModel()<CR>
noremap <silent><Plug>(tryton-search-function)
    \ :<C-U>call tryton#search#SearchFunction()<CR>
noremap <silent><Plug>(tryton-search-field)
    \ :<C-U>call tryton#search#SearchField()<CR>
noremap <silent><Plug>(tryton-search-many2one)
    \ :<C-U>call tryton#search#SearchMany2One(0)<CR>
noremap <silent><Plug>(tryton-search-one2many)
    \ :<C-U>call tryton#search#SearchOne2Many(0)<CR>
noremap <silent><Plug>(tryton-searchall-many2one)
    \ :<C-U>call tryton#search#SearchMany2One(1)<CR>
noremap <silent><Plug>(tryton-searchall-one2many)
    \ :<C-U>call tryton#search#SearchOne2Many(1)<CR>
nnoremap <silent><Plug>(tryton-browse-current-model)
    \ :<C-U>call unite#start_script([['tryton_details',
        \ tryton#tools#get_current_model()]])<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
