"""Bindings
===================

Provides the cython bindings to the corresponding c functions.

Functions that are not implemented::

    fc2SetUserBuffers
"""

include "includes/cy_compat.pxi"

from libc.stdlib cimport malloc, free
from libc.string cimport memset, memcpy
from cpython.ref cimport PyObject

import logging
from collections import namedtuple

__all__ = ('CameraContext', 'Camera', 'GUI')


cdef void image_event_callback(fc2Image *image, void *callback_data) nogil:
    with gil:
        try:
            (<Camera>(<PyObject*>callback_data)).image_callback(image)
        except Exception as e:
            logging.exception('PyFlyCap2: got exception "{}" in image_event_callback'.format(e))


TimeStamp = namedtuple(
    'TimeStamp', ['seconds', 'micro_seconds', 'cycle_seconds', 'cycle_count',
                  'cycle_offset'])
'''A namedtuple representing a timestamp.
'''


cdef unsigned int reverse_bits(unsigned int n) nogil:
    cdef unsigned int x = 0, i = 31
    while n:
        x |= (n & 1) << i
        n >>= 1
        i -= 1
    return x

cdef class CameraContext(object):
    '''Base controller that interface with the bus to which the :class:`Camera`
    devices are connected.

    :Parameters:

        `context_type`: str
            Can be one of ``IIDC`` or ``GigE``. Defaults to ``GigE``.
    '''

    def __cinit__(self, context_type='GigE', **kwargs):
        self.context = NULL
        self.context_type = context_type
        if context_type == 'GigE':
            with nogil:
                check_ret(fc2CreateGigEContext(&self.context))
        elif context_type == 'IIDC':
            with nogil:
                check_ret(fc2CreateContext(&self.context))
        else:
            raise Exception(
                'Cannot recognize camera type "{}". Valid values are '
                '"GigE" or "IIDC".'.format(context_type))

    def __dealloc__(self):
        if self.context != NULL:
            with nogil:
                fc2Disconnect(self.context)
                fc2DestroyContext(self.context)
            self.context = NULL

    def reset_1394(self, Camera camera):
        '''Resets the 1394 bus associated with the :class:`Camera`.
        '''
        with nogil:
            check_ret(fc2FireBusReset(self.context, &camera._guid))

    def get_num_cameras(self):
        '''The number of cameras connected to the bus.
        '''
        cdef unsigned int n = 0
        with nogil:
            check_ret(fc2GetNumOfCameras(self.context, &n))
        return n

    def get_num_devices(self):
        '''The number of devices connected to the bus.
        '''
        cdef unsigned int n = 0
        with nogil:
            check_ret(fc2GetNumOfDevices(self.context, &n))
        return n

    def get_device_guid_from_index(self, unsigned int index):
        '''Returns a list of size 4 representing the GUID of the device at
        index ``index``.
        '''
        cdef fc2PGRGuid guid
        with nogil:
            check_ret(fc2GetDeviceFromIndex(self.context, index, &guid))
        return [guid.value[i] for i in range(4)]

    def rescan_bus(self):
        '''Rescans the bus to discover new devices.
        '''
        with nogil:
            check_ret(fc2RescanBus(self.context))

    def force_mac_to_ip(self, ip, subnet, gateway, mac_address=None,
                        Camera cam=None):
        '''Sets the ip, subnet, and gateway (each a list of 4 integers) of the
        device at the corresponding MAC address to the provided values.

        Either ``mac_address`` (list of 6 integers) or a :class:`Camera` whose
        :attr:`Camera.mac_address` will be used must be provided.
        '''
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

        with nogil:
            check_ret(fc2ForceIPAddressToCamera(self.context, mac, _ip, _subnet, _gateway))

    def force_all_ips(self):
        '''Automatically sets the ip, subnet, and gateway of all the connected GigE
        cameras.
        '''
        with nogil:
            check_ret(fc2ForceAllIPAddressesAutomatically())

    def get_gige_cams(self):
        '''Returns a list of the serial numbers of the connected GigE cameras.
        '''
        cdef fc2Error error
        cdef fc2CameraInfo cams[8]
        cdef fc2CameraInfo *pcams = NULL
        cdef unsigned int count = sizeof(cams)
        cdef int i

        with nogil:
            error = fc2DiscoverGigECameras(self.context, cams, &count)
        if error == FC2_ERROR_BUFFER_TOO_SMALL:
            pcams = <fc2CameraInfo *>malloc(count * sizeof(fc2CameraInfo))
            if pcams == NULL:
                raise MemoryError()

            try:
                with nogil:
                    check_ret(fc2DiscoverGigECameras(self.context, pcams, &count))
                return [pcams[i].serialNumber for i in range(count)]
            finally:
                free(pcams)
        elif error != FC2_ERROR_OK:
            check_ret(error)
        else:
            return [cams[i].serialNumber for i in range(count)]

    def get_default_color_processing(self):
        '''Returns the default color processing algorithm.

        Can be one of ``'default'``, ``'no_processing'``, ``'NN'``, ``'edge'``,
        ``'linear'``, ``'rigorous'``, ``'IPP'``, ``'directional'``.
        '''
        cdef fc2ColorProcessingAlgorithm method
        with nogil:
            check_ret(fc2GetDefaultColorProcessing(&method))
        return color_algos_inv.get(method, 'unknown')

    def set_default_color_processing(self, algo):
        '''Sets the default color processing algorithm.

        Can be one of ``'default'``, ``'no_processing'``, ``'NN'``, ``'edge'``,
        ``'linear'``, ``'rigorous'``, ``'IPP'``, ``'directional'``.
        '''
        cdef fc2ColorProcessingAlgorithm default_method
        if algo not in color_algos:
            raise ValueError('"{}" not found in allowed values {}'.format(
                algo, ', '.join(['"{}"'.format(k) for k in color_algos.keys()])))

        default_method = color_algos[algo]
        with nogil:
            check_ret(fc2SetDefaultColorProcessing(default_method))

    def get_default_pix_fmt(self):
        '''Returns the default pixel format for the cameras.

        Can be one of ``'mono8'``, ``'yuv411'``, ``'yuv422'``, ``'yuv444'``,
        ``'rgb8'``, ``'mono16'``, ``'rgb16'``, ``'s_mono16'``, ``'s_rgb16'``,
        ``'raw8'``, ``'raw16'``, ``'mono12'``, ``'raw12'``, ``'bgr'``,
        ``'bgru'``, ``'rgb'``, ``'rgbu'``, ``'bgr16'``, ``'bgru16'``,
        ``'yuv422_jpeg'``.
        '''
        cdef fc2PixelFormat fmt
        with nogil:
            check_ret(fc2GetDefaultOutputFormat(&fmt))
        return pixel_fmts_inv.get(fmt, 'unknown')

    def set_default_pix_fmt(self, fmt):
        '''Sets the default pixel format for the cameras.

        Can be one of ``'mono8'``, ``'yuv411'``, ``'yuv422'``, ``'yuv444'``,
        ``'rgb8'``, ``'mono16'``, ``'rgb16'``, ``'s_mono16'``, ``'s_rgb16'``,
        ``'raw8'``, ``'raw16'``, ``'mono12'``, ``'raw12'``, ``'bgr'``,
        ``'bgru'``, ``'rgb'``, ``'rgbu'``, ``'bgr16'``, ``'bgru16'``,
        ``'yuv422_jpeg'``.
        '''
        cdef fc2PixelFormat format
        if fmt not in pixel_fmts:
            raise ValueError('"{}" not found in allowed values {}'.format(
                fmt, ', '.join(['"{}"'.format(k) for k in pixel_fmts.keys()])))

        format = pixel_fmts[fmt]
        with nogil:
            check_ret(fc2SetDefaultOutputFormat(format))

    def get_bpp(self, fmt):
        '''Returns the number of bits per pixel for the given format.

        ``fmt`` can be one of ``'mono8'``, ``'yuv411'``, ``'yuv422'``, ``'yuv444'``,
        ``'rgb8'``, ``'mono16'``, ``'rgb16'``, ``'s_mono16'``, ``'s_rgb16'``,
        ``'raw8'``, ``'raw16'``, ``'mono12'``, ``'raw12'``, ``'bgr'``,
        ``'bgru'``, ``'rgb'``, ``'rgbu'``, ``'bgr16'``, ``'bgru16'``,
        ``'yuv422_jpeg'``.
        '''
        cdef fc2PixelFormat format
        cdef unsigned int bpp

        if fmt not in pixel_fmts:
            raise ValueError('"{}" not found in allowed values {}'.format(
                fmt, ', '.join(['"{}"'.format(k) for k in pixel_fmts.keys()])))

        format = pixel_fmts[fmt]
        with nogil:
            check_ret(fc2DetermineBitsPerPixel(format, &bpp))
        return bpp

    def cycle_time(self):
        '''Returns the current timestamp, as a :attr:`TimeStamp`, of the bus.
        '''
        cdef fc2TimeStamp t
        with nogil:
            check_ret(fc2GetCycleTime(self.context, &t))
        return TimeStamp(
            t.seconds, t.microSeconds, t.cycleSeconds, t.cycleCount, t.cycleOffset)


