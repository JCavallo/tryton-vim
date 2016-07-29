# ============================================================================
# File: rplugin/python3/deoplete/sources/tryton.py
# Author: Jean Cavallo <jean.cavallo@hotmail.fr>
# License: MIT license  {{{
#     Permission is hereby granted, free of charge, to any person obtaining
#     a copy of this software and associated documentation files (the
#     "Software"), to deal in the Software without restriction, including
#     without limitation the rights to use, copy, modify, merge, publish,
#     distribute, sublicense, and/or sell copies of the Software, and to
#     permit persons to whom the Software is furnished to do so, subject to
#     the following conditions:
#
#     The above copyright notice and this permission notice shall be included
#     in all copies or substantial portions of the Software.
#
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ============================================================================

import re
from .base import Base


class Source(Base):

    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'tryton'
        self.mark = '[Tryton]'
        self.min_pattern_length = 0
        self.rank = 1000
        self.__local_cache = None

    def on_event(self, context):
        pass

    def get_complete_position(self, context):
        data = context['input']
        trimmed = data.lstrip()
        if self.get_model(trimmed):
            pos = data.rfind('.')
            return pos if pos < 0 else pos + 1
        return len(data) - len(trimmed)

    def gather_candidates(self, context):
        if self.__local_cache is None:
            cache = self.vim.funcs.exists('g:tryton_data_cache')
            if cache:
                self.__local_cache = self.vim.eval('g:tryton_data_cache')
                self.__models = [{
                            'word': x, 'abbr': x,
                            'kind': 'model'}
                        for x in sorted(self.__local_cache.keys())]
            else:
                return []
        path = context['input'].lstrip().split('.')
        first = path[0]

        model = self.get_model(first)
        if model == '':
            return self.__models

        for key in path[1:-1]:
            model_data = self.__local_cache.get(model, {})
            if not model_data:
                return []
            if key in model_data['fields']:
                model = model_data['fields'][key].get('target_model', None)
                if not model:
                    return []
            else:
                return []

        model_data = self.__local_cache.get(model, {})
        if not model_data:
            return []
        res = []
        for fname in sorted(model_data.get('fields', {}).keys()):
            res.append(self.get_field_candidate(fname, model, model_data))
        for mname in sorted(model_data.get('methods', {}).keys()):
            res.append(self.get_func_candidate(mname, model, model_data))
        return res

    def get_field_candidate(self, fname, model_name, data):
        fdata = data['fields'][fname]
        menu = ('[Function] ' if fdata['is_function'] else '') + fdata['kind']
        info = 'Field %s of %s - %s' % (fname, model_name, menu)
        return {
            'word': fname,
            'kind': 'field [%s]' % fdata['module'],
            'menu': menu,
            'info': '\n'.join([info, ''] + [str(k) + ': ' + str(v)
                    for k, v in fdata.items()]),
            }

    def get_func_candidate(self, mname, model_name, data):
        mdata = data['methods'][mname]
        module = None
        for frame in sorted(mdata['mro']):
            if mdata['mro'][frame]['initial']:
                module = mdata['mro'][frame]['module']
        return {
            'word': mname,
            'kind': 'meth  ' + ('[%s]' % module if module else ''),
            'menu': mdata['parameters'],
            'info': 'Method %s of %s : %s' % (
                mname, model_name, mdata['parameters']),
            }

    def get_model(self, text):
        if bool(text.startswith('cls') or
                re.findall(r'super\(\w+, cls\)', text) or
                text.startswith('self') or
                re.findall(r'super\(\w+, self\)', text)):
            try:
                return self.vim.call('tryton#tools#get_current_model')
            except:
                return ''
        matches = self.vim.funcs.exists('g:tryton_model_match')
        if matches:
            matches = self.vim.eval('g:tryton_model_match')
        if not matches:
            return ''
        return matches.get(text.split('.', 1)[0], '')
