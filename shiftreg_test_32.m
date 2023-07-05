
% clear
% 
% addpath('.\Library');
% addpath('.\Classes');
% 
rtps        = rtpsClass('clockRate', 1, ...
    'voltage', 1.2, ...
    'numberOfBits', 32);
% CLOCK RATE 1 means 1K

% c0 = 0;
% c1 = 0;
% c2 = 0 ;
% c3 = 0 ;
c0 = 15-14;
c1 = 15-15;
c2 = 15-0 ;

c3 = 1 ;

c4 = 15-0 ;
c5 = 15-0 ;
c6 = 15-0 ;
c7 = 15-1 ;
codeword = bitshift(c0,0) + bitshift(c1,4) + bitshift(c2,8) + ... 
           bitshift(c3,12)+ bitshift(c4,14)+ bitshift(c5,18) + ...
           bitshift(c6,22)+ bitshift(c7,26);
codeword_bin = dec2bin(codeword, 28);
           %bin2dec('0000111111111111');  % 0 to 15
rtps.setRtps(0); %clear
rtps.setRtps(codeword); %commit
%rtps.setRtps(0); %clear
% readData2 = rtps.setRtps(codeword); %clear
% readData3 = rtps.setRtps(codeword); %commit
% readData3 = rtps.setRtps(codeword); %readback

fprintf('%s\n',dec2bin(codeword,32));
% fprintf('%s\n',dec2bin(readData3,16));




