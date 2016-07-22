'''PyFlyCap2 Library
====================

Project that provides python bindings for the FlyCapture2 library
by Point Gray.
'''
__version__ = '0.1.0'

import sys
import os
from os.path import join, isdir

__all__ = ('dep_bins', )

_bins = join(sys.prefix, 'share', 'pyflycap2', 'flycapture2', 'bin')
dep_bins = []
'''A list of paths to the binaries used by the library. It can be used during
packaging for including required binaries.

It is read only.
'''

if isdir(_bins):
    os.environ["PATH"] += os.pathsep + _bins
    dep_bins = [_bins]
