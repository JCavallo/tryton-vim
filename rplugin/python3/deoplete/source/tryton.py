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
        pos = context['input'].rfind('.')
        return pos if pos < 0 else pos + 1

    def gather_candidates(self, context):
        if self.__local_cache is None:
            cache = self.vim.funcs.exists('g:tryton_data_cache')
            if cache:
                self.__local_cache = self.vim.eval('g:tryton_data_cache')
            else:
                return []
        model = self.vim.call('tryton#tools#get_current_model')
        path = context['input'].split('.')
        first = path[0]
        if first == 'cls' and len(path) > 2:
            return []

        for key in path[1:-1]:
            model_data = self.__local_cache.get(model, {})
            if not model_data:
                return []
            if key in model_data['fields']:
                model = model_data['fields'].get('target_model', None)
                if not model:
                    return
            else:
                return

        model_data = self.__local_cache.get(model, {})
        if not model_data:
            return []
        res = []
        for fname, fdata in model_data.get('fields', {}).items():
            res.append({
                    'word': fname, 'abbr': fname,
                    'kind': 'field (%s)' % fdata['kind'],
                    })
        for mname, mdata in model_data.get('methods', {}).items():
            res.append({
                    'word': mname, 'abbr': mname,
                    'kind': 'method',
                    })
        res.sort(key=lambda x: x['word'])
        return res
