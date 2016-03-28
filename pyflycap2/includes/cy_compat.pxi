

cdef inline int check_ret(fc2Error ret) nogil except 1:
    if ret != FC2_ERROR_OK:
        with gil:
            raise Exception('PyFlyCap2: {}'.format(fc2ErrorToDescription(ret)))
    return 0


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
    'fmt7': FC2_VIDEOMODE_FORMAT7
}

cdef dict video_modes_inv = {v: k for k, v in video_modes.items()}


cdef dict frame_rates = {
    1.875: FC2_FRAMERATE_1_875,
    3.75: FC2_FRAMERATE_3_75,
    7.5: FC2_FRAMERATE_7_5,
    15: FC2_FRAMERATE_15,
    30: FC2_FRAMERATE_30,
    60: FC2_FRAMERATE_60,
    120: FC2_FRAMERATE_120,
    240: FC2_FRAMERATE_240,
    'fmt7': FC2_FRAMERATE_FORMAT7
}

cdef dict frame_rates_inv = {v: k for k, v in frame_rates.items()}


cdef dict pixel_fmts = {
    'mono8': FC2_PIXEL_FORMAT_MONO8,
    'yuv411': FC2_PIXEL_FORMAT_411YUV8,
    'yuv422': FC2_PIXEL_FORMAT_422YUV8,
    'yuv444': FC2_PIXEL_FORMAT_444YUV8,
    'rgb8': FC2_PIXEL_FORMAT_RGB8,
    'mono16': FC2_PIXEL_FORMAT_MONO16,
    'rgb16': FC2_PIXEL_FORMAT_RGB16,
    's_mono16': FC2_PIXEL_FORMAT_S_MONO16,
    's_rgb16': FC2_PIXEL_FORMAT_S_RGB16,
    'raw8': FC2_PIXEL_FORMAT_RAW8,
    'raw16': FC2_PIXEL_FORMAT_RAW16,
    'mono12': FC2_PIXEL_FORMAT_MONO12,
    'raw12': FC2_PIXEL_FORMAT_RAW12,
    'bgr': FC2_PIXEL_FORMAT_BGR,
    'bgru': FC2_PIXEL_FORMAT_BGRU,
    'rgb': FC2_PIXEL_FORMAT_RGB,
    'rgbu': FC2_PIXEL_FORMAT_RGBU,
    'bgr16': FC2_PIXEL_FORMAT_BGR16,
    'bgru16': FC2_PIXEL_FORMAT_BGRU16,
    'yuv422_jpeg': FC2_PIXEL_FORMAT_422YUV8_JPEG,
}

cdef dict pixel_fmts_inv = {v: k for k, v in pixel_fmts.items()}


cdef dict color_algos = {
    'default': FC2_DEFAULT,
    'no_processing': FC2_NO_COLOR_PROCESSING,
    'NN': FC2_NEAREST_NEIGHBOR_FAST,
    'edge': FC2_EDGE_SENSING,
    'linear': FC2_HQ_LINEAR,
    'rigorous': FC2_RIGOROUS,
    'IPP': FC2_IPP,
    'directional': FC2_DIRECTIONAL
}

cdef dict color_algos_inv = {v: k for k, v in color_algos.items()}


cdef dict image_file_types = {
    'auto': FC2_FROM_FILE_EXT,
    'pgm': FC2_PGM,
    'ppm': FC2_PPM,
    'bmp': FC2_BMP,
    'jpeg': FC2_JPEG,
    'jpeg2000': FC2_JPEG2000,
    'tiff': FC2_TIFF,
    'png': FC2_PNG,
    'raw': FC2_RAW
}


cdef dict bayer_fmts = {
    'rggb': FC2_BT_RGGB,
    'grbg': FC2_BT_GRBG,
    'gbrg': FC2_BT_GBRG,
    'bggr': FC2_BT_BGGR
}

cdef dict bayer_fmts_inv = {v: k for k, v in bayer_fmts.items()}


cdef list fc2_modes = [
    FC2_MODE_0,
    FC2_MODE_1,
    FC2_MODE_2,
    FC2_MODE_3,
    FC2_MODE_4,
    FC2_MODE_5,
    FC2_MODE_6,
    FC2_MODE_7,
    FC2_MODE_8,
    FC2_MODE_9,
    FC2_MODE_10,
    FC2_MODE_11,
    FC2_MODE_12,
    FC2_MODE_13,
    FC2_MODE_14,
    FC2_MODE_15,
    FC2_MODE_16,
    FC2_MODE_17,
    FC2_MODE_18,
    FC2_MODE_19,
    FC2_MODE_20,
    FC2_MODE_21,
    FC2_MODE_22,
    FC2_MODE_23,
    FC2_MODE_24,
    FC2_MODE_25,
    FC2_MODE_26,
    FC2_MODE_27,
    FC2_MODE_28,
    FC2_MODE_29,
    FC2_MODE_30,
    FC2_MODE_31
]
