

include "FlyCapture2.pxi"

class FlyCap2Exception(Exception):

    fc2code = 0

    def __init__(self, fc2code, **kwargs):
        super(FlyCap2Exception, self).__init__(**kwargs)
        self.fc2code = fc2code
