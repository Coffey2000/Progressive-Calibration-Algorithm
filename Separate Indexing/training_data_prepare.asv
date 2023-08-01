load("channel1_S21_38r5GHz_phaseCorrected.mat");
sample_gain = abs(channel1_S21_38r5GHz_phaseCorrected);

num_gain = size(sample_gain, 1);
num_phase = size(sample_gain, 2);

for i = 1:1:num_gain
    for j = 1:1:num_phase
        sample_phase(i, j) = conversionClass.wrap22pi(angle(channel1_S21_38r5GHz_phaseCorrected(i, j)));
    end
end

normalized_sample_gain = sample_gain./max(sample_gain, [], "all");
normalized_sample_phase = sample_phase./(2*pi);

for gain_index = 1:1:num_gain
    for phase_index = 1:1:num_phase
        sample_index = (gain_index - 1)*num_gain + phase_index;
        input_output(1, sample_index) = normalized_sample_gain(gain_index, phase_index);
        input_output(2, sample_index) = normalized_sample_phase(gain_index, phase_index);
        input_output(3, sample_index) = gain_index/num_gain;
        input_output(4, sample_index) = phase_index/num_phase;
    end
end

shuffled_input_output = input_output(:, randperm(size(input_output, 2)));

input = shuffled_input_output(1:2, :);
output = shuffled_input_output(3:4, :);

save("input.mat", "input");
save("output.mat", "output");