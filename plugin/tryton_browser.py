#!/usr/bin/env python
import argparse
import pprint
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
