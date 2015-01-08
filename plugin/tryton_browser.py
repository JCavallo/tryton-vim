#!/usr/bin/env python
import argparse
import pprint

MULTIPLE_FIELDS = ['fields']


def set_client(parameters):
    from proteus import config

    config.set_xmlrpc(arguments.tryton_url)


def model_info(parameters):
    from proteus import Model
    ModelDebug = Model.get('ir.model.debug.model_info')
    values = ModelDebug.raw_info(parameters.model_name, {})
    if parameters.field_name:
        pprint.pprint(values['field_infos'][parameters.field_name])
    else:
        pprint.pprint(values)


def extract(parameters):
    from proteus import Model
    ModelDebug = Model.get('ir.model.debug.model_info')
    values = ModelDebug.raw_field_infos({})
    if parameters.what == 'models':
        values = ModelDebug.raw_model_infos({})
        print '\n'.join(['%s;%s' % (mname, '\t'.join([
                            '%s:%s' % (k, v) for k, v in mvalues.iteritems()]))
                for mname, mvalues in values.iteritems()])
    elif parameters.what == 'fields':
        values = ModelDebug.raw_info(parameters.model_name, {})
        for model_name, vals in values.iteritems():
            if not parameters.full:
                print '\n'.join(['%s:%s:%s:%s' % (model_name, fname,
                            fvalue['string'], fvalue['kind'])
                        for fname, fvalue in vals['fields'].iteritems()])
            else:
                print '\n'.join(['%s,%s;%s' % (
                            model_name, fname, '\t'.join([
                                    '%s:%s' % (k, v)
                                    for k, v in fvalues.iteritems()]))
                        for fname, fvalues in vals['fields'].iteritems()])
    elif parameters.what == 'all':
        models_as_string = []
        for model_name, vals in values.iteritems():
            new_string = model_name + ';;'
            for model_info_key, model_info_val in vals.iteritems():
                new_string += model_info_key + ':::'
                if model_info_key in MULTIPLE_FIELDS:
                    for finfo_key, finfo_val in model_info_val.iteritems():
                        new_string += finfo_key + '::'
                        for k, v in finfo_val.iteritems():
                            new_string += k + ':' + str(v) + '\t'
                        new_string += '\t'
                    new_string += '\t'
                else:
                    new_string += str(model_info_val)
                    new_string += '\t\t\t'
            models_as_string.append(new_string)
        print '\n'.join(models_as_string)


# Main parser
parser = argparse.ArgumentParser(description='Browse tryton db')
parser.add_argument('tryton_url', help='Tryton server URL')
subparsers = parser.add_subparsers(title='Main Commands',
    description='Valid Commands', dest='command')

# Model Info Parser
parser_model_info = subparsers.add_parser('model_info',
    help='Returns model info')
parser_model_info.add_argument('model_name', help='Model to look for')
parser_model_info.add_argument('--field-name', '-n', default='')

# Extract Things Parser
parser_extract = subparsers.add_parser('extract', help='Extract things')
parser_extract.add_argument('what', help='What to extract',
    choices=['models', 'fields', 'all'])
parser_extract.add_argument('--model-name', default='')
parser_extract.add_argument('--full', '-f', action='store_true')

arguments = parser.parse_args()

set_client(arguments)
globals()[arguments.command](arguments)
