close all
clear
clc
loadlibrary('ni845x', '.\library\ni845x.h');


x = ni845xSpiDio(0);
x = x.ni845xSetIoVoltageLevel(x.kNi845x18Volts);
x = x.setNi845xDioScript(x.kNi845xPushPull, [1 1 1 1 1 1 1 1]);


x = x.ni845xSpiScriptDioWritePort([1 1 1]);
%x = x.ni845xSpiScriptDioWriteLine(0, 1);

[x, ScriptReadIndex] = x.ni845xSpiScriptDioReadPort;
%[x, ScriptReadIndex] = x.ni845xSpiScriptDioReadLine(0);

%x = x.ni845xSpiScriptDisableSPI;
x = x.ni845xSpiScriptRun;

[x, ReadSize] = x.ni845xSpiScriptExtractReadDataSize(ScriptReadIndex);
[x, ReadData] = x.ni845xSpiScriptExtractReadData(ScriptReadIndex, ReadSize);
de2bi(ReadData, 8)

x = x.ni845xSpiScriptClose;
x = x.ni845xClose;