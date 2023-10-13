pnaSettings.visaAddress             = 'USB0::0x2A8D::0x2B01::MY61143913::0::INSTR'; 
pnaSettings.power                   = -15 ;  % PNA source power
pnaSettings.centerFreq              = 40e9;
pnaSettings.freqSpan                = 20e9 ;
pnaSettings.numberOfFreqPoint       = 401 ;
pnaSettings.numberAverages          = 10  ;
pnaSettings.smoothNumberOfPoints    = 10  ;
pnaSettings.measurementType         = {'S11', 'S21'};%{'S11', 'S33', 'S21', 'S43'};