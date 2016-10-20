## Tryton Vim plugin

*tryton-vim* is dedicated to helping developers using the
[tryton](http://www.tryton.org) framework. The available features are :
- Filetype detection for python and xml files which are part of a tryton
project
- Specific indentation file for python files which match the project
guidelines
- Syntax and Folding files for python files
- Xml validation / formatting (requires xmllint available, plugged in
syntastic if available)
- Code Snippets (requires UltiSnips )
- Code Search Patterns (requires [unite](http://github.com/Shougo/unite) )
- Model introspection using the
[debug module](http://github.com/coopengo/trytond_debug)
- Code completion based on the model introspection and the
[deoplete](http://github.com/Shougo/deoplete) plugin

### Requirements

For complete functionalities, you will need the trytond
[debug module](http://github.com/coopengo/trytond_debug) installed in your
tryton installation, and the [unite](http://github.com/Shougo/unite) and
[deoplete](http://github.com/Shougo/deoplete) plugins.

Nothing is mandatory, but some features will be missing if those module /
plugins are not installed.

The plugin works better with [Neovim](http://github.com/neovim/neovim), and
functionalities like code completion will not work without it.

### Installation

Just use your favorite plugin manager, and it should work properly.

### Basic usage

#### Configuration

Base configuration :

```vim
let g:tryton_default_mappings = 1
let g:tryton_trytond_path = "$PROJECT_PATH/trytond"
```

Advanced configuration :

```vim
let g:tryton_cache_dir = expand('~/.cache/unite/tryton')
let g:tryton_server_host_name = 'localhost'
let g:tryton_server_port = '7999'
let g:tryton_server_login = 'admin'
let g:tryton_server_password = 'admin'
let g:tryton_server_database = 'ref'
let g:tryton_complete_autoload = '1'
let g:tryton_model_match = {
    \ 'party': 'party.party',
    \ 'invoice': 'account.invoice',
    \ 'move': 'account.move',
    \ 'user': 'res.user',
    \ }
```

Basically, the plugin needs to know where is tryton installed (to be able to
jump between files easily). In an advanced configuration, in a local vimrc
file, you may want to give some information about the tryton server you want to
connect to for model browsing and completion. This part is optional, the plugin
will ask you for these informations if it does not find them.

The `g:tryton_cache_dir` is used to locally store the model data to avoid
asking the server everytime it is needed.

The `g:tryton_model_match` variable is used in the completion part to be able
to automatically map a variable name to a model. There are more informations
about these variables in the documentation.

The `g:tryton_complete_autoload` value will automatically trigger the loading
of the modelization from the cache or from the server if available. This can
speed up the first completion calls.


#### Filetype

The plugin adds a secondary filetype for python / xml files which are detected
to be part of a tryton installation. The detection is based on the contents of
a file (look for "tryton[d]" in the file) and on its location (for xml files in
a "view" folder under a directory which has a "tryton.cfg" file).

The filetypes are *secondary*, which means they comlpete the basic filetypes.
So a trytond python file will have the `python.trpy` filetype. This means that
it will be both considered a `python` file ans a `trpy` file.

`trpy` files have :

  - Custom syntax file, which will add highlights for tryton keywords (`Pool`,
`Transaction`, `fields`...) and create syntax groups for fields.
  - Custom indent rules which try to implement the tryton community indentation
rules.
  - Folding rules, so you can add `foldmethod=syntax` for `trpy` files. The
folding will happend on class definitions, fields definition, and method
definitions.

`trxml` files have some dedicated snippets, and can be configured to be
validated against the `.rng` files if `Syntastic` is installed. If it is not,
you can manually trigger the validation with the `tryton#tools#ValidateXml`
method.

#### Model introspection

If the [debug](http://github.com/coopengo/trytond_debug) module is installed,
the plugin can connect to a running trytond instance and request a dump of the
modelisation of a database. It may take a few seconds, so it is cached. It can
be reloaded the same way you usually reload a `unite` source.

Once the model is loaded, you can use the `tryton_details` unite source to
browse the model:

```vim
Unite tryton_details
```

The source accept parameters, so for instance if you want to look at the
different overrides of the `party.party` model, you may use:

```vim
Unite tryton_details:party.party/mro
```

The plugin also defines `tryton#tools#get_current_model()` and
`tryton#tools#get_current_method()` which you can use to create useful
mappings:

```vim
nnoremap <silent><Plug>(tryton-browse-current-function-mro)
    \ :<C-U>call unite#start_script([['tryton_details',
        \ tryton#tools#get_current_model() . '/' . 'methods' . '/' .
        \ tryton#tools#get_current_method() . '/' . 'mro']],
    \ {'start_insert': 0})<CR>
```

This will open the mro for the method you are currently working on.

The navigation in the `tryton_details` source is based on the `go_down` action
defined on the unite source. By default, this action is mapped to `<CR>`. Going
back in the tree is done through quitting the current unite window.

`mro` entries and `view` entries are `openable`, so you can have access to the
standard `open`, `split`, etc... standard actions from unite.

#### Auto complete

If [deoplete](http://github.com/Shougo/deoplete) is installed, and a database
model is loaded, vim will automatically propose auto-completion based on the
model.

It detects the `cls` and `self` keywords to detect that the completion may be
triggered, and uses the model to propose the associated fields or methods. It
displays the field original module and their type. For methods there is the
prototype (i.e. the default parameters) so you know what the method expects as
parameters.

If a field is a relation field (Many2One), the completion will continue on the
new model.

If `self` is an `æccount.invoice`, `self.party.` will trigger completion on the
`party.party` model, and so on.

You can define the `g:tryton_model_match` method to map keywords to model, so
vim can know which fields should be proposed:

```vim
let g:tryton_model_match = {
    \ 'party': 'party.party'
    \ }
```

With this configuration, writing `party` will trigger completion based on the
`party.party` model whatever model you are working on at the moment.
