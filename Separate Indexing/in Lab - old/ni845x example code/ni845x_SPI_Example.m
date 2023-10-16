close all
clear
clc
loadlibrary('ni845x', 'ni845x.h');


x = ni845xSpiDio(0);
x = x.ni845xSetIoVoltageLevel(x.kNi845x33Volts);
x = x.setNi845xSpi(0, 500, x.kNi845xSpiClockPolarityIdleLow, ...
    x.kNi845xSpiClockPhaseFirstEdge);


[x, ReadData] = x.ni845xSpiWriteRead(2, [50 255], 2);




%x = x.ni845xSpiConfigurationClose;
x = x.ni845xClose;