cdef class Camera(CameraContext):
    '''Represents a Point Gray camera connected on the bus.

    Each :class:`Camera` instance derives from :class:`CameraContext` since each
    camera requires a controller.

    At least one of the parameters must be provided.

    :Parameters:

        `guid`: list
            A list of size 4 representing the GUID of the camera. Can be None (default).
        `index`: int
            The index of the camera on the bus. Can be None (default).
        `ip`: list
            A list of size 4 representing the IP of the camera. Can be None (default).
        `serial`: int
            The serial number of the camera on the bus. Can be None (default).
    '''

    def __cinit__(self, guid=None, index=None, ip=None, serial=None, **kwargs):
        cdef int i = 0
        cdef fc2IPAddress _ip
        self.index = <unsigned int>-1
        self.ip = self.subnet = self.gateway = self.mac_address = None
        self.connected = False
        self.setting_names = sorted(setting_csr_base_reg.keys())

        if guid is not None:
            for i in range(4):
                self._guid.value[i] = guid[i]
        elif index is not None:
            self.index = index
            with nogil:
                check_ret(fc2GetCameraFromIndex(self.context, self.index, &self._guid))
        elif ip is not None:
            for i in range(4):
                _ip.octets[i] = ip[i]
            with nogil:
                check_ret(fc2GetCameraFromIPAddress(self.context, _ip, &self._guid))
        elif serial is not None:
            self.serial = serial
            with nogil:
                check_ret(fc2GetCameraFromSerialNumber(self.context, self.serial, &self._guid))
        else:
            raise Exception('At least one of guid, index, ip, or serial must be specified.')

        self.guid = [self._guid.value[i] for i in range(4)]
        with nogil:
            check_ret(fc2Connect(self.context, &self._guid))
        try:
            with nogil:
                check_ret(fc2GetCameraInfo(self.context, &self.cam_info))
        except:
            with nogil:
                fc2Disconnect(self.context)
            raise
        else:
            with nogil:
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
        else:
            self.interface_type = 'unknown'

        # check_ret(fc2SetCallback(self.context, <fc2ImageEventCallback>image_event_callback, <PyObject*>self))

    def __dealloc__(self):
        with nogil:
            fc2DestroyImage(&self.image)

    def set_register(self, unsigned int address, unsigned int value):
        '''Writes ``value`` to register ``address``.
        '''
        with nogil:
            check_ret(fc2WriteRegister(self.context, address, value))

    def get_register(self, unsigned int address):
        '''Returns the current value from register ``address``.
        '''
        cdef unsigned int value = 0
        with nogil:
            check_ret(fc2ReadRegister(self.context, address, &value))
        return value

    def get_cam_abs_setting_range(self, setting):
        '''Returns the absolute (min, max) values of the setting.
        '''
        if setting not in setting_csr_base_reg:
            raise ValueError('setting "{}" not recognized'.format(setting))

        cdef unsigned int offset = self.get_register(setting_csr_base_reg[setting])
        offset *= 4
        offset &= 0xFFFFF

        cdef unsigned int min = self.get_register(offset)
        cdef unsigned int max = self.get_register(offset + 0x4)

        return (<float *>&min)[0], (<float *>&max)[0]

    def get_cam_abs_setting_value(self, setting):
        '''Returns the absolute value of the setting.
        '''
        if setting not in setting_csr_base_reg:
            raise ValueError('setting "{}" not recognized'.format(setting))

        cdef unsigned int offset = self.get_register(setting_csr_base_reg[setting])
        offset *= 4
        offset &= 0xFFFFF

        cdef unsigned int value = self.get_register(offset + 0x8)
        return (<float *>&value)[0]

    def set_cam_abs_setting_value(self, setting, value):
        '''Returns the absolute value of the setting.
        '''
        if setting not in setting_csr_base_reg:
            raise ValueError('setting "{}" not recognized'.format(setting))

        mn, mx = self.get_cam_abs_setting_range(setting)
        cdef float val = max(min(value, mx), mn)

        cdef unsigned int offset = self.get_register(setting_csr_base_reg[setting])
        offset *= 4
        offset &= 0xFFFFF

        self.set_register(offset + 0x8, (<unsigned int *>&val)[0])

    def get_cam_setting_abilities(self, setting):
        if setting not in setting_inq_reg:
            raise ValueError('setting "{}" not recognized'.format(setting))

        cdef unsigned int config = reverse_bits(self.get_register(setting_inq_reg[setting]))
        cdef dict options = {}
        for name, bit in {
                'present': 0, 'abs': 1, 'one_push': 3,
                'read': 4, 'controllable': 5, 'auto': 6, 'manual': 7}.items():
            options[name] = bool((1 << bit) & config)

        options['min'] = ((0xFFF << 8) & config) >> 8
        options['max'] = ((0xFFF << 20) & config) >> 20
        return options

    def get_cam_setting_option_values(self, setting):
        '''Gets the setting options.
        '''
        if setting not in setting_value_reg_all:
            raise ValueError('setting "{}" not recognized'.format(setting))

        cdef unsigned int config = reverse_bits(self.get_register(setting_value_reg_all[setting]))
        cdef dict options = {}
        for name, bit in {
                'present': 0, 'abs': 1, 'one_push': 5,
                'controllable': 6, 'auto': 7}.items():
            options[name] = bool((1 << bit) & config)

        options['relative_value'] = ((0xFFF << 20) & config) >> 20
        return options

    def set_cam_setting_option_values(
            self, setting, abs=None, one_push=None, controllable=None,
            auto=None, relative_value=None):
        '''Sets the setting options.
        '''
        if setting not in setting_value_reg_all:
            raise ValueError('setting "{}" not recognized'.format(setting))

        cdef unsigned int config = reverse_bits(self.get_register(setting_value_reg_all[setting]))
        cdef unsigned int val = 0

        if abs is not None:
            config = (config | (1 << 1)) if abs else (config & ~(1 << 1))
        if one_push is not None:
            config = (config | (1 << 5)) if one_push else (config & ~(1 << 5))
        if controllable is not None:
            config = (config | (1 << 6)) if controllable else (config & ~(1 << 6))
        if auto is not None:
            config = (config | (1 << 7)) if auto else (config & ~(1 << 7))
        if relative_value is not None:
            val = relative_value
            config = ((val & 0xFFF) << 20) | (config & (0xFFFFFFFF >> 12))

        self.set_register(setting_value_reg_all[setting], reverse_bits(config))

    def get_horizontal_mirror(self):
        '''Returns tuple of (present, state). present indicates whether  this feature
        is available for this camera. state is True if mirroring is curently
        on, otherwise it's False.
        '''
        cdef unsigned int config = reverse_bits(self.get_register(0x1054))
        return bool((1 << 0) & config), bool((1 << 31) & config)

    def set_horizontal_mirror(self, value):
        '''Sets whether horizontal mirroring should be turned ON or OFF assuming
        it's available.
        '''
        if not self.get_horizontal_mirror()[0]:
            raise Exception('Horizontal mirroring is not available')

        self.set_register(0x1054, reverse_bits(int(bool(value)) << 31))

    def is_controlable(self):
        '''Returns whether the camera is controllable by the controller.
        '''
        cdef BOOL controlable = 0
        with nogil:
            check_ret(fc2IsCameraControlable(self.context, &self._guid, &controlable))
        return bool(controlable)

    def set_drop_mode(self, int drop=True):
        '''Sets whether frames should be dropped or buffered and sent later when
        not retrieved quickly enough. ``drop`` defaults to True.
        '''
        cdef fc2Config config
        with nogil:
            check_ret(fc2GetConfiguration(self.context, &config))
            config.grabMode = FC2_DROP_FRAMES if drop else FC2_BUFFER_FRAMES
            check_ret(fc2SetConfiguration(self.context, &config))

    def get_drop_mode(self):
        '''Returns True if the camera will drop frames rather than buffer it.
        '''
        cdef fc2Config config
        with nogil:
            check_ret(fc2GetConfiguration(self.context, &config))
        return config.grabMode == FC2_DROP_FRAMES

    def _convert_mode_args(self, width, height, fmt, rate):
        if fmt == 'fmt7':
            val = 'fmt7'
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
        '''Checks whether the input parameters are supported.

        Allowed values are listed in :meth:`set_video_mode`.
        '''
        cdef fc2VideoMode mode
        cdef fc2FrameRate _rate
        cdef BOOL supported = 0
        mode, _rate = self._convert_mode_args(width, height, fmt, rate)
        with nogil:
            check_ret(fc2GetVideoModeAndFrameRateInfo(self.context, mode, _rate, &supported))
        return bool(supported)

    def set_video_mode(self, width, height, fmt, rate):
        '''Sets the camera to the input parameter values.

        ``width``, ``height`` is the frame sizes. ``fmt`` is the pixel format.
        Allowed values are ``'160x120 yuv444'``, ``'320x240 yuv422'``,
        ``'640x480 yuv411'``, ``'640x480 yuv422'``, ``'640x480 rgb'``,
        ``'640x480 y8'``, ``'640x480 y16'``, ``'800x600 yuv422'``,
        ``'800x600 rgb'``, ``'800x600 y8'``, ``'800x600 y16'``,
        ``'1024x768 yuv422'``, ``'1024x768 rgb'``, ``'1024x768 y8'``,
        ``'1024x768 y16'``, ``'1280x960 yuv422'``, ``'1280x960 rgb'``,
        ``'1280x960 y8'``, ``'1280x960 y16'``, ``'1600x1200 yuv422'``,
        ``'1600x1200 rgb'``, ``'1600x1200 y8'``, ``'1600x1200 y16'``.

        A fmt of ``'fmt7'`` doesn't have a preset frame size.

        ``rate`` can be one of ``1.875``, ``3.75``, ``7.5``, ``15``, ``30``,
        ``60``, ``120``, ``240``. A rate of ``'fmt7'`` doesn't have a preset frame rate.
        '''
        cdef fc2VideoMode mode
        cdef fc2FrameRate _rate
        mode, _rate = self._convert_mode_args(width, height, fmt, rate)
        with nogil:
            check_ret(fc2SetVideoModeAndFrameRate(self.context, mode, _rate))

    def get_video_mode(self):
        '''Returns a 4 tuple of (width, height, pixel_fomrat, rate).

        Values are similar to those listed in :meth:`set_video_mode`.
        '''
        cdef fc2VideoMode _mode = FC2_VIDEOMODE_FORMAT7
        cdef fc2FrameRate _rate = FC2_FRAMERATE_FORMAT7
        with nogil:
            check_ret(fc2GetVideoModeAndFrameRate(self.context, &_mode, &_rate))

        if _mode not in video_modes_inv:
            raise Exception('Unknown video mode {}'.format(<int>_mode))
        if _rate not in frame_rates_inv:
            raise Exception('Unknown frame rate {}'.format(<int>_rate))

        mode = video_modes_inv[_mode]
        rate = frame_rates_inv[_rate]
        if rate != 'fmt7':
            rate = float(rate)
        if mode == 'fmt7':
            return None, None, 'fmt7', rate
        size, fmt = mode.split(' ')
        w, h = size.split('x')
        return int(w), int(h), fmt, rate

    def get_fmt7_specs(self):
        '''Returns the specs of the fmt7 configuration.

        The returned value is a dict whose keys are its modes and whose values
        is each a dict describing the mode. The keys of the individual dicts are

        ``'max_width'``, ``'max_height'``, ``'h_offset_step'``,
        ``'v_offset_step'``, ``'h_image_step'``, ``'v_image_step'``,
        ``'pix_fmt_bit_field'``, ``'vender_pix_fmt_bit_field'``, ``'packet_size'``,
        ``'min_packet_size'``, ``'max_packet_size'``, ``'percentage'``.
        '''
        cdef BOOL supported
        cdef fc2Mode mode
        cdef fc2Format7Info info
        cdef dict modes = {}

        for mode in fc2_modes:
            supported = 0
            memset(&info, 0, sizeof(fc2Format7Info))
            info.mode = mode
            with nogil:
                check_ret(fc2GetFormat7Info(self.context, &info, &supported))
            if not supported:
                continue
            modes[<int>mode] = {
                'max_width': info.maxWidth,
                'max_height': info.maxHeight,
                'h_offset_step': info.offsetHStepSize,
                'v_offset_step': info.offsetVStepSize,
                'h_image_step': info.imageHStepSize,
                'v_image_step': info.imageVStepSize,
                'pix_fmt_bit_field': info.pixelFormatBitField,
                'vender_pix_fmt_bit_field': info.vendorPixelFormatBitField,
                'packet_size': info.packetSize,
                'min_packet_size': info.minPacketSize,
                'max_packet_size': info.maxPacketSize,
                'percentage': info.percentage
            }
        return modes

    def validate_fmt7_specs(self, mode, offset_x, offset_y, width, height, fmt):
        '''Validates the fmt7 configuration for the mode. Similar to :meth:`get_fmt7_specs`
        and :meth:`get_fmt7_config`.
        '''
        cdef fc2Format7ImageSettings settings
        cdef BOOL valid
        cdef fc2Format7PacketInfo packet
        if fmt not in pixel_fmts:
            raise Exception('{} not found in {}'.format(fmt, ', '.join(pixel_fmts.keys())))

        settings.mode = <fc2Mode>mode
        settings.offsetX = offset_x
        settings.offsetY = offset_y
        settings.width = width
        settings.height = height
        settings.pixelFormat = pixel_fmts[fmt]
        with nogil:
            check_ret(fc2ValidateFormat7Settings(self.context, &settings, &valid, &packet))
        return (bool(valid), int(packet.recommendedBytesPerPacket),
                int(settings.maxBytesPerPacket), int(settings.unitBytesPerPacket))

    def get_fmt7_config(self):
        '''Returns a 3-tuple of the current fmt7 config.

        The tuple is ``(dict, size, percentage)``. The dict is a dict with keys
        ``'mode'``, ``'offset_x'``, ``'offset_y'``, ``'width'``, ``'height'``,
        ``'fmt'``.
        '''
        cdef fc2Format7ImageSettings settings
        cdef unsigned int size
        cdef float percentage

        with nogil:
            check_ret(fc2GetFormat7Configuration(self.context, &settings, &size, &percentage))
        fmt = pixel_fmts_inv.get(settings.pixelFormat, 'unknown')

        return ({'mode': <int>settings.mode, 'offset_x': settings.offsetX,
                'offset_y': settings.offsetY, 'width': settings.width,
                'height': settings.height, 'fmt': fmt}, size, percentage)

    def set_fmt7_config(self, mode, offset_x, offset_y, width, height, fmt,
                        packet_size=None, packet_percentage=None):
        '''Similar to :meth:`get_fmt7_config`.
        '''
        cdef fc2Format7ImageSettings settings
        cdef float packet_f
        cdef unsigned int packet_ui
        if fmt not in pixel_fmts:
            raise Exception('{} not found in {}'.format(fmt, ', '.join(pixel_fmts.keys())))

        settings.mode = <fc2Mode>mode
        settings.offsetX = offset_x
        settings.offsetY = offset_y
        settings.width = width
        settings.height = height
        settings.pixelFormat = pixel_fmts[fmt]

        if packet_size is not None:
            packet_ui = packet_size
            with nogil:
                check_ret(fc2SetFormat7ConfigurationPacket(self.context, &settings, packet_ui))
        if packet_percentage is not None:
            packet_f = packet_percentage
            with nogil:
                check_ret(fc2SetFormat7Configuration(self.context, &settings, packet_f))

    def verify_gige_mode(self, mode):
        '''Checks if the GigE camera mode is supported.
        '''
        cdef fc2Mode fcmode
        cdef BOOL supported = 0
        if mode >= <int>FC2_NUM_MODES or mode < <int>FC2_MODE_0:
            raise Exception('Unrecognized mode {}'.format(mode))

        fcmode = <fc2Mode>mode
        with nogil:
            check_ret(fc2QueryGigEImagingMode(self.context, fcmode, &supported))
        return bool(supported)

    def get_gige_mode(self):
        '''Gets the current GigE camera mode.
        '''
        cdef fc2Mode mode
        with nogil:
            check_ret(fc2GetGigEImagingMode(self.context, &mode))
        return <int>mode

    def set_gige_mode(self, mode):
        '''Sets the GigE camera mode.
        '''
        cdef fc2Mode fcmode
        if mode >= <int>FC2_NUM_MODES or mode < <int>FC2_MODE_0:
            raise Exception('Unrecognized mode {}'.format(mode))

        fcmode = <fc2Mode>mode
        with nogil:
            check_ret(fc2SetGigEImagingMode(self.context, fcmode))

    def get_gige_specs(self):
        '''Gets the specs of the GigE camera.

        Returns a dict whose keys are ``'max_width'``, ``'max_height'``,
        ``'h_offset_step'``, ``'v_offset_step'``, ``'h_image_step'``,
        ``'v_image_step'``, ``'pix_fmt_bit_field'``, ``'vender_pix_fmt_bit_field'``.
        '''
        cdef fc2GigEImageSettingsInfo info

        with nogil:
            check_ret(fc2GetGigEImageSettingsInfo(self.context, &info))
        return {
            'max_width': info.maxWidth,
            'max_height': info.maxHeight,
            'h_offset_step': info.offsetHStepSize,
            'v_offset_step': info.offsetVStepSize,
            'h_image_step': info.imageHStepSize,
            'v_image_step': info.imageVStepSize,
            'pix_fmt_bit_field': info.pixelFormatBitField,
            'vender_pix_fmt_bit_field': info.vendorPixelFormatBitField
        }

    def get_gige_config(self):
        '''Returns the current GigE configuration.

        Returns a dict whose keys are ``'offset_x'``, ``'offset_y'``,
        ``'width'``, ``'height'``, ``'fmt'``.
        '''
        cdef fc2GigEImageSettings settings

        with nogil:
            check_ret(fc2GetGigEImageSettings(self.context, &settings))

        return {'offset_x': settings.offsetX, 'offset_y': settings.offsetY,
                 'width': settings.width, 'height': settings.height,
                 'fmt': pixel_fmts_inv.get(settings.pixelFormat, 'unknown')}

    def set_gige_config(self, offset_x, offset_y, width, height, fmt):
        '''Sets the GigE configuration. Similar to :meth:`get_gige_config`.
        '''
        cdef fc2GigEImageSettings settings
        if fmt not in pixel_fmts:
            raise Exception('{} not found in {}'.format(fmt, ', '.join(pixel_fmts.keys())))

        settings.offsetX = offset_x
        settings.offsetY = offset_y
        settings.width = width
        settings.height = height
        settings.pixelFormat = pixel_fmts[fmt]
        with nogil:
            check_ret(fc2SetGigEImageSettings(self.context, &settings))

    def get_gige_packet_config(self):
        '''Returns a dict with the bus video packet config. Its keys are
        ``'resend'``, ``'timeout_retries'``, ``'timeout'``.
        '''
        cdef fc2GigEConfig settings
        with nogil:
            check_ret(fc2GetGigEConfig(self.context, &settings))
        return {'resend': bool(settings.enablePacketResend),
                'timeout_retries': settings.registerTimeoutRetries,
                'timeout': settings.registerTimeout}

    def set_gige_packet_config(self, resend, timeout, timeout_retries):
        '''Sets the bus video packet config. Similar to :meth:`get_gige_packet_config`.
        '''
        cdef fc2GigEConfig settings
        settings.enablePacketResend = resend
        settings.registerTimeoutRetries = int(timeout_retries)
        settings.registerTimeout = int(timeout)
        with nogil:
            check_ret(fc2SetGigEConfig(self.context, &settings))

    def get_gige_binning(self):
        '''Returns a 2-tuple of the horizontal and vertical pixel binning.
        '''
        cdef unsigned int hvalue, vvalue
        with nogil:
            check_ret(fc2GetGigEImageBinningSettings(self.context, &hvalue, &vvalue))
        return hvalue, vvalue

    def set_gige_binning(self, unsigned int horizontal, unsigned int vertical):
        '''Sets the horizontal and vertical pixel binning.
        '''
        with nogil:
            check_ret(fc2SetGigEImageBinningSettings(self.context, horizontal, vertical))

    def get_gige_num_streams(self):
        '''Gets the number of stream for the camera.
        '''
        cdef unsigned int value
        with nogil:
            check_ret(fc2GetNumStreamChannels(self.context, &value))
        return value

    def get_gige_stream_config(self, unsigned int chan):
        '''Returns a dict with the with information about the channel.

        Its keys are ``'net_index'``, ``'host_port'``, ``'frag'``,
        ``'packet_size'``, ``'delay'``, ``'dest_ip'``, ``'src_port'``.
        '''
        cdef fc2GigEStreamChannel config
        cdef int i
        with nogil:
            check_ret(fc2GetGigEStreamChannelInfo(self.context, chan, &config))
        return {
            'net_index': config.networkInterfaceIndex,
            'host_port': config.hostPort,
            'frag': bool(config.doNotFragment),
            'packet_size': config.packetSize,
            'delay': config.interPacketDelay,
            'dest_ip': [config.destinationIpAddress.octets[i] for i in range(4)],
            'src_port': config.sourcePort}

    def set_gige_stream_config(
            self, unsigned int chan, net_index, host_port, frag, packet_size, delay,
            dest_ip, src_port):
        '''Sets the stream configuration. Similar to :meth:`get_gige_stream_config`.
        '''
        cdef int i
        cdef fc2GigEStreamChannel config

        config.networkInterfaceIndex = net_index
        config.hostPort = host_port
        config.doNotFragment = frag
        config.packetSize = packet_size
        config.interPacketDelay = delay

        for i in range(4):
            config.destinationIpAddress.octets[i] = dest_ip[i]
        config.sourcePort = src_port

        with nogil:
            check_ret(fc2SetGigEStreamChannelInfo(self.context, chan, &config))

    def connect(self):
        '''Connects the camera represented by the instance.
        '''
        if not self.connected:
            with nogil:
                check_ret(fc2CreateImage(&self.image))
                check_ret(fc2Connect(self.context, &self._guid))
            self.connected = True

    def disconnect(self):
        '''Disconnects the camera represented by the instance.
        '''
        if self.connected:
            with nogil:
                check_ret(fc2Disconnect(self.context))
                check_ret(fc2DestroyImage(&self.image))
            self.connected = False

    cdef image_callback(self, fc2Image *image):
        pass

    def start_capture(self):
        '''Sets the camera to start capturing and acquiring frames.
        '''
        with nogil:
            check_ret(fc2StartCapture(self.context))

    def start_capture_sync(self, other_cams):
        '''Sets the camera to start capturing in sync with all the :class:`Camera`
        instances listed in ``other_cams``. All these cameras will start
        capturing simultaneously.
        '''
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
            with nogil:
                check_ret(fc2StartSyncCapture(n, contexts))
        finally:
            free(contexts)

    def stop_capture(self):
        '''Stops the camera from capturing frames.
        '''
        with nogil:
            check_ret(fc2StopCapture(self.context))

    def read_next_image(self):
        '''Requests that the next acquired frame be read fro the bus.
        '''
        with nogil:
            check_ret(fc2RetrieveBuffer(self.context, &self.image))

    cpdef get_current_image_config(self):
        '''Returns the configuration parameters of the last read image.

        Its keys are ``'rows'``, ``'cols'``, ``'stride'``, ``'data_size'``,
        ``'received_size'``, ``'pix_fmt'``, ``'bayer_fmt'``, ``'ts'``.

        The value of ``'ts'`` is a :attr:`TimeStamp` instance.
        '''
        cdef fc2TimeStamp t
        with nogil:
            t = fc2GetImageTimeStamp(&self.image)
        ts = TimeStamp(
            t.seconds, t.microSeconds, t.cycleSeconds, t.cycleCount, t.cycleOffset)

        return {
            'rows': self.image.rows,
            'cols': self.image.cols,
            'stride': self.image.stride,
            'data_size': self.image.dataSize,
            'received_size': self.image.receivedDataSize,
            'pix_fmt': pixel_fmts_inv.get(self.image.format, 'unknown'),
            'bayer_fmt': bayer_fmts_inv.get(self.image.bayerFormat, 'unknown'),
            'ts': ts
        }

    cpdef get_current_image(self):
        '''Returns the last read frame.

        It's a ``bytearray`` of size ``data_size`` as returned by
        :meth:`get_current_image_config`.
        '''
        cdef object buffer = bytearray(b'\0') * self.image.dataSize
        cdef unsigned char *dest = buffer
        cdef unsigned char *src = NULL
        cdef dict res = self.get_current_image_config()

        if self.image.dataSize:
            with nogil:
                check_ret(fc2GetImageData(&self.image, &src))
                memcpy(dest, src, self.image.dataSize)
        res['buffer'] = buffer
        return res

    def save_current_image(self, filename, ext='auto'):
        '''Saves the last image read to disk.

        ``ext`` is the extension type, defaults to ``'auto'``. Can be one of
        ``'auto'``, ``'pgm'``, ``'ppm'``, ``'bmp'``, ``'jpeg'``, ``'jpeg2000'``,
        ``'tiff'``, ``'png'``, ``'raw'``.
        '''
        cdef bytes fname = filename if isinstance(filename, bytes) else filename.encode('utf8')
        cdef char *cname = fname
        cdef fc2ImageFileFormat format
        if ext not in image_file_types:
            raise ValueError('"{}" not found in allowed values {}'.format(
                ext, ', '.join(['"{}"'.format(k) for k in image_file_types.keys()])))

        format = image_file_types[ext]
        with nogil:
            check_ret(fc2SaveImage(&self.image, cname, format))


