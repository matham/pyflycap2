.. _install:

************
Installation
************

Using binary wheels
-------------------

On windows 7+, compiled PyFlyCap2 binaries can be installed for python 2.7 and 3.4+,
on either a 32 or 64 bit system using::

    pip install pyflycap2

.. warning::

    Due to the licensing restrictions, Fly Capture dlls cannot be redistributed,
    therefore the wheels only include the compiled bindings. To use, the Fly Capture
    dlls must be provided independently, e.g. by placing them on the system PATH.

    On Windows, the required dlls are::

        FlyCap2CameraControl_v110.dll
        FlyCapture2_v110.dll
        FlyCapture2GUI_Managed_v110.dll
        FlyCapture2Managed_v110.dll
        FlyCapture2_C_v110.dll
        FlyCapture2GUI_C_v110.dll
        FlyCapture2GUI_v110.dll
        libiomp5md.dll

    On ubuntu, you should download flycapture2, extract it and install with
    ``install_flycapture.sh``. That will put the required ``.so`` files on the path.

For other OSs or to compile with master see below.

Compiling
---------

Requirements
============

To compile pyflycap2 we need:

    * Python 2.7, 3.3+
    * Cython (``pip install --upgrade cython``).
    * A c compiler (e.g. MinGW, ``pip install mingwpy``, on windows).
    * FlyCapture2 SDK which includes the required headers, lib, and dll (.so) files.
      It can be downloaded only from the Point Gray website.

Compiling pyflycap2
====================

This library provides Cython bindings to FlyCapture2 which can be called form
Python. That means that we need to compile the Cython code and link with
the FlyCapture2 dlls (.so). This guide describes how to use MinGW gcc as the
compiler.

Preparing Windows
^^^^^^^^^^^^^^^^^^^^^^

* Locate `FlyCapture2GUI_C.dll` and the other dlls listed above.
  The dlls are typically under `Point Grey Research\FlyCapture2\bin64` or just
  `bin` for a 32 bit installation. The `Point Grey Research` directory
  is typically under Program Files.
* Now, in your environment set the environment variable ``PYFLYCAP2_LIB``
  to the full path where those dll files are. Those dlls should also be added to
  the PATH by e.g. setting ``$PATH=$PATH:dll_path`` so that it'll be found at
  runtime. When making or installing from a wheel with these dlls, they will
  automatically be included and added to the PATH at runtime.
* Now, in your environment set the environment variable ``PYFLYCAP2_INCLUDE``
  to the full path where the include files are (typically also under
  `Point Grey Research\FlyCapture2\include`). E.g. on bash::

      export PYFLYCAP2_INCLUDE="E:\Point Grey Research\FlyCapture2\include"
      export PYFLYCAP2_LIB="E:\Point Grey Research\FlyCapture2\bin64"

Preparing Ubuntu
^^^^^^^^^^^^^^^^^^^

* If flycapture2 was installed with ``install_flycapture.sh``, just do::

      export PYFLYCAP2_INCLUDE=/usr/include/flycapture

Compiling
^^^^^^^^^^^^^

* Now we're ready to compile. CD to the pyflycap2 directory
  such that Makefile is in your path and just execute `make`. This will
  compile pyflycap2. Alternatively run ``python setup.py build_ext --inplace``.
* Finally, assuming pyflycap2 is properly installed, you should be
  to import pyflycap2, as long as the dlls (.so) are still on the PATH.
  Once compiled, only the dlls (.so) are required.
