clear
close all
clc

%% S parameters 

% addpath('.\Library');
% addpath('.\Classes');
% 
% % s4p file save path pna
% SaveDir = 'D:\Measurement\Mehran\RTPS\10DEC_2022\CHIP1\';
% % Initialize
% rtps        = rtpsClass('clockRate', 10, ...
%     'voltage', 1.2, ...
%     'numberOfBits', 12);
% pause(1);
% 
% 
% % PNA Visa Address
% PNA.visaAddress 	= 'USB0::0x2A8D::0x2B01::US56070658::0::INSTR'; 

% Settings
power                   = -10;  % PNA source power
centerFreq              = 40e9;
freqSpan                = 10e9;
numberOfFreqPoint       = 401;

%rtpsPhaseSettingArray   = 1:2:2^12-1;  % 2^12-1
%rtpsPhaseSettingArray   = 0:100:800;  % 2^12-1
[LUT_all_1] = phase_shifter_all_LUT_2();
% [LUT_all_1] = phase_shifter_all_LUT();
% [LUT_all_2] = phase_shifter_all_LUT();

for abc = 1:1:4096*2
    LUT_all_1(abc, 6) = str(dec2bin(LUT_all_1(abc, 5), 12));
end

for i = 1:1:256
    if S_dd21_abs(i, 1) < 0.1
        S_dd21_abs(i, 1) = 0;
    end
end


tic
% for dataIndex2 = 1:1:length(LUT_all_2)
% 
%     c4 = LUT_all_2(dataIndex2, 2);
%     c5 = LUT_all_2(dataIndex2, 3);
%     c6 = LUT_all_2(dataIndex2, 4);
%     c7 = LUT_all_2(dataIndex2, 5);

index = 4
dec2bin(LUT_all_1(index, 2).*2^(0) + LUT_all_1(index, 3).*2^(4) + LUT_all_1(index, 4).*2^(8) + LUT_all_1(index, 5).*2^(12), 14)

     for dataIndex1 = 1:1:length(LUT_all_1)   % LUT_all
     
         c0 = LUT_all_1(dataIndex1, 2);
         c1 = LUT_all_1(dataIndex1, 3);
         c2 = LUT_all_1(dataIndex1, 4);
%           c3 = LUT_all_1(dataIndex1, 5);
%          c4 = LUT_all_1(dataIndex1, 4);
%          c5 = LUT_all_1(dataIndex1, 5);
%         codeword = c0.*2^(0) + c1.*2^(4);
 codeword = c0.*2^(0) + c1.*2^(4) + c2.*2^(8);


     
%         codeword = c0.*2^(0) + c1.*2^(4) + c2.*2^(8) + c3.*2^(12) + c4.*2^(14) + c5.*2^(18) ...
%         + c6.*2^(22) + c7.*2^(26) + 0.*2^(28); 
%         codeword = c0.*2^(2) + c1.*2^(6) + c2.*2^(10) + c3.*2^(14) + c4.*2^(16) + c5.*2^(20) ...
%         + c6.*2^(24) + c7.*2^(28) + 0.*2^(28);
        dec2bin(codeword, 12) 
%         dec2bin(4000, 12) 

    
        readData = rtps.setRtps(0);
        readData = rtps.setRtps(codeword)
%         readData = rtps.setRtps(codeword)
%         readData = rtps.setRtps(codeword)
%          readData = rtps.setRtps(0)
%           readData = rtps.setRtps(4000)


        dec2bin(readData, 12) 
        
        pause(1);
    
    
        % Open Link with PNA
        PNA.interfaceObj    = pnaInit(PNA);
        
% measurementType     = {'S11', 'S22','S33', 'S44', 'S21', 'S23', 'S41', 'S43'};
% measurementType     = {'S11', 'S22','S33', 'S44', 'S21', 'S23', 'S24', 'S31', 'S32', 'S34', 'S41'};
      measurementType     = {'S11', 'S12','S13', 'S14', 'S21', 'S22', 'S23', 'S24','S31', 'S32','S33', 'S34', 'S41', 'S42', 'S43', 'S44'};
