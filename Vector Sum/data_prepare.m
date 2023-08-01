load("rfvm_40GHz.mat");

% for i = 1:1:64
% plot(S_dd21(i, 201), "O");
% ylim([-0.2 0.7]);
% xlim([0.1 0.7]);
% hold on
% drawnow
% end
% 
 plot(S_dd21(:, 201), "O");
% hold on
% plot(S_dd21(64*32, 201), "O");
% hold on
% plot(S_dd21(64*33, 201), "O");
% hold on

rfvm_40GHz_table = zeros(64, 64);

for i = 1:1:64
    rfvm_40GHz_table(i, :) = S_dd21((i-1)*64+1:i*64, 201);
end

save("rfvm_40GHz_table.mat", "rfvm_40GHz_table");

plot(rfvm_40GHz_table(32, :), "O");

(rfvm_40GHz_table(32, 32) + rfvm_40GHz_table(32, 33) + rfvm_40GHz_table(33, 33) + rfvm_40GHz_table(33, 32))/4