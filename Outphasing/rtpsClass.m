classdef rtpsClass < handle
    properties
        com;
    end
    
    properties
        numberOfBits            = 8    ;
        voltage                 = 1.8   ;
        clockRate               = 1000  ;
        rst                     = 0     ; % DIO Line
        rstStatus               = 0     ; % RST Init Value
        errorMode;     
    end
    
    methods
        
        function obj = rtpsClass(varargin)
            loadlibrary('ni845x', 'ni845x.h');
            portNumber = 0;
            if ~isempty(varargin)
                for counter = 1:length(varargin)-1
                   switch(varargin{counter})
                       case 'numberOfBits'
                           obj.numberOfBits = varargin{counter+1}   ;
                       case 'voltage'
                           obj.voltage = varargin{counter+1}        ;
                       case 'clockRate'
                           obj.clockRate = varargin{counter+1}      ;
                   end
                end
            end
            
            if ~isempty(obj.com)
                obj = obj.comClose;
            end
            obj = obj.comOpen(portNumber);
        end
        
        function delete(obj)
            obj.comClose;
            unloadlibrary ni845x;
            disp('Bye');
        end
        
       
                   
       
        
        function ReadData = setRtps(obj, value2send)
            writeSize     = ceil(obj.numberOfBits./8);
            value2sendBin = dec2bin(value2send, writeSize.*8);
            

            for counter = 1:writeSize
             value2sendByte(counter) = bin2dec(value2sendBin((counter-1)*8+1:(counter)*8));
            end
            [~, ReadData] = obj.readWrite(writeSize, value2sendByte);
            
        end
             

        function obj = scripSpiOpen(obj)
            obj.com = obj.com.setNi845xSpiScript(obj.clockRate, ...
                obj.com.kNi845xSpiClockPolarityIdleHigh, ...
                obj.com.kNi845xSpiClockPhaseSecondEdge);
            obj.com = obj.com.setNi845xDioScript(...
                obj.com.kNi845xPushPull, ones(1, 8));
        end

        function [obj, ReadData] = readWrite(obj, writeSize, sendData)
            
            
            
            numberOfWriteRead = ceil(length(sendData)./writeSize);
            % Init SPI com
            obj     = obj.scripSpiOpen;
            obj.com = obj.com.ni845xSpiScriptNumBitsPerSample(obj.numberOfBits);
            
           
            
            % Reset 
            % obj.com = obj.com.ni845xSpiScriptDioWriteLine(obj.Latch, 1);

            %obj.rstStatus(obj.rst+1) = 1;
            obj.rstStatus = 0;
            obj.com = obj.com.ni845xDioWritePort(obj.rstStatus);

            
            
            
            % Send and read SPI data
            scriptReadIndex = zeros(1, numberOfWriteRead);
            index = 0;
            for i = 1:writeSize:numberOfWriteRead*writeSize
                index = index + 1;
                [obj.com, scriptReadIndex(index)] = ...
                    obj.com.ni845xSpiScriptWriteRead(writeSize, ...
                    sendData(i:writeSize+i-1));
            end
            
            

            obj.com = obj.com.ni845xSpiScriptUsDelay(2);
            % Latch data
%             obj.com = obj.com.ni845xSpiScriptCSLow(obj.Latch);
%             obj.com = obj.com.ni845xSpiScriptUsDelay(10);
%             obj.com = obj.com.ni845xSpiScriptCSHigh(obj.Latch);
            
%             obj.com = obj.com.ni845xSpiScriptDioWriteLine(obj.Latch, 0);
%             obj.com = obj.com.ni845xSpiScriptUsDelay(10);
%             obj.com = obj.com.ni845xSpiScriptDioWriteLine(obj.Latch, 1);
            
            % Execute commands
            obj.com = obj.com.ni845xSpiScriptRun;
            % Read data size in bytes
            index = 0;
            ReadData =[];
            for i = 1:writeSize:numberOfWriteRead*writeSize
                index = index + 1;
                [obj.com, ReadSize] = ...
                    obj.com.ni845xSpiScriptExtractReadDataSize(...
                    scriptReadIndex(index));
                % Read data
                [obj.com, temp] = ...
                    obj.com.ni845xSpiScriptExtractReadData(...
                    scriptReadIndex(index), ReadSize);
                ReadData = [ReadData, temp];
                ReadData = bin2dec(reshape(dec2bin(ReadData).', 1, ...
                    size(dec2bin(ReadData), 2)*size(dec2bin(ReadData), 1)));

            end
        end
        
        
        function obj = reset(obj)
            obj.rstStatus = 1;
            obj.com = obj.com.ni845xDioWritePort(obj.rstStatus);
            pause(0.1);
            obj.rstStatus = 0;
            obj.com = obj.com.ni845xDioWritePort(obj.rstStatus);
            
        end
        
        
        % Close SPI communication with chip 
        function obj = comClose(obj)
            if ~isempty(obj.com)
                if ~isempty(obj.com.ScriptHandle)
                    obj.com = obj.com.ni845xSpiScriptDisableSPI;
                    obj.com = obj.com.ni845xSpiScriptClose;
                end
                obj.com = obj.com.ni845xClose;  
                obj.com = [];
            end
        end
        
        function obj = comOpen(obj, PortNumber)
            obj.com = ni845xSpiDio(PortNumber);
            switch obj.voltage
                case 1.2
                    obj.com = obj.com.ni845xSetIoVoltageLevel(...
                        obj.com.kNi845x12Volts);
                case 1.8
                    obj.com = obj.com.ni845xSetIoVoltageLevel(...
                        obj.com.kNi845x18Volts);
                case 3.3
                    obj.com = obj.com.ni845xSetIoVoltageLevel(...
                        obj.com.kNi845x33Volts);
                otherwise
                    obj.com = obj.com.ni845xSetIoVoltageLevel(...
                        obj.com.kNi845x18Volts);
            end
            obj.com = obj.com.setNi845xDio(obj.com.kNi845xPushPull, ...
                ones(1, 8));
        end
        
        
    end
end
