try:
    from setuptools import setup, Extension
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension
import os
import sys
from os.path import join, exists, dirname, abspath, isdir
from os import environ, listdir
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

def get_wheel_data():
    data = []
    deps = environ.get('PYFLYCAP2_WHEEL_DEPS')
    if deps and isdir(deps):
        data.append(
            ('share/pyflycap2/flycapture2/bin',
             [join(deps, f) for f in listdir(deps)]
            )
        )
    return data

libraries = ['FlyCapture2_C_v110', 'FlyCapture2GUI_C_v110']
include_dirs = []
library_dirs = []

include = environ.get('PYFLYCAP2_INCLUDE')
if include:
    include_dirs.append(include)

lib = environ.get('PYFLYCAP2_LIB')
if lib:
    library_dirs.append(lib)


mods = ['interface']
extra_compile_args = ["-O3", '-fno-strict-aliasing']
mod_suffix = '.pyx' if have_cython else '.c'
include_dirs.append(join(abspath(dirname(__file__)), 'pyflycap2', 'includes'))

ext_modules = [Extension(
    'pyflycap2.' + src_file,
    sources=[join('pyflycap2', src_file + mod_suffix)], libraries=libraries,
    include_dirs=include_dirs, library_dirs=library_dirs,
    extra_compile_args=extra_compile_args) for src_file in mods]

for e in ext_modules:
    e.cython_directives = {"embedsignature": True}

with open('README.rst') as fh:
    long_description = fh.read()

setup(
    name='pyflycap2',
    version=__version__,
    author='Matthew Einhorn',
    license='MIT',
    description='Cython bindings for Point Gray Fly Capture 2.',
    url='http://matham.github.io/pyflycap2/',
    long_description=long_description,
    classifiers=[
        'License :: OSI Approved :: MIT License',
        'Topic :: Multimedia :: Graphics :: Capture :: Digital Camera',
        'Topic :: Multimedia :: Graphics :: Capture',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX :: Linux',
        'Intended Audience :: Developers'],
    packages=['pyflycap2'],
    data_files=get_wheel_data(),
    cmdclass=cmdclass, ext_modules=ext_modules,
    setup_requires=['cython'])
