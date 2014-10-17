" Xml validation based on relaxng files
nnoremap <leader>xf :%w !xmllint --noout --relaxng $VIRTUAL_ENV/tryton-workspace/trytond/trytond/ir/ui/form.rng %:p
nnoremap <leader>xt :%w !xmllint --noout --relaxng $VIRTUAL_ENV/tryton-workspace/trytond/trytond/ir/ui/tree.rng %:p
nnoremap <leader>xg :%w !xmllint --noout --relaxng $VIRTUAL_ENV/tryton-workspace/trytond/trytond/ir/ui/graph.rng %:p
nnoremap <leader>xx :silent 1,$!XMLLINT_INDENT="    " xmllint --format --recover - 2>/dev/null<CR>

let g:tr_grep_command = 'Unite grep:.:-inR:'
let g:tr_grep_options =' -buffer-name=grep%".tabpagenr()." -auto-preview -no-split -no-empty'

nnoremap <leader>ac :call SearchClass()<CR>
nnoremap <leader>an :call SearchModel()<CR>
nnoremap <leader>ad :call SearchFunction()<CR>
nnoremap <leader>af :call SearchField()<CR>
nnoremap <leader>arm :call SearchRelationMany2One()<CR>
nnoremap <leader>aro :call SearchRelationOne2Many()<CR>
function! SearchClass()
    let a:class_name = unite#util#input('Class Name: ')
    let a:request = '^\ *class\ [a-zA-Z0-9]*' . a:class_name
    execute g:tr_grep_command . a:request . g:tr_grep_options
endfunction
function! SearchModel()
    let a:model_name = unite#util#input('Model Name: ')
    let a:request = '^\ *__name__\ =\ ' . "\'" . a:model_name . "\'"
    execute g:tr_grep_command . a:request . g:tr_grep_options
endfunction
function! SearchFunction()
    let a:function_name = unite#util#input('Function Name: ')
    let a:request = '^\ *def\ ' . a:function_name
    execute g:tr_grep_command . a:request . g:tr_grep_options
endfunction
function! SearchField()
    let a:field_name = unite#util#input('Field Name: ')
    let a:request = '^\ *' . a:field_name . '\ =\ fields\.[a-zA-Z0-9]*\\\('
    execute g:tr_grep_command . a:request . g:tr_grep_options
endfunction
function! SearchRelationMany2One()
    let a:relation_model = unite#util#input('Relation Model: ')
    let a:request = '^\ *[a-z0-9_]*\ =\ fields\.Many2One\\\([\\n\ ]*' . "'" . a:relation_model . "'"
    execute g:tr_grep_command . a:request . g:tr_grep_options
endfunction
function! SearchRelationOne2Many()
    let a:relation_model = unite#util#input('Relation Model: ')
    let a:request = '^\ *[a-z0-9_]*\ =\ fields\.One2Many\\\([\\n\ ]*' . "'" . a:relation_model . "'"
    execute g:tr_grep_command . a:request . g:tr_grep_options
endfunction

" Other mappings to do
" nmap <leader>ax <Esc>:Ag -G xml 
" nmap <leader>agfm <Esc>:Ag "^ *[a-zA-Z_]* = (fields\.Function\()?[\n ]*fields\.Many2One\([\n ]*'
" nmap <leader>agfo <Esc>:Ag "^ *[a-zA-Z_]* = (fields\.Function\()?[\n ]*fields\.One2Many\([\n ]*'
