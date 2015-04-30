#!/usr/bin/env python
###############################################################################
# File: plugin/tryton_browser.vim
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
# }}}
###############################################################################
import argparse
import json


def set_client(parameters):
    from proteus import config

    config.set_xmlrpc(arguments.tryton_url)


def extract(parameters):
    from proteus import Model
    ModelDebug = Model.get('ir.model.debug.model_info')
    if parameters.what == 'model':
        values = ModelDebug.raw_field_infos({})
    elif parameters.what == 'modules':
        values = ModelDebug.raw_module_infos({})
    print json.dumps(values)


# Main parser
parser = argparse.ArgumentParser(description='Browse tryton db')
parser.add_argument('tryton_url', help='Tryton server URL')
subparsers = parser.add_subparsers(title='Main Commands',
    description='Valid Commands', dest='command')

# Extract Things Parser
parser_extract = subparsers.add_parser('extract', help='Extract things')
parser_extract.add_argument('what', help='What to extract',
    choices=['model', 'modules'])

arguments = parser.parse_args()

set_client(arguments)
globals()[arguments.command](arguments)
