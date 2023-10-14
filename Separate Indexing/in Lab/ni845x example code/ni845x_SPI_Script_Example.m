close all
clear
clc
loadlibrary('ni845x', 'ni845x.h');


x = ni845xSpiDio(0);
x = x.ni845xSetIoVoltageLevel(x.kNi845x33Volts);
x = x.setNi845xSpiScript(500, x.kNi845xSpiClockPolarityIdleLow, ...
    x.kNi845xSpiClockPhaseFirstEdge);

x = x.ni845xSpiScriptCSLow(0);
[x, ScriptReadIndex] = x.ni845xSpiScriptWriteRead(2, [50 255]);
x = x.ni845xSpiScriptCSHigh(0);

%x = x.ni845xSpiScriptDisableSPI;
x = x.ni845xSpiScriptRun;


[x, ReadSize] = x.ni845xSpiScriptExtractReadDataSize(ScriptReadIndex);
[x, ReadData] = x.ni845xSpiScriptExtractReadData(ScriptReadIndex, ReadSize);



x = x.ni845xSpiScriptClose;
x = x.ni845xClose;
