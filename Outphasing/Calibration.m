global DC_offset L1 L2 phase1_offset phase2_offset num_target_gain_states num_target_phase_states num_RTPS_gain_states num_RTPS_phase_states Measurements Mapping Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states ...
    target_phase_states RTPS_gain_states RTPS_phase_states num_MODES phase_error_criteria kernel_size target_phase_resolution RTPS_phase_resolution S_dd21 simulation_data_mode1 magnitude_scaling_factor last_phase1_error last_phase2_error target_gain_resolution_dB ...
    RTPS_gain_resolution_dB lowest_detectable_gain_dB lowest_detectable_gain target_gain_states_dB phase_error_history RTPS_gain_resolution Selected_Measurements Current_Point_Iteration_Count original_kernel_size filter_tolerance Starting_Gain_Index Ending_Gain_Index...
    measurement_counter total_measurement_counter simulation_data_mode2 simulation_data_mode3 original_RTPS_phase_resolution original_RTPS_gain_resolution kernel_offset...
    VALIDATION num_hit total_num_hit phase_error_sum gain_error_sum


%%
VALIDATION = 0;
PLOT_TARGET_POINTS = 1;
num_hit = 0;
total_num_hit = 0;



%%
kernel_size = 1;
lowest_detectable_gain_dB = -8;

Starting_Gain_Index = 1;
Ending_Gain_Index = 8;

filter_tolerance = 1;


%%

% load("./RTPSdata/sp/Sp.mat", "S_dd21");
load("simulation_data_mode1.mat");
load("simulation_data_mode2.mat");
load("simulation_data_mode3.mat");
%load('gain_resolution.mat');

DC_offset = 0;
phase1_offset = 0;
phase2_offset = 0;
L1 = 0.5;
L2 = 0.5;
magnitude_scaling_factor = 1;

kernel_offset = 0;

lowest_detectable_gain = 10^(lowest_detectable_gain_dB/20);

phase_error_sum = 0;
gain_error_sum = 0;

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

num_MODES = 1;

original_kernel_size = kernel_size;
original_RTPS_phase_resolution = RTPS_phase_resolution;
original_RTPS_gain_resolution = RTPS_gain_resolution;

Measurements = zeros(num_RTPS_phase_states, num_RTPS_phase_states, num_MODES) + 1234;
%Measurements_code = zeros(2, num_RTPS_phase_states^2*num_MODES);
Mapping = zeros(num_target_gain_states, num_target_phase_states);

Selected_Measurements = zeros(num_target_gain_states, num_target_phase_states);

target_gain_states_dB = linspace(-1*(num_target_gain_states - 1), 0, num_target_gain_states);
target_gain_states = 10.^(target_gain_states_dB./20);
target_phase_states = linspace(0, 2*pi - target_phase_resolution, num_target_phase_states);

RTPS_gain_states_dB = linspace(-1*(num_target_gain_states - 1), 0, num_RTPS_gain_states);
RTPS_gain_states = 10.^(RTPS_gain_states_dB./20);
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



figure;
set(gcf, 'Position',  [900, 300, 1000, 800]);
%movegui(gcf,'center');

disp(" ");
disp("Starting Calibration with kernel size of " + kernel_size);

next_state = "Start Calibration";
next_measurements = [];
next_choice = "";
current_measured_points = [];

