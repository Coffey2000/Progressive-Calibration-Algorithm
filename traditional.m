global DC_offset L1 L2 phase1_offset phase2_offset num_target_gain_states num_target_phase_states num_RTPS_gain_states num_RTPS_phase_states Measurements Mapping Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states ...
    target_phase_states RTPS_gain_states RTPS_phase_states num_MODES phase_error_criteria kernel_size target_phase_resolution RTPS_phase_resolution S_dd21 simulation_data_mode2 magnitude_scaling_factor last_phase1_error last_phase2_error target_gain_resolution_dB ...
    RTPS_gain_resolution_dB lowest_detectable_gain_dB lowest_detectable_gain target_gain_states_dB phase_error_history RTPS_gain_resolution Selected_Measurements Current_Point_Iteration_Count original_kernel_size filter_tolerance Starting_Gain_Index Ending_Gain_Index...
    measurement_counter total_measurement_counter


kernel_size = 5;
lowest_detectable_gain_dB = -8;

Starting_Gain_Index = 5;
Ending_Gain_Index = 8;

filter_tolerance = 1.3;


%%

% load("./RTPSdata/sp/Sp.mat", "S_dd21");
load("simulation_data_mode2.mat");
%load('gain_resolution.mat');

DC_offset = 0;
phase1_offset = 0;
phase2_offset = 0;
L1 = 0.5;
L2 = 0.5;
magnitude_scaling_factor = 2.495425790739931;

lowest_detectable_gain = 10^(lowest_detectable_gain_dB/10);

target_gain_resolution_dB = 1;
RTPS_gain_resolution_dB = 0.5;
RTPS_gain_resolution = 0.02;

num_target_gain_states = (0 - lowest_detectable_gain_dB)/target_gain_resolution_dB + 1;
num_target_phase_states = 64;

num_RTPS_gain_states = (0 - lowest_detectable_gain_dB)/RTPS_gain_resolution_dB + 1;
num_RTPS_phase_states = 90;

last_phase1_error = 0;
last_phase2_error = 0;

target_phase_resolution = 2*pi/num_target_phase_states;
RTPS_phase_resolution = 2*pi/num_RTPS_phase_states;

phase_error_history = zeros(2, 4);

phase_error_criteria = RTPS_phase_resolution;

num_MODES = 9;

original_kernel_size = kernel_size;

Measurements = zeros(num_RTPS_phase_states, num_RTPS_phase_states, num_MODES) + 1234;
%Measurements_code = zeros(2, num_RTPS_phase_states^2*num_MODES);
Mapping = zeros(num_target_gain_states, num_target_phase_states);

Selected_Measurements = zeros(num_target_gain_states, num_target_phase_states);

target_gain_states_dB = linspace(-1*(num_target_gain_states - 1), 0, num_target_gain_states);
target_gain_states = 10.^(target_gain_states_dB./10);
target_phase_states = linspace(0, 2*pi - target_phase_resolution, num_target_phase_states);

RTPS_gain_states_dB = linspace(-1*(num_target_gain_states - 1), 0, num_RTPS_gain_states);
RTPS_gain_states = 10.^(RTPS_gain_states_dB./10);
RTPS_phase_states = linspace(0, 2*pi - RTPS_phase_resolution, num_RTPS_phase_states);

Current_Calibration_Gain_Index = Starting_Gain_Index;
Current_Calibration_Phase_Index = 1;

Current_Point_Iteration_Count = 0;

measurement_counter = 0;
total_measurement_counter = 0;

figure;

WB = waitbar(0,'Please wait...');

while Current_Calibration_Gain_Index <= Ending_Gain_Index
    for i = 1:1:num_target_phase_states
        waitbar(((Current_Calibration_Gain_Index - Starting_Gain_Index)*num_target_phase_states+i)/(Ending_Gain_Index-Starting_Gain_Index + 1)*num_target_phase_states, WB, 'Please wait...');
        distance = abs(simulation_data_mode2*magnitude_scaling_factor - conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(i)));
        index = find(distance == min(distance));
        Selected_Measurements(Current_Calibration_Gain_Index, i) = simulation_data_mode2(index, 1)*magnitude_scaling_factor;
    end
    circle_report();
    Current_Calibration_Gain_Index = Current_Calibration_Gain_Index + 1;
end

close(WB);

Current_Calibration_Gain_Index = Current_Calibration_Gain_Index - 1;

plot(simulation_data_mode2*magnitude_scaling_factor, "X")
hold on
plot(Selected_Measurements(Starting_Gain_Index:Current_Calibration_Gain_Index, :), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "g");
hold on
plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
hold off
xlim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
ylim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
drawnow


function plot_gain_circle(gain)
    x0=0;
    y0=0;
    syms x y
    fimplicit((x-x0).^2 + (y-y0).^2 -gain^2, "Color", "k")
    
    hold on
    axis equal
end



function circle_report()
global Current_Calibration_Gain_Index target_gain_states target_gain_states_dB target_phase_states Selected_Measurements measurement_counter total_measurement_counter Ending_Gain_Index Starting_Gain_Index

    actual_phase = angle(Selected_Measurements(Current_Calibration_Gain_Index, :));
    
    for i = round(size(actual_phase, 2)/3) : 1 : size(actual_phase, 2)
        actual_phase(1, i) = conversionClass.wrap22pi(actual_phase(1, i));
    end

    phase_RMS_error = rmse(target_phase_states, actual_phase);
    gain_RMS_error = rmse(target_gain_states(Current_Calibration_Gain_Index), abs(Selected_Measurements(Current_Calibration_Gain_Index, :)));

    disp(" ");
    disp("Gain Circle " + Current_Calibration_Gain_Index + " at " + target_gain_states(Current_Calibration_Gain_Index) + " / " + target_gain_states_dB(Current_Calibration_Gain_Index) + " dB");
    disp("RMS Phase Error: " + phase_RMS_error + " / " + phase_RMS_error*180/pi + " degrees");
    disp("RMS Gain Error: " + gain_RMS_error + " / " + 10*log10(gain_RMS_error) + " dB");
    disp("Number of new measurements: " + measurement_counter);

    measurement_counter = 0;

    if Current_Calibration_Gain_Index == Ending_Gain_Index
        disp(" ");
        disp("Calibration finish");
        disp("Total number of measurements for " + (Ending_Gain_Index - Starting_Gain_Index + 1) + " gain circles: " + total_measurement_counter);
    end

end