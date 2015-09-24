'''
Not implemented:

fc2RegisterCallback
fc2UnregisterCallback
format7

fc2RetrieveBuffer
fc2SetUserBuffers
'''

from libc.stdlib cimport malloc, free
from cpython.ref cimport PyObject

from pyflycap2.exception import FlyCap2Exception
import logging

cdef inline check_ret(fc2Error ret):
    if ret != FC2_ERROR_OK:
        raise Exception('PyFlyCap2: {}'.format(fc2ErrorToDescription(ret)))


cdef void image_event_callback(fc2Image *image, void *callback_data) nogil:
    with gil:
        try:
            (<Camera>(<PyObject*>callback_data)).image_callback(image)
        except Exception as e:
            logging.exception('PyFlyCap2: got exception "{}" in image_event_callback'.format(e))


cdef dict video_modes = {
    '160x120 yuv444': FC2_VIDEOMODE_160x120YUV444,
    '320x240 yuv422': FC2_VIDEOMODE_320x240YUV422,
    '640x480 yuv411': FC2_VIDEOMODE_640x480YUV411,
    '640x480 yuv422': FC2_VIDEOMODE_640x480YUV422,
    '640x480 rgb': FC2_VIDEOMODE_640x480RGB,
    '640x480 y8': FC2_VIDEOMODE_640x480Y8,
    '640x480 y16': FC2_VIDEOMODE_640x480Y16,
    '800x600 yuv422': FC2_VIDEOMODE_800x600YUV422,
    '800x600 rgb': FC2_VIDEOMODE_800x600RGB,
    '800x600 y8': FC2_VIDEOMODE_800x600Y8,
    '800x600 y16': FC2_VIDEOMODE_800x600Y16,
    '1024x768 yuv422': FC2_VIDEOMODE_1024x768YUV422,
    '1024x768 rgb': FC2_VIDEOMODE_1024x768RGB,
    '1024x768 y8': FC2_VIDEOMODE_1024x768Y8,
    '1024x768 y16': FC2_VIDEOMODE_1024x768Y16,
    '1280x960 yuv422': FC2_VIDEOMODE_1280x960YUV422,
    '1280x960 rgb': FC2_VIDEOMODE_1280x960RGB,
    '1280x960 y8': FC2_VIDEOMODE_1280x960Y8,
    '1280x960 y16': FC2_VIDEOMODE_1280x960Y16,
    '1600x1200 yuv422': FC2_VIDEOMODE_1600x1200YUV422,
    '1600x1200 rgb': FC2_VIDEOMODE_1600x1200RGB,
    '1600x1200 y8': FC2_VIDEOMODE_1600x1200Y8,
    '1600x1200 y16': FC2_VIDEOMODE_1600x1200Y16,
    'format7': FC2_VIDEOMODE_FORMAT7
}


cdef dict frame_rates = {
    1.875: FC2_FRAMERATE_1_875,
    3.75: FC2_FRAMERATE_3_75,
    7.5: FC2_FRAMERATE_7_5,
    15: FC2_FRAMERATE_15,
    30: FC2_FRAMERATE_30,
    60: FC2_FRAMERATE_60,
    120: FC2_FRAMERATE_120,
    240: FC2_FRAMERATE_240,
    'format7': FC2_FRAMERATE_FORMAT7
}


