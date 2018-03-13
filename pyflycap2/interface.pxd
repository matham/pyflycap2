
include "includes/FlyCapture2.pxi"


cdef class CameraContext(object):

    cdef fc2Context context
    cdef public object context_type
    '''The bus type controlled by the context. Can be one of `IIDC` or `GigE`.
    '''


cdef class Camera(CameraContext):

    cdef fc2PGRGuid _guid
    cdef public list guid
    '''A list of size 4 representing the GUID of the :class:`Camera` or None.
    '''

    cdef public unsigned int index
    '''The index of the camera on the bus.
    '''

    cdef public unsigned int serial
    '''The serial number of the :class:`Camera`.
    '''

    cdef public object interface_type
    '''The :class:`Camera` interface type. Can be one of IEEE1394, USB2, USB3,
GigE, or unknown.
    '''

    cdef public list ip
    '''A list of size 4 representing the ip of the :class:`Camera` or None.
    '''

    cdef public list subnet
    '''A list of size 4 representing the subnet of the :class:`Camera` or None.
    '''

    cdef public list gateway
    '''A list of size 4 representing the gateway of the :class:`Camera` or None.
    '''

    cdef public list mac_address
    '''A list of size 6 representing the MAC address of the :class:`Camera` or None.
    '''

    cdef fc2CameraInfo cam_info

    cdef public object is_color
    '''Whether the :class:`Camera` is color or B/W.
    '''

    cdef public object connected
    '''If the :class:`Camera` is currently connected to its
internal :class:`CameraContext`.
    '''

    cdef public list setting_names
    '''A list of the names of the setting, e.g. brightness that are supported by
    point gray cameras (even if this camera doesn't support it).
    '''

    cdef fc2Image image

    cdef image_callback(self, fc2Image *image)
    cpdef get_current_image_config(self)
    cpdef get_current_image(self)


cdef class GUI(object):

    cdef fc2GuiContext gui_context
    cdef object cam_type
