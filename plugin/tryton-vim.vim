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

noremap <silent><Plug>TrytonValidateXmlForm :call tryton#tools#ValidateXml("form")<CR>
noremap <silent><Plug>TrytonValidateXmlTree :call tryton#tools#ValidateXml("tree")<CR>
noremap <silent><Plug>TrytonValidateXmlGraph :call tryton#tools#ValidateXml("graph")<CR>
noremap <silent><Plug>TrytonFormatXml :call tryton#tools#FormatXml()<CR>
noremap <silent><Plug>TrytonSearchClass :call tryton#search#SearchClass()<CR>
noremap <silent><Plug>TrytonSearchModel :call tryton#search#SearchModel()<CR>
noremap <silent><Plug>TrytonSearchFunction :call tryton#search#SearchFunction()<CR>
noremap <silent><Plug>TrytonSearchField :call tryton#search#SearchField()<CR>
noremap <silent><Plug>TrytonSearchMany2One :call tryton#search#SearchMany2One(0)<CR>
noremap <silent><Plug>TrytonSearchOne2Many :call tryton#search#SearchOne2Many(0)<CR>
noremap <silent><Plug>TrytonSearchAllMany2One :call tryton#search#SearchMany2One(1)<CR>
noremap <silent><Plug>TrytonSearchAllOne2Many :call tryton#search#SearchOne2Many(1)<CR>

if !exists("g:tryton_default_mappings") || g:tryton_default_mappings
    nnoremap <leader>xf <Plug>TrytonValidateXmlForm
    nnoremap <leader>xt <Plug>TrytonValidateXmlTree
    nnoremap <leader>xg <Plug>TrytonValidateXmlGraph
    nnoremap <leader>xx <Plug>TrytonFormatXml
    nnoremap <leader>ac <Plug>TrytonSearchClass
    nnoremap <leader>an <Plug>TrytonSearchModel
    nnoremap <leader>ad <Plug>TrytonSearchFunction
    nnoremap <leader>af <Plug>TrytonSearchField
    nnoremap <leader>arm <Plug>TrytonSearchMany2One
    nnoremap <leader>aro <Plug>TrytonSearchOne2Many
    nnoremap <leader>arfm <Plug>TrytonSearchMany2One
    nnoremap <leader>arfo <Plug>TrytonSearchOne2Many
endif