cdef class CameraContext(object):
    '''

    `context_type`: str
        Can be one of `IIDC` or `GigE`.
    '''

    def __cinit__(self, context_type='GigE', **kwargs):
        self.context = NULL
        self.context_type = context_type
        if context_type == 'GigE':
            check_ret(fc2CreateGigEContext(&self.context))
        elif context_type == 'IIDC':
            check_ret(fc2CreateContext(&self.context))
        else:
            raise Exception(
                'Cannot recognize camera type "{}". Valid values are '
                '"GigE" or "IIDC".'.format(context_type))

    def __dealloc__(self):
        if self.context != NULL:
            fc2DestroyContext(self.context)
            self.context = NULL

    def reset_1394(self, Camera camera):
        check_ret(fc2FireBusReset(self.context, &camera._guid))

    def get_num_cameras(self):
        cdef unsigned int n = 0
        check_ret(fc2GetNumOfCameras(self.context, &n))
        return n

    def get_num_devices(self):
        cdef unsigned int n = 0
        check_ret(fc2GetNumOfDevices(self.context, &n))
        return n

    def get_device_guid_from_index(self, index):
        cdef fc2PGRGuid guid
        check_ret(fc2GetDeviceFromIndex(self.context, index, &guid))
        return [guid.value[i] for i in range(4)]

    def rescan_bus(self):
        check_ret(fc2RescanBus(self.context))

    def force_mac_to_ip(self, ip, subnet, gateway, mac_address=None,
                        Camera cam=None):
        cdef fc2MACAddress mac
        cdef int i
        cdef fc2IPAddress _ip, _subnet, _gateway
        if cam is not None:
            mac_address = cam.mac_address

        for i in range(6):
            mac.octets[i] = mac_address[i]
        for i in range(4):
            _ip.octets[i] = ip[i]
        for i in range(4):
            _subnet.octets[i] = subnet[i]
        for i in range(4):
            _gateway.octets[i] = gateway[i]

        check_ret(fc2ForceIPAddressToCamera(self.context, mac, _ip, _subnet, _gateway))

    def force_all_ips(self):
        check_ret(fc2ForceAllIPAddressesAutomatically())

    def get_gige_cams(self):
        cdef fc2Error error
        cdef fc2CameraInfo cams[8]
        cdef fc2CameraInfo *pcams = NULL
        cdef unsigned int count = sizeof(cams)
        cdef int i

        error = fc2DiscoverGigECameras(self.context, cams, &count)
        if error == FC2_ERROR_BUFFER_TOO_SMALL:
            pcams = <fc2CameraInfo *>malloc(count * sizeof(fc2CameraInfo))
            if pcams == NULL:
                raise MemoryError()

            try:
                check_ret(fc2DiscoverGigECameras(self.context, pcams, &count))
                return [pcams[i].serialNumber for i in range(count)]
            finally:
                free(pcams)
        elif error != FC2_ERROR_OK:
            check_ret(error)
        else:
            return [cams[i].serialNumber for i in range(count)]


