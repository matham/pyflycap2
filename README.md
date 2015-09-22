# pyflycap2
Cython bindings to Point Gray FlyCapture2


# Installing

This library provides Cython bindings to FlyCapture2 which can be called form
Python. That means that we need to compile the Cython code and link with
the FlyCapture2 dlls. This guide describes how to use MinGW gcc as the
compiler.

* Locate the `FlyCapture2GUI_C.dll`, `FlyCapture2_C.dll`, and `libiomp5md.dll` dlls.
  The dlls are typically under `Point Grey Research\FlyCapture2\bin64` or just
  `bin` for a 32 bit installation. The `Point Grey Research` directory
  is typically under Program Files.

* Move the files to location that is on the path so that it's accessible
 by Windows. Then cd to that directory and run the following commands:

 ```
  gendef FlyCapture2_C_v110.dll
  gendef FlyCapture2GUI_C_v110.dll
  dlltool --dllname FlyCapture2_C_v110.dll --def FlyCapture2_C_v110.def --output-lib libFlyCapture2_C_v110.dll.a
  dlltool --dllname FlyCapture2GUI_C_v110.dll --def FlyCapture2GUI_C_v110.def --output-lib libFlyCapture2GUI_C_v110.dll.a
 ```
  This will generate the library files required by mingw to link with them.

* Now, in your environment set the environment variable `FLYCAP2_INCLUDE`
  to the full path where the include files are (typically under
  `Point Grey Research\FlyCapture2\include`), and set
  `FLYCAP2_BIN` to the folder containing dll files and the generated libx.dll.a
  files from above. E.g.

  ```
  export FLYCAP2_INCLUDE="E:\Point Grey Research\FlyCapture2\include"
  export FLYCAP2_BIN="E:\Point Grey Research\FlyCapture2\bin64"
  ```

* Now we're ready to compile. CD to the pyflycap2 directory
  such that Makefile is in your path and just execute `make`. This will
  compile pyflycap2.

* FInally, assuming pyflycap2 is properly installed, you should be
  to import pyflycap2, as long as the dlls are still on the Windows path.
  Once compiled, only the dlls are required.
