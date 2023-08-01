classdef ni845xSpiDio
    
    properties % User Defined Properties
       
        ClockRate;                           % Clock Rate in KHz
        ClockPolarity;                       % Polarity 1 or 0
        ClockPhase;                          % Phase 1 or 0
        
    end
    
    properties % System Properties
        ni845x;                              % ni845x C Driver Object
        PortNumber;                          % User Defined Port Number
        FirstDevice;                         % Device Address
        DeviceHandle;                        % Device Handle
        ScriptHandle;                        % Script Spi Handle
        SpiHandle;                           % Spi Handle  
    end
    
    properties % Constant Properties
        kNi845xSpiClockPolarityIdleLow  = 0; % Idle Low
        kNi845xSpiClockPolarityIdleHigh = 1; % Idle High
        kNi845xSpiClockPhaseFirstEdge   = 0; % First Edge
        kNi845xSpiClockPhaseSecondEdge  = 1; % Second Edge
        kNi845x33Volts = 33;                 % 3.3V 
        kNi845x25Volts = 25;                 % 2.5V
        kNi845x18Volts = 18;                 % 1.8V
        kNi845x15Volts = 15;                 % 1.5V
        kNi845x12Volts = 12;                 % 1.2V
        kNi845xDioOutput  = 1;               % DIO Output
        kNi845xDioInput   = 0;               % DIO Input
        kNi845xOpenDrain  = 0;               % Open Drain
        kNi845xPushPull   = 1;               % Push Pull
    end
    
    properties % Error Check Properties
        errorFindDevice;                      
        errorOpen;
        errorDioSetDriverType;
        errorSpiScriptOpen;
        errorSetIoVoltageLevel;
        errorDioSetPortLineDirectionMap;
        errorDioWriteLine;
        errorDioReadLine;
        errorDioWritePort;
        errorDioReadPort;
        errorSpiConfigurationOpen;
        errorSpiConfigurationClose;
        errorSpiConfigurationSetChipSelect;
        errorSpiConfigurationSetClockRate;
        errorSpiConfigurationSetClockPolarity;
        errorSpiConfigurationSetClockPhase;
        errorSpiWriteRead;
        errorSpiScriptDioConfigureLine;
        errorSpiScriptDioConfigurePort
        errorSpiScriptDioWriteLine;
        errorSpiScriptDioWritePort;
        errorSpiScriptDioReadLine;
        errorSpiScriptDioReadPort;
        errorSpiScriptEnableSPI;
        errorSpiScriptDisableSPI;
        errorSpiScriptClockRate;
        errorSpiScriptClockPolarityPhase;
        errorSpiScriptCSLow;
        errorSpiScriptCSHigh;
        errorSpiScriptWriteRead
        errorSpiScriptRun;
        errorSpiScriptExtractReadDataSize;
        errorSpiScriptExtractReadData;
        errorSpiScriptNumBitsPerSample
        errorSpiScriptReset;
        errorSpiScriptUsDelay
        errorSpiScriptClose;
        errorClose;
        
        
    end
    
    methods
        % Constructer of this class
        function obj = ni845xSpiDio(varargin)
            % Create C library Instance
            obj.ni845x     = libstruct('ni845x');
            % Set the Port Number defaul value is 0
            if isempty(varargin)
                PortNumber = 0;
            else
                PortNumber = varargin{1};
            end
            
            obj.PortNumber = PortNumber;
