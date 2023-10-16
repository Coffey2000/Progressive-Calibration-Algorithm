close all
clear
clc
loadlibrary('ni845x', 'ni845x.h');


x = ni845xSpiDio(0);
x = x.ni845xSetIoVoltageLevel(x.kNi845x33Volts);
x = x.setNi845xDio(x.kNi845xPushPull, [1 1 1 1 1 1 1 1]);

%x = x.ni845xDioWriteLine(0, 0);
x = x.ni845xDioWritePort([1]);
%[x, ReadData] = x.ni845xDioReadLine(1);
[x, ReadData] = x.ni845xDioReadPort;

x = x.ni845xClose;