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

let g:tryton_xml_indent = "    "
let g:tryton_grep_command = 'Unite grep:.:-inR:'
let g:tryton_grep_options = " -auto-preview -no-split -no-empty"

if !exists("g:tryton_default_mappings") || g:tryton_default_mappings
    nnoremap <leader>xf :call tryton#tools#ValidateXml("form")<CR>
    nnoremap <leader>xt :call tryton#tools#ValidateXml("tree")<CR>
    nnoremap <leader>xg :call tryton#tools#ValidateXml("graph")<CR>
    nnoremap <leader>xx :call tryton#tools#FormatXml()<CR>
    nnoremap <leader>ac :call tryton#search#SearchClass()<CR>
    nnoremap <leader>an :call tryton#search#SearchModel()<CR>
    nnoremap <leader>ad :call tryton#search#SearchFunction()<CR>
    nnoremap <leader>af :call tryton#search#SearchField()<CR>
    nnoremap <leader>arm :call tryton#search#SearchMany2One(0)<CR>
    nnoremap <leader>aro :call tryton#search#SearchOne2Many(0)<CR>
    nnoremap <leader>arfm :call tryton#search#SearchMany2One(1)<CR>
    nnoremap <leader>arfo :call tryton#search#SearchOne2Many(1)<CR>
endif