%        measurementType     = {'CH1_SDD11', 'S12','S21', 'S22'};
        %measurementType     = {'S11','S22'};
%         measurementType     = {'S21','S43'};
        
        
        
        % Set Input Power
        fprintf(PNA.interfaceObj,sprintf(['SOUR:POW %d'], power)); 
        
        % Set Center Frequency
        fprintf(PNA.interfaceObj,sprintf(['SENS:FREQ:CENT %d'], centerFreq));
        
        % Set Frequency Span
        fprintf(PNA.interfaceObj,sprintf(['SENS:FREQ:SPAN %d'], freqSpan));
        
        
        % % Set Frequency Start Freq
        % fprintf(PNA.interfaceObj,sprintf(['SENS:FREQ:STAR %d'], startFreq));
        % 
        % % Set Frequency Stop Freq
        % fprintf(PNA.interfaceObj,sprintf(['SENS:FREQ:STOP %d'], stopFreq));
        
        % Set Trigger EXTernal or IMMediate
        fprintf(PNA.interfaceObj,sprintf('TRIG:SOUR %s', 'IMMediate')); %EXT
        
        
        % Set Number of Frequency points
        fprintf(PNA.interfaceObj,sprintf(['SENS:SWE:POIN %d'], numberOfFreqPoint));
        
        % Set Sweep Type to Frequency
        fprintf(PNA.interfaceObj,sprintf(['SENS:SWE:TYPE LIN']));
        
        
        % Turn ON Ports
        fprintf(PNA.interfaceObj,sprintf('OUTP %s', 'ON'));
        
%         Close Open Windows
        temp = query(PNA.interfaceObj, 'DISPlay:CATalog?');
        for i = 1:length(temp)
            fprintf(PNA.interfaceObj,sprintf(['DISP:WIND%d OFF'], temp(i)));
        end
        
%         Delete all Measurements
        fprintf(PNA.interfaceObj,sprintf('CALCulate:PARameter:DELete:ALL'));
       
    
        for itr = 1:length(measurementType)
            % Open Window
            fprintf(PNA.interfaceObj, sprintf('DISP:WIND%d ON', itr));
        
            % Set Measurement
            fprintf(PNA.interfaceObj, sprintf('CALC1:PAR:EXT %s, %s', ...
                measurementType{itr}, measurementType{itr}));
            
            % Display Measurement
            fprintf(PNA.interfaceObj, sprintf('DISP:WIND%d:TRAC1:FEED %s', itr, ...
                measurementType{itr}));
        end

        % Set Averaging Mode
        fprintf(PNA.interfaceObj, sprintf('SENS1:AVER:MODE POIN'));
        
        % set number of AVR points
        fprintf(PNA.interfaceObj, sprintf('SENS1:AVER:COUN 3'));
	        
        % Enable Averaging
        fprintf(PNA.interfaceObj, sprintf('SENS1:AVER ON'));
        
        pause(3)
        
        for itr = 1:length(measurementType)
        
            %Select Measurement to Capture
            fprintf(PNA.interfaceObj, sprintf('CALC1:PAR:SEL %s', ...
                measurementType{itr}));
        
            %Capture Data
            status = xquery(PNA.interfaceObj, '*OPC?');
             
            dataTemp = xquery(PNA.interfaceObj, 'CALC1:DATA? SDATA');
            data(itr, :)    = complex(dataTemp(1:2:end), dataTemp(2:2:end));
        end
   
    
        Path = [SaveDir 'rtps_en_' num2str(dataIndex1) '.s4p'];
        % Set Measurement
        fprintf(PNA.interfaceObj, sprintf('CALC1:DATA:SNP:PORTs:SAVE "1,2,3,4", "%s"', Path));

        dataSave{dataIndex1}.data               = data;
        dataSave{dataIndex1}.power              = power;
        %     dataSave{dataIndex}.startFreq                   = startFreq;
        %     dataSave{dataIndex}.stopFreq                    = stopFreq;
        dataSave{dataIndex1}.numberOfFreqPoint  = numberOfFreqPoint;
        dataSave{dataIndex1}.centerFreq         = centerFreq;
        dataSave{dataIndex1}.freqSpan           = freqSpan;
        dataSave{dataIndex1}.measurementType    = measurementType;
        dataSave{dataIndex1}.codeword           = codeword;
        dataSave{dataIndex1}.readData           = floor(readData/12);
    
