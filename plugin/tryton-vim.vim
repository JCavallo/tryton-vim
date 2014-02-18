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
