global DC_offset L1 L2 phase1_offset phase2_offset num_target_gain_states num_target_phase_states num_RTPS_gain_states num_RTPS_phase_states Measurements Mapping Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states ...
    target_phase_states RTPS_gain_states RTPS_phase_states num_MODES phase_error_criteria kernel_size target_phase_resolution RTPS_phase_resolution S_dd21 simulation_data magnitude_scaling_factor last_phase1_error last_phase2_error target_gain_resolution_dB ...
    RTPS_gain_resolution_dB lowest_detectable_gain_dB lowest_detectable_gain target_gain_states_dB phase_error_history RTPS_gain_resolution Selected_Measurements Current_Point_Iteration_Count original_kernel_size filter_tolerance Starting_Gain_Index Ending_Gain_Index...
    measurement_counter total_measurement_counter


%%
kernel_size = 3;
lowest_detectable_gain_dB = -8;

Starting_Gain_Index = 5;
Ending_Gain_Index = 8;

filter_tolerance = 1.3;


%%

% load("./RTPSdata/sp/Sp.mat", "S_dd21");
load("simulation_data.mat");
%load('gain_resolution.mat');

DC_offset = 0;
phase1_offset = 0;
phase2_offset = 0;
L1 = 0.5;
L2 = 0.5;
magnitude_scaling_factor = 1;

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

% [c0, c1, c2, c3] = phase2code(360*pi/180);

%%
% data = measure(0.4 + 0.75j, "cartesian", 1)
% codeword = polar2code(0.7, 1.2, 2);
% data = OUTPHASER_READ(codeword);
% nice = linspace(0,360, 96);
% [c0,c1,c2,c3] = phase2code(40*pi/180);

% [p1, p2] = cartesian2phases(polar2cartesian(0.5, 126*pi/180));

% sweep_phases = linspace(0.0001, 2*pi*89/90 + 0.0001, 90);
% sweep_reading = zeros(1, 90);
% 

% next_measurements(1:90, 1) = target_gain_states(5);
% next_measurements(1:90, 2) = transpose(RTPS_phase_states);
% next_choice = "polar";
% 
% for i = 1:1:90
% 
% 
%              current_point = measure(next_measurements(i, :), next_choice, 1)*2.49;
% 
%                  plot(current_point, "O","MarkerFaceColor", "r");
%                  hold on
% 
% 
% 
% end
% 
%         target_point = polar2cartesian(0.316, 2);
%         [vector1_phase, vector2_phase] = cartesian2phases(target_point);
% 
% 
%     vector1_phase_index = phase2RTPS_phase_index(vector1_phase) + 1
%     vector2_phase_index = phase2RTPS_phase_index(vector2_phase) + 1
% 


% plot(sweep_reading(1, :), "o");
% sweep_reading_ang = angle(sweep_reading)*180/pi;

%plot(simulation_data(1:95, 1), "o");

disp(" ");
disp("Starting Calibration with kernel size of " + kernel_size);

next_state = "Start Calibration";
next_measurements = [];
next_choice = "";
current_measured_points = [];

while (next_state ~= "Finish Calibration")
    present_state = next_state;
    
    num_next_measurements = size(next_measurements, 1);
    if num_next_measurements ~= 0

        if (next_choice == "cartesian") || (next_choice == "")
             current_measured_points = zeros(num_next_measurements, 2);
        else
             current_measured_points = zeros(num_next_measurements, 3);
        end

        for i = 1:1:num_next_measurements
            current_measured_points(i, 1) = measure(next_measurements(i, :), next_choice, 1);
            current_measured_points(i, 2:end) = next_measurements(i, :);
        end
    end
    
    [next_measurements, next_choice, next_state] = Calibration_FSM(current_measured_points, present_state);
end

hold off

plot(Selected_Measurements(Starting_Gain_Index:Current_Calibration_Gain_Index, :), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "g");
hold on
plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
hold off
xlim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
ylim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
drawnow













%%
function [next_measurements, next_choice, next_state] = Calibration_FSM(current_measured_points, present_state)
global DC_offset L1 L2 phase1_offset phase2_offset num_target_phase_states num_target_gain_states Mapping Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states ...
    target_phase_states phase_error_criteria magnitude_scaling_factor phase_error_history Selected_Measurements Current_Point_Iteration_Count kernel_size original_kernel_size Starting_Gain_Index Ending_Gain_Index

% next_phases is a N by 2 matrix where N is the number of phases to measured next and the 2 columns are phase 1 and phase 2.
% current_measured_points is a N by 1 vector where N is the number of points in the current measurements.
% Calibration_State is a string that indicates the current calibration state.

switch present_state
    case "Start Calibration"
        next_state = "DC Offset Calibration";
        next_measurements = [0 0; pi/2 pi/2; pi pi; 3*pi/2 3*pi/2; pi/4 pi/4; 3*pi/4 3*pi/4; 5*pi/4 5*pi/4; 7*pi/4 7*pi/4];
        next_choice = "phases";
        




    case "DC Offset Calibration"
        %DC_offset = DC_offset_calibration(current_measured_points);
        DC_offset = 0;

        next_state = "Vector Length Calibration";
        
        phase_sweep = transpose(linspace(0.001, 2*pi*19/20 + 0.001, 20));
        phase_constant = zeros(20, 1);
        
        next_measurements(1:20, 1) = phase_constant + pi/4;
        next_measurements(1:20, 2) = phase_sweep;
        next_measurements(21:40, 1) = phase_constant + 3*pi/4;
        next_measurements(21:40, 2) = phase_sweep;
        next_measurements(41:60, 1) = phase_constant + 5*pi/4;
        next_measurements(41:60, 2) = phase_sweep;
        next_measurements(61:80, 1) = phase_constant + 7*pi/4;
        next_measurements(61:80, 2) = phase_sweep;

        next_measurements(81:100, 1) = phase_sweep;
        next_measurements(81:100, 2) = phase_constant + pi/4;
        next_measurements(101:120, 1) = phase_sweep;
        next_measurements(101:120, 2) = phase_constant + 3*pi/4;
        next_measurements(121:140, 1) = phase_sweep;
        next_measurements(121:140, 2) = phase_constant + 5*pi/4;
        next_measurements(141:160, 1) = phase_sweep;
        next_measurements(141:160, 2) = phase_constant + 7*pi/4;


        % next_measurements(1:20, 1) = phase_constant;
        % next_measurements(1:20, 2) = phase_sweep;
        % next_measurements(21:40, 1) = phase_constant + pi/2;
        % next_measurements(21:40, 2) = phase_sweep;
        % next_measurements(41:60, 1) = phase_constant + pi;
        % next_measurements(41:60, 2) = phase_sweep;
        % next_measurements(61:80, 1) = phase_constant + 3*pi/2;
        % next_measurements(61:80, 2) = phase_sweep;
        % 
        % next_measurements(81:100, 1) = phase_sweep;
        % next_measurements(81:100, 2) = phase_constant;
        % next_measurements(101:120, 1) = phase_sweep;
        % next_measurements(101:120, 2) = phase_constant + pi/2;
        % next_measurements(121:140, 1) = phase_sweep;
        % next_measurements(121:140, 2) = phase_constant + pi;
        % next_measurements(141:160, 1) = phase_sweep;
        % next_measurements(141:160, 2) = phase_constant + 3*pi/2;


        next_choice = "phases";
        




    case "Vector Length Calibration"

        %plot(current_measured_points(1:80, 1), "o");

        L2_1 = vector_length_calibration(current_measured_points(1:20, 1));
        L2_2 = vector_length_calibration(current_measured_points(21:40, 1));
        L2_3 = vector_length_calibration(current_measured_points(41:60, 1));
        L2_4 = vector_length_calibration(current_measured_points(61:80, 1));

        L1_1 = vector_length_calibration(current_measured_points(81:100, 1));
        L1_2 = vector_length_calibration(current_measured_points(101:120, 1));
        L1_3 = vector_length_calibration(current_measured_points(121:140, 1));
        L1_4 = vector_length_calibration(current_measured_points(141:160, 1));

        L_max = max([L2_1, L2_2, L2_3, L2_4, L1_1, L1_2, L1_3, L1_4]);
        magnitude_scaling_factor = 0.5/L_max;

        L2 = mean([L2_1 L2_2 L2_3 L2_4], "all") * magnitude_scaling_factor;
        L1 = mean([L1_1 L1_2 L1_3 L1_4], "all") * magnitude_scaling_factor;

        gain_resolution_calibration();

        next_state = "Phase Offset Calibration";

        next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
        next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
        next_choice = "polar";

        % scatter(real(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(1))), imag(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(1))));
        % hold on
        




    case "Phase Offset Calibration"
        [phase1_offset, phase2_offset] = phase_offset(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), current_measured_points(1,1));
%         scatter(real(current_measured_points(1,1)), imag(current_measured_points(1,1)));
%         hold on

        next_state = "Phase Offset Control";
        next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
        next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
        next_choice = "polar";





    case "Phase Offset Control"
        [phase1_error, phase2_error] = phase_offset(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), current_measured_points(1, 1));
        
        % plot(current_measured_points(1,1), "o");
        % hold on

        if abs(phase1_error) < phase_error_criteria && abs(phase2_error) < phase_error_criteria

            Mapping(Current_Calibration_Gain_Index, Current_Calibration_Phase_Index) = polar2code(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index), 1);

            next_state = "Next Target Point";
            %Current_Calibration_Phase_Index = Current_Calibration_Phase_Index + 1;
            next_measurements = next_kernel();
            next_choice = "polar";

            plot(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), 0, "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            plot_measurements(next_measurements, "polar");

        elseif (phase1_error == phase_error_history(1, 1)) && (phase2_error == phase_error_history(1, 2))
            if abs(phase1_error * phase2_error) > abs(phase_error_history(2, 1)) * abs(phase_error_history(2, 2))
                phase1_offset = phase_error_history(2, 3);
                phase2_offset = phase_error_history(2, 4);
            end
            next_state = "Next Target Point";
            next_measurements = next_kernel();
            next_choice = "polar";

            % plot(current_measured_points(1, 1), "*");
            % hold on
            plot(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            plot_measurements(next_measurements, "polar");

        elseif (phase1_error == phase_error_history(2, 1)) && (phase2_error == phase_error_history(2, 2))
            if abs(phase1_error * phase2_error) > abs(phase_error_history(1, 1)) * abs(phase_error_history(1, 2))
                phase1_offset = phase_error_history(1, 3);
                phase2_offset = phase_error_history(1, 4);
            end
            next_state = "Next Target Point";
            next_measurements = next_kernel();
            next_choice = "polar";

            plot(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            plot_measurements(next_measurements, "polar");
        else
            next_state = "Phase Offset Control";
            phase1_offset = phase1_offset + phase1_error;
            phase2_offset = phase2_offset + phase2_error;
            next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
            next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
            next_choice = "polar";
        end

        phase_error_history(2, :) = phase_error_history(1, :);
        phase_error_history(1, :) =  [phase1_error, phase2_error, phase1_offset, phase2_offset];
        
        




    case "Next Target Point"
        % polar2code(0.4121,0.8356, 1);
        % polar2code(0.462908,0.906156, 1);

        % phase1_offset = 0;
        % phase2_offset = 0;

        Current_Point_Iteration_Count = Current_Point_Iteration_Count + 1;

        plot(current_measured_points(:, 1), "X", "LineWidth", 1.5, "MarkerSize", 10, "Color", "r");
        hold on
        filtered_measurements = filter_measurements(current_measured_points);

        if Current_Calibration_Gain_Index > Starting_Gain_Index
            plot(Selected_Measurements(Starting_Gain_Index:Current_Calibration_Gain_Index - 1, :), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "g");
            hold on
        end
        plot(Selected_Measurements(Current_Calibration_Gain_Index, 1:Current_Calibration_Phase_Index - 1), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "g");
        xlim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
        ylim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
        drawnow
        hold on

        closest_measured_point = find_closest_measurement(current_measured_points);

        [phase1_error, phase2_error] = phase_offset(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), closest_measured_point(1, 1));
        
        if abs(phase1_error) < phase_error_criteria*0.4 && abs(phase2_error) < phase_error_criteria*0.4
            valid = 1;
        else
            valid = measurement_validation(filtered_measurements(:, 1));
        end

        if valid
            Current_Point_Iteration_Count = 0;
            kernel_size = original_kernel_size;

            plot(polar2cartesian(closest_measured_point(1, 2), closest_measured_point(1, 3)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "r");
            hold on
            Selected_Measurements(Current_Calibration_Gain_Index, Current_Calibration_Phase_Index) = closest_measured_point(1, 1);
            plot(closest_measured_point(1, 1), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "g");
            xlim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
            ylim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
            drawnow
            hold off
            Mapping(Current_Calibration_Gain_Index, Current_Calibration_Phase_Index) = polar2code(closest_measured_point(2), closest_measured_point(3), 1);
            
            if Current_Calibration_Phase_Index == num_target_phase_states

                circle_report();

                if Current_Calibration_Gain_Index == Ending_Gain_Index
                    next_state = "Finish Calibration";
                    next_measurements = [];
                    next_choice = "";
                else
                    Current_Calibration_Gain_Index = Current_Calibration_Gain_Index + 1;
                    Current_Calibration_Phase_Index = 1;
                    
                    next_state = "Phase Offset Calibration";
                    next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
                    next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
                    next_choice = "polar";
                end
            else

                next_state = "Next Target Point";
                Current_Calibration_Phase_Index = Current_Calibration_Phase_Index + 1;
                next_measurements = next_kernel();
                next_choice = "polar";
            end
        else
            hold off

            % next_state = "Phase Offset Calibration";
            % next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
            % next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
            % next_choice = "polar";

            next_state = "Next Target Point";

            if Current_Point_Iteration_Count > 4
                kernel_size = kernel_size + 4;
                Current_Point_Iteration_Count = 0;
            end

            next_measurements = next_supporting_kernel(filtered_measurements);
            next_choice = "polar";
        end

        plot(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
        hold on
        plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
        plot_measurements(next_measurements, "polar");


    otherwise
end


end


















%%
function DC_offset = DC_offset_calibration(measurements)
    DC_offset = mean(measurements, 1);
end





function L = vector_length_calibration(measured_points)
% measured_phase2_acute = 2*pi - measured_phase2;
%
% L1 = zero_degree_side_length*sin(measured_phase2_acute)/sin(pi-measured_phase1-measured_phase2_acute);
% L2 = zero_degree_side_length*sin(measured_phase1)/sin(pi-measured_phase1-measured_phase2_acute);
center = mean(measured_points, "all");
number_of_points = size(measured_points, 1);
radius = zeros(number_of_points, 1);

for i = 1:1:number_of_points
    radius(i, 1) = abs(measured_points(i, 1) - center);
end

L = mean(radius, "all");
end





function [phase1_offset, phase2_offset] = phase_offset(ideal_point, measured_point)
[ideal_phase1, ideal_phase2] = cartesian2phases(ideal_point);
[measured_phase1, measured_phase2] = cartesian2phases(measured_point);
phase1_offset = measured_phase1 - ideal_phase1;
phase2_offset = measured_phase2 - ideal_phase2;

if phase1_offset > pi
    phase1_offset = phase1_offset - 2*pi;
elseif phase1_offset < -1*pi
    phase1_offset = phase1_offset + 2*pi;
end

if phase2_offset > pi
    phase2_offset = phase2_offset - 2*pi;
elseif phase2_offset < -1*pi
    phase2_offset = phase2_offset + 2*pi;
end

end





function next_polar = next_kernel()
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index kernel_size RTPS_phase_resolution RTPS_gain_resolution_dB target_gain_states_dB ...
    target_phase_states lowest_detectable_gain_dB lowest_detectable_gain RTPS_gain_resolution

k = 0;
for gain = 1:1:kernel_size
    for angle = 1:1:kernel_size
        %next_gain_dB = target_gain_states_dB(Current_Calibration_Gain_Index) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
        next_gain = 10^(target_gain_states_dB(Current_Calibration_Gain_Index)/10) + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
        next_angle = wrap22pi(target_phase_states(Current_Calibration_Phase_Index) + RTPS_phase_resolution * (angle - (kernel_size + 1)/2));
        
        if (next_gain >= lowest_detectable_gain) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
            k = k + 1;
        end
    end
end

next_polar = zeros(k, 2);


k = 1;
for gain = 1:1:kernel_size
    for angle = 1:1:kernel_size
        %next_gain_dB = target_gain_states_dB(Current_Calibration_Gain_Index) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
        next_gain = 10^(target_gain_states_dB(Current_Calibration_Gain_Index)/10) + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
        next_angle = wrap22pi(target_phase_states(Current_Calibration_Phase_Index) + RTPS_phase_resolution * (angle - (kernel_size + 1)/2));
        
        if (next_gain >= lowest_detectable_gain) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
            %next_polar(k, 1) = 10^(next_gain_dB/10);
            next_polar(k, 1) = next_gain;
            next_polar(k, 2) = next_angle;
            k = k + 1;
        end
    end
end

end





function [phase1, phase2] = cartesian2phases(point)
global L1 L2
X = real(point);
Y = imag(point);

% first_term = (L1^2 + X^2 + Y^2 - L2^2)/(2*L1*sqrt(X^2 + Y^2));
% second_term = X/(sqrt(X^2 + Y^2));

if Y >= 0
    phase1 = acos((L1^2 + X^2 + Y^2 - L2^2)/(2*L1*sqrt(X^2 + Y^2))) + acos(X/(sqrt(X^2 + Y^2)));
    phase2 = -1 * (pi - acos((L1^2 - X^2 - Y^2 + L2^2)/(2*L1*L2)) - phase1);
else
    phase1 = pi + acos((L1^2 + X^2 + Y^2 - L2^2)/(2*L1*sqrt(X^2 + Y^2))) + acos(-1 * X/(sqrt(X^2 + Y^2)));
    phase2 = pi + (-1 * (pi - acos((L1^2 - X^2 - Y^2 + L2^2)/(2*L1*L2)) - phase1 + pi));
end

phase1 = wrap22pi(phase1);
phase2 = wrap22pi(phase2);
end





function point = polar2cartesian(radius, phase)
point = radius*cos(phase) + 1i * radius*sin(phase);
end





function phase = wrap22pi(phase)
if phase < 0
    phase = phase + 2*pi;
elseif phase > 2*pi
    phase = phase - 2*pi;
end
end





function codeword = polar2code(gain, phase, MODE)
global DC_offset phase1_offset phase2_offset magnitude_scaling_factor

uncompensated_target_point = polar2cartesian(gain, phase);
target_point = DC_offset_compensation(uncompensated_target_point, DC_offset, magnitude_scaling_factor);
[uncompensated_vector1_phase, uncompensated_vector2_phase] = cartesian2phases(target_point);
[vector1_phase, vector2_phase] = phase_offset_compensation(uncompensated_vector1_phase, uncompensated_vector2_phase, phase1_offset, phase2_offset);

% plot(L1*cos(vector1_phase) + L2*cos(vector2_phase) + 1i*L1*sin(vector1_phase) + 1i*L2*sin(vector2_phase), 'o');
% hold on

codeword = vectors2code(vector1_phase, vector2_phase, MODE);
end





function [b, a] = swap(a, b)
end





function index = phase2RTPS_phase_index(phase)
    global num_RTPS_phase_states RTPS_phase_resolution
    
    achievable_phase = linspace(0, 2*pi - RTPS_phase_resolution, num_RTPS_phase_states);
    phase_distance = abs(achievable_phase - phase);
    index = find(phase_distance == min(phase_distance)) - 1;
    
    if length(index) > 1
        index = index(end);
    end
end





function [c0, c1, c2, c3] = phase2code(phase)
global num_RTPS_phase_states RTPS_phase_resolution

phase_code = phase2RTPS_phase_index(phase);

if phase_code <= 15
    section_number = 1;
elseif phase_code <= 30
    section_number = 2;
elseif phase_code <= 45
    section_number = 3;
elseif phase_code <= 60
    section_number = 4;
elseif phase_code <= 75
    section_number = 5;
elseif phase_code <= 90
    section_number = 6;
end

RTPS_phase_code = phase_code - (section_number - 1)*15;


switch section_number
    case 1
        c0 = RTPS_phase_code;
        c1 = 0;
        c2 = 0;
        c3 = 1;
    case 2
        c0 = RTPS_phase_code;
        c1 = 15;
        c2 = 0;
        c3 = 1;
    case 3
        c0 = RTPS_phase_code;
        c1 = 15;
        c2 = 15;
        c3 = 1;
    case 4
        c0 = RTPS_phase_code;
        c1 = 0;
        c2 = 0;
        c3 = 2;
    case 5
        c0 = RTPS_phase_code;
        c1 = 15;
        c2 = 0;
        c3 = 2;
    case 6
        c0 = RTPS_phase_code;
        c1 = 15;
        c2 = 15;
        c3 = 2;
    otherwise
        c0 = 0;
        c1 = 0;
        c2 = 0;
        c3 = 1;
end
end





function codeword = vectors2code(vector1_phase, vector2_phase, MODE)
    [c0, c1, c2, c3] = phase2code(vector1_phase);
    [c4, c5, c6, c7] = phase2code(vector2_phase);
    
    switch MODE
        case 2
            [c4, c5] = swap(c4, c5);
        case 3
            [c4, c6] = swap(c4, c6);
        case 4
            [c0, c1] = swap(c0, c1);
        case 5
            [c0, c1] = swap(c0, c1);
            [c4, c5] = swap(c4, c5);
        case 6
            [c0, c1] = swap(c0, c1);
            [c4, c6] = swap(c4, c6);
        case 7
            [c0, c2] = swap(c0, c2);
        case 8
            [c0, c2] = swap(c0, c2);
            [c4, c5] = swap(c4, c5);
        case 9
            [c0, c2] = swap(c0, c2);
            [c4, c6] = swap(c4, c6);
        otherwise
    end
    
    codeword_inSequence_bin = strcat(dec2bin(c0, 4), dec2bin(c1, 4), dec2bin(c2, 4), dec2bin(c3, 2), dec2bin(c4, 4), dec2bin(c5, 4), dec2bin(c6, 4), dec2bin(c7, 2));
    codeword = bin2dec(flip(codeword_inSequence_bin));
end





function codeword = single_vector2code(vector1_phase, MODE)
    [c0, c1, c2, c3] = phase2code(vector1_phase);
    
    switch MODE
        case 2
            [c0, c1] = swap(c0, c1);
        case 3
            [c0, c2] = swap(c0, c2);
        otherwise
    end
    
    codeword_inSequence_bin = strcat(dec2bin(c0, 4), dec2bin(c1, 4), dec2bin(c2, 4), dec2bin(c3, 2));
    codeword = bin2dec(flip(codeword_inSequence_bin));
end





function compensated_point = DC_offset_compensation(point, DC_offset, magnitude_scaling_factor)
    compensated_point = point - DC_offset * magnitude_scaling_factor;
end





function [compensated_vector1, compensated_vector2] = phase_offset_compensation(vector1, vector2, phase1_offset, phase2_offset)
    compensated_vector1 = wrap22pi(vector1 - phase1_offset);
    compensated_vector2 = wrap22pi(vector2 - phase2_offset);
end





function reading = measure(next, choice, MODE)
global DC_offset phase1_offset phase2_offset magnitude_scaling_factor Measurements measurement_counter total_measurement_counter

    if size(next, 1) == 0
        reading = [];

    elseif choice == "phases"
        vector1_phase = wrap22pi(next(1));
        vector2_phase = wrap22pi(next(2));

    elseif choice == "polar"
        uncompensated_target_point = polar2cartesian(next(1), next(2));
        target_point = DC_offset_compensation(uncompensated_target_point, DC_offset, magnitude_scaling_factor);
        [uncompensated_vector1_phase, uncompensated_vector2_phase] = cartesian2phases(target_point);
        [vector1_phase, vector2_phase] = phase_offset_compensation(uncompensated_vector1_phase, uncompensated_vector2_phase, phase1_offset, phase2_offset);

        %show_codeword(codeword);
    elseif choice == "cartesian"
        target_point = DC_offset_compensation(next, DC_offset, magnitude_scaling_factor);
        [uncompensated_vector1_phase, uncompensated_vector2_phase] = cartesian2phases(target_point);
        [vector1_phase, vector2_phase] = phase_offset_compensation(uncompensated_vector1_phase, uncompensated_vector2_phase, phase1_offset, phase2_offset);
        
    else
        disp("Error: Invalid choise of measurement");
    end

    vector1_phase_index = phase2RTPS_phase_index(vector1_phase) + 1;
    vector2_phase_index = phase2RTPS_phase_index(vector2_phase) + 1;

    previous_measurement = Measurements(vector1_phase_index, vector2_phase_index, MODE);
    
    if previous_measurement == 1234
        codeword = vectors2code(vector1_phase, vector2_phase, MODE);
        reading = SIMULATION_READ(codeword);
        Measurements(vector1_phase_index, vector2_phase_index, MODE) = reading;
        measurement_counter = measurement_counter + 1;
        total_measurement_counter = total_measurement_counter + 1;
    else
        reading = previous_measurement;
    end
end





function reading = OUTPHASER_READ(codeword)
    global S_dd21

    codeword_inSequence_bin = flip(dec2bin(codeword, 28));
    codeword1 = codeword_inSequence_bin(1:14);
    codeword2 = codeword_inSequence_bin(15:28);

    vector1_address = bin2dec(flip(codeword1(1:12))) + 1;
    if codeword1(13:14) == "10"
        vector1_address = vector1_address + 4096;
    end

    vector2_address = bin2dec(flip(codeword2(1:12))) + 1;
    if codeword2(13:14) == "10"
        vector2_address = vector2_address + 4096;
    end

    vector1_reading = S_dd21(vector1_address, 161);
    vector2_reading = S_dd21(vector2_address, 161);

    if abs(vector1_reading)<0.3
        vector1_reading = vector1_reading/abs(vector1_reading)*0.35;
    end
    if abs(vector2_reading)<0.3
        vector2_reading = vector2_reading/abs(vector2_reading)*0.35;
    end

    reading = 0.5*(vector1_reading + vector2_reading);

    reading = reading * 2;
end




function reading = RTPS_READ(codeword)
    global S_dd21

    codeword_inSequence_bin = flip(dec2bin(codeword, 14));

    vector1_address = bin2dec(flip(codeword_inSequence_bin(1:12))) + 1;

    if codeword_inSequence_bin(13:14) == "10"
        vector1_address = vector1_address + 4096;
    end

    reading = S_dd21(vector1_address, 161);
    
    if abs(reading)<0.3
        reading = reading/abs(reading)*0.35;
    end
end





function reading = RTPS_READ_FAKE(codeword)
global RTPS_phase_resolution

    codeword_inSequence_bin = flip(dec2bin(codeword, 14));

    c0 = bin2dec(codeword_inSequence_bin(1:4));
    c1 = bin2dec(codeword_inSequence_bin(5:8));
    c2 = bin2dec(codeword_inSequence_bin(9:12));

    phase = (c0 + c1 + c2)*RTPS_phase_resolution;

    if codeword_inSequence_bin(13:14) == "10"
        phase = phase + pi;
    end

    reading = 0.5*cos(phase) + 1i*0.5*sin(phase);
end





function reading = SIMULATION_READ(codeword)
    global simulation_data magnitude_scaling_factor

    codeword_inSequence_bin = flip(dec2bin(codeword, 28));
    codeword1 = codeword_inSequence_bin(1:14);
    codeword2 = codeword_inSequence_bin(15:28);

    c0 = bin2dec(codeword1(1:4));
    c1 = bin2dec(codeword1(5:8));
    c2 = bin2dec(codeword1(9:12));
    c3 = bin2dec(codeword1(13:14));

    c4 = bin2dec(codeword2(1:4));
    c5 = bin2dec(codeword2(5:8));
    c6 = bin2dec(codeword2(9:12));
    c7 = bin2dec(codeword2(13:14));

    if (c1 == 0) && (c2 == 0)
        index1 = c0;
    elseif (c1 == 15) && (c2 == 0)
        index1 = c0 + 16;
    elseif (c1 == 15) && (c2 == 15)
        index1 = c0 + 32;
    end

    if c3 == 2
        index1 = index1 + 48;
    end

    if (c5 == 0) && (c6 == 0)
        index2 = c4;
    elseif (c5 == 15) && (c6 == 0)
        index2 = c4 + 16;
    elseif (c5 == 15) && (c6 == 15)
        index2 = c4 + 32;
    end

    if c7 == 2
        index2 = index2 + 48;
    end

    index = index1 + 1 + (index2 * 95);

    reading = simulation_data(index, 1) * magnitude_scaling_factor;
end




function show_codeword(codeword)
    codeword_inSequence_bin = flip(dec2bin(codeword, 28));
    codeword1 = codeword_inSequence_bin(1:14);
    codeword2 = codeword_inSequence_bin(15:28);

    c0 = bin2dec(codeword1(1:4));
    c1 = bin2dec(codeword1(5:8));
    c2 = bin2dec(codeword1(9:12));
    c3 = bin2dec(codeword1(13:14));

    c4 = bin2dec(codeword2(1:4));
    c5 = bin2dec(codeword2(5:8));
    c6 = bin2dec(codeword2(9:12));
    c7 = bin2dec(codeword2(13:14));

    disp([c0 c1 c2 c3 c4 c5 c6 c7]);
end





function point = phase2cartesian(phase1, phase2)
global L1 L2
    point = L1*cos(phase1) + L2*cos(phase2) + 1i*(L1*sin(phase1) + L2*sin(phase2));
end





function plot_measurements(next, choice)
global DC_offset phase1_offset phase2_offset magnitude_scaling_factor Measurements

num_next = size(next, 1);
points = zeros(num_next, 1);

    if num_next == 0

    elseif choice == "phases"
        for k = 1:1:num_next
            points(k, 1) = phase2cartesian(next(k, 1), next(k, 2));
        end

    elseif choice == "polar"
        for k = 1:1:num_next
            points(k, 1) = polar2cartesian(next(k, 1), next(k, 2));
        end

        %show_codeword(codeword);
    elseif choice == "cartesian"
        
    else
        disp("Error: Invalid choise of measurement");
    end

    plot(points, "O", "LineWidth", 1.5, "MarkerSize", 10, "Color", [0 0.4470 0.7410]);
    
    hold on

end





function double_filtered_points = filter_measurements(current_measured_points)
global filter_tolerance

    distance = zeros(size(current_measured_points, 1), 1);
    for k = 1:1:size(current_measured_points, 1)
        distance(k, 1) = abs(current_measured_points(k, 1) - polar2cartesian(current_measured_points(k, 2), current_measured_points(k, 3)));
    end

    % points = current_measured_points(:, 1);
    % center = mean(points);
    % distance = abs(points - center);

    mean_distance = mean(distance, "all");

    outlier_indexes = find(distance > filter_tolerance * mean_distance);

    filtered_points = zeros(size(current_measured_points, 1) - size(outlier_indexes, 1), 3);

    j = 1;

    for k = 1:1:size(current_measured_points, 1)
        if ~ismember(k, outlier_indexes)
            filtered_points(j, :) = current_measured_points(k, :);
            j = j + 1;
        end
    end


    mean_data = mean(filtered_points(:, 1), "all");
    center_distance = abs(filtered_points(:, 1) - mean_data);
    mean_distance = mean(center_distance, "all");

    double_outlier_indexes = find(center_distance > filter_tolerance * mean_distance);

    double_filtered_points = zeros(size(filtered_points, 1) - size(double_outlier_indexes, 1), 3);

    j = 1;

    for k = 1:1:size(filtered_points, 1)
        if ~ismember(k, double_outlier_indexes)
            double_filtered_points(j, :) = filtered_points(k, :);
            j = j + 1;
        end
    end

    % plot(current_measured_points(:, 1), "O");
    % hold on
    % plot(filtered_points(:, 1), "X");
    % hold on
end




function valid = measurement_validation(measurement_points)
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states target_phase_states
    % num_measurement_points = size(measurement_points, 1);
    % 
    % if num_measurement_points < 4
    %     valid = 0;
    % else
    %     upper = imag(measurement_points(1, 1));
    %     lower = upper;
    %     left = real(measurement_points(1, 1));
    %     right = left;
    % 
    %     for k = 2:1:num_measurement_points
    %         if imag(measurement_points(k, 1)) > upper
    %             upper = imag(measurement_points(k, 1));
    %         elseif imag(measurement_points(k, 1)) < lower
    %             lower = imag(measurement_points(k, 1));
    %         end
    % 
    %         if real(measurement_points(k, 1)) < left
    %             left = real(measurement_points(k, 1));
    %         elseif real(measurement_points(k, 1)) > right
    %             right = real(measurement_points(k, 1));
    %         end
    %     end
    % 
    %     target_point = polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index));
    % 
    %     if (imag(target_point) >= lower) && (imag(target_point) <= upper) && (real(target_point) >= left) && (real(target_point) <= right)
    %         valid = 1;
    %     else
    %         valid = 0;
    %     end
    % end

    target_point = polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index));

    X = real(measurement_points);
    Y = imag(measurement_points);
    boundary_index = boundary(X, Y);
    num_boundary_index = size(boundary_index, 1);

    boundary_X = zeros(num_boundary_index, 1);
    boundary_Y = zeros(num_boundary_index, 1);

    for k = 1:1:num_boundary_index
        boundary_X(k, 1) = X(boundary_index(k, 1), 1);
        boundary_Y(k, 1) = Y(boundary_index(k, 1), 1);
    end

    valid = inpolygon(real(target_point), imag(target_point), boundary_X, boundary_Y);
