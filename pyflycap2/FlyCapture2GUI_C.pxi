cdef extern from "C/FlyCapture2GUI_C.h":

    fc2Error fc2CreateGUIContext(fc2GuiContext* pContext)

    fc2Error fc2DestroyGUIContext(fc2GuiContext context)

    void fc2GUIConnect(fc2GuiContext context, fc2Context cameraContext)

    void fc2GUIDisconnect(fc2GuiContext context)

    void fc2Show(fc2GuiContext context)

    void fc2Hide(fc2GuiContext context)

    BOOL fc2IsVisible(fc2GuiContext context)

    void fc2ShowModal(fc2GuiContext context, BOOL* pOkSelected, fc2PGRGuid* guidArray, unsigned int* size)
