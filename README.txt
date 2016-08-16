*tryton.txt* Vim tools to develop on the tryton framework

Version: 1.0
Author : Jean Cavallo <jean.cavallo@hotmail.fr>
License: MIT license  {{{
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}}

CONTENTS                                            *tryton-contents*

Introduction                                        |tryton-introduction|
Install                                             |tryton-install|
Usage                                               |tryton-usage|
Variables                                           |tryton-variables|
Mappings                                            |tryton-mappings|

==============================================================================
INTRODUCTION                                        *tryton-introduction*

*tryton-vim* is dedicated to helping developers using the tryton
(http://www.tryton.org) framework. The available features are :
    - Filetype detection for python and xml files which are part of a tryton
      project
    - Specific indentation file for python files which match the project
      guidelines
    - Syntax and Folding files for python files
    - Xml validation / formatting (requires xmllint available)
    - Code Snippets (requires *UltiSnips* )
    - Code Search Patterns (requires *unite* )

==============================================================================
INSTALL                                             *tryton-install*

Install the distributed files into your Vim script directory which is usually
~/.vim/. You should consider to use one of the famous package managers for Vim
like vundle or neobundle to install the plugin.

==============================================================================
USAGE                                               *tryton-usage*

Filetype detection, indentation, syntax and folding are automatically done
when editing python or xml files which are part of a tryton project.
Detection is performed by looking for the "tryton" keyword in the file (which
covers 90% of the use cases). Another test is performed on xml files because
they can be view descriptors, which usually do not contains the "tryton" word

tryton#tools#ValidateXml(view_type)                 *tryton-validate-xml*

    Performs rng validation for the given view_type, which must be one of
    "form", "tree" or "graph". This requires the
    *g:tryton_trytond_default_path* to be properly set to behave correctly.

    Command line output indicates the detected errors.

    TODO: map error to location list

tryton#tools#FormatXML()                            *tryton-format-xml*

    Format the current xml file using xmllint

tryton#search#SearchClass()                         *tryton-search-class*

    Prompts the user for a class name, and uses unite to perform a search for
    this class.

tryton#search#SearchModel()                         *tryton-search-model*

    Prompts the user for a model name, and uses unite to perform a search for
    this model. It does so by searching the "__name__ = '<model_name>'
    pattern.

tryton#search#SearchFunction()                      *tryton-search-function*

    Prompts the user for a function name, and uses unite to search for
    all function definitions matching the name.

tryton#search#SearchField()                         *tryton-search-field*

    Prompts the user for a field name, and use unite to perform a search for
    this field.

tryton#search#SearchMany2One(include_functions)     *tryton-search-many2one*

    Prompts the user for a model name, and use unite to perform a search for
    all Many2One fiels that refers to this model. The "include_functions"
    parameter must be True to include function fiels in the search

tryton#search#SearchOne2Many(include_functions)     *tryton-search-one2many*

    Prompts the user for a model name, and use unite to perform a search for
    all One2Many fiels that refers to this model. The "include_functions"
    parameter must be True to include function fiels in the search


==============================================================================
VARIABLES                                           *tryton-variables*

g:tryton_trytond_default_path                   *g:tryton_trytond_default_path*

        This variable is used to declare the location of the trytond folder.
        It is necessary for xml validation features, as we use the rng
        validation files from this folder.

        If not set, it will try to use the installed trytond in virtualenv,
        and fail if not available

        default: not set

g:tryton_default_mappings                           *g:tryton_default_mappings*

        Set to 0 to manually manage plugin mappings

        default: 1

g:tryton_xml_indent                                 *g:tryton_xml_indent*

        Defines the indentation to use for xml formatting.

        default: "    "

g:tryton_grep_command                               *g:tryton_grep_command*

        The base command to use for search features

        default: 'Unite grep:.:-inR:'

g:tryton_grep_options                               *g:tryton_grep_options*

        The options to use for search features

        default: " -auto-preview -no-split -no-empty"

==============================================================================
MAPPINGS                                            *tryton-mappings*

Mappings that are set if *g:tryton_default_mappings* is set are :

    <Leader>xf           tryton#tools#ValidateXml("form")
    <Leader>xt           tryton#tools#ValidateXml("tree")
    <Leader>xg           tryton#tools#ValidateXml("graph")
    <Leader>xx           tryton#tools#FormatXml()
    <Leader>ac           tryton#search#SearchClass()
    <Leader>an           tryton#search#SearchModel()
    <Leader>ad           tryton#search#SearchFunction()
    <Leader>af           tryton#search#SearchField()
    <Leader>arm          tryton#search#SearchMany2One(0)
    <Leader>aro          tryton#search#SearchOne2Many(0)
    <Leader>arfm         tryton#search#SearchMany2One(1)
    <Leader>arfo         tryton#search#SearchOne2Many(1)

==============================================================================
 vim:tw=78:ts=8:ft=help:norl:
