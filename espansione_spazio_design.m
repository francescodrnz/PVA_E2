%% Script Analisi Trade-off: Fronte di Pareto con Vincolo
clc; close all; clearvars;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% Estrazione Variabili
X_fuel = data.W_block_fuel;
Y_batt = data.W_battery; 
P_em_vec = data.P_em; % [W] o [kW] a seconda dei dati

% --- 2. FILTRAGGIO (Vincolo Potenza) ---
limit_power = 2.16e6; % 2.15 MW
idx_feasible = P_em_vec <= limit_power; % Punti "Buoni" (Rossi)
idx_excluded = P_em_vec > limit_power;  % Punti "Esclusi" (Grigi)

% Coordinate punti fattibili per il calcolo Pareto
x_feas = X_fuel(idx_feasible);
y_feas = Y_batt(idx_feasible);

% --- 3. CALCOLO FRONTE DI PARETO ---
% Cerchiamo di minimizzare sia Fuel che Batterie.
% Un punto i domina j se: (x_i <= x_j) AND (y_i <= y_j) con almeno una disuguaglianza stretta.
% Il fronte di Pareto è l'insieme dei punti non dominati.

is_pareto = false(size(x_feas));
for i = 1:length(x_feas)
    % Controlla se esiste un punto 'j' che domina 'i'
    % Nota: Poiché abbiamo un trade-off (Meno fuel = Più batterie), 
    % il fronte sarà il bordo "inferiore" della nuvola.
    is_dominated = any(x_feas <= x_feas(i) & y_feas <= y_feas(i) & ...
                      (x_feas < x_feas(i) | y_feas < y_feas(i)));
    if ~is_dominated
        is_pareto(i) = true;
    end
end

% Estrai punti Pareto e ordinali per il plot (fondamentale per fare la linea)
x_pareto = x_feas(is_pareto);
y_pareto = y_feas(is_pareto);
[x_pareto, sort_idx] = sort(x_pareto);
y_pareto = y_pareto(sort_idx);

% --- 4. IDENTIFICAZIONE PUNTO SCELTO ---
% Trova il punto scelto (quello a ~319.88 kg fuel)
% Cerchiamo nell'intero dataset per avere l'indice corretto
[~, idx_scelto_global] = min(abs(X_fuel - 319.88)); 
x_green = X_fuel(idx_scelto_global);
y_green = Y_batt(idx_scelto_global);

% --- 5. PLOT ---
figure('Name', 'Pareto_Frontier', 'Color', 'w', 'Position', [150 150 1000 600]);
hold on;

% A) Scatter Punti ESCLUSI (Sfondo, Grigio chiaro)
h_excl = scatter(X_fuel(idx_excluded), Y_batt(idx_excluded), 30, [0.85 0.85 0.85], 'filled');

% B) Scatter Punti FATTIBILI (Rosso)
h_feas = scatter(x_feas, y_feas, 30, [0.9 0.2 0.2], 'filled', 'MarkerFaceAlpha', 0.6);

% C) Fronte di Pareto (Linea Nera Spessa)
h_line = plot(x_pareto, y_pareto, 'k-', 'LineWidth', 2);

% D) Punto Scelto (Stella Verde)
h_star = plot(x_green, y_green, 'p', 'MarkerSize', 18, ...
    'MarkerFaceColor', '#77AC30', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);

% --- 6. FORMATTAZIONE E ANNOTAZIONI ---
xlabel('Block Fuel [kg]', 'FontWeight', 'bold');
ylabel('Massa Batterie [kg]', 'FontWeight', 'bold');
set(gca, 'XDir', 'reverse'); % Fuel decrescente verso destra (più intuitivo per "miglioramento")
grid on; box on;

title(['Fronte di Pareto con potenza elettrica <= ' sprintf('%.2f', limit_power/1e6+.04) ' MW'], ...
    'Interpreter', 'tex', 'FontSize', 14);

% Legenda
legend([h_star, h_line, h_feas, h_excl], ...
    {'Design Scelto', 'Fronte di Pareto', 'Configurazioni fattibili (<=2.2 MW)', 'Configurazioni escluse (>2.2 MW)'}, ...
    'Location', 'northwest', 'FontSize', 11);


% Annotazione Intelligente
% Calcola distanza dal fronte (se il punto scelto non fosse perfettamente sul fronte numerico)
min_fuel_pareto = min(x_pareto);
max_fuel_pareto = max(x_pareto);

annotation_str = sprintf(['\\bfDesign Scelto\\rm\n' ...
                          'Fuel: %.1f kg\n' ...
                          'Batt: %.0f kg\n' ...
                          ], x_green, y_green);

text(x_green-20, y_green - 400, annotation_str, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top', ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5);

% Tuning Assi (Zoom sulla zona interessante)
ylim([min(y_feas)-200, max(y_feas)+200]);
xlim([min(x_feas)-10, max(x_feas)+10]);
ylim([6500 9800]);
xlim([270 420]);

saveas(gcf, 'Pareto_Frontier_Design_zoom.png');
disp('Grafico Pareto generato.');