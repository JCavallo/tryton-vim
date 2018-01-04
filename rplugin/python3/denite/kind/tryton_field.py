# ============================================================================
# File: rplugin/python3/denite/kind/tryton_field.py
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

from .walkable import Kind as Walkable


class Kind(Walkable):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'tryton_field'

    def _method_action(self, context, meth_key):
        if not context['targets'][0].get('action__' + meth_key, ''):
            return
        self.vim.call('denite#start',
                      [{'name': 'tryton',
                        'args': [context['targets'][0]['action__tryton_model']
                                 + '/methods/'
                                 + context['targets'][0]['action__' +
                                                         meth_key]]}],
                      {'mode': 'normal'})

    def action_jump_to_getter(self, context):
        self._method_action(context, 'getter')

    def action_jump_to_setter(self, context):
        self._method_action(context, 'setter')

    def action_jump_to_searcher(self, context):
        self._method_action(context, 'searcher')

    def action_jump_to_default(self, context):
        self._method_action(context, 'default')

    def action_jump_to_order(self, context):
        self._method_action(context, 'order')

    def action_jump_to_on_change(self, context):
        self._method_action(context, 'on_change')

    def action_jump_to_on_change_with(self, context):
        self._method_action(context, 'on_change_with')