while (next_state ~= "Finish Calibration")
    present_state = next_state;
    
    num_next_measurements = size(next_measurements, 1);
    if present_state == "Fine Tune Current Point"
        current_measured_points = zeros(num_MODES*2, 4);
        for i = 1:1:num_MODES
            current_measured_points(2*i - 1, 1) = measurementClass.measure(next_measurements, next_choice, i, 1);
            current_measured_points(2*i - 1, 2:(end-1)) = next_measurements;
            current_measured_points(2*i - 1, end) = 1;

            current_measured_points(2*i, 1) = measurementClass.measure(next_measurements, next_choice, i, 2);
            current_measured_points(2*i, 2:(end-1)) = next_measurements;
            current_measured_points(2*i, end) = 2;
        end
    elseif num_next_measurements ~= 0

        % if (next_choice == "cartesian") || (next_choice == "")
        %      current_measured_points = zeros(num_next_measurements, 2);
        % else
        %      current_measured_points = zeros(num_next_measurements, 3);
        % end
        % 
        % for i = 1:1:num_next_measurements
        %     current_measured_points(i, 1) = measurementClass.measure(next_measurements(i, :), next_choice, 1, 1);
        %     current_measured_points(i, 2:end) = next_measurements(i, :);
        % end

        if (next_choice == "cartesian") || (next_choice == "")
             current_measured_points = zeros(num_next_measurements*2, 3);
        elseif next_choice == "polar"
             current_measured_points = zeros(num_next_measurements*2, 4);
        else
            current_measured_points = zeros(num_next_measurements, 4);
        end
        
        if next_choice == "phases"
            for i = 1:1:num_next_measurements
                current_measured_points(i, 1) = measurementClass.measure(next_measurements(i, :), next_choice, 1, 1);
                current_measured_points(i, 2:(end-1)) = next_measurements(i, :);
                current_measured_points(i, end) = 1;
            end
        else
            for i = 1:1:num_next_measurements
                current_measured_points(2*i - 1, 1) = measurementClass.measure(next_measurements(i, :), next_choice, 1, 1);
                current_measured_points(2*i - 1, 2:(end-1)) = next_measurements(i, :);
                current_measured_points(2*i - 1, end) = 1;

                current_measured_points(2*i, 1) = measurementClass.measure(next_measurements(i, :), next_choice, 1, 2);
                current_measured_points(2*i, 2:(end-1)) = next_measurements(i, :);
                current_measured_points(2*i, end) = 2;
            end
        end
    end
    
    [next_measurements, next_choice, next_state] = Calibration_FSM(current_measured_points, present_state);
end

hold off

if PLOT_TARGET_POINTS
    for i = Starting_Gain_Index:1:Ending_Gain_Index
        for j = 1:1:num_target_phase_states
            plot(conversionClass.polar2cartesian(target_gain_states(i), target_phase_states(j))+0.000001*1i, "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
        end
    end
end

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
    target_phase_states phase_error_criteria magnitude_scaling_factor phase_error_history Selected_Measurements Current_Point_Iteration_Count kernel_size original_kernel_size Starting_Gain_Index Ending_Gain_Index...
    RTPS_phase_resolution original_RTPS_phase_resolution original_RTPS_gain_resolution RTPS_gain_resolution kernel_offset VALIDATION num_hit total_num_hit total_measurement_counter

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

        %gain_resolution_calibration();

        next_state = "Phase Offset Calibration";

        next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
        next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
        next_choice = "polar";

        % scatter(real(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(1))), imag(polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(1))));
        % hold on
        




    case "Phase Offset Calibration"
        [phase1_offset, phase2_offset] = phase_offset(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), current_measured_points(1,1));
