classdef conversionClass
    methods (Static)


        function index = cap(pre_cap_index, start, ending)
            if pre_cap_index < start
                index = start;
            elseif pre_cap_index > ending
                index = ending;
            else
                index = pre_cap_index;
            end
        end


        function [L1, L2] = cartesian2vectors(point)
            global theta1 theta2

            X = real(point);
            Y = imag(point);

            a = linsolve([cos(theta1) cos(theta2); sin(theta1) sin(theta2)], [X; Y]);

            L1 = a(1);
            L2 = a(2);
        end




        function [vector1_index, vector2_index] = vectorLength2index(L1, L2)
            global vector1_profile vector2_profile vector1_envelop_profile vector2_envelop_profile reference_index
            vector1Length_scaling_minus = abs(interp1(vector1_envelop_profile(:, 2), vector1_envelop_profile(:, 1), L2)/vector1_profile(1, 2));
            vector1Length_scaling_plus = abs(interp1(vector1_envelop_profile(:, 4), vector1_envelop_profile(:, 3), L2)/vector1_profile(end, 2));

            vector2Length_scaling_minus = abs(interp1(vector2_envelop_profile(:, 1), vector2_envelop_profile(:, 2), L1)/vector2_profile(1, 2));
            vector2Length_scaling_plus = abs(interp1(vector2_envelop_profile(:, 3), vector2_envelop_profile(:, 4), L1)/vector2_profile(end, 2));
        
            scaled_vector1_profile = vector1_profile;
            scaled_vector1_profile(1:9, 2) = scaled_vector1_profile(1:9, 2)*vector1Length_scaling_minus;
            scaled_vector1_profile(11:20, 2) = scaled_vector1_profile(11:20, 2)*vector1Length_scaling_plus;

            scaled_vector2_profile = vector2_profile;
            scaled_vector2_profile(1:9, 2) = scaled_vector2_profile(1:9, 2)*vector2Length_scaling_minus;
            scaled_vector2_profile(11:20, 2) = scaled_vector2_profile(11:20, 2)*vector2Length_scaling_plus;

            % vector1_index = round(interp1(scaled_vector1_profile(:, 2), scaled_vector1_profile(:, 1), L1)) + reference_index(1);
            % vector2_index = round(interp1(scaled_vector2_profile(:, 2), scaled_vector2_profile(:, 1), L2)) + reference_index(2);
            vector1_index = round(interp1(scaled_vector1_profile(:, 2), scaled_vector1_profile(:, 1), L1));
            vector2_index = round(interp1(scaled_vector2_profile(:, 2), scaled_vector2_profile(:, 1), L2));
        end




        function index = phase2index(phase)
            global num_actual_phase_states
            index = round(conversionClass.wrap22pi(phase)*(num_actual_phase_states - 1)/(2*pi)) + 1;
        end





        function index = gain2index(gain, compensated_phase_index)
            global gain_profile max_gain_measurement min_gain
            
            gain_scaling = (max_gain_measurement(compensated_phase_index, 1) - min_gain)/(max_gain_measurement(1, 1) - min_gain);
            index = round(interp1(gain_profile(:, 2)*gain_scaling, gain_profile(:, 1), gain));
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
            
            phase1 = conversionClass.wrap22pi(phase1);
            phase2 = conversionClass.wrap22pi(phase2);
        end
        




        function point = phase2cartesian(phase1, phase2)
        global L1 L2
            point = L1*cos(phase1) + L2*cos(phase2) + 1i*(L1*sin(phase1) + L2*sin(phase2));
        end
        
        
        
        
        
        function point = polar2cartesian(radius, phase)
        point = radius*cos(phase) + 1i * radius*sin(phase);
        end
        
        

        
        
        function [gain, phase] = cartesian2polar(point)
            gain = abs(point);
            phase = conversionClass.wrap22pi(angle(point));
        end
        



        
        function phase = wrap22pi(phase)
            if phase < 0
                phase = phase + 2*pi;
            elseif phase > 2*pi
                phase = phase - 2*pi;
            end
        end





        function [b, a] = swap(a, b)
        end




        
        function codeword = polar2code(gain, phase, MODE, SOLUTION)
        global DC_offset phase1_offset phase2_offset magnitude_scaling_factor
        
        uncompensated_target_point = conversionClass.polar2cartesian(gain, phase);
        target_point = measurementClass.DC_offset_compensation(uncompensated_target_point, DC_offset, magnitude_scaling_factor);
        [uncompensated_vector1_phase, uncompensated_vector2_phase] = conversionClass.cartesian2phases(target_point);
        if SOLUTION == 2
            [uncompensated_vector1_phase, uncompensated_vector2_phase] = conversionClass.swap(uncompensated_vector1_phase, uncompensated_vector2_phase);
        end
        [vector1_phase, vector2_phase] = measurementClass.phase_offset_compensation(uncompensated_vector1_phase, uncompensated_vector2_phase, phase1_offset, phase2_offset);
        
        % plot(L1*cos(vector1_phase) + L2*cos(vector2_phase) + 1i*L1*sin(vector1_phase) + 1i*L2*sin(vector2_phase), 'o');
        % hold on
        
        codeword = conversionClass.vectors2code(vector1_phase, vector2_phase, MODE);
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
        
        phase_code = conversionClass.phase2RTPS_phase_index(phase);
        
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
            [c0, c1, c2, c3] = conversionClass.phase2code(vector1_phase);
            [c4, c5, c6, c7] = conversionClass.phase2code(vector2_phase);
            
            switch MODE
                case 2
                    [c4, c5] = conversionClass.swap(c4, c5);
                case 3
                    [c4, c6] = conversionClass.swap(c4, c6);
                case 4
                    [c0, c1] = conversionClass.swap(c0, c1);
                case 5
                    [c0, c1] = conversionClass.swap(c0, c1);
                    [c4, c5] = conversionClass.swap(c4, c5);
                case 6
                    [c0, c1] = conversionClass.swap(c0, c1);
                    [c4, c6] = conversionClass.swap(c4, c6);
                case 7
                    [c0, c2] = conversionClass.swap(c0, c2);
                case 8
                    [c0, c2] = conversionClass.swap(c0, c2);
                    [c4, c5] = conversionClass.swap(c4, c5);
                case 9
                    [c0, c2] = conversionClass.swap(c0, c2);
                    [c4, c6] = conversionClass.swap(c4, c6);
                otherwise
            end
            
            codeword_inSequence_bin = strcat(dec2bin(c0, 4), dec2bin(c1, 4), dec2bin(c2, 4), dec2bin(c3, 2), dec2bin(c4, 4), dec2bin(c5, 4), dec2bin(c6, 4), dec2bin(c7, 2));
            codeword = bin2dec(flip(codeword_inSequence_bin));
        end
        
        
        
        
        
        function codeword = single_vector2code(vector1_phase, MODE)
            [c0, c1, c2, c3] = conversionClass.phase2code(vector1_phase);
            
            switch MODE
                case 2
                    [c0, c1] = conversionClass.swap(c0, c1);
                case 3
                    [c0, c2] = conversionClass.swap(c0, c2);
                otherwise
            end
            
            codeword_inSequence_bin = strcat(dec2bin(c0, 4), dec2bin(c1, 4), dec2bin(c2, 4), dec2bin(c3, 2));
            codeword = bin2dec(flip(codeword_inSequence_bin));
        end



    end
end