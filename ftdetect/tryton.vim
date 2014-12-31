" #############################################################################
" File: tryton.vim
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

if exists("g:tryton_ftdetect") && g:tryton_ftdetect
    finish
endif

let g:tryton_ftdetect = 1

" Guess for python or xml files
autocmd BufNewFile,BufRead *.py call <SID>IsTrytonPy()
autocmd BufNewFile,BufRead *.xml call <SID>IsTrytonXml()

function! s:HasTryton()  " {{{
    return search('tryton', 'nw')
endfunction  " }}}

function! s:IsTrytonPy()  " {{{
    if <SID>HasTryton()
        setlocal filetype=python.trpy
    endif
endfunction  " }}}

function! s:IsTrytonXml()  " {{{
    if <SID>HasTryton()
        setlocal filetype=xml.trxml
    else
        " Check we are not in the 'view' folder
        let tryton_cfg = globpath(expand("%:p:h"), '../tryton.cfg')
        if strlen(tryton_cfg) > 0
            setlocal filetype=xml.trxml
        endif
    endif
endfunction  " }}}

let &cpo = s:save_cpo
unlet s:save_cpo
