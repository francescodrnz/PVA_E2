%% Script Analisi Trade-off: Diminishing Returns
clc; close all; clearvars;

data = loadMostRecentCSV();

% --- DATI SIMULATI (Sostituisci con i tuoi dati reali caricati) ---
% Assumo che 'data' sia la tua table con tutte le configurazioni
% Se non l'hai caricata, usa: data = loadMostRecentCSV(); 

% Estrai i vettori
X_fuel = data.W_block_fuel;
Y_mtow = data.WTO;
Y_batt = data.W_battery;

% Calcola la Battery Mass Fraction
Y_frac = Y_batt ./ Y_mtow;

% --- IDENTIFICAZIONE PUNTI CHIAVE ---
% Trova la tua configurazione SCELTA (quella da 118 kg fuel)
% (Qui uso una logica approssimata, tu puoi usare l'indice esatto se lo sai)
[~, idx_scelto] = min(abs(X_fuel - 118.5)); 

% Trova la configurazione "MATEMATICAMENTE MIGLIORE" (quella da 102 kg fuel)
[~, idx_best] = min(abs(X_fuel - 102.8)); 

% --- PLOT 1: BATTERY MASS FRACTION (La tua idea) ---
figure('Name', 'Battery_Fraction', 'Color', 'w', 'Position', [100 100 800 600]);
scatter(X_fuel, Y_frac * 100, 40, Y_mtow, 'filled'); % Colore = MTOW
colormap(jet); c = colorbar; c.Label.String = 'MTOW [kg]';
grid on; box on;
xlabel('Block Fuel [kg] (Obiettivo: Minimizzare)', 'FontWeight', 'bold');
ylabel('Frazione di Massa Batterie [% del MTOW]', 'FontWeight', 'bold');
set(gca, 'XDir', 'reverse'); % Asse X invertito: andare a destra è meglio (meno fuel)
title('L''aereo diventa una "batteria volante"?');

hold on;
% Evidenzia i due punti
plot(X_fuel(idx_scelto), Y_frac(idx_scelto)*100, 'p', 'MarkerSize', 20, ...
    'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k'); % Stella Verde (Scelto)
plot(X_fuel(idx_best), Y_frac(idx_best)*100, 'h', 'MarkerSize', 20, ...
    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k'); % Esagono Rosso (Best Fuel)

legend({'Configurazioni', 'Design Scelto', 'Minimo Fuel Teorico'}, 'Location', 'best');

% --- PLOT 2: IL COSTO DEL RISPARMIO (Exchange Rate) ---
figure('Name', 'Design_Cost', 'Color', 'w', 'Position', [150 150 900 600]);
scatter(X_fuel, Y_mtow, 30, [0.8 0.8 0.8], 'filled', 'MarkerFaceAlpha', 0.5); hold on;

% Disegna solo i due punti di interesse
p1 = plot(X_fuel(idx_scelto), Y_mtow(idx_scelto), 'p', 'MarkerSize', 25, ...
    'MarkerFaceColor', '#77AC30', 'MarkerEdgeColor', 'k'); % Verde
p2 = plot(X_fuel(idx_best), Y_mtow(idx_best), 'h', 'MarkerSize', 25, ...
    'MarkerFaceColor', '#A2142F', 'MarkerEdgeColor', 'k'); % Rosso

% Disegna la linea che li collega
line([X_fuel(idx_scelto), X_fuel(idx_best)], [Y_mtow(idx_scelto), Y_mtow(idx_best)], ...
    'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);

% Calcolo dei Delta
d_fuel = X_fuel(idx_scelto) - X_fuel(idx_best); % Risparmio Fuel (positivo)
d_weight = Y_mtow(idx_best) - Y_mtow(idx_scelto); % Aumento Peso (positivo)
exchange_rate = d_weight / d_fuel; % kg di peso per kg di fuel

% Annotazione Intelligente
mid_x = mean([X_fuel(idx_scelto), X_fuel(idx_best)]);
mid_y = mean([Y_mtow(idx_scelto), Y_mtow(idx_best)]) + 500; % Un po' sopra

text_str = sprintf(['\\bfCOSTO MARGINALE:\n' ...
    'Spendiamo %.0f kg di MTOW\n' ...
    'per risparmiare %.0f kg di Fuel\n' ...
    '(Rapporto %.1f : 1)'], d_weight, d_fuel, exchange_rate);

text(mid_x, mid_y, text_str, 'HorizontalAlignment', 'center', ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5);

% Frecce per chiarire il movimento
quiver(X_fuel(idx_scelto), Y_mtow(idx_scelto), -d_fuel, 0, 'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5);
quiver(X_fuel(idx_best), Y_mtow(idx_scelto), 0, d_weight, 'Color', 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);

xlabel('Block Fuel [kg]', 'FontWeight', 'bold');
ylabel('MTOW [kg]', 'FontWeight', 'bold');
set(gca, 'XDir', 'reverse'); 
title('Analisi Costi-Benefici: Ne vale la pena?');
grid on;