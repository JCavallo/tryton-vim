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


" Tryton Request Parser
python << EOF
import vim
import json
import datetime
def convert_to_json():
    class JSONEncoder(json.JSONEncoder):
        def __init__(self, *args, **kwargs):
            super(JSONEncoder, self).__init__(*args, **kwargs)
            # Force to use our custom decimal with simplejson
            self.use_decimal = False

        def default(self, obj):
            if isinstance(obj, datetime.date):
                if isinstance(obj, datetime.datetime):
                    return {'__class__': 'datetime',
                            'year': obj.year,
                            'month': obj.month,
                            'day': obj.day,
                            'hour': obj.hour,
                            'minute': obj.minute,
                            'second': obj.second,
                            }
                return {'__class__': 'date',
                        'year': obj.year,
                        'month': obj.month,
                        'day': obj.day,
                        }
            elif isinstance(obj, datetime.time):
                return {'__class__': 'time',
                    'hour': obj.hour,
                    'minute': obj.minute,
                    'second': obj.second,
                    }
            elif isinstance(obj, buffer):
                return {'__class__': 'buffer',
                    'base64': base64.encodestring(obj),
                    }
            elif isinstance(obj, Decimal):
                return {'__class__': 'Decimal',
                    'decimal': str(obj),
                    }
            return super(JSONEncoder, self).default(obj)

    vim.command("Scratch")
    vim.command("normal ggdG")
    vim.command("set tw=0")
    vim.command("set filetype=javascript")
    vim.command("set foldmethod=indent")
    vim.command("set foldlevel=3")
    vim.command("set paste")
    vim.command("normal \"*P")
    vim.command("normal gg")
    stop = False
    i = 0
    while stop == False:
        try:
            vim.command("normal %sG0" % str(i + 1))
            value = vim.current.buffer[i]
            if value.startswith('DEBUG'):
                vim.command("normal d2f:")
            elif value.startswith('INFO'):
                vim.command("normal df(")
                vim.command("normal i[")
                vim.command("normal $")
                vim.command("normal r]")
            value = vim.current.buffer[i]
            value = eval(value)
            vim.current.buffer[i] = json.dumps(value, cls=JSONEncoder) + ','
        except:
            stop = True
        i += 1
    # Convert single quotes to double quotes
    # vim.command("%s/\"/xyxz/g")
    # vim.command("%s/'/\"/g")
    # vim.command("%s/xyxz/'/g")
    # Clean values
    try:
        vim.command("%s/None/null/g")
    except:
        pass
    try:
        vim.command("%s/False/false/g")
    except:
        pass
    try:
        vim.command("%s/True/true/g")
    except:
        pass
    # Remove escaped chars
    try:
        vim.command("%s/\\//g")
    except:
        pass
    vim.command("normal gg0i[")
    vim.command("normal %sG$r]" % str(i - 1))
    vim.command("%!python -mjson.tool")
    vim.command("set nopaste")
EOF
map <Leader>fj :py convert_to_json()<CR>
