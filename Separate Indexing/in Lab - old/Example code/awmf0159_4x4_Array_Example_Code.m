clc
close all
clear

addpath('.\Library');
addpath('.\Classes');
addpath('.\Init Files');

% Total number of chips
numberOfICs             = 4;
numberOfICsDaisyChained = 2;  

% Create instance of the array
Array    = awmf0159Array('numberOfICs', numberOfICs, ...
    'numberOfICsDaisyChained', numberOfICsDaisyChained, 'csPin', {'cs0', 'cs1'});

% Select array mode
Array.mode('TX'); % SBY, TX, RX, SLP

% Init array sequence provided by anokiwave
Array.init;

phaseIC1_A_master   = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC2_A_slave    = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC3_A_master   = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC4_A_slave    = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)

phaseIC1_B_master   = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC2_B_slave    = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC3_B_master   = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)
phaseIC4_B_slave    = [0 0 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 63)

phase_A = [phaseIC1_A_master; phaseIC2_A_slave; phaseIC3_A_master; phaseIC4_A_slave];
phase_B = [phaseIC1_B_master; phaseIC2_B_slave; phaseIC3_B_master; phaseIC4_B_slave];

attenIC1_A_master   = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC2_A_slave    = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC3_A_master   = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC4_A_slave    = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)

attenIC1_B_master   = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC2_B_slave    = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC3_B_master   = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)
attenIC4_B_slave    = [0 0 0 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 15)

atten_A = [attenIC1_A_master; attenIC2_A_slave; attenIC3_A_master; attenIC4_A_slave];
atten_B = [attenIC1_B_master; attenIC2_B_slave; attenIC3_B_master; attenIC4_B_slave];


enIC1_A_master      = [0 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC2_A_slave       = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC3_A_master      = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC4_A_slave       = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)

enIC1_B_master      = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC2_B_slave       = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC3_B_master      = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)
enIC4_B_slave       = [1 1 1 1].*1    ; %RF1, RF2, RF3, RF4 (0 or 1)

en_A = [enIC1_A_master; enIC2_A_slave; enIC3_A_master; enIC4_A_slave];
en_B = [enIC1_B_master; enIC2_B_slave; enIC3_B_master; enIC4_B_slave];

Array.setBW0A(phase_A, atten_A, en_A);
Array.setBW0B(phase_B, atten_B, en_B);

setBeamVPol4x4(Array, 'Theta', 0, 'Phi', 0, 'Attenuation', 0); 
setBeamHPol4x4(Array, 'Theta', 0, 'Phi', 0, 'Attenuation', 0); 

thetaArray = -60:1:60;

Array.mode('SBY');