%         dec2bin(codeword,8)
        dataIndex1
%         dataIndex2
        
    end
    
toc


%DC.trunOFF;
 
save('data_RTPS_indep_sweep_DEC10_2022_chip1_en', 'dataSave');



% freq = (centerFreq-freqSpan/2:freqSpan/numberOfFreqPoint:...
%     centerFreq+freqSpan/2-freqSpan/numberOfFreqPoint)./10^9;
% 
% figure
% hold on
% grid on
% for counter = 1:length(dataSave)
%     plot(freq, 20*log10(abs(dataSave{counter}.data(1,:))));  % S11
%     xlabel('Frequency (GHz)')
%     ylabel('S11 (dB)')
%     xlim([30 50])
% end
% hold off
% 
% figure
% hold on
% grid on
% for counter = 1:length(dataSave)
%     plot(freq, 20*log10(abs(dataSave{counter}.data(2,:)))); % S22
%     xlabel('Frequency (GHz)')
%     ylabel('S22 (dB)')
%     xlim([30 50])
% end
% hold off

%% Plot S11 for all phase states (4096 states)

% load('data_RTPS_Results_Jan_21_2021_step2_set1');
% 
% centerFreq = dataSave{1,2}.centerFreq;
% freqSpan = dataSave{1,2}.freqSpan;
% numberOfFreqPoint = dataSave{1,2}.numberOfFreqPoint;
% freq = (centerFreq-freqSpan/2:freqSpan/numberOfFreqPoint:...
%     centerFreq+freqSpan/2-freqSpan/numberOfFreqPoint)./10^9;
% 
% figure
% hold on
% grid on
% for counter = 1:length(dataSave)
%     plot(freq, 20*log10(abs(dataSave{counter}.data(1,:))));
%     xlabel('Frequency (GHz)')
%     ylabel('S11 (dB)')
%     xlim([30 50])
% end
% load('data_RTPS_Results_Jan_21_2021_step2_set2');
% hold on
% for counter = 1:length(dataSave)
%     plot(freq, 20*log10(abs(dataSave{counter}.data(1,:))));
%     xlabel('Frequency (GHz)')
%     ylabel('S11 (dB)')
%     xlim([30 50])
%     ylim([-30 0])
% end
% hold off
% 
% % Curve Fitting
% load('data_RTPS_Results_Jan_21_2021_step2_set1');
% centerFreq = dataSave{1,2}.centerFreq;
% freqSpan = dataSave{1,2}.freqSpan;
% numberOfFreqPoint = dataSave{1,2}.numberOfFreqPoint;
% freq = (centerFreq-freqSpan/2:freqSpan/numberOfFreqPoint:...
%     centerFreq+freqSpan/2-freqSpan/numberOfFreqPoint)./10^9;
% figure
% hold on
% grid on
% for counter = 1:length(dataSave)
%     f=smooth(20*log10(abs(dataSave{counter}.data(1,:))), 30);
%     plot(freq, f);
%     xlabel('Frequency (GHz)')
%     ylabel('S11 (dB)')
%     xlim([30 50])
%     ylim([-30 0])
% end
% load('data_RTPS_Results_Jan_21_2021_step2_set2');
% hold on
% for counter = 1:length(dataSave)
%     f2=smooth(20*log10(abs(dataSave{counter}.data(1,:))), 30);
%     plot(freq, f2);
% end
% hold off










