# -*- coding: utf-8 -*-

import pyflycap2
import sphinx_rtd_theme
import os

project = 'PyFlyCap2'
copyright = '2015, Matthew Einhorn'
author = 'Matthew Einhorn'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    "sphinx_rtd_theme",
]


# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'sphinx_rtd_theme'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']


def no_namedtuple_attrib_docstring(app, what, name,
                                   obj, options, lines):
    if any((l.startswith('Alias for field number') for l in lines)):
        # We don't return, so we need to purge in-place
        del lines[:]


def setup(app):
    app.connect(
        'autodoc-process-docstring',
        no_namedtuple_attrib_docstring,
    )
