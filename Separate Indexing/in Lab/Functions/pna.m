classdef pna < handle
    properties
        interfaceObj;
        pnaSettings;
    end

    methods
        
        function obj = pna(settingsPath)

            obj    = obj.initPna(settingsPath);

        end

        
        function obj = initPna(obj, settingsPath)
            pnaSettings      = []   ;
            run(['./Parameters/', settingsPath]) ;
            obj.pnaSettings  = pnaSettings ;  
            obj.setPnaParameters;
        end


        % function obj = pna(settingsPath, varargin)
        % 
        %     obj    = obj.initPna(settingsPath, varargin{1});
        % 
        % end
        % 
        % 
        % function obj = initPna(obj, settingsPath, varargin)
        %     pnaSettings      = []   ;
        %     run(['./Parameters/', settingsPath]) ;
        %     obj.pnaSettings  = pnaSettings ;  
        %     if ~isempty(varargin)
        %         obj.pnaSettings.measurementType = varargin{1};
        %     end
        %     obj.setPnaParameters;
        % end


        function obj = setPnaParameters(obj)
            obj.open;
            % Set Input Power
            fprintf(obj.interfaceObj,sprintf(['SOUR:POW %d'], obj.pnaSettings.power)); 


            % Set Number of Frequency points
            fprintf(obj.interfaceObj,sprintf(['SENS:SWE:POIN %d'], obj.pnaSettings.numberOfFreqPoint));

            % Set Center Frequency
            fprintf(obj.interfaceObj,sprintf(['SENS:FREQ:CENT %d'], obj.pnaSettings.centerFreq));


            % Set Frequency Span
            fprintf(obj.interfaceObj,sprintf(['SENS:FREQ:SPAN %d'], obj.pnaSettings.freqSpan));


            %     % Set Frequency Start Freq
            %     fprintf(PNA.interfaceObj,sprintf(['SENS:FREQ:STAR %d'], freqArray(1)));

            %     % Set Frequency Stop Freq
            %     fprintf(PNA.interfaceObj,sprintf(['SENS:FREQ:STOP %d'], freqArray(end)));

            % Set Trigger EXTernal or IMMediate
            fprintf(obj.interfaceObj,sprintf('TRIG:SOUR %s', 'IMMediate'));

            % Set Sweep Type to Frequency
            fprintf(obj.interfaceObj,sprintf(['SENS:SWE:TYPE LIN']));


            % Turn ON Ports
            fprintf(obj.interfaceObj,sprintf('OUTP %s', 'ON'));


            % Close Open Windows
            temp = obj.xquery(obj.interfaceObj, 'DISPlay:CATalog?');
            for i = 1:length(temp)
                fprintf(obj.interfaceObj,sprintf(['DISP:WIND%d OFF'], temp(i)));
            end

            % Delete all Measurements
            fprintf(obj.interfaceObj,sprintf('CALCulate:PARameter:DELete:ALL'));
            
            pause(0.1);
            for itr = 1:length(obj.pnaSettings.measurementType)
                % Open Window
                fprintf(obj.interfaceObj, sprintf('DISP:WIND%d ON', itr));

                fprintf(obj.interfaceObj, sprintf('CALC1:PAR:EXT %s, %s', ...
                    obj.pnaSettings.measurementType{itr}, obj.pnaSettings.measurementType{itr}));

                fprintf(obj.interfaceObj, sprintf('DISP:WIND%d:TRAC1:FEED %s', itr, ...
                    obj.pnaSettings.measurementType{itr}));
                

            end

            % Set Averaging Mode
            fprintf(obj.interfaceObj, sprintf('SENS1:AVER:MODE POIN'));

            % set number of AVR points
            fprintf(obj.interfaceObj, sprintf('SENS1:AVER:COUN %d', obj.pnaSettings.numberAverages));

            % Enable Averaging
            fprintf(obj.interfaceObj, sprintf('SENS1:AVER ON'));
            
            for itr = 1:length(obj.pnaSettings.measurementType)
                %Select Measurement to Capture
                fprintf(obj.interfaceObj, sprintf('CALC1:PAR:SEL %s', ...
                obj.pnaSettings.measurementType{itr}));
                % Enable Smoothing
                fprintf(obj.interfaceObj, sprintf('CALC1:SMO ON'));
                % Set Smoothing mode and points
                fprintf(obj.interfaceObj, sprintf('CALC1:SMO:POIN %d', obj.pnaSettings.smoothNumberOfPoints));
            end
  
        end
        
        function results = getSParameters(obj)
            obj.open;
            fprintf(obj.interfaceObj, 'SENS:SWE:MODE SING');
            %xquery(PNA.interfaceObj, '*ESR? ')
            obj.xquery(obj.interfaceObj, '*OPC?');
            for itr = 1:length(obj.pnaSettings.measurementType)
                %Select Measurement to Capture
                fprintf(obj.interfaceObj, sprintf('CALC1:PAR:SEL %s', ...
                obj.pnaSettings.measurementType{itr}));
                dataTemp = obj.xquery(obj.interfaceObj, 'CALC1:DATA? SDATA');
                results(itr, :)    = complex(dataTemp(1:2:end), dataTemp(2:2:end));
            end
        end
        
        function readData = xquery(~, FID, CMD)
            readData = query(FID, CMD);
            readData(readData == '"') = [];
            readData = str2num(cell2mat(strsplit(readData(1:end-1), ',').'));
        end
        
        function obj = open(obj)
            newobjs = instrfind;  
            if isempty(newobjs) == false
                fclose(newobjs);
                delete(newobjs);
            end
            clear newobjs
            % Set The Number Of Points To Capture
            PointsPerRecord = 200000;
            % Set The Driver Location
            resourceDesc = obj.pnaSettings.visaAddress;
            % Intitiate the Driver
            obj.interfaceObj = visa('agilent', resourceDesc);
            % Set Time Out Length In Seconds
            GLOBAL_TIMEOUT = 40;
            obj.interfaceObj.Timeout = GLOBAL_TIMEOUT;
            % Set The Scope Buffer Size at least X2.5 The Number of Points
            obj.interfaceObj.inputbuffersize = uint64(PointsPerRecord*3);
            % Set The Byte Order "Little Endian" or "Big Endian"
            obj.interfaceObj.ByteOrder = 'littleEndian';
            % Open the Communication Link With The Scope
            fopen(obj.interfaceObj);
            % fprintf(PNA.interfaceObj,sprintf(['FORM ASCii,0']));
            % fprintf(PNA.interfaceObj, 'FORM:BORD SWAP');
            clrdevice(obj.interfaceObj);
        end
        
        function delete(obj)
            fprintf(obj.interfaceObj,sprintf('OUTP %s', 'OFF'));
        end
        
        function turnOFF(obj)
            obj.open;
            fprintf(obj.interfaceObj,sprintf('OUTP %s', 'OFF'));
        end
            
        
    end
end