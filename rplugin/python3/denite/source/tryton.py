# ============================================================================
# File: rplugin/python3/denite/source/tryton.py
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

import json
from .base import Base
from ..kind.walkable import Kind


class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'tryton'
        self.kind = Kind(vim)
        self.__local_cache = None
        self.__syn_clear = []

    def on_init(self, context):
        self.walk_path = []
        if context['args'] and len(context['args'][0]) > 0:
            self.walk_path = context['args'][0].split('/')
        self.format_config = self.vim.call(
            'tryton#tools#get_conf_from_path', self.walk_path + [''])
        self.trytond_path = self.vim.funcs.expand(
            self.vim.call('tryton#tools#GetTrytondPath'))

    def _get_data(self, path, context):
        data = self.local_cache
        for key in path:
            data = data[key]
        return data

    @property
    def local_cache(self):
        if self.__local_cache is not None:
            return self.__local_cache
        cache = self.vim.funcs.exists('g:tryton_data_cache')
        if cache:
            fname = self.vim.call('tryton#tools#get_model_cache_path')
            with open(fname, 'r') as f:
                self.__local_cache = json.loads(f.read()[:-2])
            return self.__local_cache
        else:
            self.vim.call('LoadTrytonData')
            return self.local_cache

    def pad_value(self, value, size):
        return value[:size - 1].ljust(size - 1) + ' '

    def gather_candidates(self, context):
        data = self._get_data(self.walk_path, context)
        candidates = []
        for key in sorted(data.keys()):
            candidates.append(self.new_candidate(key, context))
        return candidates

    def new_candidate(self, key, context):
        candidate = {
            'word': self.format_candidate_word(key, context),
            }
        candidate.update(self._new_candidate_base_actions(key, context))
        candidate.update(self._new_candidate_actions(key, context))
        return candidate

    def format_candidate_word(self, key, context):
        data = self._get_data(self.walk_path, context)[key]
        format_method = getattr(self, self.format_config['word__extract'])
        return format_method(key, data, self.format_config['word__columns'])

    def format_default(self, key, data, config):
        value = str(data)
        if isinstance(data, dict):
            if len(data):
                value = '----->'
            else:
                value = '(empty)'
        return self.pad_value(key, config['string'][0]) + value

    def format_model(self, key, data, config):
        return self.pad_value(data['string'], config['string'][0]) + key

    def format_field(self, key, data, config):
        word = self.pad_value(data['string'], config['string'][0])
        word += '(F) ' if data['is_function'] else '    '
        word += self.pad_value('(' + data['kind'] + ')', config['kind'][0])
        word += self.pad_value(key, config['key'][0]) + self.walk_path[0]
        return word

    def format_mro(self, key, data, config):
        word = self.pad_value(key, config['key'][0])
        word += self.pad_value(data['path'], config['path'][0])
        if data['override']:
            word += '[O] '
        elif data['initial']:
            word += '[I] '
        else:
            word += '    '
        word += self.pad_value(data['module'], config['module'][0])
        return word + data['base_name']

    def format_method(self, key, data, config):
        word = self.pad_value(key, config['key'][0])
        return word + (' (' + data['field'] + ')' if data['field'] else '  ')

    def format_view(self, key, data, config):
        word = self.pad_value(key, config['key'][0])
        word += self.pad_value(data['type'], config['type'][0])
        word += '[I] ' if len(data.get('inherit', [])) > 0 else '    '
        return word + data['module'] + '.' + data['functional_id']

    def _new_candidate_base_actions(self, key, context):
        target_path = self.walk_path.copy()
        data = self._get_data(self.walk_path, context)
        if isinstance(data[key], (dict, list)) and len(data[key]):
            target_path.append(key)
        model = self.walk_path[0] if self.walk_path else key
        path, pattern = self.candidate_path(context, key)
        return {
            'kind': 'walkable',
            'action__walk_source': 'tryton',
            'action__walk_down': '/'.join(target_path),
            'action__walk_up': '/'.join(self.walk_path[:-1]),
            'action__tryton_model': model,
            'action__initial_model': self.candidate_initial_model(model),
            'action__path': path,
            'action__pattern': pattern,
            }

    def _new_candidate_actions(self, key, context):
        method = getattr(self, self.format_config.get('action__extract'))
        return method(key, context)

    def action_default(self, key, context):
        return {}

    def action_mro(self, key, context):
        return {}

    def action_fields(self, key, context):
        data = self._get_data(self.walk_path, context)[key]
        methods = self._get_data([self.walk_path[0], 'methods'], context)
        action_data = {'kind': 'tryton_field'}
        action_data['action__getter'] = data.get('getter', '')
        action_data['action__setter'] = data.get('setter', '')
        action_data['action__searcher'] = data.get('searcher', '')
        for mname in ['order', 'default', 'on_change', 'on_change_with']:
            real_method = mname + '_' + key
            action_data['action__' + mname] = real_method \
                if real_method in methods else ''
        return action_data

    def action_method_mro(self, key, context):
        return {}

    def action_view(self, key, context):
        return {}

    def candidate_initial_model(self, model):
        if not self.trytond_path or not model:
            return None
        initial = [x for _, x in self.local_cache[model]['mro'].items()
                   if x['initial']][0]
        return self.trytond_path + '/' + initial['path'].replace('.', '/') + \
            '.py'

    def candidate_path(self, context, key):
        if not self.trytond_path:
            return None, None
        data = self._get_data(self.walk_path, context)
        if self.walk_path and self.walk_path[-1] in ('views', 'inherit'):
            return (self.trytond_path + '/trytond/modules/' +
                    data[key]['module'] + '/view/' + data[key]['name'] +
                    '.xml',
                    None)
        elif 'views' in self.walk_path:
            return (self.trytond_path + '/trytond/modules/' +
                    data['module'] + '/view/' + data['name'] + '.xml', None)
        if 'methods 'in self.walk_path:
            if 'mro' in self.walk_path:
                path = self.trytond_path + '/' + \
                    data[key]['path'].replace('.', '/') + '.py'
                pattern = '^ *__name__ = [\'"]' + self.walk_path[0] + '[\'"]' \
                    + '\\n\\(.*\\n\\)\\{-} *\\zsdef ' + self.walk_path[-2] + \
                    '\\ze('
                return path, pattern
            else:
                initial = [x for _, x in data[key]['mro'].items()
                           if x['initial']][0]
                path = self.trytond_path + '/' + \
                    initial['path'].replace('.', '/') + '.py'
                pattern = '^ *__name__ = [\'"]' + self.walk_path[0] + '[\'"]' \
                    + '\\n\\(.*\\n\\)\\{-} *\\zsdef ' + key + '\\ze('
                return path, pattern
        if 'mro' in self.walk_path and self.walk_path[-1] == 'mro':
            path = self.trytond_path + '/' + \
                data[key]['path'].replace('.', '/') + '.py'
            if data[key]['initial'] or data[key]['override']:
                pattern = '^ *__name__ = [\'"]' + self.walk_path[0] + '[\'"]'
            else:
                pattern = '^ *class ' + data[key]['base_name'] + '\\((\\|:\\)'
            return path, pattern
        if 'fields' in self.walk_path:
            model = self.walk_path[0]
            field = self.walk_path[2] if len(self.walk_path) > 2 else key
            field_data = self.local_cache[model]['fields'][field]
            good = [x for x in self.local_cache[model]['mro'].values()
                    if x['module'] == field_data['module']][0]
            path = self.trytond_path + '/' + \
                good['path'].replace('.', '/') + '.py'
            pattern = '^ *__name__ = [\'"]' + self.walk_path[0] + '[\'"]' \
                + '\\n\\(.*\\n\\)\\{-} *\\zs' + field + '\\ze = fields\\.'
            return path, pattern
        model = self.walk_path[0] if self.walk_path else key
        initial = [x for x in self.local_cache[model]['mro'].values()
                   if x['initial']][0]
        path = self.trytond_path + '/' + initial['path'].replace('.', '/') + \
            '.py'
        pattern = '^ *__name__ = [\'"]' + model + '[\'"]'
        return path, pattern

    def highlight(self):
        for key in self.__syn_clear:
            self.vim.command('syntax clear %s' % key)
        self.__syn_clear = []
        for k, (_, value) in self.format_config['word__columns'].items():
            key = 'deniteSource__tryton%s%s' % (
                self.format_config['word__kind'], k)
            self.vim.command(
                'highlight default link %s %s' % (key, value))
            self.__syn_clear.append(key)

    def define_syntax(self):
        def get_width(key):
            return self.format_config['word__columns'][key][0]

        def get_highlight(key):
            return 'deniteSource__tryton%s%s' % (
                self.format_config['word__kind'], key)

        cur_end = 1
        if not self.walk_path:
            cur_end += get_width('string')
            self.vim.command(
                'syntax region %s start="^" end="\%%%ic"'
                % (get_highlight('string'), cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('string')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="$"'
                % (get_highlight('key'), cur_start))
        elif self.walk_path[-1] == 'fields':
            cur_end += get_width('string')
            self.vim.command(
                'syntax region %s start="^" end="\%%%ic"'
                % (get_highlight('string'), cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('function')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('function'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('kind')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('kind'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('key')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('key'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('module')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="$"'
                % (get_highlight('module'), cur_start))
        elif self.walk_path[-1] == 'mro':
            cur_end += get_width('key')
            self.vim.command(
                'syntax region %s start="^" end="\%%%ic"'
                % (get_highlight('key'), cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('path')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('path'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('override')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('override'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('module')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('module'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('base_name')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="$"'
                % (get_highlight('base_name'), cur_start))
        elif self.walk_path[-1] in ('views', 'inherit'):
            cur_end += get_width('key')
            self.vim.command(
                'syntax region %s start="^" end="\%%%ic"'
                % (get_highlight('key'), cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('type')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('type'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('inherit')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="\%%%ic"'
                % (get_highlight('inherit'), cur_start, cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('id')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="$"'
                % (get_highlight('id'), cur_start))
        elif self.walk_path[-1] == 'methods':
            cur_end += get_width('key')
            self.vim.command(
                'syntax region %s start="^" end="\%%%ic"'
                % (get_highlight('key'), cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('field')
            self.vim.command(
                'syntax region %s start="\%%%ic" end="$"'
                % (get_highlight('field'), cur_start))
        else:
            cur_end += get_width('string')
            self.vim.command(
                'syntax region %s start="^" end="\%%%ic"'
                % (get_highlight('string'), cur_end))
            cur_start, cur_end = cur_end + 1, cur_end + get_width('value')
            self.vim.command(
                'syntax match %s /----->/' % (get_highlight('arrow')))
            self.vim.command(
                'syntax match %s /\%%%ic[^-].*[^>]$/'
                % (get_highlight('value'), cur_start))
        return