%         scatter(real(current_measured_points(1,1)), imag(current_measured_points(1,1)));
%         hold on

        next_state = "Phase Offset Control";
        next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
        next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
        next_choice = "polar";





    case "Phase Offset Control"
        [phase1_error, phase2_error] = phase_offset(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), current_measured_points(1, 1));
        
        % plot(current_measured_points(1,1), "o");
        % hold on

        if abs(phase1_error) < phase_error_criteria && abs(phase2_error) < phase_error_criteria

            %Mapping(Current_Calibration_Gain_Index, Current_Calibration_Phase_Index) = conversionClass.polar2code(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index), 1);

            next_state = "Next Target Point";
            %Current_Calibration_Phase_Index = Current_Calibration_Phase_Index + 1;
            next_measurements = next_kernel();
            next_choice = "polar";

            plot(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), 0, "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            measurementClass.plot_measurements(next_measurements, "polar");

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
            plot(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            measurementClass.plot_measurements(next_measurements, "polar");

        elseif (phase1_error == phase_error_history(2, 1)) && (phase2_error == phase_error_history(2, 2))
            if abs(phase1_error * phase2_error) > abs(phase_error_history(1, 1)) * abs(phase_error_history(1, 2))
                phase1_offset = phase_error_history(1, 3);
                phase2_offset = phase_error_history(1, 4);
            end
            next_state = "Next Target Point";
            next_measurements = next_kernel();
            next_choice = "polar";

            plot(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            measurementClass.plot_measurements(next_measurements, "polar");
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
        filtered_measurements = measurementClass.filter_measurements(current_measured_points);

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

        [phase1_error, phase2_error] = phase_offset(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)), closest_measured_point(1, 1));


        if VALIDATION
            if abs(phase1_error) < phase_error_criteria*0.4 && abs(phase2_error) < phase_error_criteria*0.4
                valid = 1;
            else
                valid = measurementClass.measurement_validation(filtered_measurements(:, 1));
            end
        else
            valid = 1;

            if abs(phase1_error) < phase_error_criteria*0.4 && abs(phase2_error) < phase_error_criteria*0.4
                num_hit = num_hit + 1;
                total_num_hit = total_num_hit + 1;
            end
        end


        if valid
            kernel_offset = 0;
            Current_Point_Iteration_Count = 0;
            kernel_size = original_kernel_size;
            % RTPS_phase_resolution = original_RTPS_phase_resolution;
            % RTPS_gain_resolution = original_RTPS_gain_resolution;

            plot(conversionClass.polar2cartesian(closest_measured_point(1, 2), closest_measured_point(1, 3)), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "r");
            hold on
            plot(closest_measured_point(1, 1), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0.9290, 0.6940, 0.1250]);
            xlim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
            ylim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
            drawnow
            hold on
            
            next_state = "Fine Tune Current Point";
            next_measurements = [closest_measured_point(1, 2) closest_measured_point(1, 3)];
            next_choice = "polar";
        else
            hold off

            % next_state = "Phase Offset Calibration";
            % next_measurements(1, 1) = target_gain_states(Current_Calibration_Gain_Index);
            % next_measurements(1, 2) = target_phase_states(Current_Calibration_Phase_Index);
            % next_choice = "polar";

            next_state = "Next Target Point";

            if Current_Point_Iteration_Count > 4
                kernel_size = kernel_size + 4;
                % kernel_size = kernel_size*4 + 1;
                % RTPS_phase_resolution = RTPS_phase_resolution/1.5;
                % RTPS_gain_resolution = RTPS_gain_resolution/1.5;
                Current_Point_Iteration_Count = 0;
            end

            next_measurements = next_supporting_kernel(filtered_measurements);
            next_choice = "polar";

            plot(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index))+0.000001*1i, "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
            hold on
            plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
            measurementClass.plot_measurements(next_measurements, "polar");
        end







    case "Fine Tune Current Point"

        closest_measured_point = find_closest_measurement(current_measured_points);
        selected_MODE_inter = find(current_measured_points(:, 1) == closest_measured_point(1));
        selected_MODE = ceil(selected_MODE_inter(1, 1)/2);

        plot(current_measured_points(:, 1), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0.9290, 0.6940, 0.1250]);
        hold on
        plot(closest_measured_point(1, 1), "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", "g");
        xlim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
        ylim([-1*(target_gain_states(Current_Calibration_Gain_Index)+0.1) target_gain_states(Current_Calibration_Gain_Index)+0.1]);
        drawnow
        hold off

        Selected_Measurements(Current_Calibration_Gain_Index, Current_Calibration_Phase_Index) = closest_measured_point(1, 1);
        Mapping(Current_Calibration_Gain_Index, Current_Calibration_Phase_Index) = conversionClass.polar2code(closest_measured_point(2), closest_measured_point(3), selected_MODE, closest_measured_point(end));
        
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

        plot(conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index))+0.000001*1i, "O", "LineWidth", 1.5, "MarkerSize", 10, "MarkerFaceColor", [0 0.4470 0.7410]);
        hold on
        plot_gain_circle(target_gain_states(Current_Calibration_Gain_Index));
        measurementClass.plot_measurements(next_measurements, "polar");
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
[ideal_phase1, ideal_phase2] = conversionClass.cartesian2phases(ideal_point);
[measured_phase1, measured_phase2] = conversionClass.cartesian2phases(measured_point);
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
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index kernel_size RTPS_phase_resolution RTPS_gain_resolution_dB target_gain_states ...
    target_phase_states lowest_detectable_gain_dB lowest_detectable_gain RTPS_gain_resolution

