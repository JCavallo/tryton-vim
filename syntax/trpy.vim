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

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    " We need to complete the python syntax file
    if b:current_syntax ==# 'trpy'
        finish
    endif
endif

let python_highlight_all = 1

setlocal foldmethod=syntax

syn keyword trytonKeywords      fields model Transaction Pool context PoolMeta
syn keyword trytonKeywords      pool _history __name__

syn keyword trytonFieldData     depends domain ondelete setter getter searcher
syn keyword trytonFieldData     states required select size order_field loading
syn keyword trytonFieldData     digits readonly context

syn keyword trytonFieldClass    One2Many Char Integer Many2One Dict Text Date
syn keyword trytonFieldClass    Many2Many Binary Selection Reference Function
syn keyword trytonFieldClass    Numeric Boolean Wizard StateAction Button
syn keyword trytonFieldClass    StateView StateTransition

syn keyword trytonPyson         Eval Bool Len If Or And Not In

syn match   trytonFieldName     "^    [a-zA-Z_][a-zA-Z0-9][a-zA-Z0-9_]* "
    \ contained

" Clear pythonFunction for proper matching order, replaced with trytonXXXDef
syn clear pythonFunction

" Remove pythonDocTestValue, fails with trytonFieldDeclaration
syn clear pythonDoctestValue

" Redefine pythonStatement to remove class / def
syn clear pythonStatement
syn keyword pythonStatement     False None True
syn keyword pythonStatement     as assert break continue del exec global
syn keyword pythonStatement     lambda nonlocal pass print return with yield

syn match   OperatorChars       "?\|+\|-\|\*\|;\|:\|,\|<\|>\|&\||\|!\|\~\|%\|=\|\.\|/\(/\|*\)\@!"

" Add self / cls to pythonBuiltin
syn keyword trytonBuiltin       self cls

syn match   trytonSpecial       "__[a-zA-Z0-9_]*__"
syn match   trytonFunctionDef   /^\s*def /
    \ nextgroup=trytonSpecFunction,trytonCoreFunction,trytonStandardFunction
    \ skipwhite
syn match   trytonClassDef      /^\s*class / nextgroup=trytonStandardFunction
    \ skipwhite
syn match   trytonStandardFunction "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn match   trytonSpecFunction  "\%(on_change_with_\|on_change_\|default_\|transition_\|search_\|getter_\|order_\|domain\)[a-zA-Z0-9_]\+" contained
syn match   trytonCoreFunction  "\%(__setup__\|__register__\|create\|write\|delete\|copy\)" contained

syn region  trytonVariableDeclaration   start="^[a-zA-Z_][a-zA-Z0-9_]* = "
  \ end="\ze\%(\s*\n\)\+\%(\s\)\@!." fold transparent
syn region  trytonFunctionFold  start="^\z(\s*\)def "
    \ end="\ze\%(\s*\n\)\+\%(\z1\s\)\@!." fold transparent
syn region  trytonClassFold  start="^\z(\s*\)class "
    \ end="\ze\%(\s*\n\)\+\%(\z1\s\)\@!." fold transparent
syn region  trytonFieldDeclaration   start="^\z(\s*\)\([a-zA-Z_][a-zA-Z0-9_]*\) = \%(fields\.\|StateTransition\|StateView\|StateAction\)"
  \ end="\ze\%(\s*\n\)\+\%(\z1\s\)\@!." fold transparent contains=ALLBUT,trytonFunctionDef

if version >= 508 || !exists("did_python_syn_inits")
    if version <= 508
        let did_python_syn_inits = 1
        command -nargs=+ HiLink hi link <args>
    else
        command -nargs=+ HiLink hi def link <args>
    endif

    " The default methods for highlighting.  Can be overridden later
    HiLink trytonFieldName          StorageClass
    HiLink trytonFieldClass         Directory
    HiLink trytonKeywords           Label
    HiLink trytonSpecial            Label
    HiLink trytonPyson              Label
    HiLink trytonFieldData          Delimiter
    HiLink trytonFunctionDef        Statement
    HiLink trytonClassDef           Statement
    HiLink trytonCoreFunction       Directory
    HiLink trytonSpecFunction       Directory
    HiLink trytonStandardFunction   Function
    HiLink trytonBuiltin            PreCondit
    HiLink OperatorChars            Identifier
    delcommand HiLink
endif

let b:current_syntax = "trpy"
