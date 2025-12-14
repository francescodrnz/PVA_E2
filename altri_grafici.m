%% Script Rapido: Grafici Sensibilità Batterie e Nuvola Potenza
clc; clearvars; close all;
data = loadMostRecentCSV();

% --- GRAFICO 1: IMPACT TRENDS SU BATTERIE ---
Y_target = data.W_battery;
Y_label = 'Massa Batterie [kg]';
X_data = [data.W_S, data.Hp, data.phi_ice_cl, data.phi_ice_cr, data.phi_ice_de];
var_names = {'WS', 'Hp', 'Phi_Climb', 'Phi_Cruise', 'Phi_Descent'}; 

figure('Name', 'Impact_Trends_Batt', 'Color', 'w', 'Position', [100 100 1200 400]);
for i = 1:5
    subplot(1, 5, i);
    scatter(X_data(:,i), Y_target, 30, 'filled', 'MarkerFaceAlpha', 0.4, 'MarkerFaceColor', [0.8 0.2 0.2]); % Rosso
    hold on;
    % Fit semplice
    if length(unique(X_data(:,i))) > 2
        p = polyfit(X_data(:,i), Y_target, 2);
        x_r = linspace(min(X_data(:,i)), max(X_data(:,i)), 50);
        plot(x_r, polyval(p, x_r), 'k-', 'LineWidth', 2);
    end
    xlabel(var_names{i}, 'FontWeight', 'bold');
    if i==1, ylabel(Y_label, 'FontWeight', 'bold'); end
    grid on; title(['vs ' var_names{i}]);
end
saveas(gcf, 'Impact_Trends_Batt.png');

%% --- GRAFICO 2: LA "NUVOLA" (FUEL vs POTENZA TERMICA) ---
figure('Name', 'Cloud_Fuel_Power', 'Color', 'w');
scatter(data.P_ice/1000, data.W_block_fuel, 50, data.W_battery, 'filled', 'MarkerFaceAlpha', 0.6);
colormap("cool"); c = colorbar; c.Label.String = 'Massa Batterie [kg]';
grid on;
xlabel('Potenza Termica Installata [kW]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Block Fuel [kg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Disaccoppiamento: Potenza Termica vs Consumo', 'FontSize', 14);
% Annotazione
text(mean(xlim), mean(ylim), 'Nessuna Correlazione Diretta', 'FontSize', 16, 'Color', 'r', 'HorizontalAlignment', 'center');
saveas(gcf, 'Scatter_Cloud_Power.png');