%% Script Analisi Trade-off: Diminishing Returns + Vincolo Potenza
clc; close all; clearvars;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% Estrazione Variabili
X_fuel = data.W_block_fuel;
Y_mtow = data.WTO;
P_em_vec = data.P_em; % Assumo sia in [kW]. Se è in W, usa data.P_em / 1000

% --- 2. IDENTIFICAZIONE PUNTI E FILTRI ---
% Soglia di Potenza (2 MW = 2000 kW)
limit_power = 1.95e6; 

% Maschere logiche
idx_feasible = P_em_vec <= limit_power; % Punti "Buoni"
idx_excluded = P_em_vec > limit_power;  % Punti "Esclusi"

% Trova i punti specifici (Scelto e Best)
[~, idx_scelto] = min(abs(X_fuel - 118.5)); 
[~, idx_best] = min(abs(X_fuel - 102.8)); 

% Coordinate per il plot
x_green = X_fuel(idx_scelto);
y_green = Y_mtow(idx_scelto);
x_red = X_fuel(idx_best);
y_red = Y_mtow(idx_best);

% Calcolo Delta
d_fuel = x_green - x_red;     
d_weight = y_red - y_green;   
rate = d_weight / d_fuel;

% --- 3. PLOT ---
figure('Name', 'Design_Cost_Power_Constraint', 'Color', 'w', 'Position', [150 150 900 600]);
hold on;

% A) Scatter Punti FATTIBILI (Grigio)
h1 = scatter(X_fuel(idx_feasible), Y_mtow(idx_feasible), 40, [1 0.8 0.6], 'filled'); 

% B) Scatter Punti ESCLUSI (> 2MW) (Arancione Chiaro)
h2 = scatter(X_fuel(idx_excluded), Y_mtow(idx_excluded), 40, [0.85 0.85 0.85], 'filled'); 

% C) Linee del "Percorso" a gradino
line([x_green, x_red], [y_green, y_green], 'Color', [0 0.45 0.74], 'LineWidth', 3); 
line([x_red, x_red], [y_green, y_red], 'Color', [0.85 0.33 0.1], 'LineWidth', 3);

% D) Punti Scelti (Sopra tutto)
h3 = plot(x_green, y_green, 'p', 'MarkerSize', 22, ...
    'MarkerFaceColor', '#77AC30', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5); % Stella Verde
h4 = plot(x_red, y_red, 'h', 'MarkerSize', 22, ...
    'MarkerFaceColor', '#A2142F', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5); % Esagono Rosso

% --- 4. ANNOTAZIONI ---
% Etichette assi del trade-off
text(mean([x_green, x_red]), y_green - 50, sprintf('-%.1f kg Fuel', d_fuel), ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'Color', [0 0.45 0.74], 'FontWeight', 'bold', 'FontSize', 10);

text(x_red + 2.3, mean([y_green, y_red])+30, sprintf('+%.0f kg MTOW', d_weight), ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', ...
    'Color', [0.85 0.33 0.1], 'FontWeight', 'bold', 'FontSize', 10);

% Box Informativo
text_str = sprintf(['\\rmSi aggiungono \\bf%.0f kg\\rm di MTOW\n' ...
    'per risparmiare \\bf%.1f kg\\rm fuel\n' ...
    '\\it(Rapporto %.1f : 1)'], d_weight, d_fuel, rate);

text(180, 2.3e4, text_str, ... % Coordinate manuali (aggiusta se serve)
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'EdgeColor', 'k', ...
    'Margin', 6, ...
    'FontSize', 11);

% --- 5. FORMATTAZIONE FINALE ---
xlabel('Block Fuel [kg]', 'FontWeight', 'bold');
ylabel('MTOW [kg]', 'FontWeight', 'bold');
set(gca, 'XDir', 'reverse'); % Fuel decrescente a destra
grid on; box on;
title('Analisi Costi-Benefici con Vincolo di Potenza Elettrica', 'FontSize', 12);

% Legenda Aggiornata
legend([h3, h4, h1, h2], ...
    {'Design scelto', 'Minimo block fuel', 'P_{EM} < 2 MW', 'P_{EM} > 2 MW'}, ...
    'Location', 'southeast', 'FontSize', 10);

% Zoom
margin_x = 80; 
margin_y = 1000;
xlim([min([x_red, x_green]) - margin_x*.53, max([x_red, x_green]) + margin_x]);
ylim([min([y_red, y_green]) - margin_y*1.5, max([y_red, y_green]) + margin_y*.6]);

saveas(gcf, 'costi-benefici alternativa.png');