from distutils.core import setup
from distutils.extension import Extension
import os
import sys
from os.path import join, exists
from os import environ
from pyflycap2 import __version__
try:
    import Cython.Compiler.Options
    #Cython.Compiler.Options.annotate = True
    from Cython.Distutils import build_ext
    have_cython = True
    cmdclass = {'build_ext': build_ext}
except ImportError:
    have_cython = False
    cmdclass = {}

suffix = '.dll.a'
prefix = 'lib'
libraries = []

include = environ.get('FLYCAP2_INCLUDE')
bin = environ.get('FLYCAP2_BIN')

include_dirs = [include]
extra_objects = []
for obj in ['FlyCapture2_C', 'FlyCapture2GUI_C']:
    extra_objects.append(join(bin, prefix + obj + suffix))

mods = ['_gui']
extra_compile_args = ["-O3", '-fno-strict-aliasing']

if have_cython:
    mod_suffix = '.pyx'
else:
    mod_suffix = '.c'

ext_modules = [Extension('pyflycap2.' + src_file,
    sources=[join('pyflycap2', src_file + mod_suffix)],
    libraries=libraries,
    include_dirs=include_dirs, extra_objects=extra_objects,
    extra_compile_args=extra_compile_args) for src_file in mods]

for e in ext_modules:
    e.cython_directives = {"embedsignature": True}

setup(name='PyFlyCap2',
      version=__version__,
      author='Matthew Einhorn',
      license='MIT',
      description='Cython bindings for Point Gray Fly Capture 2.',
      packages=['pyflycap2'],
      cmdclass=cmdclass, ext_modules=ext_modules)