cdef class Camera(CameraContext):

    def __cinit__(self, guid=None, index=None, ip=None, serial=None, **kwargs):
        cdef int i = 0
        cdef fc2IPAddress _ip
        self.index = <unsigned int>-1
        self.ip = self.subnet = self.gateway = self.mac_address = None
        self.connected = False

        if guid is not None:
            for i in range(4):
                self._guid.value[i] = guid[i]
        elif index is not None:
            self.index = index
            check_ret(fc2GetCameraFromIndex(self.context, self.index, &self._guid))
        elif ip is not None:
            for i in range(4):
                _ip.octets[i] = ip[i]
            check_ret(fc2GetCameraFromIPAddress(self.context, _ip, &self._guid))
        elif serial is not None:
            self.serial = serial
            check_ret(fc2GetCameraFromSerialNumber(self.context, self.serial, &self._guid))
        else:
            raise Exception('At least one of guid, index, ip, or serial must be specified.')

        self.guid = [self._guid.value[i] for i in range(4)]
        check_ret(fc2Connect(self.context, &self._guid))
        try:
            check_ret(fc2GetCameraInfo(self.context, &self.cam_info))
        except:
            fc2Disconnect(self.context)
            raise
        else:
            check_ret(fc2Disconnect(self.context))

        self.serial = self.cam_info.serialNumber
        self.is_color = bool(self.cam_info.isColorCamera)

        if self.cam_info.interfaceType == FC2_INTERFACE_IEEE1394:
            self.interface_type = 'IEEE1394'
        elif self.cam_info.interfaceType == FC2_INTERFACE_USB_2:
            self.interface_type = 'USB2'
        elif self.cam_info.interfaceType == FC2_INTERFACE_USB_3:
            self.interface_type = 'USB3'
        elif self.cam_info.interfaceType == FC2_INTERFACE_GIGE:
            self.interface_type = 'GigE'
            self.ip = [self.cam_info.ipAddress.octets[i] for i in range(4)]
            self.subnet = [self.cam_info.subnetMask.octets[i] for i in range(4)]
            self.gateway = [self.cam_info.defaultGateway.octets[i] for i in range(4)]
            self.mac_address = [self.cam_info.macAddress.octets[i] for i in range(6)]
        elif self.cam_info.interfaceType == FC2_INTERFACE_UNKNOWN:
            self.interface_type = 'unknown'
        elif self.cam_info.interfaceType == FC2_INTERFACE_TYPE_FORCE_32BITS:
            self.interface_type = '32bits'

        check_ret(fc2SetCallback(self.context, <fc2ImageEventCallback>image_event_callback, <PyObject*>self))

    def is_controlable(self):
        cdef BOOL controlable = 0
        check_ret(fc2IsCameraControlable(self.context, &self._guid, &controlable))
        return bool(controlable)

    def connect(self):
        check_ret(fc2Connect(self.context, &self._guid))
        self.connected = True

    def diconnect(self):
        check_ret(fc2Disconnect(self.context))
        self.connected = False

    cdef image_callback(self, fc2Image *image):
        pass

    def start_capture(self):
        check_ret(fc2StartCapture(self.context))

    def start_capture_sync(self, other_cams):
        cdef list cams = [self] + list(other_cams)
        cdef unsigned int n = len(cams)
        cdef fc2Context *contexts = NULL
        cdef Camera cam
        cdef int i

        contexts = <fc2Context *>malloc(n * sizeof(fc2Context))
        if contexts == NULL:
            raise MemoryError()

        try:
            for i, cam in enumerate(cams):
                contexts[i] = cam.context
            check_ret(fc2StartSyncCapture(n, contexts))
        finally:
            free(contexts)

    def stop_capture(self):
        check_ret(fc2StopCapture(self.context))

    def set_buffer_mode(self, drop=True):
        cdef fc2Config config
        check_ret(fc2GetConfiguration(self.context, &config))
        config.grabMode = FC2_DROP_FRAMES if drop else FC2_BUFFER_FRAMES
        check_ret(fc2SetConfiguration(self.context, &config))

    def _convert_mode_args(self, width, height, fmt, rate):
        if fmt == 'format7':
            val = 'format7'
        else:
            val = '{}x{} {}'.format(int(width), int(height), fmt)

        if val not in video_modes:
            raise ValueError('"{}" not found in allowed values {}'.format(
                val, ', '.join(['"{}"'.format(k) for k in video_modes.keys()])))

        if rate not in frame_rates:
            raise ValueError('"{}" not found in allowed values {}'.format(
                rate, ', '.join(['"{}"'.format(k) for k in frame_rates.keys()])))

        return video_modes[val], frame_rates[rate]

    def check_video_mode(self, width, height, fmt, rate):
        cdef fc2VideoMode mode
        cdef fc2FrameRate _rate
        cdef BOOL supported = 0
        mode, _rate = self._convert_mode_args(width, height, fmt, rate)
        check_ret(fc2GetVideoModeAndFrameRateInfo(self.context, mode, rate, &supported))
        return bool(supported)

    def set_video_mode(self, width, height, fmt, rate):
        cdef fc2VideoMode mode
        cdef fc2FrameRate _rate
        mode, _rate = self._convert_mode_args(width, height, fmt, rate)
        check_ret(fc2SetVideoModeAndFrameRate(self.context, mode, rate))

    def get_video_mode(self):
        cdef fc2VideoMode _mode
        cdef fc2FrameRate _rate
        check_ret(fc2GetVideoModeAndFrameRate(self.context, &_mode, &_rate))

        modes = {v: k for k, v in video_modes.values()}
        rates = {v: k for k, v in frame_rates.values()}
        if _mode not in modes:
            raise Exception('Unknown video mode {}'.format(<int>_mode))
        if _rate not in rates:
            raise Exception('Unknown frame rate {}'.format(<int>_rate))

        mode = modes[_mode]
        rate = rates[_rate]
        if rate != 'format7':
            rate = float(rate)
        if mode == 'format7':
            return None, None, 'format7', rate
        size, fmt = mode.split(' ')
        w, h = size.split('x')
        return int(w), int(h), fmt, rate


cdef class GUI(object):

    def __cinit__(self, **kwargs):
        self.gui_context = NULL
        check_ret(fc2CreateGUIContext(&self.gui_context))

    def __dealloc__(self):
        if self.gui_context != NULL:
            fc2DestroyGUIContext(self.gui_context)
            self.gui_context = NULL

    def show(self):
        if not self.is_gui_visible():
            fc2Show(self.gui_context)

    def hide(self):
        if self.is_gui_visible():
            fc2Hide(self.gui_context)

    def is_gui_visible(self):
        return bool(fc2IsVisible(self.gui_context))

    def show_selection(self):
        cdef BOOL selected = 0
        cdef unsigned int s = 10
        cdef fc2PGRGuid guid[10]
        fc2ShowModal(self.gui_context, &selected, guid, &s)
        print s, selected
