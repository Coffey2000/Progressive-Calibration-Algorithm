global array Pna

measurementClass.measurementSetup();

channel_readings_38GHz = zeros(256, 256, 2);

%channel 1
en = [1 0 1 1]    ; %RF1, RF2, RF3, RF4 (0 or 1)
tic;
for gain_index = 1:1:256
    for phase_index = 1:1:256
        phase = [0 (phase_index-1) 0 0]    ; %RF1, RF2, RF3, RF4 (0 to 255)
        atten = [0 (gain_index-1) 0 0]  ; %RF1, RF2, RF3, RF4 (0 to 255)
        
        [array, readData] = array.setBW0(phase, atten, en);
        
        channel_readings_38GHz(gain_index, phase_index, 1) = Pna.getSParameters;
    end
end
time = toc;
disp("S21 Measurement time: " + time);


%channel 2
Pna = pna('Set_PNA_Parameters2');
en = [1 1 1 0]    ; %RF1, RF2, RF3, RF4 (0 or 1)
tic;
for gain_index = 1:1:256
    for phase_index = 1:1:256
        phase = [0 0 0 (phase_index-1)]    ; %RF1, RF2, RF3, RF4 (0 to 255)
        atten = [0 0 0 (gain_index-1)]  ; %RF1, RF2, RF3, RF4 (0 to 255)
        
        [array, readData] = array.setBW0(phase, atten, en);
        
        channel_readings_38GHz(gain_index, phase_index, 2) = Pna.getSParameters;
    end
end
time = toc;
disp("S21 Measurement time: " + time);

save("channel_readings_38GHz.mat", "channel_readings_38GHz");

measurementClass.measurementOFF();