%             % Set the Clock Rate in KHz
%             obj.ClockRate  = ClockRate;
            % Init ni845x
            obj = obj.initNi845x;
        end
        
        % Initialize Device
        function obj = initNi845x(obj)
            % Find first device
            [obj, obj.FirstDevice]  = obj.ni845xFindDevice;
            % Open device handle
            [obj, obj.DeviceHandle] = obj.ni845xOpen;
        end
        
        % Setup SPI
        function obj = setNi845xSpi(obj, ChipSelect, ClockRate, ...
                ClockPolarity, ClockPhase)
            [obj, obj.SpiHandle] = obj.ni845xSpiConfigurationOpen;
            obj.ni845xSpiConfigurationSetChipSelect(ChipSelect);
            obj.ni845xSpiConfigurationSetClockRate(ClockRate);
            obj.ni845xSpiConfigurationSetClockPolarity(ClockPolarity);
            obj.ni845xSpiConfigurationSetClockPhase(ClockPhase);
        end
        
        % Setup Script SPI
        function obj = setNi845xSpiScript(obj, ClockRate, ...
                ClockPolarity, ClockPhase)
            
            if isempty(obj.errorSpiScriptOpen)
                [obj, obj.ScriptHandle] = obj.ni845xSpiScriptOpen;
            end
            obj.ni845xSpiScriptReset;
            obj.ni845xSpiScriptEnableSPI;
            obj.ni845xSpiScriptClockRate(ClockRate);
            obj.ni845xSpiScriptClockPolarityPhase(ClockPolarity, ClockPhase);
            obj.ClockRate = ClockRate;
            obj.ClockPolarity = ClockPolarity;
            obj.ClockPhase = ClockPhase;
        end
        
        % Setup DIO Line and Port
        function obj = setNi845xDio(obj, Type, LineMap)
            obj.ni845xDioSetDriverType(Type);
            obj.ni845xDioSetPortLineDirectionMap(LineMap);
        end
        
        % Setup Script DIO Port
        function obj = setNi845xDioScript(obj, Type, LineMap)
            obj.ni845xDioSetDriverType(Type);
            if isempty(obj.errorSpiScriptOpen)
                [obj, obj.ScriptHandle] = obj.ni845xSpiScriptOpen;
            end

            obj.ni845xSpiScriptDioConfigurePort(LineMap);
        end
        
        % Find Device
        function [obj, FirstDevice] = ni845xFindDevice(obj)
            [obj.errorFindDevice, FirstDevice] = ...
                obj.ni845x.ni845xFindDevice(blanks(256), [], []);
        end
        
        % Open device handle
        function [obj, DeviceHandle] = ni845xOpen(obj)
            [obj.errorOpen, ~, DeviceHandle] = ...
                obj.ni845x.ni845xOpen(obj.FirstDevice, 0);
        end
        
        function [obj, ScriptHandle] = ni845xSpiScriptOpen(obj)
            % Start Spi Connection
            [obj.errorSpiScriptOpen, ScriptHandle] = ... 
                obj.ni845x.ni845xSpiScriptOpen(0);
        end
        
        % Set the IO Voltages
        function obj = ni845xSetIoVoltageLevel(obj, Level)
            obj.errorSetIoVoltageLevel = ... 
                obj.ni845x.ni845xSetIoVoltageLevel(obj.DeviceHandle, Level);
        end
        
        % Set DIO Type kNi845xOpenDrain or kNi845xPushPull
        function obj = ni845xDioSetDriverType(obj, Type)
            obj.errorDioSetDriverType = obj.ni845x.ni845xDioSetDriverType(...
                obj.DeviceHandle, obj.PortNumber, Type);
        end      
        
        % Set the DIO Lines Types kNi845xDioOutput or kNi845xDioInput
        function obj = ni845xDioSetPortLineDirectionMap(obj, LineMap)
            LineMap = bi2de(LineMap);
            obj.errorDioSetPortLineDirectionMap = ...
                obj.ni845x.ni845xDioSetPortLineDirectionMap ...
                (obj.DeviceHandle, obj.PortNumber, LineMap);
        end
        
        % Set the DIO Line Output Value
        function obj = ni845xDioWriteLine(obj, LineNumber, Value)
            obj.errorDioWriteLine= obj.ni845x.ni845xDioWriteLine(...
                obj.DeviceHandle, obj.PortNumber, LineNumber, Value);
        end
        
        % Read the DIO Line Input Value
        function [obj, ReadValue] = ni845xDioReadLine(obj, LineNumber)
            [obj.errorDioReadLine, ReadValue] = ...
                obj.ni845x.ni845xDioReadLine(obj.DeviceHandle, ...
                obj.PortNumber, LineNumber, 0);
        end
        
        % Set the DIO Lines Output Value
        function obj = ni845xDioWritePort(obj, ValueMap)
            ValueMap = bi2de(ValueMap);
            obj.errorDioWritePort= obj.ni845x.ni845xDioWritePort(...
                obj.DeviceHandle, obj.PortNumber, ValueMap);
        end
        
        % Read the DIO Lines Input Values
        function [obj, ReadValue] = ni845xDioReadPort(obj)
            [obj.errorDioReadPort, ReadValue]= obj.ni845x.ni845xDioReadPort(...
                obj.DeviceHandle, obj.PortNumber, 0);
            ReadValue = de2bi(ReadValue, 8);
        end
        
        % Set the DIO Line Type kNi845xDioOutput or kNi845xDioInput
        function obj = ni845xSpiScriptDioConfigureLine(obj, LineNumber, ...
                Type)
            obj.errorSpiScriptDioConfigureLine = ...
                obj.ni845x.SpiScriptDioConfigureLine(obj.ScriptHandle, ...
                obj.PortNumber, LineNumber, Type);
        end
        
        % Set the DIO Lines Type kNi845xDioOutput or kNi845xDioInput
        function obj = ni845xSpiScriptDioConfigurePort(obj, ...
                Type)
            Type = bi2de(Type);
            obj.errorSpiScriptDioConfigurePort = ...
                obj.ni845x.ni845xSpiScriptDioConfigurePort(obj.ScriptHandle, ...
                obj.PortNumber, Type);
        end
        
        % Script Write DIO Line
        function obj = ni845xSpiScriptDioWriteLine(obj, LineNumber, Value)
            obj.errorSpiScriptDioWriteLine = ...
                obj.ni845x.ni845xSpiScriptDioWriteLine ...
                (obj.ScriptHandle, obj.PortNumber, LineNumber, Value);
        end
        
        % Script Read the DIO Line Input Value
        function [obj, ScriptReadIndex] = ni845xSpiScriptDioReadLine ... 
                (obj, LineNumber)
            [obj.errorDioReadLine, ScriptReadIndex] = ...
                obj.ni845x.ni845xSpiScriptDioReadLine(obj.ScriptHandle, ...
                obj.PortNumber, LineNumber, 0);
        end
        
        % Script Write DIO Lines
        function obj = ni845xSpiScriptDioWritePort(obj,ValueMap)
            ValueMap = bi2de(ValueMap);
            obj.errorSpiScriptDioWriteLine = ...
                obj.ni845x.ni845xSpiScriptDioWritePort(...
                obj.ScriptHandle, obj.PortNumber, ValueMap);
        end
        
        % Script Read the DIO Lines Input Values
        function [obj, ScriptReadIndex] = ni845xSpiScriptDioReadPort(obj)
            [obj.errorDioWritePort, ScriptReadIndex] = ...
                obj.ni845x.ni845xSpiScriptDioReadPort(obj.ScriptHandle, ...
                obj.PortNumber, 0);
        end
        
        % Enable SPI
        function [obj, SpiHandle] = ni845xSpiConfigurationOpen(obj)
            [obj.errorSpiConfigurationOpen, SpiHandle] = ...
                obj.ni845x.ni845xSpiConfigurationOpen(0);
        end
        
        % Disable SPI
        function [obj] = ni845xSpiConfigurationClose(obj)
            obj.errorSpiConfigurationClose = ...
                obj.ni845x.ni845xSpiConfigurationClose(obj.SpiHandle);
            obj.SpiHandle = [];
        end
        
        % Set the chip select line
        function obj = ni845xSpiConfigurationSetChipSelect(obj, ChipSelect)
            obj.errorSpiConfigurationSetChipSelect = ...
                obj.ni845x.ni845xSpiConfigurationSetChipSelect ...
                (obj.SpiHandle, ChipSelect);
        end
        
        % Set the Clock Rate
        function obj = ni845xSpiConfigurationSetClockRate(obj, ClockRate)
            obj.errorSpiConfigurationSetClockRate = ...
                obj.ni845x.ni845xSpiConfigurationSetClockRate ...
                (obj.SpiHandle, ClockRate);
        end
        
        % Set Clock Polarity
        function obj = ni845xSpiConfigurationSetClockPolarity(obj, Polarity)
            obj.errorSpiConfigurationSetClockPolarity = ...
                obj.ni845x.ni845xSpiConfigurationSetClockPolarity(obj.SpiHandle, ... 
                Polarity);
        end
        
        % Set Clock Phase
        function obj = ni845xSpiConfigurationSetClockPhase(obj, Phase)
            obj.errorSpiConfigurationSetClockPhase = ...
                obj.ni845x.ni845xSpiConfigurationSetClockPhase(obj.SpiHandle, ... 
                Phase);
        end
        
        % Reset Script
        
        function obj = ni845xSpiScriptReset(obj)
            obj.errorSpiScriptReset = ...
                obj.ni845x.ni845xSpiScriptReset(obj.ScriptHandle);
        end
        
        % SPI Write Read
        function [obj, ReadData] = ni845xSpiWriteRead ... 
                (obj, WriteSize, SendData, ReadSize)
        [obj.errorSpiWriteRead, ~, ~,ReadData] = ...
            obj.ni845x.ni845xSpiWriteRead(obj.DeviceHandle, obj.SpiHandle, ... 
            WriteSize, SendData, ReadSize, zeros(1, ReadSize));
        end
        
        % Enable Script SPI
        function obj = ni845xSpiScriptEnableSPI(obj)
            obj.errorSpiScriptEnableSPI = ...
                obj.ni845x.ni845xSpiScriptEnableSPI(obj.ScriptHandle);
        end
        
        % Disable Script SPI
        function obj = ni845xSpiScriptDisableSPI(obj)
            obj.errorSpiScriptDisableSPI = ...
                obj.ni845x.ni845xSpiScriptDisableSPI(obj.ScriptHandle);
        end
        
        % Set the Script Clock Rate
        function obj = ni845xSpiScriptClockRate(obj, ClockRate)
            obj.errorSpiScriptClockRate = obj.ni845x.ni845xSpiScriptClockRate ...
                (obj.ScriptHandle, ClockRate);
        end
        
        % Set the Script Clock Polarity and Phase
        function obj = ni845xSpiScriptClockPolarityPhase(obj, Polarity, Phase)
            obj.errorSpiScriptClockPolarityPhase = ...
                obj.ni845x.ni845xSpiScriptClockPolarityPhase ...
                (obj.ScriptHandle, Polarity, Phase);
        end
        
        % Set Script Chip Select Low
        function obj = ni845xSpiScriptCSLow(obj, ChipSelect)
            obj.errorSpiScriptCSLow = obj.ni845x.ni845xSpiScriptCSLow...
                (obj.ScriptHandle, ChipSelect);
        end
        
        % Set Script Chip Select High
        function obj = ni845xSpiScriptCSHigh(obj, ChipSelect)
            obj.errorSpiScriptCSHigh = obj.ni845x.ni845xSpiScriptCSHigh...
                (obj.ScriptHandle, ChipSelect);
        end
        
        % SPI Script Read and Write
        function [obj, ScriptReadIndex] = ni845xSpiScriptWriteRead(obj, ...
                WriteSize, SendData)
            [obj.errorSpiScriptWriteRead, ~, ScriptReadIndex] = ...
                obj.ni845x.ni845xSpiScriptWriteRead(obj.ScriptHandle, ...
                WriteSize, SendData,  0);
        end
        
        % SPI set number of bits per sample
        
        function obj = ni845xSpiScriptNumBitsPerSample(obj, NumBitsPerSample)
            obj.errorSpiScriptNumBitsPerSample = ...
                obj.ni845x.ni845xSpiScriptNumBitsPerSample(...
                obj.ScriptHandle, NumBitsPerSample);
        end
        
        % Run Script
        function obj = ni845xSpiScriptRun(obj)
            obj.errorSpiScriptRun = obj.ni845x.ni845xSpiScriptRun...
                (obj.ScriptHandle, obj.DeviceHandle, obj.PortNumber);
        end
        
        % Script Extract Read Size
        function [obj, ReadSize] =  ni845xSpiScriptExtractReadDataSize ...
                (obj, ScriptReadIndex)
            [obj.errorSpiScriptExtractReadDataSize, ReadSize] = ...
                obj.ni845x.ni845xSpiScriptExtractReadDataSize ...
                (obj.ScriptHandle, ScriptReadIndex, 0);
        end
        
        % Script Extract Read Size
        function [obj, ReadData] =  ni845xSpiScriptExtractReadData ...
                (obj, ScriptReadIndex, ReadSize)
            [obj.errorSpiScriptExtractReadData, ReadData] = ...
                obj.ni845x.ni845xSpiScriptExtractReadData ...
                (obj.ScriptHandle, ScriptReadIndex, zeros(1, ReadSize));
        end
        
        % SPI delay
        function obj = ni845xSpiScriptUsDelay(obj, Delay)
            obj.errorSpiScriptUsDelay = ...
                obj.ni845x.ni845xSpiScriptUsDelay ...
                (obj.ScriptHandle, Delay);
        end
        
        % Close Script Handle
        function obj = ni845xSpiScriptClose(obj)
            [obj.errorSpiScriptClose]= obj.ni845x.ni845xSpiScriptClose...
                (obj.ScriptHandle);
            obj.ScriptHandle = [];
        end
        
        % Close Device Handle
        function obj = ni845xClose(obj)
            obj.errorClose = obj.ni845x.ni845xClose(obj.DeviceHandle);
            obj.DeviceHandle = [];
        end

    end
end

