cdef extern from "C/FlyCapture2_C.h":

    fc2Error fc2CreateContext(fc2Context* pContext)

    fc2Error fc2CreateGigEContext(fc2Context* pContext)

    fc2Error fc2DestroyContext(fc2Context context)

    fc2Error fc2FireBusReset(fc2Context context, fc2PGRGuid* pGuid)

    fc2Error fc2GetNumOfCameras(fc2Context context, unsigned int* pNumCameras)

    fc2Error fc2IsCameraControlable(fc2Context context, fc2PGRGuid* pGuid, BOOL* pControlable)

    fc2Error fc2GetCameraFromIndex(fc2Context context, unsigned int index, fc2PGRGuid* pGuid)

    fc2Error fc2GetCameraFromIPAddress(fc2Context context, fc2IPAddress ipAddress, fc2PGRGuid* pGuid)

    fc2Error fc2GetCameraFromSerialNumber(fc2Context context, unsigned int serialNumber, fc2PGRGuid* pGuid)

    fc2Error fc2GetCameraSerialNumberFromIndex(fc2Context context, unsigned int index, unsigned int* pSerialNumber)

    fc2Error fc2GetInterfaceTypeFromGuid(fc2Context context, fc2PGRGuid *pGuid, fc2InterfaceType* pInterfaceType)

    fc2Error fc2GetNumOfDevices(fc2Context context, unsigned int* pNumDevices)

    fc2Error fc2GetDeviceFromIndex(fc2Context context, unsigned int index, fc2PGRGuid* pGuid)

    fc2Error fc2RegisterCallback(fc2Context context, fc2BusEventCallback enumCallback, fc2BusCallbackType callbackType, void* pParameter, fc2CallbackHandle* pCallbackHandle)

    fc2Error fc2UnregisterCallback(fc2Context context, fc2CallbackHandle callbackHandle)

    fc2Error fc2RescanBus(fc2Context context)

    fc2Error fc2ForceIPAddressToCamera(fc2Context context, fc2MACAddress macAddress, fc2IPAddress ipAddress, fc2IPAddress subnetMask, fc2IPAddress defaultGateway)

    fc2Error fc2ForceAllIPAddressesAutomatically()

    fc2Error fc2DiscoverGigECameras(fc2Context context, fc2CameraInfo* gigECameras, unsigned int* arraySize)

    fc2Error fc2WriteRegister(fc2Context context, unsigned int address, unsigned int value)

    fc2Error fc2WriteRegisterBroadcast(fc2Context context, unsigned int address, unsigned int value)

    fc2Error fc2ReadRegister(fc2Context context, unsigned int address, unsigned int* pValue)

    fc2Error fc2WriteRegisterBlock(fc2Context context, unsigned short addressHigh, unsigned int addressLow, const unsigned int *pBuffer, unsigned int length)

    fc2Error fc2ReadRegisterBlock(fc2Context context, unsigned short addressHigh, unsigned int addressLow, unsigned int* pBuffer, unsigned int length)

    fc2Error fc2Connect(fc2Context context, fc2PGRGuid* guid)

    fc2Error fc2Disconnect(fc2Context context)

    fc2Error fc2SetCallback(fc2Context context, fc2ImageEventCallback pCallbackFn, void* pCallbackData)

    fc2Error fc2StartCapture(fc2Context context)

    fc2Error fc2StartCaptureCallback(fc2Context context, fc2ImageEventCallback pCallbackFn, void* pCallbackData)

    fc2Error fc2StartSyncCapture(unsigned int numCameras, fc2Context *pContexts)

    fc2Error fc2StartSyncCaptureCallback(unsigned int numCameras, fc2Context *pContexts, fc2ImageEventCallback* pCallbackFns, void** pCallbackDataArray)

    fc2Error fc2RetrieveBuffer(fc2Context context, fc2Image* pImage)

    fc2Error fc2StopCapture(fc2Context context)

    fc2Error fc2SetUserBuffers(fc2Context context, unsigned char* const ppMemBuffers, int size, int nNumBuffers)

    fc2Error fc2GetConfiguration(fc2Context context, fc2Config* config)

    fc2Error fc2SetConfiguration(fc2Context context, fc2Config* config)

    fc2Error fc2GetCameraInfo(fc2Context context, fc2CameraInfo* pCameraInfo)

    fc2Error fc2GetPropertyInfo(fc2Context context, fc2PropertyInfo* propInfo)

    fc2Error fc2GetProperty(fc2Context context, fc2Property* prop)

    fc2Error fc2SetProperty(fc2Context context, fc2Property* prop)

    fc2Error fc2SetPropertyBroadcast(fc2Context context, fc2Property* prop)

    fc2Error fc2GetGPIOPinDirection(fc2Context context, unsigned int pin, unsigned int* pDirection)

    fc2Error fc2SetGPIOPinDirection(fc2Context context, unsigned int pin, unsigned int direction)

    fc2Error fc2SetGPIOPinDirectionBroadcast(fc2Context context, unsigned int pin, unsigned int direction)

    fc2Error fc2GetTriggerModeInfo(fc2Context context, fc2TriggerModeInfo* triggerModeInfo)

    fc2Error fc2GetTriggerMode(fc2Context context, fc2TriggerMode* triggerMode)

    fc2Error fc2SetTriggerMode(fc2Context context, fc2TriggerMode* triggerMode)

    fc2Error fc2SetTriggerModeBroadcast(fc2Context context, fc2TriggerMode* triggerMode)

    fc2Error fc2FireSoftwareTrigger(fc2Context context)

    fc2Error fc2FireSoftwareTriggerBroadcast(fc2Context context)

    fc2Error fc2GetTriggerDelayInfo(fc2Context context, fc2TriggerDelayInfo* triggerDelayInfo)

    fc2Error fc2GetTriggerDelay(fc2Context context, fc2TriggerDelay* triggerDelay)

    fc2Error fc2SetTriggerDelay(fc2Context context, fc2TriggerDelay* triggerDelay)

    fc2Error fc2SetTriggerDelayBroadcast(fc2Context context, fc2TriggerDelay* triggerDelay)

    fc2Error fc2GetStrobeInfo(fc2Context context, fc2StrobeInfo* strobeInfo)

    fc2Error fc2GetStrobe(fc2Context context, fc2StrobeControl* strobeControl)

    fc2Error fc2SetStrobe(fc2Context context, fc2StrobeControl* strobeControl)

    fc2Error fc2SetStrobeBroadcast(fc2Context context, fc2StrobeControl* strobeControl)

    fc2Error fc2GetVideoModeAndFrameRateInfo(fc2Context context, fc2VideoMode videoMode, fc2FrameRate frameRate, BOOL* pSupported)

    fc2Error fc2GetVideoModeAndFrameRate(fc2Context context, fc2VideoMode* videoMode, fc2FrameRate* frameRate)

    fc2Error fc2SetVideoModeAndFrameRate(fc2Context context, fc2VideoMode videoMode, fc2FrameRate frameRate)

    fc2Error fc2GetFormat7Info(fc2Context context, fc2Format7Info* info, BOOL* pSupported)

    fc2Error fc2ValidateFormat7Settings(fc2Context context, fc2Format7ImageSettings* imageSettings, BOOL* settingsAreValid, fc2Format7PacketInfo* packetInfo)

    fc2Error fc2GetFormat7Configuration(fc2Context context, fc2Format7ImageSettings* imageSettings, unsigned int* packetSize, float* percentage)

    fc2Error fc2SetFormat7ConfigurationPacket(fc2Context context, fc2Format7ImageSettings* imageSettings, unsigned int packetSize)

    fc2Error fc2SetFormat7Configuration(fc2Context context, fc2Format7ImageSettings* imageSettings, float percentSpeed)

    fc2Error fc2WriteGVCPRegister(fc2Context context, unsigned int address, unsigned int value)

    fc2Error fc2WriteGVCPRegisterBroadcast(fc2Context context, unsigned int address, unsigned int value)

    fc2Error fc2ReadGVCPRegister(fc2Context context, unsigned int address, unsigned int* pValue)

    fc2Error fc2WriteGVCPRegisterBlock(fc2Context context, unsigned int address, const unsigned int *pBuffer, unsigned int length)

    fc2Error fc2ReadGVCPRegisterBlock(fc2Context context, unsigned int address, unsigned int* pBuffer, unsigned int length)

    fc2Error fc2WriteGVCPMemory(fc2Context context, unsigned int address, const unsigned char *pBuffer, unsigned int length)

    fc2Error fc2ReadGVCPMemory(fc2Context context, unsigned int address, unsigned char* pBuffer, unsigned int length)

    fc2Error fc2GetGigEProperty(fc2Context context, fc2GigEProperty* pGigEProp)

    fc2Error fc2SetGigEProperty(fc2Context context, const fc2GigEProperty* pGigEProp)

    fc2Error fc2QueryGigEImagingMode(fc2Context context, fc2Mode mode, BOOL* isSupported)

    fc2Error fc2GetGigEImagingMode(fc2Context context, fc2Mode* mode)

    fc2Error fc2SetGigEImagingMode(fc2Context context, fc2Mode mode)

    fc2Error fc2GetGigEImageSettingsInfo(fc2Context context, fc2GigEImageSettingsInfo* pInfo)

    fc2Error fc2GetGigEImageSettings(fc2Context context, fc2GigEImageSettings* pImageSettings)

    fc2Error fc2SetGigEImageSettings(fc2Context context, const fc2GigEImageSettings* pImageSettings)

    fc2Error fc2GetGigEConfig(fc2Context context, fc2GigEConfig* pConfig)

    fc2Error fc2SetGigEConfig(fc2Context context, const fc2GigEConfig* pConfig)

    fc2Error fc2GetGigEImageBinningSettings(fc2Context context, unsigned int* horzBinnningValue, unsigned int* vertBinnningValue)

    fc2Error fc2SetGigEImageBinningSettings(fc2Context context, unsigned int horzBinnningValue, unsigned int vertBinnningValue)

    fc2Error fc2GetNumStreamChannels(fc2Context context, unsigned int* numChannels)

    fc2Error fc2GetGigEStreamChannelInfo(fc2Context context, unsigned int channel, fc2GigEStreamChannel* pChannel)

    fc2Error fc2SetGigEStreamChannelInfo(fc2Context context, unsigned int channel, fc2GigEStreamChannel* pChannel)

    fc2Error fc2GetLUTInfo(fc2Context context, fc2LUTData* pData)

    fc2Error fc2GetLUTBankInfo(fc2Context context, unsigned int bank, BOOL* pReadSupported, BOOL* pWriteSupported)

    fc2Error fc2GetActiveLUTBank(fc2Context context, unsigned int* pActiveBank)

    fc2Error fc2SetActiveLUTBank(fc2Context context, unsigned int activeBank)

    fc2Error fc2EnableLUT(fc2Context context, BOOL on)

    fc2Error fc2GetLUTChannel(fc2Context context, unsigned int bank, unsigned int channel, unsigned int sizeEntries, unsigned int* pEntries)

    fc2Error fc2SetLUTChannel(fc2Context context, unsigned int bank, unsigned int channel, unsigned int sizeEntries, unsigned int* pEntries)

    fc2Error fc2GetMemoryChannel(fc2Context context, unsigned int* pCurrentChannel)

    fc2Error fc2SaveToMemoryChannel(fc2Context context, unsigned int channel)

    fc2Error fc2RestoreFromMemoryChannel(fc2Context context, unsigned int channel)

    fc2Error fc2GetMemoryChannelInfo(fc2Context context, unsigned int* pNumChannels)

    fc2Error fc2GetEmbeddedImageInfo(fc2Context context, fc2EmbeddedImageInfo* pInfo)

    fc2Error fc2SetEmbeddedImageInfo(fc2Context context, fc2EmbeddedImageInfo* pInfo)

    const char* fc2GetRegisterString(unsigned int registerVal)

    fc2Error fc2CreateImage(fc2Image* pImage)

    fc2Error fc2DestroyImage(fc2Image* image)

    fc2Error fc2SetDefaultColorProcessing(fc2ColorProcessingAlgorithm defaultMethod)

    fc2Error fc2GetDefaultColorProcessing(fc2ColorProcessingAlgorithm* pDefaultMethod)

    fc2Error fc2SetDefaultOutputFormat(fc2PixelFormat format)

    fc2Error fc2GetDefaultOutputFormat(fc2PixelFormat* pFormat)

    fc2Error fc2DetermineBitsPerPixel(fc2PixelFormat format, unsigned int* pBitsPerPixel)

    fc2Error fc2SaveImage(fc2Image* pImage, const char* pFilename, fc2ImageFileFormat format)

    fc2Error fc2SaveImageWithOption(fc2Image* pImage, const char* pFilename, fc2ImageFileFormat format, void* pOption)

    fc2Error fc2ConvertImage(fc2Image* pImageIn, fc2Image* pImageOut)

    fc2Error fc2ConvertImageTo(fc2PixelFormat format, fc2Image* pImageIn, fc2Image* pImageOut)

    fc2Error fc2GetImageData(fc2Image* pImage, unsigned char** ppData)

    fc2Error fc2SetImageData(fc2Image* pImage, const unsigned char *pData, unsigned int dataSize)

    fc2Error fc2SetImageDimensions(fc2Image* pImage, unsigned int rows, unsigned int cols, unsigned int stride, fc2PixelFormat pixelFormat, fc2BayerTileFormat bayerFormat)

    fc2TimeStamp fc2GetImageTimeStamp(fc2Image* pImage)

    fc2Error fc2CalculateImageStatistics(fc2Image* pImage, fc2ImageStatisticsContext* pImageStatisticsContext)

    fc2Error fc2CreateImageStatistics(fc2ImageStatisticsContext* pImageStatisticsContext)

    fc2Error fc2DestroyImageStatistics(fc2ImageStatisticsContext imageStatisticsContext)

    const fc2Error fc2GetChannelStatus(fc2ImageStatisticsContext imageStatisticsContext, fc2StatisticsChannel channel, BOOL* pEnabled)

    fc2Error fc2SetChannelStatus(fc2ImageStatisticsContext imageStatisticsContext, fc2StatisticsChannel channel, BOOL enabled)

    fc2Error fc2GetImageStatistics(fc2ImageStatisticsContext imageStatisticsContext, fc2StatisticsChannel channel, unsigned int* pRangeMin, unsigned int* pRangeMax, unsigned int* pPixelValueMin, unsigned int* pPixelValueMax, unsigned int* pNumPixelValues, float* pPixelValueMean, int** ppHistogram)

    fc2Error fc2CreateAVI(fc2AVIContext* pAVIContext)

    fc2Error fc2AVIOpen(fc2AVIContext AVIContext, const char* pFileName, fc2AVIOption* pOption)

    fc2Error fc2MJPGOpen(fc2AVIContext AVIContext, const char* pFileName, fc2MJPGOption* pOption)

    fc2Error fc2H264Open(fc2AVIContext AVIContext, const char* pFileName, fc2H264Option* pOption)

    fc2Error fc2AVIAppend(fc2AVIContext AVIContext, fc2Image* pImage)

    fc2Error fc2AVIClose(fc2AVIContext AVIContext)

    fc2Error fc2DestroyAVI(fc2AVIContext AVIContext)

    fc2Error fc2GetSystemInfo(fc2SystemInfo* pSystemInfo)

    fc2Error fc2GetLibraryVersion(fc2Version* pVersion)

    fc2Error fc2LaunchBrowser(const char* pAddress)

    fc2Error fc2LaunchHelp(const char* pFileName)

    fc2Error fc2LaunchCommand(const char* pCommand)

    fc2Error fc2LaunchCommandAsync(const char* pCommand, fc2AsyncCommandCallback pCallback, void* pUserData)

    const char* fc2ErrorToDescription(fc2Error error)

    fc2Error fc2GetCycleTime(fc2Context context, fc2TimeStamp* pTimeStamp)
