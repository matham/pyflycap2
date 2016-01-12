
DEF FALSE = 0
DEF TRUE = 1
DEF FULL_32BIT_VALUE = 0x7FFFFFFF
DEF MAX_STRING_LENGTH = 512


cdef extern from "C/FlyCapture2Defs_C.h" nogil:

    ctypedef int BOOL

    ctypedef void* fc2Context

    ctypedef void* fc2GuiContext

    ctypedef void* fc2ImageImpl

    ctypedef void* fc2AVIContext

    ctypedef void* fc2ImageStatisticsContext

    cdef struct _fc2PGRGuid:
        unsigned int value[4]
    ctypedef _fc2PGRGuid fc2PGRGuid

    cdef enum _fc2Error:
        FC2_ERROR_UNDEFINED = -1
        FC2_ERROR_OK
        FC2_ERROR_FAILED
        FC2_ERROR_NOT_IMPLEMENTED
        FC2_ERROR_FAILED_BUS_MASTER_CONNECTION
        FC2_ERROR_NOT_CONNECTED
        FC2_ERROR_INIT_FAILED
        FC2_ERROR_NOT_INTITIALIZED
        FC2_ERROR_INVALID_PARAMETER
        FC2_ERROR_INVALID_SETTINGS
        FC2_ERROR_INVALID_BUS_MANAGER
        FC2_ERROR_MEMORY_ALLOCATION_FAILED
        FC2_ERROR_LOW_LEVEL_FAILURE
        FC2_ERROR_NOT_FOUND
        FC2_ERROR_FAILED_GUID
        FC2_ERROR_INVALID_PACKET_SIZE
        FC2_ERROR_INVALID_MODE
        FC2_ERROR_NOT_IN_FORMAT7
        FC2_ERROR_NOT_SUPPORTED
        FC2_ERROR_TIMEOUT
        FC2_ERROR_BUS_MASTER_FAILED
        FC2_ERROR_INVALID_GENERATION
        FC2_ERROR_LUT_FAILED
        FC2_ERROR_IIDC_FAILED
        FC2_ERROR_STROBE_FAILED
        FC2_ERROR_TRIGGER_FAILED
        FC2_ERROR_PROPERTY_FAILED
        FC2_ERROR_PROPERTY_NOT_PRESENT
        FC2_ERROR_REGISTER_FAILED
        FC2_ERROR_READ_REGISTER_FAILED
        FC2_ERROR_WRITE_REGISTER_FAILED
        FC2_ERROR_ISOCH_FAILED
        FC2_ERROR_ISOCH_ALREADY_STARTED
        FC2_ERROR_ISOCH_NOT_STARTED
        FC2_ERROR_ISOCH_START_FAILED
        FC2_ERROR_ISOCH_RETRIEVE_BUFFER_FAILED
        FC2_ERROR_ISOCH_STOP_FAILED
        FC2_ERROR_ISOCH_SYNC_FAILED
        FC2_ERROR_ISOCH_BANDWIDTH_EXCEEDED
        FC2_ERROR_IMAGE_CONVERSION_FAILED
        FC2_ERROR_IMAGE_LIBRARY_FAILURE
        FC2_ERROR_BUFFER_TOO_SMALL
        FC2_ERROR_IMAGE_CONSISTENCY_ERROR
        FC2_ERROR_INCOMPATIBLE_DRIVER
        FC2_ERROR_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2Error fc2Error

    cdef enum _fc2BusCallbackType:
        FC2_BUS_RESET
        FC2_ARRIVAL
        FC2_REMOVAL
        FC2_CALLBACK_TYPE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2BusCallbackType fc2BusCallbackType

    cdef enum _fc2GrabMode:
        FC2_DROP_FRAMES
        FC2_BUFFER_FRAMES
        FC2_UNSPECIFIED_GRAB_MODE
        FC2_GRAB_MODE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2GrabMode fc2GrabMode

    cdef enum _fc2GrabTimeout:
        FC2_TIMEOUT_NONE = 0
        FC2_TIMEOUT_INFINITE = -1
        FC2_TIMEOUT_UNSPECIFIED = -2
        FC2_GRAB_TIMEOUT_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2GrabTimeout fc2GrabTimeout

    cdef enum _fc2BandwidthAllocation:
        FC2_BANDWIDTH_ALLOCATION_OFF = 0
        FC2_BANDWIDTH_ALLOCATION_ON = 1
        FC2_BANDWIDTH_ALLOCATION_UNSUPPORTED = 2
        FC2_BANDWIDTH_ALLOCATION_UNSPECIFIED = 3
        FC2_BANDWIDTH_ALLOCATION_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2BandwidthAllocation fc2BandwidthAllocation

    cdef enum _fc2InterfaceType:
        FC2_INTERFACE_IEEE1394
        FC2_INTERFACE_USB_2
        FC2_INTERFACE_USB_3
        FC2_INTERFACE_GIGE
        FC2_INTERFACE_UNKNOWN
        FC2_INTERFACE_TYPE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2InterfaceType fc2InterfaceType

    cdef enum _fc2DriverType:
        FC2_DRIVER_1394_CAM
        FC2_DRIVER_1394_PRO
        FC2_DRIVER_1394_JUJU
        FC2_DRIVER_1394_VIDEO1394
        FC2_DRIVER_1394_RAW1394
        FC2_DRIVER_USB_NONE
        FC2_DRIVER_USB_CAM
        FC2_DRIVER_USB3_PRO
        FC2_DRIVER_GIGE_NONE
        FC2_DRIVER_GIGE_FILTER
        FC2_DRIVER_GIGE_PRO
        FC2_DRIVER_UNKNOWN = -1
        FC2_DRIVER_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2DriverType fc2DriverType

    cdef enum _fc2PropertyType:
        FC2_BRIGHTNESS
        FC2_AUTO_EXPOSURE
        FC2_SHARPNESS
        FC2_WHITE_BALANCE
        FC2_HUE
        FC2_SATURATION
        FC2_GAMMA
        FC2_IRIS
        FC2_FOCUS
        FC2_ZOOM
        FC2_PAN
        FC2_TILT
        FC2_SHUTTER
        FC2_GAIN
        FC2_TRIGGER_MODE
        FC2_TRIGGER_DELAY
        FC2_FRAME_RATE
        FC2_TEMPERATURE
        FC2_UNSPECIFIED_PROPERTY_TYPE
        FC2_PROPERTY_TYPE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2PropertyType fc2PropertyType

    cdef enum _fc2FrameRate:
        FC2_FRAMERATE_1_875
        FC2_FRAMERATE_3_75
        FC2_FRAMERATE_7_5
        FC2_FRAMERATE_15
        FC2_FRAMERATE_30
        FC2_FRAMERATE_60
        FC2_FRAMERATE_120
        FC2_FRAMERATE_240
        FC2_FRAMERATE_FORMAT7
        FC2_NUM_FRAMERATES
        FC2_FRAMERATE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2FrameRate fc2FrameRate

    cdef enum _fc2VideoMode:
        FC2_VIDEOMODE_160x120YUV444
        FC2_VIDEOMODE_320x240YUV422
        FC2_VIDEOMODE_640x480YUV411
        FC2_VIDEOMODE_640x480YUV422
        FC2_VIDEOMODE_640x480RGB
        FC2_VIDEOMODE_640x480Y8
        FC2_VIDEOMODE_640x480Y16
        FC2_VIDEOMODE_800x600YUV422
        FC2_VIDEOMODE_800x600RGB
        FC2_VIDEOMODE_800x600Y8
        FC2_VIDEOMODE_800x600Y16
        FC2_VIDEOMODE_1024x768YUV422
        FC2_VIDEOMODE_1024x768RGB
        FC2_VIDEOMODE_1024x768Y8
        FC2_VIDEOMODE_1024x768Y16
        FC2_VIDEOMODE_1280x960YUV422
        FC2_VIDEOMODE_1280x960RGB
        FC2_VIDEOMODE_1280x960Y8
        FC2_VIDEOMODE_1280x960Y16
        FC2_VIDEOMODE_1600x1200YUV422
        FC2_VIDEOMODE_1600x1200RGB
        FC2_VIDEOMODE_1600x1200Y8
        FC2_VIDEOMODE_1600x1200Y16
        FC2_VIDEOMODE_FORMAT7
        FC2_NUM_VIDEOMODES
        FC2_VIDEOMODE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2VideoMode fc2VideoMode

    cdef enum _fc2Mode:
        FC2_MODE_0 = 0
        FC2_MODE_1
        FC2_MODE_2
        FC2_MODE_3
        FC2_MODE_4
        FC2_MODE_5
        FC2_MODE_6
        FC2_MODE_7
        FC2_MODE_8
        FC2_MODE_9
        FC2_MODE_10
        FC2_MODE_11
        FC2_MODE_12
        FC2_MODE_13
        FC2_MODE_14
        FC2_MODE_15
        FC2_MODE_16
        FC2_MODE_17
        FC2_MODE_18
        FC2_MODE_19
        FC2_MODE_20
        FC2_MODE_21
        FC2_MODE_22
        FC2_MODE_23
        FC2_MODE_24
        FC2_MODE_25
        FC2_MODE_26
        FC2_MODE_27
        FC2_MODE_28
        FC2_MODE_29
        FC2_MODE_30
        FC2_MODE_31
        FC2_NUM_MODES
        FC2_MODE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2Mode fc2Mode

    cdef enum _fc2PixelFormat:
        FC2_PIXEL_FORMAT_MONO8 = 0x80000000
        FC2_PIXEL_FORMAT_411YUV8 = 0x40000000
        FC2_PIXEL_FORMAT_422YUV8 = 0x20000000
        FC2_PIXEL_FORMAT_444YUV8 = 0x10000000
        FC2_PIXEL_FORMAT_RGB8 = 0x08000000
        FC2_PIXEL_FORMAT_MONO16 = 0x04000000
        FC2_PIXEL_FORMAT_RGB16 = 0x02000000
        FC2_PIXEL_FORMAT_S_MONO16 = 0x01000000
        FC2_PIXEL_FORMAT_S_RGB16 = 0x00800000
        FC2_PIXEL_FORMAT_RAW8 = 0x00400000
        FC2_PIXEL_FORMAT_RAW16 = 0x00200000
        FC2_PIXEL_FORMAT_MONO12 = 0x00100000
        FC2_PIXEL_FORMAT_RAW12 = 0x00080000
        FC2_PIXEL_FORMAT_BGR = 0x80000008
        FC2_PIXEL_FORMAT_BGRU = 0x40000008
        FC2_PIXEL_FORMAT_RGB = FC2_PIXEL_FORMAT_RGB8
        FC2_PIXEL_FORMAT_RGBU = 0x40000002
        FC2_PIXEL_FORMAT_BGR16 = 0x02000001
        FC2_PIXEL_FORMAT_BGRU16 = 0x02000002
        FC2_PIXEL_FORMAT_422YUV8_JPEG = 0x40000001
        FC2_NUM_PIXEL_FORMATS = 20
        FC2_UNSPECIFIED_PIXEL_FORMAT = 0
    ctypedef _fc2PixelFormat fc2PixelFormat

    cdef enum _fc2BusSpeed:
        FC2_BUSSPEED_S100
        FC2_BUSSPEED_S200
        FC2_BUSSPEED_S400
        FC2_BUSSPEED_S480
        FC2_BUSSPEED_S800
        FC2_BUSSPEED_S1600
        FC2_BUSSPEED_S3200
        FC2_BUSSPEED_S5000
        FC2_BUSSPEED_10BASE_T
        FC2_BUSSPEED_100BASE_T
        FC2_BUSSPEED_1000BASE_T
        FC2_BUSSPEED_10000BASE_T
        FC2_BUSSPEED_S_FASTEST
        FC2_BUSSPEED_ANY
        FC2_BUSSPEED_SPEED_UNKNOWN = -1
        FC2_BUSSPEED_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2BusSpeed fc2BusSpeed

    cdef enum _fc2PCIeBusSpeed:
        FC2_PCIE_BUSSPEED_2_5
        FC2_PCIE_BUSSPEED_5_0
        FC2_PCIE_BUSSPEED_UNKNOWN = -1
        FC2_PCIE_BUSSPEED_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2PCIeBusSpeed fc2PCIeBusSpeed

    cdef enum _fc2ColorProcessingAlgorithm:
        FC2_DEFAULT
        FC2_NO_COLOR_PROCESSING
        FC2_NEAREST_NEIGHBOR_FAST
        FC2_EDGE_SENSING
        FC2_HQ_LINEAR
        FC2_RIGOROUS
        FC2_IPP
        FC2_DIRECTIONAL
        FC2_COLOR_PROCESSING_ALGORITHM_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2ColorProcessingAlgorithm fc2ColorProcessingAlgorithm

    cdef enum _fc2BayerTileFormat:
        FC2_BT_NONE
        FC2_BT_RGGB
        FC2_BT_GRBG
        FC2_BT_GBRG
        FC2_BT_BGGR
        FC2_BT_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2BayerTileFormat fc2BayerTileFormat

    cdef enum _fc2ImageFileFormat:
        FC2_FROM_FILE_EXT = -1
        FC2_PGM
        FC2_PPM
        FC2_BMP
        FC2_JPEG
        FC2_JPEG2000
        FC2_TIFF
        FC2_PNG
        FC2_RAW
        FC2_IMAGE_FILE_FORMAT_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2ImageFileFormat fc2ImageFileFormat

    cdef enum _fc2GigEPropertyType:
        FC2_HEARTBEAT
        FC2_HEARTBEAT_TIMEOUT
    ctypedef _fc2GigEPropertyType fc2GigEPropertyType

    cdef enum _fc2StatisticsChannel:
        FC2_STATISTICS_GREY
        FC2_STATISTICS_RED
        FC2_STATISTICS_GREEN
        FC2_STATISTICS_BLUE
        FC2_STATISTICS_HUE
        FC2_STATISTICS_SATURATION
        FC2_STATISTICS_LIGHTNESS
        FC2_STATISTICS_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2StatisticsChannel fc2StatisticsChannel

    cdef enum _fc2OSType:
        FC2_WINDOWS_X86
        FC2_WINDOWS_X64
        FC2_LINUX_X86
        FC2_LINUX_X64
        FC2_MAC
        FC2_UNKNOWN_OS
        FC2_OSTYPE_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2OSType fc2OSType

    cdef enum _fc2ByteOrder:
        FC2_BYTE_ORDER_LITTLE_ENDIAN
        FC2_BYTE_ORDER_BIG_ENDIAN
        FC2_BYTE_ORDER_FORCE_32BITS = FULL_32BIT_VALUE
    ctypedef _fc2ByteOrder fc2ByteOrder

    cdef struct _fc2Image:
        unsigned int rows
        unsigned int cols
        unsigned int stride
        unsigned char* pData
        unsigned int dataSize
        unsigned int receivedDataSize
        fc2PixelFormat format
        fc2BayerTileFormat bayerFormat
        fc2ImageImpl imageImpl
    ctypedef _fc2Image fc2Image

    cdef struct _fc2SystemInfo:
        fc2OSType osType
        char osDescription[MAX_STRING_LENGTH]
        fc2ByteOrder byteOrder
        size_t sysMemSize
        char cpuDescription[MAX_STRING_LENGTH]
        size_t numCpuCores
        char driverList[MAX_STRING_LENGTH]
        char libraryList[MAX_STRING_LENGTH]
        char gpuDescription[MAX_STRING_LENGTH]
        size_t screenWidth
        size_t screenHeight
        unsigned int reserved[16]
    ctypedef _fc2SystemInfo fc2SystemInfo

    cdef struct _fc2Version:
        unsigned int major
        unsigned int minor
        unsigned int type
        unsigned int build
    ctypedef _fc2Version fc2Version

    cdef struct _fc2Config:
        unsigned int numBuffers
        unsigned int numImageNotifications
        unsigned int minNumImageNotifications
        int grabTimeout
        fc2GrabMode grabMode
        fc2BusSpeed isochBusSpeed
        fc2BusSpeed asyncBusSpeed
        fc2BandwidthAllocation bandwidthAllocation
        unsigned int registerTimeoutRetries
        unsigned int registerTimeout
        unsigned int reserved[16]
    ctypedef _fc2Config fc2Config

    cdef struct _fc2PropertyInfo:
        fc2PropertyType type
        BOOL present
        BOOL autoSupported
        BOOL manualSupported
        BOOL onOffSupported
        BOOL onePushSupported
        BOOL absValSupported
        BOOL readOutSupported
        unsigned int min
        unsigned int max
        float absMin
        float absMax
        char pUnits[MAX_STRING_LENGTH]
        char pUnitAbbr[MAX_STRING_LENGTH]
        unsigned int reserved[8]
    ctypedef _fc2PropertyInfo fc2PropertyInfo
    ctypedef _fc2PropertyInfo fc2TriggerDelayInfo

    cdef struct _Property:
        fc2PropertyType type
        BOOL present
        BOOL absControl
        BOOL onePush
        BOOL onOff
        BOOL autoManualMode
        unsigned int valueA
        unsigned int valueB
        float absValue
        unsigned int reserved[8]
    ctypedef _Property fc2Property
    ctypedef _Property fc2TriggerDelay

    cdef struct _fc2TriggerModeInfo:
        BOOL present
        BOOL readOutSupported
        BOOL onOffSupported
        BOOL polaritySupported
        BOOL valueReadable
        unsigned int sourceMask
        BOOL softwareTriggerSupported
        unsigned int modeMask
        unsigned int reserved[8]
    ctypedef _fc2TriggerModeInfo fc2TriggerModeInfo

    cdef struct _fc2TriggerMode:
        BOOL onOff
        unsigned int polarity
        unsigned int source
        unsigned int mode
        unsigned int parameter
        unsigned int reserved[8]
    ctypedef _fc2TriggerMode fc2TriggerMode

    cdef struct _fc2StrobeInfo:
        unsigned int source
        BOOL present
        BOOL readOutSupported
        BOOL onOffSupported
        BOOL polaritySupported
        float minValue
        float maxValue
        unsigned int reserved[8]
    ctypedef _fc2StrobeInfo fc2StrobeInfo

    cdef struct _fc2StrobeControl:
        unsigned int source
        BOOL onOff
        unsigned int polarity
        float delay
        float duration
        unsigned int reserved[8]
    ctypedef _fc2StrobeControl fc2StrobeControl

    cdef struct _fc2Format7ImageSettings:
        fc2Mode mode
        unsigned int offsetX
        unsigned int offsetY
        unsigned int width
        unsigned int height
        fc2PixelFormat pixelFormat
        unsigned int reserved[8]
    ctypedef _fc2Format7ImageSettings fc2Format7ImageSettings

    cdef struct _fc2Format7Info:
        fc2Mode mode
        unsigned int maxWidth
        unsigned int maxHeight
        unsigned int offsetHStepSize
        unsigned int offsetVStepSize
        unsigned int imageHStepSize
        unsigned int imageVStepSize
        unsigned int pixelFormatBitField
        unsigned int vendorPixelFormatBitField
        unsigned int packetSize
        unsigned int minPacketSize
        unsigned int maxPacketSize
        float percentage
        unsigned int reserved[16]
    ctypedef _fc2Format7Info fc2Format7Info

    cdef struct _fc2Format7PacketInfo:
        unsigned int recommendedBytesPerPacket
        unsigned int maxBytesPerPacket
        unsigned int unitBytesPerPacket
        unsigned int reserved[8]
    ctypedef _fc2Format7PacketInfo fc2Format7PacketInfo

    cdef struct _fc2IPAddress:
        unsigned char octets[4]
    ctypedef _fc2IPAddress fc2IPAddress

    cdef struct _fc2MACAddress:
        unsigned char octets[6]
    ctypedef _fc2MACAddress fc2MACAddress

    cdef struct _fc2GigEProperty:
        fc2GigEPropertyType propType
        BOOL isReadable
        BOOL isWritable
        unsigned int min
        unsigned int max
        unsigned int value
        unsigned int reserved[8]
    ctypedef _fc2GigEProperty fc2GigEProperty

    cdef struct _fc2GigEStreamChannel:
        unsigned int networkInterfaceIndex
        unsigned int hostPost
        BOOL doNotFragment
        unsigned int packetSize
        unsigned int interPacketDelay
        fc2IPAddress destinationIpAddress
        unsigned int sourcePort
        unsigned int reserved[8]
    ctypedef _fc2GigEStreamChannel fc2GigEStreamChannel

    cdef struct _fc2GigEConfig:
        BOOL enablePacketResend
        unsigned int timeoutForPacketResend
        unsigned int maxPacketsToResend
        unsigned int reserved[8]
    ctypedef _fc2GigEConfig fc2GigEConfig

    cdef struct _fc2GigEImageSettingsInfo:
        unsigned int maxWidth
        unsigned int maxHeight
        unsigned int offsetHStepSize
        unsigned int offsetVStepSize
        unsigned int imageHStepSize
        unsigned int imageVStepSize
        unsigned int pixelFormatBitField
        unsigned int vendorPixelFormatBitField
        unsigned int reserved[16]
    ctypedef _fc2GigEImageSettingsInfo fc2GigEImageSettingsInfo

    cdef struct _fc2GigEImageSettings:
        unsigned int offsetX
        unsigned int offsetY
        unsigned int width
        unsigned int height
        fc2PixelFormat pixelFormat
        unsigned int reserved[8]
    ctypedef _fc2GigEImageSettings fc2GigEImageSettings

    cdef struct _fc2TimeStamp:
        long long seconds
        unsigned int microSeconds
        unsigned int cycleSeconds
        unsigned int cycleCount
        unsigned int cycleOffset
        unsigned int reserved[8]
    ctypedef _fc2TimeStamp fc2TimeStamp

    cdef struct _fc2ConfigROM:
        unsigned int nodeVendorId
        unsigned int chipIdHi
        unsigned int chipIdLo
        unsigned int unitSpecId
        unsigned int unitSWVer
        unsigned int unitSubSWVer
        unsigned int vendorUniqueInfo_0
        unsigned int vendorUniqueInfo_1
        unsigned int vendorUniqueInfo_2
        unsigned int vendorUniqueInfo_3
        char pszKeyword[MAX_STRING_LENGTH]
        unsigned int reserved[16]
    ctypedef _fc2ConfigROM fc2ConfigROM

    cdef struct _fc2CameraInfo:
        unsigned int serialNumber
        fc2InterfaceType interfaceType
        fc2DriverType driverType
        BOOL isColorCamera
        char modelName[MAX_STRING_LENGTH]
        char vendorName[MAX_STRING_LENGTH]
        char sensorInfo[MAX_STRING_LENGTH]
        char sensorResolution[MAX_STRING_LENGTH]
        char driverName[MAX_STRING_LENGTH]
        char firmwareVersion[MAX_STRING_LENGTH]
        char firmwareBuildTime[MAX_STRING_LENGTH]
        fc2BusSpeed maximumBusSpeed
        fc2PCIeBusSpeed pcieBusSpeed
        fc2BayerTileFormat bayerTileFormat
        unsigned short busNumber
        unsigned short nodeNumber
        unsigned int iidcVer
        fc2ConfigROM configROM
        unsigned int gigEMajorVersion
        unsigned int gigEMinorVersion
        char userDefinedName[MAX_STRING_LENGTH]
        char xmlURL1[MAX_STRING_LENGTH]
        char xmlURL2[MAX_STRING_LENGTH]
        fc2MACAddress macAddress
        fc2IPAddress ipAddress
        fc2IPAddress subnetMask
        fc2IPAddress defaultGateway
        unsigned int ccpStatus
        unsigned int applicationIPAddress
        unsigned int applicationPort
        unsigned int reserved[16]
    ctypedef _fc2CameraInfo fc2CameraInfo

    cdef struct _fc2EmbeddedImageInfoProperty:
        BOOL available
        BOOL onOff
    ctypedef _fc2EmbeddedImageInfoProperty fc2EmbeddedImageInfoProperty

    cdef struct _fc2EmbeddedImageInfo:
        fc2EmbeddedImageInfoProperty timestamp
        fc2EmbeddedImageInfoProperty gain
        fc2EmbeddedImageInfoProperty shutter
        fc2EmbeddedImageInfoProperty brightness
        fc2EmbeddedImageInfoProperty exposure
        fc2EmbeddedImageInfoProperty whiteBalance
        fc2EmbeddedImageInfoProperty frameCounter
        fc2EmbeddedImageInfoProperty strobePattern
        fc2EmbeddedImageInfoProperty GPIOPinState
        fc2EmbeddedImageInfoProperty ROIPosition
    ctypedef _fc2EmbeddedImageInfo fc2EmbeddedImageInfo

    cdef struct _fc2ImageMetadata:
        unsigned int embeddedTimeStamp
        unsigned int embeddedGain
        unsigned int embeddedShutter
        unsigned int embeddedBrightness
        unsigned int embeddedExposure
        unsigned int embeddedWhiteBalance
        unsigned int embeddedFrameCounter
        unsigned int embeddedStrobePattern
        unsigned int embeddedGPIOPinState
        unsigned int embeddedROIPosition
        unsigned int reserved[31]
    ctypedef _fc2ImageMetadata fc2ImageMetadata

    cdef struct _fc2LUTData:
        BOOL supported
        BOOL enabled
        unsigned int numBanks
        unsigned int numChannels
        unsigned int inputBitDepth
        unsigned int outputBitDepth
        unsigned int numEntries
        unsigned int reserved[8]
    ctypedef _fc2LUTData fc2LUTData

    cdef struct _fc2PNGOption:
        BOOL interlaced
        unsigned int compressionLevel
        unsigned int reserved[16]
    ctypedef _fc2PNGOption fc2PNGOption

    cdef struct _fc2PPMOption:
        BOOL binaryFile
        unsigned int reserved[16]
    ctypedef _fc2PPMOption fc2PPMOption

    cdef struct _fc2PGMOption:
        BOOL binaryFile
        unsigned int reserved[16]
    ctypedef _fc2PGMOption fc2PGMOption

    cdef enum _fc2TIFFCompressionMethod:
        FC2_TIFF_NONE = 1
        FC2_TIFF_PACKBITS
        FC2_TIFF_DEFLATE
        FC2_TIFF_ADOBE_DEFLATE
        FC2_TIFF_CCITTFAX3
        FC2_TIFF_CCITTFAX4
        FC2_TIFF_LZW
        FC2_TIFF_JPEG
    ctypedef _fc2TIFFCompressionMethod fc2TIFFCompressionMethod

    cdef struct _fc2TIFFOption:
        fc2TIFFCompressionMethod compression
        unsigned int reserved[16]
    ctypedef _fc2TIFFOption fc2TIFFOption

    cdef struct _fc2JPEGOption:
        BOOL progressive
        unsigned int quality
        unsigned int reserved[16]
    ctypedef _fc2JPEGOption fc2JPEGOption

    cdef struct _fc2JPG2Option:
        unsigned int quality
        unsigned int reserved[16]
    ctypedef _fc2JPG2Option fc2JPG2Option

    cdef struct _fc2AVIOption:
        float frameRate
        unsigned int reserved[256]
    ctypedef _fc2AVIOption fc2AVIOption

    cdef struct _fc2MJPGOption:
        float frameRate
        unsigned int quality
        unsigned int reserved[256]
    ctypedef _fc2MJPGOption fc2MJPGOption

    cdef struct _fc2H264Option:
        float frameRate
        unsigned int width
        unsigned int height
        unsigned int bitrate
        unsigned int reserved[256]
    ctypedef _fc2H264Option fc2H264Option

    ctypedef void* fc2CallbackHandle

    ctypedef void (*fc2BusEventCallback)( void* pParameter, unsigned int serialNumber )

    ctypedef void (*fc2ImageEventCallback)( fc2Image* image, void* pCallbackData )

    ctypedef void (*fc2AsyncCommandCallback)( fc2Error retError, void* pUserData )
