RTPS_phase_states = linspace(0, 2*pi - 2*pi/90, 90);

data = zeros(1, 90*90);

% figure
for i = 1:1:90
    for j = 1:1:90
     data((i-1)*90 + j) = phase2cartesian(RTPS_phase_states(i), RTPS_phase_states(j));
%      plot(data((i-1)*90 + j), "O");
%      hold on
    end
end
% hold off

index = find(abs(imag(data)) < 0.00001);
gains = unique(sort(abs(data(index))));

index = find(gains > 0.001);
gains = unique(round(gains(index)*10^4)/10^4);

gain_resolution = zeros(2, size(gains,2) - 1);

for i = 1:1:size(gains, 2) - 1
    gain_resolution(1, i) = gains(i);
    gain_resolution(2, i) = gains(i + 1) - gains(i);
end

figure
plot(gain_resolution(1, :), gain_resolution(2, :));

save("gain_resolution.mat", "gain_resolution")

function point = phase2cartesian(phase1, phase2)
    point = 0.48*cos(phase1) + 0.48*cos(phase2) + 1i*(0.48*sin(phase1) + 0.48*sin(phase2));
end