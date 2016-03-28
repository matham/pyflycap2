'''
Not implemented:

fc2SetUserBuffers
'''

include "includes/cy_compat.pxi"

from libc.stdlib cimport malloc, free
from libc.string cimport memset, memcpy
from cpython.ref cimport PyObject

import logging
from collections import namedtuple


cdef void image_event_callback(fc2Image *image, void *callback_data) nogil:
    with gil:
        try:
            (<Camera>(<PyObject*>callback_data)).image_callback(image)
        except Exception as e:
            logging.exception('PyFlyCap2: got exception "{}" in image_event_callback'.format(e))


TimeStamp = namedtuple(
    'TimeStamp', ['seconds', 'micro_seconds', 'cycle_seconds', 'cycle_count',
                  'cycle_offset'])


cdef class CameraContext(object):
    '''

    `context_type`: str
        Can be one of `IIDC` or `GigE`.
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
        with nogil:
            check_ret(fc2FireBusReset(self.context, &camera._guid))

    def get_num_cameras(self):
        cdef unsigned int n = 0
        with nogil:
            check_ret(fc2GetNumOfCameras(self.context, &n))
        return n

    def get_num_devices(self):
        cdef unsigned int n = 0
        with nogil:
            check_ret(fc2GetNumOfDevices(self.context, &n))
        return n

    def get_device_guid_from_index(self, unsigned int index):
        cdef fc2PGRGuid guid
        with nogil:
            check_ret(fc2GetDeviceFromIndex(self.context, index, &guid))
        return [guid.value[i] for i in range(4)]

    def rescan_bus(self):
        with nogil:
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

        with nogil:
            check_ret(fc2ForceIPAddressToCamera(self.context, mac, _ip, _subnet, _gateway))

    def force_all_ips(self):
        with nogil:
            check_ret(fc2ForceAllIPAddressesAutomatically())

    def get_gige_cams(self):
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
        cdef fc2ColorProcessingAlgorithm method
        with nogil:
            check_ret(fc2GetDefaultColorProcessing(&method))
        return color_algos_inv.get(method, 'unknown')

    def set_default_color_processing(self, algo):
        cdef fc2ColorProcessingAlgorithm default_method
        if algo not in color_algos:
            raise ValueError('"{}" not found in allowed values {}'.format(
                algo, ', '.join(['"{}"'.format(k) for k in color_algos.keys()])))

        default_method = color_algos[algo]
        with nogil:
            check_ret(fc2SetDefaultColorProcessing(default_method))

    def get_default_pix_fmt(self):
        cdef fc2PixelFormat fmt
        with nogil:
            check_ret(fc2GetDefaultOutputFormat(&fmt))
        return pixel_fmts_inv.get(fmt, 'unknown')

    def set_default_pix_fmt(self, fmt):
        cdef fc2PixelFormat format
        if fmt not in pixel_fmts:
            raise ValueError('"{}" not found in allowed values {}'.format(
                fmt, ', '.join(['"{}"'.format(k) for k in pixel_fmts.keys()])))

        format = pixel_fmts[fmt]
        with nogil:
            check_ret(fc2SetDefaultOutputFormat(format))

    def get_bpp(self, fmt):
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
        cdef fc2TimeStamp t
        with nogil:
            check_ret(fc2GetCycleTime(self.context, &t))
        return TimeStamp(
            t.seconds, t.microSeconds, t.cycleSeconds, t.cycleCount, t.cycleOffset)


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

    def is_controlable(self):
        cdef BOOL controlable = 0
        with nogil:
            check_ret(fc2IsCameraControlable(self.context, &self._guid, &controlable))
        return bool(controlable)

    def set_drop_mode(self, int drop=True):
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
        cdef fc2VideoMode mode
        cdef fc2FrameRate _rate
        cdef BOOL supported = 0
        mode, _rate = self._convert_mode_args(width, height, fmt, rate)
        with nogil:
            check_ret(fc2GetVideoModeAndFrameRateInfo(self.context, mode, _rate, &supported))
        return bool(supported)

    def set_video_mode(self, width, height, fmt, rate):
        cdef fc2VideoMode mode
        cdef fc2FrameRate _rate
        mode, _rate = self._convert_mode_args(width, height, fmt, rate)
        with nogil:
            check_ret(fc2SetVideoModeAndFrameRate(self.context, mode, _rate))

    def get_video_mode(self):
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
                'max_width': info.maxWidth, 'max_height': info.maxHeight,
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
        cdef fc2Mode fcmode
        cdef BOOL supported = 0
        if mode >= <int>FC2_NUM_MODES or mode < <int>FC2_MODE_0:
            raise Exception('Unrecognized mode {}'.format(mode))

        fcmode = <fc2Mode>mode
        with nogil:
            check_ret(fc2QueryGigEImagingMode(self.context, fcmode, &supported))
        return bool(supported)

    def get_gige_mode(self):
        cdef fc2Mode mode
        with nogil:
            check_ret(fc2GetGigEImagingMode(self.context, &mode))
        return <int>mode

    def set_gige_mode(self, mode):
        cdef fc2Mode fcmode
        if mode >= <int>FC2_NUM_MODES or mode < <int>FC2_MODE_0:
            raise Exception('Unrecognized mode {}'.format(mode))

        fcmode = <fc2Mode>mode
        with nogil:
            check_ret(fc2SetGigEImagingMode(self.context, fcmode))

    def get_gige_specs(self):
        cdef fc2GigEImageSettingsInfo info

        with nogil:
            check_ret(fc2GetGigEImageSettingsInfo(self.context, &info))
        return {
            'max_width': info.maxWidth, 'max_height': info.maxHeight,
            'h_offset_step': info.offsetHStepSize,
            'v_offset_step': info.offsetVStepSize,
            'h_image_step': info.imageHStepSize,
            'v_image_step': info.imageVStepSize,
            'pix_fmt_bit_field': info.pixelFormatBitField,
            'vender_pix_fmt_bit_field': info.vendorPixelFormatBitField
        }

    def get_gige_config(self):
        cdef fc2GigEImageSettings settings

        with nogil:
            check_ret(fc2GetGigEImageSettings(self.context, &settings))

        return {'offset_x': settings.offsetX, 'offset_y': settings.offsetY,
                 'width': settings.width, 'height': settings.height,
                 'fmt': pixel_fmts_inv.get(settings.pixelFormat, 'unknown')}

    def set_gige_config(self, offset_x, offset_y, width, height, fmt):
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
        cdef fc2GigEConfig settings
        with nogil:
            check_ret(fc2GetGigEConfig(self.context, &settings))
        return {'resend': bool(settings.enablePacketResend),
                'resend_timeout': settings.timeoutForPacketResend,
                'max_resend_packets': settings.maxPacketsToResend}

    def set_gige_packet_config(self, resend, resend_timeout, max_resend_packets):
        cdef fc2GigEConfig settings
        settings.enablePacketResend = resend
        settings.timeoutForPacketResend = int(resend_timeout)
        settings.maxPacketsToResend = int(max_resend_packets)
        with nogil:
            check_ret(fc2SetGigEConfig(self.context, &settings))

    def get_gige_binning(self):
        cdef unsigned int hvalue, vvalue
        with nogil:
            check_ret(fc2GetGigEImageBinningSettings(self.context, &hvalue, &vvalue))
        return hvalue, vvalue

    def set_gige_binning(self, unsigned int horizontal, unsigned int vertical):
        with nogil:
            check_ret(fc2SetGigEImageBinningSettings(self.context, horizontal, vertical))

    def get_gige_num_streams(self):
        cdef unsigned int value
        with nogil:
            check_ret(fc2GetNumStreamChannels(self.context, &value))
        return value

    def get_gige_stream_config(self, unsigned int chan):
        cdef fc2GigEStreamChannel config
        cdef int i
        with nogil:
            check_ret(fc2GetGigEStreamChannelInfo(self.context, chan, &config))
        return {
            'net_index': config.networkInterfaceIndex,
            'host_post': config.hostPost, 'frag': bool(config.doNotFragment),
            'packet_size': config.packetSize, 'delay': config.interPacketDelay,
            'dest_ip': [config.destinationIpAddress.octets[i] for i in range(4)],
            'src_port': config.sourcePort}

    def set_gige_stream_config(
            self, unsigned int chan, net_index, host_post, frag, packet_size, delay,
            dest_ip, src_port):
        cdef int i
        cdef fc2GigEStreamChannel config

        config.networkInterfaceIndex = net_index
        config.hostPost = host_post
        config.doNotFragment = frag
        config.packetSize = packet_size
        config.interPacketDelay = delay

        for i in range(4):
            config.destinationIpAddress.octets[i] = dest_ip[i]
        config.sourcePort = src_port

        with nogil:
            check_ret(fc2SetGigEStreamChannelInfo(self.context, chan, &config))

    def connect(self):
        if not self.connected:
            with nogil:
                check_ret(fc2CreateImage(&self.image))
                check_ret(fc2Connect(self.context, &self._guid))
            self.connected = True

    def disconnect(self):
        if self.connected:
            with nogil:
                check_ret(fc2Disconnect(self.context))
                check_ret(fc2DestroyImage(&self.image))
            self.connected = False

    cdef image_callback(self, fc2Image *image):
        pass

    def start_capture(self):
        with nogil:
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
            with nogil:
                check_ret(fc2StartSyncCapture(n, contexts))
        finally:
            free(contexts)

    def stop_capture(self):
        with nogil:
            check_ret(fc2StopCapture(self.context))

    def read_next_image(self):
        with nogil:
            check_ret(fc2RetrieveBuffer(self.context, &self.image))

    cpdef get_current_image_config(self):
        cdef fc2TimeStamp t
        with nogil:
            t = fc2GetImageTimeStamp(&self.image)
        ts = TimeStamp(
            t.seconds, t.microSeconds, t.cycleSeconds, t.cycleCount, t.cycleOffset)

        return {
            'rows': self.image.rows, 'cols': self.image.cols,
            'stride': self.image.stride, 'data_size': self.image.dataSize,
            'received_size': self.image.receivedDataSize,
            'pix_fmt': pixel_fmts_inv.get(self.image.format, 'unknown'),
            'bayer_fmt': bayer_fmts_inv.get(self.image.bayerFormat, 'unknown'),
            'ts': ts
        }

    cpdef get_current_image(self):
        cdef object buffer = bytearray('\0') * self.image.dataSize
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
        with nogil:
            fc2GUIConnect(self.gui_context, cam.context)

    def disconnect_camera(self):
        with nogil:
            fc2GUIDisconnect(self.gui_context)

    def show(self):
        if not self.is_gui_visible():
            with nogil:
                fc2Show(self.gui_context)

    def hide(self):
        if self.is_gui_visible():
            with nogil:
                fc2Hide(self.gui_context)

    def is_gui_visible(self):
        cdef int visible
        with nogil:
            visible = fc2IsVisible(self.gui_context)
        return bool(visible)

    def show_selection(self):
        cdef BOOL selected = 0
        cdef unsigned int s = 16
        cdef fc2PGRGuid guid[16]
        cdef int i, j

        with nogil:
            fc2ShowModal(self.gui_context, &selected, guid, &s)
        if selected:
            return bool(selected), [[guid[i].value[j] for j in range(4)] for i in range(s)]
        return False, []