end





function  closest_measured_point = find_closest_measurement(current_measured_points)
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states target_phase_states
    target_point = polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index));
    distance = abs(current_measured_points(:, 1) - target_point);
    index = distance == min(distance);
    closest_measured_point = current_measured_points(index, :);
end





function plot_gain_circle(gain)
    x0=0;
    y0=0;
    syms x y
    fimplicit((x-x0).^2 + (y-y0).^2 -gain^2, "Color", "k")
    
    hold on
    axis equal
end





function next_polar = next_supporting_kernel(filtered_measurements)
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index kernel_size RTPS_phase_resolution RTPS_gain_resolution_dB target_phase_states lowest_detectable_gain_dB target_gain_states...
    RTPS_gain_resolution lowest_detectable_gain
    
    error_vector_sum = 0;

    for k = 1:1:size(filtered_measurements, 1)
        error_vector_sum = error_vector_sum + filtered_measurements(k, 1) - polar2cartesian(filtered_measurements(k, 2), filtered_measurements(k, 3));
    end

    average_error_vector = error_vector_sum/size(filtered_measurements, 1);

    new_target_point = polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)) - average_error_vector;

    [new_target_gain, new_target_phase] = cartesian2polar(new_target_point);
    
    k = 0;
    for gain = 1:1:kernel_size
        for angle = 1:1:kernel_size
            %next_gain_dB = 10*log10(new_target_gain) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
            next_gain = new_target_gain + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
            next_angle = new_target_phase + RTPS_phase_resolution * (angle - (kernel_size + 1)/2);

            
            if (next_gain >= lowest_detectable_gain) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
                k = k + 1;
            end
        end
    end
    
    next_polar = zeros(k, 2);
    
    
    k = 1;
    for gain = 1:1:kernel_size
        for angle = 1:1:kernel_size
            %next_gain_dB = 10*log10(new_target_gain) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
            next_gain = new_target_gain + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
            next_angle = new_target_phase + RTPS_phase_resolution * (angle - (kernel_size + 1)/2);

            
            if (next_gain >= lowest_detectable_gain) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
                %next_polar(k, 1) = 10^(next_gain_dB/10);
                next_polar(k, 1) = next_gain;
                next_polar(k, 2) = next_angle;
                k = k + 1;
            end
        end
    end

