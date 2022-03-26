"""PyFlyCap2 Library
====================

Project that provides python bindings for the FlyCapture2 library
by Point Gray.
"""
__version__ = '0.3.1'

import sys
import site
import os
from os.path import join

__all__ = ('dep_bins', )

dep_bins = []
'''A list of paths to the binaries used by the library. It can be used during
packaging for including required binaries.

It is read only.
'''

for d in [sys.prefix, site.USER_BASE]:
    p = join(d, 'share', 'pyflycap2', 'flycapture2', 'bin')
    if os.path.isdir(p):
        os.environ["PATH"] = p + os.pathsep + os.environ["PATH"]
        if hasattr(os, 'add_dll_directory'):
            os.add_dll_directory(p)
        dep_bins.append(p)
