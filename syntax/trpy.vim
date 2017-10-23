" #############################################################################
" File: syntax/trpy.vim
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

if exists("b:current_syntax")
    " This file completes the base python syntax file
    if b:current_syntax ==# 'trpy'
        finish
    endif
endif

let python_highlight_all = 1

setlocal foldmethod=syntax

syn keyword trytonKeywords      fields model Transaction Pool context PoolMeta
syn keyword trytonKeywords      pool _history __name__ _table _rec_name __rpc__
syn keyword trytonKeywords      _buttons _error_messages __table__
syn keyword trytonKeywords      _sql_constraints __all__ __name__ __metaclass__
syn keyword trytonKeywords      cursor transaction RPC

syn keyword trytonFieldData     depends domain ondelete setter getter searcher
syn keyword trytonFieldData     states required select size order_field loading
syn keyword trytonFieldData     digits readonly context

syn keyword trytonFieldClass    One2Many Char Integer Many2One Dict Text Date
syn keyword trytonFieldClass    Many2Many Binary Selection Reference Function
syn keyword trytonFieldClass    Numeric Boolean Wizard StateAction Button
syn keyword trytonFieldClass    StateView StateTransition TimeDelta TimeStamp
syn keyword trytonFieldClass    MultiValue Property

syn keyword trytonPyson         Eval Bool Len If Or And Not In

syn match   trytonFieldName     "^    [a-zA-Z_][a-zA-Z0-9][a-zA-Z0-9_]* "
    \ contained

" Following clears must be tried because they may not exist depending on the
" runtime version

" Clear pythonFunction for proper matching order, replaced with trytonXXXDef
try
    syn clear pythonFunction
catch
endtry

" Remove pythonDocTestValue, fails with trytonFieldDeclaration
try
    syn clear pythonDoctestValue
catch
endtry

" Redefine pythonStatement to remove class / def
try
    syn clear pythonStatement
catch
endtry

" Redefine pythonAttribute to allow custom highlighting of special functions
try
    syn clear pythonAttribute
catch
endtry

" Remove unused expensive match
try
    syn clear pythonMatrixMultiply
catch
endtry

" Add self / cls to pythonBuiltin
syn keyword trytonBuiltin       self cls

syn match   trytonConstant      "\%(^\|\W\)\zs[A-Z_][A-Z_]\+\ze\%(\W\|$\)"

syn match   trytonFunctionDef   /^\s*def /me=e-1
    \ nextgroup=trytonCoreFunction,trytonSpecFunction,trytonStandardFunction
    \ skipwhite
syn match   trytonClassDef      /^\s*class\ze / nextgroup=trytonStandardFunction
    \ skipwhite
syn match   trytonStandardFunction " [a-zA-Z_][a-zA-Z0-9_]*\%((\|:\)"me=e-1,ms=s+1 contained
syn match   trytonSpecFunction  "\W\%(on_change_with_\|on_change_\|default_\|transition_\|search_\|getter_\|setter_\|order_\|domain_\)[a-zA-Z0-9_]\+("me=e-1,ms=s+1
syn match   trytonCoreFunction  "\W\%(__setup__\|__register__\|create\|write\|delete\|copy\|view_attributes\)("me=e-1,ms=s+1

syn region  trytonVariableDeclaration   start="^[a-zA-Z_][a-zA-Z0-9_]* = "
  \ end="\ze\%(\s*\n\)\+\%(\s\)\@!." fold transparent
syn region  trytonFunctionFold  start="^\z(\s*\)def "
    \ end="\ze\%(\s*\n\)\+\%(\z1\s\)\@!." fold transparent
syn region  trytonClassFold  start="^\z(\s*\)class "
    \ end="\ze\%(\s*\n\)\+\%(\z1\s\)\@!." fold transparent
syn region  trytonFieldDeclaration   start="^\z(\s*\)\([a-zA-Z_][a-zA-Z0-9_]*\) = \%(fields\.\|StateTransition\|StateView\|StateAction\|[a-zA-Z0-9_]\+\.translated\)"
  \ end="\ze\%(\s*\n\)\+\%(\z1\s\)\@!." fold transparent contains=ALLBUT,trytonFunctionDef

syn keyword pythonStatement False None True
syn keyword pythonStatement as assert break continue del exec global
syn keyword pythonStatement lambda nonlocal pass print return with yield

hi def link trytonFieldName          StorageClass
hi def link trytonFieldClass         Directory
hi def link trytonKeywords           Label
hi def link trytonConstant           Label
hi def link trytonSpecial            Label
hi def link trytonPyson              Label
hi def link trytonFieldData          Delimiter
hi def link trytonFunctionDef        Statement
hi def link trytonClassDef           Statement
hi def link trytonCoreFunction       Directory
hi def link trytonSpecFunction       Directory
hi def link trytonStandardFunction   Function
hi def link trytonBuiltin            PreCondit

let b:current_syntax = "trpy"
