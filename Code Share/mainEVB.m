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
array.mode('SBY'); % SBY, TX, RX, SLP


phase       = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)
atten       = [0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)
en          = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 or 1)


[array, readData] = array.setBW0(phase, atten, en);



Pna                 = pna('Set_PNA_Parameters');
sparameters         = Pna.getSParameters;


% Close communication with array
array = array.comClose;

