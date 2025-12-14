%% Script Radar Chart - Confronto Multidimensionale Configurazioni
clc; clearvars; close all;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% --- 2. SELEZIONE METRICHE PER IL CONFRONTO ---
% Scegliamo 5-6 metriche chiave per definire la "bontà" del design
% Nota: Adatta i nomi delle colonne se necessario (copiato dai tuoi script precedenti)
try
    metrics_data = [ ...
        data.W_block_fuel, ...  % 1. Consumo (Obiettivo primario)
        data.WTO, ...           % 2. MTOW (Costi/Operatività)
        data.W_battery, ...     % 3. Peso Batterie (Complessità/Volume)
        data.W_S, ...           % 4. Carico Alare (Prestazioni volo)
        data.Hp ...             % 5. Grado Ibridizzazione (Strategia)
    ];
    
    % Gestione Potenze (con fallback)
    if ismember('P_em', data.Properties.VariableNames), P_el = data.P_em;
    elseif ismember('P_el_tot', data.Properties.VariableNames), P_el = data.P_el_tot;
    else, P_el = data.W_battery * 1.0; end % Fallback
    
    if ismember('P_ice', data.Properties.VariableNames), P_ice = data.P_ice;
    elseif ismember('P_ice_tot', data.Properties.VariableNames), P_ice = data.P_ice_tot;
    else, P_ice = data.WTO * 0.2; end % Fallback

    % Aggiungo Potenze alle metriche
    metrics_data = [metrics_data, P_el, P_ice];
    
    % Nomi delle etichette per il grafico
    metric_labels = {'Block Fuel', 'MTOW', 'Massa Batt.', 'W/S', 'Hp', 'P Elettrica', 'P Termica'};
    
catch
    error('Errore nel recupero delle colonne dal CSV.');
end


% --- 3. IDENTIFICAZIONE CONFIGURAZIONI ---

% A) REFERENCE: BEST FUEL (Il minimo consumo assoluto)
[~, idx_ref] = min(data.W_block_fuel);

% B) TARGET: DESIGN SCELTO (La tua scelta bilanciata)
target_WS = 280; target_phi_cl = 0.1; target_phi_cr = 0.1; 
target_phi_de = 0.3; target_Hp = 0.4;
tol = 1e-4;

idx_target = find(abs(data.W_S - target_WS) < tol & ...
                  abs(data.phi_ice_cl - target_phi_cl) < tol & ...
                  abs(data.phi_ice_cr - target_phi_cr) < tol & ...
                  abs(data.phi_ice_de - target_phi_de) < tol & ...
                  abs(data.Hp - target_Hp) < tol, 1);

if isempty(idx_target)
    warning('Design scelto non trovato! Uso il Best Fuel come target (grafico sarà piatto).');
    idx_target = idx_ref;
else
    fprintf('Confronto Riga %d (Ref) vs Riga %d (Scelto)\n', idx_ref, idx_target);
end

% --- 4. ESTRAZIONE E NORMALIZZAZIONE DATI ---
vals_ref = metrics_data(idx_ref, :);
vals_target = metrics_data(idx_target, :);

% Normalizzo rispetto al Reference (Best Fuel = 1.0)
% Attenzione ai valori zero (aggiungo eps)
vals_norm_ref = vals_ref ./ (vals_ref + eps);     % Sarà tutto 1 (tranne zeri)
vals_norm_target = vals_target ./ (vals_ref + eps); 

% --- 5. PLOT RADAR (Custom Implementation) ---
figure('Name', 'Radar_Comparison', 'Color', 'w', 'Position', [100 100 800 600]);

n_metrics = length(metric_labels);
% Angoli per le metriche (in radianti)
theta = linspace(0, 2*pi, n_metrics + 1); 

% Chiudo il cerchio aggiungendo il primo punto alla fine
rho_ref = [vals_norm_ref, vals_norm_ref(1)];
rho_target = [vals_norm_target, vals_norm_target(1)];

% -- Disegno Assi e Griglia --
ax = polaraxes;
hold on;

% 1. Disegno il Poligono REFERENCE (Best Fuel) - BLU
polarplot(theta, rho_ref, '-o', 'LineWidth', 2, 'Color', [0 0.4 0.8], 'MarkerFaceColor', [0 0.4 0.8]);
% Riempimento (opzionale, richiede patch in cartesiano, ma polarplot è più pulito per linee)

% 2. Disegno il Poligono TARGET (Scelto) - ROSSO
polarplot(theta, rho_target, '-o', 'LineWidth', 2, 'Color', [0.8 0.2 0.2], 'MarkerFaceColor', [0.8 0.2 0.2]);

% -- Formattazione --
ax.ThetaTick = rad2deg(theta(1:end-1));
ax.ThetaTickLabel = metric_labels;
ax.FontSize = 11;
ax.GridAlpha = 0.3;
ax.LineWidth = 1.5;

% Limiti asse radiale (Zoom intelligente)
max_val = max([rho_ref, rho_target]);
rlim([0, max_val * 1.1]); 

% Legenda
legend({'Best Fuel Design (Ref = 1.0)', 'Design Scelto'}, 'Location', 'southoutside', 'Orientation', 'horizontal');
title('Confronto Adimensionale (1.0 = Best Fuel)', 'FontSize', 14, 'FontWeight', 'bold');

% --- 6. TABELLA DI RIEPILOGO NELLA CONSOLE ---
fprintf('\n--- CONFRONTO DIRETTO ---\n');
fprintf('%-15s | %-15s | %-15s | %-10s\n', 'Metrica', 'Best Fuel', 'Scelto', 'Delta %');
fprintf('--------------------------------------------------------------\n');
for i = 1:n_metrics
    val_r = vals_ref(i);
    val_t = vals_target(i);
    delta_p = ((val_t - val_r) / val_r) * 100;
    
    fprintf('%-15s | %15.2f | %15.2f | %+9.1f%%\n', ...
        metric_labels{i}, val_r, val_t, delta_p);
end

% Salvataggio
saveas(gcf, 'Radar_Comparison.png');
disp('Radar chart generato.');