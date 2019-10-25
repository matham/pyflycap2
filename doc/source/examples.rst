.. _examples:

********
Examples
********


Listing GigE cams:

.. code-block:: python

    from pyflycap2.interface import CameraContext
    cc = CameraContext()
    cc.rescan_bus()
    print(cc.get_gige_cams())  # prints list of serial numbers.


Configuring with the GUI:

.. code-block:: python

    from pyflycap2.interface import GUI
    gui = GUI()
    gui.show_selection()


Reading images from a camera:

.. code-block:: python

    from pyflycap2.interface import Camera
    c = Camera(serial=cam_serial)
    c.connect()
    c.start_capture()
    c.read_next_image()
    image = c.get_current_image()  # last image
    c.disconnect()
