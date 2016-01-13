
__version__ = '0.1.dev0'

import sys
import os
from os.path import join, isdir

_bins = join(sys.prefix, 'share', 'pyflycap2', 'flycapture2', 'bin')
dep_bins = []
if isdir(_bins):
    os.environ["PATH"] += os.pathsep + _bins
    dep_bins = [_bins]
