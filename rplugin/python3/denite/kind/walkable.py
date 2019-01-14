# ============================================================================
# File: rplugin/python3/denite/kind/walkable.py
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

from .openable import Kind as Openable


class Kind(Openable):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'walkable'
        self.default_action = 'walk_down'

    def get_walk_command(self, context, direction):
        target = context['targets'][0]
        return [{'name': target['action__walk_source'],
                'args': [target['action__walk_' + direction]]}]

    def get_walk_options(self, context, direction):
        if direction == 'up' and not context['targets'][0]['action__walk_up']:
            return {'mode': 'insert'}
        return {'mode': 'normal'}

    def action_walk_down(self, context):
        self.vim.call('denite#start', self.get_walk_command(context, 'down'),
                      self.get_walk_options(context, 'down'))

    def action_walk_up(self, context):
        self.vim.call('denite#start', self.get_walk_command(context, 'up'),
                      self.get_walk_options(context, 'up'))

    def action_initial_model(self, context):
        to_open = []
        for target in context['targets']:
            if not target['action__initial_model']:
                continue
            target['action__path'] = target['action__initial_model']
            target['action__pattern'] = '^ *__name__ = [\'"]' + \
                target['action__walk_down'].split('/')[0] + '[\'"]'
            to_open.append(target)
        context['targets'] = to_open
        return self.action_open(context)

    def action_model_fields(self, context):
        self.vim.call('denite#start',
                      [{'name': 'tryton',
                        'args': [context['targets'][0]['action__tryton_model']
                                 + '/fields']}],
                      {'mode': 'insert'})

    def action_model_mro(self, context):
        self.vim.call('denite#start',
                      [{'name': 'tryton',
                        'args': [context['targets'][0]['action__tryton_model']
                                 + '/mro']}],
                      {'mode': 'normal'})

    def action_model_methods(self, context):
        self.vim.call('denite#start',
                      [{'name': 'tryton',
                        'args': [context['targets'][0]['action__tryton_model']
                                 + '/methods']}],
                      {'mode': 'insert'})
