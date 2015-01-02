" #############################################################################
" File: tools.vim
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

function! tryton#tools#GetTrytondPath()  " {{{
    if exists("g:tryton_trytond_path") &&
            \ isdirectory(expand(g:tryton_trytond_path))
        return g:tryton_trytond_path
    elseif isdirectory(expand("$VIRTUAL_ENV/lib/python-2.7/site-packages/trytond"))
        return "$VIRTUAL_ENV/lib/python-2.7/site-packages/trytond"
    else
        echoerr "Please set the g:tryton_trytond_path variable to a valid path"
        return 0
    endif
endfunction  " }}}

function! tryton#tools#ValidateXml(view_kind)  " {{{
    let path = tryton#tools#GetTrytondPath()
    if path =~ ".*trytond"
        execute ":%w !xmllint --noout --relaxng "
            \ . path . "/trytond/ir/ui/" . a:view_kind
            \ . ".rng %:p"
    endif
endfunction  " }}}

function! tryton#tools#FormatXml()  " {{{
    execute ':silent 1, $!XMLLINT_INDENT="' . g:tryton_xml_indent
        \ '" xmllint --format --recover - 2>/dev/null'
endfunction  " }}}
