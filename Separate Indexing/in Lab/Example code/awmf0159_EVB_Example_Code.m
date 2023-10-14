clc
close all
clear

addpath('.\Library');
addpath('.\Classes');
addpath('.\Init Files');

% Total number of chips
numberOfICs             = 1;
numberOfICsDaisyChained = 1;  

% Create instance of the array
array    = awmf0159Array('numberOfICs', numberOfICs, ...
    'numberOfICsDaisyChained', numberOfICsDaisyChained, 'csPin', {'cs0'});

% Select array mode
array.mode('TX'); % SBY, TX, RX, SLP

% Init array sequence provided by anokiwave
array.init;

phaseIC1_A       = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC1_B       = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)



attenIC1_A       = [1 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC1_B       = [1 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)


enIC1_A          = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC1_B          = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 or 1)


[dataRead_A, decodeRead_A] = array.setBW0A(phaseIC1_A, attenIC1_A, enIC1_A);
[dataRead_B, decodeRead_B] = array.setBW0B(phaseIC1_B, attenIC1_B, enIC1_B);

% Close communication with array
array = array.comClose;

