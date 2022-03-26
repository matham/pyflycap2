from setuptools import setup, Extension
import sys
from os.path import join, exists, dirname, abspath, isdir
from os import environ, listdir
from pyflycap2 import __version__
from Cython.Distutils import build_ext
import pathlib

cmdclass = {'build_ext': build_ext}


def get_wheel_data():
    deps = environ.get('PYFLYCAP2_WHEEL_DEPS')
    if not deps or not isdir(deps):
        return []

    root = pathlib.Path(deps)
    items = list(map(str, root.glob('FlyCap*_v140.dll')))
    items = [
        val for val in items
        if val[-10] != 'd' or val[:-10] + 'd' + val[-10:] in items
    ]
    items.extend(map(str, root.glob('msvcp140.dll')))
    items.extend(map(str, root.glob('libiomp5md.dll')))

    return [('share/pyflycap2/flycapture2/bin', items)]


include_dirs = []
library_dirs = []

if sys.platform in ('win32', 'cygwin'):
    libraries = ['FlyCapture2_C_v140', 'FlyCapture2GUI_C_v140']
else:
    libraries = ['flycapturegui-c', 'flycapture-c']
    include_dirs.append('/usr/include/flycapture')
    include_dirs.append('/usr/include/flycapture/C')

include = environ.get('PYFLYCAP2_INCLUDE')
if include:
    include_dirs.append(include)

lib = environ.get('PYFLYCAP2_LIB')
if lib:
    library_dirs.append(lib)


mods = ['interface']
mod_suffix = '.pyx'
include_dirs.append(join(abspath(dirname(__file__)), 'pyflycap2', 'includes'))

ext_modules = [Extension(
    'pyflycap2.' + src_file,
    sources=[join('pyflycap2', src_file + mod_suffix)], libraries=libraries,
    include_dirs=include_dirs, library_dirs=library_dirs) for src_file in mods]

for e in ext_modules:
    e.cython_directives = {
        "embedsignature": True, 'c_string_encoding': 'utf-8',
        'language_level': 3}

with open('README.rst') as fh:
    long_description = fh.read()

setup(
    name='pyflycap2',
    version=__version__,
    author='Matthew Einhorn',
    license='MIT',
    description='Cython bindings for Point Gray Fly Capture 2.',
    url='https://matham.github.io/pyflycap2/',
    long_description=long_description,
    classifiers=[
        'License :: OSI Approved :: MIT License',
        'Topic :: Multimedia :: Graphics :: Capture :: Digital Camera',
        'Topic :: Multimedia :: Graphics :: Capture',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX :: Linux',
        'Intended Audience :: Developers'],
    packages=['pyflycap2'],
    data_files=get_wheel_data(),
    cmdclass=cmdclass, ext_modules=ext_modules)
