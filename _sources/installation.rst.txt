.. _install:

************
Installation
************

Using binary wheels
-------------------

On **Windows**, compiled PyFlyCap2 binaries can be installed for python
on either a 32 or 64 bit system. To install from pypi, just do::

    pip install pyflycap2

For **Ubuntu** on 64-bit, or to install a specific release, locate the compiled wheel for the [latest
release](https://github.com/matham/pyflycap2/releases), or a dev wheel
by downloading the artifact from the last
[Github action run](https://github.com/matham/pyflycap2/actions). Then
install it using::

    pip install pyflycap2_wheel_name.whl

.. warning::

    On linux, the compiled wheel doesn't contain any flycapture2 library binaries,
    so flycapture2 should be installed before using pyflycap2 by following the
    instructions on the point gray [website](https://www.flir.com/products/flycapture-sdk).

    E.g. on ubuntu, you should download flycapture2, extract it and install with
    ``install_flycapture.sh``. That will put the required ``.so`` files on the path.

    On Windows, the following dlls are required, but are **already included** in the wheel.
    Only provide them if manually compiling pyflycap2::

        FlyCap2CameraControl_v110.dll
        FlyCapture2_v110.dll
        FlyCapture2GUI_Managed_v110.dll
        FlyCapture2Managed_v110.dll
        FlyCapture2_C_v110.dll
        FlyCapture2GUI_C_v110.dll
        FlyCapture2GUI_v110.dll
        libiomp5md.dll

For other OSs or to compile with master see below.

Compiling
---------

Requirements
============

To compile pyflycap2 we need:

    * Python
    * A c compiler (e.g. visual studio, on windows).
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
  `Point Grey Research\FlyCapture2\include`). E.g. on cmd::

      set PYFLYCAP2_INCLUDE="E:\Point Grey Research\FlyCapture2\include"
      set PYFLYCAP2_LIB="E:\Point Grey Research\FlyCapture2\bin64"

Preparing Ubuntu
^^^^^^^^^^^^^^^^^^^

* If flycapture2 was installed with ``install_flycapture.sh``, just do::

      export PYFLYCAP2_INCLUDE=/usr/include/flycapture

Compiling
^^^^^^^^^^^^^

* Now we're ready to compile. CD to the pyflycap2 directory
  and run ``pip install -e .`` to compile it and make it available to python.
* Finally, assuming pyflycap2 is properly installed, you should be
  to import pyflycap2, as long as the dlls (.so) are still on the PATH.
  Once compiled, only the dlls (.so) are required.
* On linux, the file ``/usr/bin/FlyCapture2GUI_GTK.glade`` needs to be
  copied to the current directory if any of the GUI functions are
  used, otherwise an error will be raised and the GUI will not launch.
