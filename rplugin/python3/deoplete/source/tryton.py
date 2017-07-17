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
import json
from .base import Base

SUPER_KEY = ' super('


class Source(Base):

    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'tryton'
        self.mark = '[Tryton]'
        self.min_pattern_length = 0
        self.rank = 1000
        self.__local_cache = None
        self.__models = []

    @property
    def local_cache(self):
        if self.__local_cache is not None:
            return self.__local_cache
        cache = self.vim.funcs.exists('g:tryton_data_cache')
        if cache:
            fname = self.vim.call('tryton#tools#get_model_cache_path')
            with open(fname, 'r') as f:
                self.__local_cache = json.loads(f.read()[:-2])
            self.__models = [{
                        'word': x, 'abbr': x,
                        'kind': 'model'}
                    for x in sorted(self.__local_cache.keys())]
            return self.__local_cache
        else:
            self.vim.call('LoadTrytonData')
            return self.local_cache

    def on_event(self, context):
        pass

    def get_base_string(self, context):
        data = ' ' + context['input'].lstrip()
        idx = -1
        while True:
            new_idx = data.find(SUPER_KEY, idx + 1)
            if new_idx != -1:
                idx = new_idx
            break
        if idx == -1:
            return context['input'].lstrip().split(' ')[-1]
        new_base = context['input'].lstrip()[idx:]
        matchs = re.findall(r'super\([^)]*\)', new_base)
        if not matchs:
            return new_base
        if len(new_base[len(matchs[0]):].split(' ')) > 1:
            return new_base[len(matchs[0]):].split(' ')[-1]
        return new_base

    def get_complete_position(self, context):
        data = context['input']
        trimmed = self.get_base_string(context)
        if self.get_model(trimmed):
            pos = data.rfind('.')
            return pos if pos < 0 else pos + 1
        if trimmed.startswith("'"):
            return len(data) - len(trimmed) + 1
        return len(data) - len(trimmed)

    def gather_candidates(self, context):
        path = self.get_base_string(context).split('.')
        first = path[0]

        model = self.get_model(first)
        if model == '':
            if first.startswith("'"):
                return self.__models
            return []

        for key in path[1:-1]:
            model_data = self.local_cache.get(model, {})
            if not model_data:
                return []
            if key in model_data['fields']:
                model = model_data['fields'][key].get('target_model', None)
                if not model:
                    return []
            else:
                return []

        model_data = self.local_cache.get(model, {})
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
        info = 'Method %s of %s : %s' % (mname, model_name,
                                         mdata['parameters'])
        modules, classes = [], []
        for k in sorted(mdata['mro'].keys()):
            frame = mdata['mro'][k]
            if frame['base_name'] == model_name:
                modules.append(frame['module'])
            else:
                classes.append(frame['base_name'])
        return {
            'word': mname,
            'kind': 'meth  ' + ('[%s]' % module if module else ''),
            'menu': mdata['parameters'],
            'info': '\n'.join([info, '', 'Classes : ' + ', '.join(classes),
                               '', 'Modules : ' + ', '.join(modules)]),
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
