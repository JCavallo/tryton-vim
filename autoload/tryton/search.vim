" #############################################################################
" File: autoload/tryton/search.vim
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

function! tryton#search#Search(pattern, unite_bufname)  " {{{
    let buffer_name_opt = " -buffer-name=" . a:unite_bufname
    execute g:tryton_grep_command . a:pattern . buffer_name_opt
        \ . g:tryton_grep_options
endfunction  " }}}

function! tryton#search#SearchClass()  " {{{
    let class_name = unite#util#input('Class Name: ')
    let pattern = '^\ *class\ [a-zA-Z0-9]*' . class_name
    call tryton#search#Search(pattern, 'Search\ for\ Class\ ' . class_name)
endfunction  " }}}

function! tryton#search#SearchModel()  " {{{
    let model_name = unite#util#input('Model Name: ')
    let pattern = '^\ *__name__\ =\ ' . "\'" . model_name . "\'"
    call tryton#search#Search(pattern, 'Search\ for\ Model\ ' . model_name)
endfunction  " }}}

function! tryton#search#SearchFunction()  " {{{
    let function_name = unite#util#input('Function Name: ')
    let pattern = '^\ *def\ ' . function_name
    call tryton#search#Search(pattern, 'Search\ for\ Function\ '
        \ . function_name)
endfunction  " }}}

function! tryton#search#SearchField()  " {{{
    let field_name = unite#util#input('Field Name: ')
    let pattern = '^\ *' . field_name . '\ =\ fields\.[a-zA-Z0-9]*\\\('
    call tryton#search#Search(pattern, 'Search\ for\ Field\ ' . field_name)
endfunction  " }}}

function! tryton#search#SearchMany2One(include_functions)  " {{{
    let relation_model = unite#util#input('Relation Model: ')
    let pattern = '^\ *[a-z0-9_]*\ =\ '
    if a:include_functions
        let pattern = pattern . '(fields\.Function\\\([\\n\ ]*)?'
    endif
    let pattern = pattern . 'fields\.Many2One\\\([\\n\ ]*' . "'"
        \ . relation_model . "'"
    call tryton#search#Search(pattern, 'Search\ for\ Many2One\ '
        \ . relation_model)
endfunction  " }}}

function! tryton#search#SearchOne2Many(include_functions)  " {{{
    let relation_model = unite#util#input('Relation Model: ')
    let pattern = '^\ *[a-z0-9_]*\ =\ '
    if a:include_functions
        let pattern = pattern . '(fields\.Function\\\([\\n\ ]*)?'
    endif
    let pattern = pattern . 'fields\.One2Many\\\([\\n\ ]*' . "'"
        \ . relation_model . "'"
    call tryton#search#Search(pattern, 'Search\ for\ One2Many\ '
        \ . relation_model)
endfunction  " }}}