cdef class GUI(object):
    '''Controls a GUI for configuring and selecting Point Gray cameras.

    There are two GUI options, :meth:`show` and :meth:`show_selection`.
    '''

    def __cinit__(self, **kwargs):
        self.gui_context = NULL
        with nogil:
            check_ret(fc2CreateGUIContext(&self.gui_context))

    def __dealloc__(self):
        if self.gui_context != NULL:
            with nogil:
                fc2DestroyGUIContext(self.gui_context)
            self.gui_context = NULL

    def connect_camera(self, Camera cam):
        '''Connects the GUI to the provided :class:`Camera`.
        '''
        with nogil:
            fc2GUIConnect(self.gui_context, cam.context)

    def disconnect_camera(self):
        '''Disconnects the :class:`Camera` connected with :meth:`connect_camera`.
        '''
        with nogil:
            fc2GUIDisconnect(self.gui_context)

    def show(self):
        '''Show the GUI for the :class:`Camera` connected with :meth:`connect_camera`.

        Currently this method may crash or freeze. As of 2016 it is a confirmed bug with
        the Point Gray C library.
        '''
        if not self.is_gui_visible():
            with nogil:
                fc2Show(self.gui_context)

    def hide(self):
        '''Hides the GUI shown with :meth:`show`.
        '''
        if self.is_gui_visible():
            with nogil:
                fc2Hide(self.gui_context)

    def is_gui_visible(self):
        '''Returns whether the GUI is currently shown with :meth:`show`.
        '''
        cdef int visible
        with nogil:
            visible = fc2IsVisible(self.gui_context)
        return bool(visible)

    def show_selection(self):
        '''Shows a non-specific GUI from which any of the cameras can be selected and
        configured.

        Returns a 2-tuple of ``(selected, GUIDs)``.
        ``Selected`` is True if OK was pressed or False if it was canceled.
        ``GUIDs`` is a list of the GUIDs of all the selected cameras.
        '''
        cdef BOOL selected = 0
        cdef unsigned int s = 16
        cdef fc2PGRGuid guid[16]
        cdef int i, j

        with nogil:
            fc2ShowModal(self.gui_context, &selected, guid, &s)
        if selected:
            return bool(selected), [[guid[i].value[j] for j in range(4)] for i in range(s)]
        return False, []
