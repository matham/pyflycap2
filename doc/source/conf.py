# -*- coding: utf-8 -*-

import pyflycap2

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.todo',
    'sphinx.ext.coverage'
]

html_sidebars = {
    '**': [
        'about.html',
        'navigation.html',
        'relations.html',
        'searchbox.html',
        'sourcelink.html'
    ]
}

html_theme_options = {
    'github_button': 'true',
    'github_banner': 'true',
    'github_user': 'matham',
    'github_repo': 'pyflycap2'
}

# The suffix of source filenames.
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = u'PyFlyCap2'

# The short X.Y version.
version = pyflycap2.__version__
# The full version, including alpha/beta/rc tags.
release = pyflycap2.__version__

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = []

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'alabaster'

# Output file base name for HTML help builder.
htmlhelp_basename = 'PyFlyCap2doc'

latex_elements = {}

latex_documents = [
  ('index', 'PyFlyCap2.tex', u'PyFlyCap2 Documentation',
   u'Matthew Einhorn', 'manual'),
]

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    ('index', 'PyFlyCap2', u'PyFlyCap2 Documentation',
     [u'Matthew Einhorn'], 1)
]

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
  ('index', 'PyFlyCap2', u'PyFlyCap2 Documentation',
   u'Matthew Einhorn', 'PyFlyCap2', 'One line description of project.',
   'Miscellaneous'),
]


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
