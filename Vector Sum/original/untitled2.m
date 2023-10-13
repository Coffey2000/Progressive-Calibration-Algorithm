% clear
% close all
% clc
% 
%  
% 
% %% S parameters
% 
%  
% 
% addpath('.\Library');
% addpath('.\Classes');
% 
%  
% 
% % s4p file save path pna
% SaveDir = 'D:\Measurement\Mehran\RFVM\11DEC_2022\CHIP3\';
% % Initialize
% rtps        = rtpsClass('clockRate', 10, ...
%     'voltage', 1.2, ...
%     'numberOfBits', 12);
% pause(1);
% 
%  
% 
% 
% % PNA Visa Address
% PNA.visaAddress     = 'USB0::0x2A8D::0x2B01::US56070658::0::INSTR';
% 
%  
% 
% % Settings
% power                   = -10;  % PNA source power
% centerFreq              = 40e9;
% freqSpan                = 10e9;
% numberOfFreqPoint       = 401;

 

%rtpsPhaseSettingArray   = 1:2:2^12-1;  % 2^12-1
%rtpsPhaseSettingArray   = 0:100:800;  % 2^12-1
[LUT_all_1] = phase_shifter_all_LUT();
% [LUT_all_1] = phase_shifter_all_LUT();
[LUT_all_2] = phase_shifter_all_LUT();

 

tic
% for dataIndex2 = 1:1:length(LUT_all_2)
% 
%     c4 = LUT_all_2(dataIndex2, 2);
%     c5 = LUT_all_2(dataIndex2, 3);
%     c6 = LUT_all_2(dataIndex2, 4);
%     c7 = LUT_all_2(dataIndex2, 5);
for dataIndex1 = 1:1:length(LUT_all_1)   % LUT_all

 

     for dataIndex2 = 1:1:length(LUT_all_2)   % LUT_all

         c0 = LUT_all_1(dataIndex1, 2);
         c1 = LUT_all_1(dataIndex1, 3);
         c2 = LUT_all_2(dataIndex2, 2);
         c3 = LUT_all_2(dataIndex2, 3);
%          c2 = LUT_all_1(dataIndex1, 4);
%          c3 = LUT_all_1(dataIndex1, 5);
%          c4 = LUT_all_1(dataIndex1, 4);
%          c5 = LUT_all_1(dataIndex1, 5);
        codeword = c0.*2^(0) + c1.*2^(4) + c2.*2^(6) + c3.*2^(10);
     
%         codeword = c0.*2^(0) + c1.*2^(4) + c2.*2^(8) + c3.*2^(12) + c4.*2^(14) + c5.*2^(18) ...
%         + c6.*2^(22) + c7.*2^(26) + 0.*2^(28); 
%         codeword = c0.*2^(2) + c1.*2^(6) + c2.*2^(10) + c3.*2^(14) + c4.*2^(16) + c5.*2^(20) ...
%         + c6.*2^(24) + c7.*2^(28) + 0.*2^(28);
        dec2bin(codeword, 12) 
     end
end

        readData = rtps.setRtps(0);
        readData = rtps.setRtps(codeword);
%         readData = rtps.setRtps(codeword)
%         readData = rtps.setRtps(codeword)

 

%           readData = rtps.setRtps(0)
%          readData = rtps.setRtps(4000)

 


        dec2bin(readData, 12) 
%         dec2bin(4095, 12)