circle_radius = 0.99;
bit_length = 12;
division_ratio = 0.5;

phase = linspace(0, 2*pi, 2^bit_length);
achievable_phase = linspace(0, 2*pi, 64);
%continuous_phase = linspace(0, 2*pi, 1000000);
point_coordinates = zeros(2^bit_length, 2);

for i = 1:1:2^bit_length
    point_coordinates(i, 1) = circle_radius * cos(phase(i));
    point_coordinates(i, 2) = circle_radius * sin(phase(i));
end

%scatter(point_coordinates(:, 1), point_coordinates(:, 2))


L1 = division_ratio;
L2 = 1 - division_ratio;
X = point_coordinates(:, 1);
Y = point_coordinates(:, 2);

vector1_ideal_phase = zeros(2^bit_length, 1);
vector2_ideal_phase = zeros(2^bit_length, 1);

for i = 1:1:2^bit_length
    if Y(i, 1) >= 0
        vector1_ideal_phase(i, 1) = acos((L1^2 + X(i, 1)^2 + Y(i, 1)^2 - L2^2)/(2*L1*sqrt(X(i, 1)^2 + Y(i, 1)^2))) + acos(X(i, 1)/(sqrt(X(i, 1)^2 + Y(i, 1)^2)));
        vector2_ideal_phase(i, 1) = -1 * (pi - acos((L1^2 - X(i, 1)^2 - Y(i, 1)^2 + L2^2)/(2*L1*L2)) - vector1_ideal_phase(i, 1));
    else
        vector1_ideal_phase(i, 1) = pi + acos((L1^2 + X(i, 1)^2 + Y(i, 1)^2 - L2^2)/(2*L1*sqrt(X(i, 1)^2 + Y(i, 1)^2))) + acos(-1 * X(i, 1)/(sqrt(X(i, 1)^2 + Y(i, 1)^2)));
        vector2_ideal_phase(i, 1) = pi + (-1 * (pi - acos((L1^2 - X(i, 1)^2 - Y(i, 1)^2 + L2^2)/(2*L1*L2)) - vector1_ideal_phase(i, 1) + pi));
    end

    if vector1_ideal_phase(i, 1) < 0
        vector1_ideal_phase(i, 1) = vector1_ideal_phase(i, 1) + 2*pi;
    end

    if vector2_ideal_phase(i, 1) < 0
        vector2_ideal_phase(i, 1) = vector2_ideal_phase(i, 1) + 2*pi;
    end

    if vector1_ideal_phase(i, 1) > 2*pi
        vector1_ideal_phase(i, 1) = vector1_ideal_phase(i, 1) - 2*pi;
    end

    if vector2_ideal_phase(i, 1) > 2*pi
        vector2_ideal_phase(i, 1) = vector2_ideal_phase(i, 1) - 2*pi;
    end

end

ideal_coordinates = zeros(2^bit_length, 2);

for i = 1:1:2^bit_length
    ideal_coordinates(i, 1) = L1 * cos(vector1_ideal_phase(i, 1)) + L2 * cos(vector2_ideal_phase(i, 1));
    ideal_coordinates(i, 2) = L1 * sin(vector1_ideal_phase(i, 1)) + L2 * sin(vector2_ideal_phase(i, 1));
end

figure;
ideal = scatter(ideal_coordinates(:, 1), ideal_coordinates(:, 2));
hold on

vector1_phase_distance = zeros(64, 1);
vector2_phase_distance = zeros(64, 1);

vector1_phase = zeros(2^bit_length, 1);
vector2_phase = zeros(2^bit_length, 1);

for i=1:1:2^bit_length
vector1_phase_distance(:, 1) = abs(achievable_phase - vector1_ideal_phase(i, 1));
index = find(vector1_phase_distance == min(vector1_phase_distance));
vector1_phase(i, 1) = achievable_phase(index);

vector2_phase_distance(:, 1) = abs(achievable_phase - vector2_ideal_phase(i, 1));
index = find(vector2_phase_distance == min(vector2_phase_distance));
vector2_phase(i, 1) = achievable_phase(index);
end

coordinates = zeros(2^bit_length, 2);

for i = 1:1:2^bit_length
    coordinates(i, 1) = L1 * cos(vector1_phase(i, 1)) + L2 * cos(vector2_phase(i, 1));
    coordinates(i, 2) = L1 * sin(vector1_phase(i, 1)) + L2 * sin(vector2_phase(i, 1));
end


real = scatter(coordinates(:, 1), coordinates(:, 2));
hold off
legend([ideal, real], "Ideal", "Realistic");
title("Realistic Coordinates")

vector_phase = zeros(2^bit_length, 2);
vector_phase(:, 1) = vector1_phase;
vector_phase(:, 2) = vector2_phase;

