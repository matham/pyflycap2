
include "includes/FlyCapture2.pxi"


cdef class CameraContext(object):

    cdef fc2Context context
    cdef public object context_type


cdef class Camera(CameraContext):

    cdef fc2PGRGuid _guid
    cdef public list guid

    cdef public unsigned int index
    cdef public unsigned int serial
    cdef public object interface_type

    cdef public list ip
    cdef public list subnet
    cdef public list gateway
    cdef public list mac_address

    cdef fc2CameraInfo cam_info

    cdef public object is_color

    cdef public object connected

    cdef fc2Image image

    cdef image_callback(self, fc2Image *image)
    cpdef get_current_image_config(self)
    cpdef get_current_image(self)


cdef class GUI(object):

    cdef fc2GuiContext gui_context
    cdef object cam_type