k = 0;
for gain = 1:1:kernel_size
    for angle = 1:1:kernel_size
        %next_gain_dB = target_gain_states_dB(Current_Calibration_Gain_Index) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
        next_gain = target_gain_states(Current_Calibration_Gain_Index) + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
        next_angle = conversionClass.wrap22pi(target_phase_states(Current_Calibration_Phase_Index) + RTPS_phase_resolution/2 * (angle - (kernel_size + 1)/2));
        
        if (next_gain >= lowest_detectable_gain/2) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
            k = k + 1;
        end
    end
end

next_polar = zeros(k, 2);


k = 1;
for gain = 1:1:kernel_size
    for angle = 1:1:kernel_size
        %next_gain_dB = target_gain_states_dB(Current_Calibration_Gain_Index) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
        next_gain = target_gain_states(Current_Calibration_Gain_Index) + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
        next_angle = conversionClass.wrap22pi(target_phase_states(Current_Calibration_Phase_Index) + RTPS_phase_resolution/2 * (angle - (kernel_size + 1)/2));
        
        if (next_gain >= lowest_detectable_gain/2) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
            %next_polar(k, 1) = 10^(next_gain_dB/10);
            next_polar(k, 1) = next_gain;
            next_polar(k, 2) = next_angle;
            k = k + 1;
        end
    end
end

end





function  closest_measured_point = find_closest_measurement(current_measured_points)
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index target_gain_states target_phase_states
    target_point = conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index));
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







% function next_polar = next_supporting_kernel(filtered_measurements)
% global Current_Calibration_Gain_Index Current_Calibration_Phase_Index kernel_size RTPS_phase_resolution RTPS_gain_resolution_dB target_phase_states lowest_detectable_gain_dB target_gain_states...
%     RTPS_gain_resolution lowest_detectable_gain kernel_offset
% 
%     error_vector_sum = 0;
% 
%     ideal_kernel = next_kernel();
% 
%     for k = 1:1:size(filtered_measurements, 1)
%         error_vector_sum = error_vector_sum + filtered_measurements(k, 1) - conversionClass.polar2cartesian(ideal_kernel(k, 1), ideal_kernel(k, 2));
%     end
% 
%     average_error_vector = error_vector_sum/size(filtered_measurements, 1);
% 
%     kernel_offset = kernel_offset + average_error_vector;
% 
%     new_target_point = conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)) - kernel_offset;
% 
%     [new_target_gain, new_target_phase] = conversionClass.cartesian2polar(new_target_point);
% 
%     k = 0;
%     for gain = 1:1:kernel_size
%         for angle = 1:1:kernel_size
%             %next_gain_dB = 10*log10(new_target_gain) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
%             next_gain = new_target_gain + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
%             next_angle = conversionClass.wrap22pi(new_target_phase + RTPS_phase_resolution/2 * (angle - (kernel_size + 1)/2));
% 
% 
%             if (next_gain >= lowest_detectable_gain/2) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
%                 k = k + 1;
%             end
%         end
%     end
% 
%     next_polar = zeros(k, 2);
% 
% 
%     k = 1;
%     for gain = 1:1:kernel_size
%         for angle = 1:1:kernel_size
%             %next_gain_dB = 10*log10(new_target_gain) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
%             next_gain = new_target_gain + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
%             next_angle = conversionClass.wrap22pi(new_target_phase + RTPS_phase_resolution/2 * (angle - (kernel_size + 1)/2));
% 
% 
%             if (next_gain >= lowest_detectable_gain/2) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
%                 %next_polar(k, 1) = 10^(next_gain_dB/10);
%                 next_polar(k, 1) = next_gain;
%                 next_polar(k, 2) = next_angle;
%                 k = k + 1;
%             end
%         end
%     end
% 
% end







