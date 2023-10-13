load("channel1_S21_38r5GHz.mat");

for gain_index = 1:1:size(channel1_S21_38r5GHz, 1)
    [gain_reference, phase_reference] = conversionClass.cartesian2polar(channel1_S21_38r5GHz(gain_index, 1));
    for phase_index = 1:1:size(channel1_S21_38r5GHz, 2)
        [gain, phase] = conversionClass.cartesian2polar(channel1_S21_38r5GHz(gain_index, phase_index));
        phase = conversionClass.wrap22pi(phase - phase_reference);
        channel1_S21_38r5GHz_phaseCorrected(gain_index, phase_index) = conversionClass.polar2cartesian(gain, phase);
    end
end

save("channel1_S21_38r5GHz_phaseCorrected.mat", "channel1_S21_38r5GHz_phaseCorrected");