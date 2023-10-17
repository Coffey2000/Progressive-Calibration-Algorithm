clc
close all
clear

global array Pna

addpath('.\Library');
addpath('.\Classes');
addpath('.\Init Files');
addpath('.\Functions');
addpath('.\Parameters');


% Total number of chips
numberOfICs             = 1;
numberOfICsDaisyChained = 1;  

% Create instance of the array
array    = mmw9003kcArray('numberOfICs', numberOfICs, ...
    'numberOfICsDaisyChained', numberOfICsDaisyChained, 'csPin', {'cs0'});
Pna                 = pna('Set_PNA_Parameters');

Pna                 = pna('Set_PNA_Parameters', {'S41'});
Pna.pnaSettings.measurementType = {'S41'};
Pna.setPnaParameters;


% Select array mode
array.mode('TX'); % SBY, TX, RX, SLP


phase       = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)
atten       = [0 16 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)
en          = [1 0 1 1]    ; %RF1, RF2, RF3, RF4 (0 or 1)


[array, readData] = array.setBW0(phase, atten, en);




sparameters         = Pna.getSParameters;

angle(sparameters(1, 1))*180/pi
Pna.turnOFF;

