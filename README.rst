Project that provides python bindings for the FlyCapture2 library
by Point Gray.

For more information: http://matham.github.io/pyflycap2/index.html

To install: http://matham.github.io/pyflycap2/installation.html

.. image:: https://ci.appveyor.com/api/projects/status/w43tdnppyqrhvs4x/branch/master?svg=true
    :target: https://ci.appveyor.com/project/matham/pyflycap2/branch/master
    :alt: Appveyor status

.. image:: https://img.shields.io/pypi/pyversions/pyflycap2.svg
    :target: https://pypi.python.org/pypi/pyflycap2/
    :alt: Supported Python versions

.. image:: https://img.shields.io/pypi/v/pyflycap2.svg
    :target: https://pypi.python.org/pypi/pyflycap2/
    :alt: Latest Version on PyPI

.. warning::

    Due to the licensing restrictions, Fly Capture dlls cannot be redistributed,
    therefore the wheels only include the compiled bindings. To use, the Fly Capture
    dlls must be provided independently, e.g. by placing them on the system PATH.

Examples
=============

Listing GigE cams:

.. code-block:: python

    cc = CameraContext()
    cc.rescan_bus()
    print(cc.get_gige_cams())  # prints list of serial numbers.


Configuring with the GUI:

.. code-block:: python

    gui = GUI()
    gui.show_selection()


Reading images from a camera:

.. code-block:: python

    c = Camera(serial=cam_serial)
    c.connect()
    c.start_capture()
    c.read_next_image()
    image = c.get_current_image()  # last image
    c.disconnect()