function next_polar = next_supporting_kernel(filtered_measurements)
global Current_Calibration_Gain_Index Current_Calibration_Phase_Index kernel_size RTPS_phase_resolution RTPS_gain_resolution_dB target_phase_states lowest_detectable_gain_dB target_gain_states...
    RTPS_gain_resolution lowest_detectable_gain

    error_vector_sum = 0;

    for k = 1:1:size(filtered_measurements, 1)
        error_vector_sum = error_vector_sum + filtered_measurements(k, 1) - conversionClass.polar2cartesian(filtered_measurements(k, 2), filtered_measurements(k, 3));
    end

    average_error_vector = error_vector_sum/size(filtered_measurements, 1);

    new_target_point = conversionClass.polar2cartesian(target_gain_states(Current_Calibration_Gain_Index), target_phase_states(Current_Calibration_Phase_Index)) - average_error_vector;

    [new_target_gain, new_target_phase] = conversionClass.cartesian2polar(new_target_point);

    k = 0;
    for gain = 1:1:kernel_size
        for angle = 1:1:kernel_size
            %next_gain_dB = 10*log10(new_target_gain) + RTPS_gain_resolution_dB * (gain - (kernel_size + 1)/2);
            next_gain = new_target_gain + RTPS_gain_resolution * (gain - (kernel_size + 1)/2);
            next_angle = conversionClass.wrap22pi(new_target_phase + RTPS_phase_resolution/2 * (angle - (kernel_size + 1)/2));


            if (next_gain >= lowest_detectable_gain/2) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
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
            next_angle = conversionClass.wrap22pi(new_target_phase + RTPS_phase_resolution/2 * (angle - (kernel_size + 1)/2));


            if (next_gain >= lowest_detectable_gain/2) && (next_gain <= 1) && (next_angle >= 0) && (next_angle <= 2*pi)
                %next_polar(k, 1) = 10^(next_gain_dB/10);
                next_polar(k, 1) = next_gain;
                next_polar(k, 2) = next_angle;
                k = k + 1;
            end
        end
    end

end









