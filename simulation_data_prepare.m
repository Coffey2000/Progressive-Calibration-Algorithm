% simulation_data = readtable("outphasersp21.csv");
% simulation_reading_text = simulation_data(1:end, 4);

FILE = fopen('simulation_data_mode1.txt');
% Read all lines & collect in cell array
txt = textscan(FILE, '%s / %s'); 

gain = str2double(txt{1});
phase = str2double(txt{2}) * pi/180 * -1;

simulation_data_mode1 = zeros(size(gain, 1), 1);

for j = 1:1:size(gain, 1)
    simulation_data_mode1(j, 1) = gain(j, 1) * cos(phase(j, 1)) + 1i * gain(j, 1) * sin(phase(j, 1));
end

save("simulation_data_mode1.mat", "simulation_data_mode1");

fclose(FILE);


FILE = fopen('simulation_data_mode2.txt');
% Read all lines & collect in cell array
txt = textscan(FILE, '%s / %s'); 

gain = str2double(txt{1});
phase = str2double(txt{2}) * pi/180 * -1;

simulation_data_mode2 = zeros(size(gain, 1), 1);

for j = 1:1:size(gain, 1)
    simulation_data_mode2(j, 1) = gain(j, 1) * cos(phase(j, 1)) + 1i * gain(j, 1) * sin(phase(j, 1));
end

save("simulation_data_mode2.mat", "simulation_data_mode2");

fclose(FILE);