end





function [gain, phase] = cartesian2polar(point)
    gain = abs(point);
    phase = wrap22pi(angle(point));
end





function circle_report()
global Current_Calibration_Gain_Index target_gain_states target_gain_states_dB target_phase_states Selected_Measurements measurement_counter total_measurement_counter Ending_Gain_Index Starting_Gain_Index

    actual_phase = angle(Selected_Measurements(Current_Calibration_Gain_Index, :));
    
    for i = round(size(actual_phase, 2)/3) : 1 : size(actual_phase, 2)
        actual_phase(1, i) = wrap22pi(actual_phase(1, i));
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





function gain_resolution_calibration()
global RTPS_phase_states num_RTPS_phase_states gain_resolution L1 L2

data = zeros(1, num_RTPS_phase_states*num_RTPS_phase_states);

L = (L1 + L2)/2;

% figure
for i = 1:1:num_RTPS_phase_states
    for j = 1:1:num_RTPS_phase_states
     data((i-1)*num_RTPS_phase_states + j) = L*cos(RTPS_phase_states(i)) + L*cos(RTPS_phase_states(j)) + 1i*(L*sin(RTPS_phase_states(i)) + L*sin(RTPS_phase_states(j)));
%      plot(data((i-1)*num_RTPS_phase_states + j), "O");
%      hold on
    end
end
% hold off

index = find(abs(imag(data)) < 0.05);
gains = unique(sort(abs(data(index))));

index = find(gains > 0.001);
gains = unique(round(gains(index)*10^4)/10^4);

gain_resolution = zeros(2, size(gains,2) - 1);

for i = 1:1:size(gains, 2) - 1
    gain_resolution(1, i) = gains(i);
    gain_resolution(2, i) = gains(i + 1) - gains(i);
end

% figure
% plot(gain_resolution(1, :), gain_resolution(2, :));

end