function circle_report()
    global Current_Calibration_Gain_Index target_gain_states target_gain_states_dB target_phase_states Selected_Measurements measurement_counter total_measurement_counter Ending_Gain_Index Starting_Gain_Index phase_error_sum gain_error_sum...
        VALIDATION num_hit total_num_hit num_target_phase_states
    
        actual_phase = angle(Selected_Measurements(Current_Calibration_Gain_Index, :));
        
        for i = round(size(actual_phase, 2)/3) : 1 : size(actual_phase, 2)
            actual_phase(1, i) = conversionClass.wrap22pi(actual_phase(1, i));
        end
    
        phase_RMS_error = rmse(target_phase_states, actual_phase);
        gain_RMS_error = rmse(target_gain_states(Current_Calibration_Gain_Index), abs(Selected_Measurements(Current_Calibration_Gain_Index, :)));
    
        phase_error_sum = phase_error_sum + phase_RMS_error^2;
        gain_error_sum = gain_error_sum + gain_RMS_error^2;
    
        disp(" ");
        disp("Gain Circle " + Current_Calibration_Gain_Index + " at " + target_gain_states(Current_Calibration_Gain_Index) + " / " + target_gain_states_dB(Current_Calibration_Gain_Index) + " dB");
        disp("RMS Phase Error: " + phase_RMS_error + " / " + phase_RMS_error*180/pi + " degrees");
        disp("RMS Gain Error: " + gain_RMS_error + " / " + 10*log10(gain_RMS_error) + " dB");
    
        if ~VALIDATION
            hit_rate = num_hit/num_target_phase_states*100;
            disp("Hit rate: " + hit_rate + "%");
            num_hit = 0;
        else
            disp("Number of new measurements: " + measurement_counter);
            measurement_counter = 0;
        end
    
    
        if Current_Calibration_Gain_Index == Ending_Gain_Index
        
            total_RMS_phase_error = sqrt(phase_error_sum/(Ending_Gain_Index - Starting_Gain_Index + 1));
            total_RMS_gain_error = sqrt(gain_error_sum/(Ending_Gain_Index - Starting_Gain_Index + 1));
    
            disp(" ");
            disp("Calibration finish");
            disp("Total RMS Phase Error: " + total_RMS_phase_error + " / " + total_RMS_phase_error*180/pi + " degrees");
            disp("Total RMS Gain Error: " + total_RMS_gain_error + " / " + 10*log10(total_RMS_gain_error) + " dB");
            
            if ~VALIDATION
                total_hit_rate = total_num_hit/(num_target_phase_states*(Ending_Gain_Index - Starting_Gain_Index + 1))*100;
                disp("Total hit rate: " + total_hit_rate + "%");
            else
                disp("Total number of measurements for " + (Ending_Gain_Index - Starting_Gain_Index + 1) + " gain circles: " + total_measurement_counter);
            end
    
        end
    
    end





function gain_resolution_calibration()
global RTPS_phase_states num_RTPS_phase_states achievable_gain_states L1 L2

data = zeros(1, num_RTPS_phase_states*num_RTPS_phase_states);

L = (L1 + L2)/2;

% figure
for i = 1:1:num_RTPS_phase_states
    for j = 1:1:num_RTPS_phase_states
     data((i-1)*num_RTPS_phase_states + j) = L*cos(RTPS_phase_states(i)) + L*cos(RTPS_phase_states(j)) + 1i*(L*sin(RTPS_phase_states(i)) + L*sin(RTPS_phase_states(j)));
     % plot(data((i-1)*num_RTPS_phase_states + j), "O");
     % hold on
    end
end
% hold off

index = find(abs(imag(data)) < 0.05);
gains = unique(sort(abs(data(index))));

index = find(gains > 0.001);
gains = unique(round(gains(index)*10^4)/10^4);

achievable_gain_states_1 = zeros(1, size(gains, 2)*2 - 1);

for i = 1:1:size(gains, 2)
    achievable_gain_states_1(1, i*2 - 1) = gains(1, i);
end

for i = 1:1:(size(gains, 2) - 1)
    achievable_gain_states_1(1, i*2) = (gains(1, i) + gains(1, i + 1))/2;
end

achievable_gain_states = zeros(1, size(achievable_gain_states_1, 2)*2 - 1);

for i = 1:1:size(gains, 2)
    achievable_gain_states(1, i*2 - 1) = achievable_gain_states_1(1, i);
end

for i = 1:1:(size(gains, 2) - 1)
    achievable_gain_states(1, i*2) = (achievable_gain_states_1(1, i) + achievable_gain_states_1(1, i + 1))/2;
end


% achievable_gain_states = zeros(2, size(gains,2) - 1);
% 
% for i = 1:1:size(gains, 2) - 1
%     achievable_gain_states(1, i) = gains(i);
%     achievable_gain_states(2, i) = gains(i + 1) - gains(i);
% end
% 
% figure
% plot(achievable_gain_states(1, :), achievable_gain_states(2, :));
% hold off

end