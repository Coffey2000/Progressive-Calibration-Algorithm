clc
close all
clear

addpath('.\Library');
addpath('.\Classes');
addpath('.\Init Files');
addpath('.\Functions');

% Total number of chips
numberOfICs             = 4;
numberOfICsDaisyChained = 2;  

% Create instance of the array
array    = mmw9003kcArray('numberOfICs', numberOfICs, ...
    'numberOfICsDaisyChained', numberOfICsDaisyChained, 'csPin', {'cs0', 'cs1'});

% Select array mode
array.mode('SBY'); % SBY, TX, RX


phaseIC1_master   = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)
phaseIC2_slave    = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)
phaseIC3_master   = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)
phaseIC4_slave    = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)


phase = [phaseIC1_master; phaseIC2_slave; phaseIC3_master; phaseIC4_slave];


attenIC1_master   = [0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)
attenIC2_slave    = [0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)
attenIC3_master   = [0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)
attenIC4_slave    = [0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)



atten = [attenIC1_master; attenIC2_slave; attenIC3_master; attenIC4_slave];



enIC1_master      = [1 1 1 1].*0    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC2_slave       = [1 1 1 1].*0    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC3_master      = [1 1 1 1].*0    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC4_slave       = [1 1 1 1].*0    ; %RF1, RF2, RF3, RF4 (0 or 1)



en = [enIC1_master; enIC2_slave; enIC3_master; enIC4_slave];



[array, readData] = array.setBW0(phase, atten, en);

Pna                 = pna('Set_PNA_Parameters');
sparameters         = Pna.getSParameters;


% Close communication with array
array = array.comClose;

