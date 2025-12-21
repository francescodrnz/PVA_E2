%% Script Radar Chart - Confronto Finale (Leggibilità Ottimizzata)
clc; close all;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% --- 2. SELEZIONE METRICHE ---
try
    metrics_data = [ ...
        data.W_block_fuel, ...  % 1. Fuel
        data.WTO, ...           % 2. MTOW
        data.OEW, ...           % 3. OEW
        data.W_battery, ...     % 4. Peso Batterie
        data.P_em, ...          % 5. Potenza Elettrica
        data.P_ice, ...         % 6. Potenza Termica
        data.W_propuls, ...     % 7. Massa Propulsori
        data.S ...              % 8. Superficie Alare
    ];
    
    metric_labels = {'Block Fuel', 'MTOW', 'OEW', 'Massa Batterie', 'P_{EM}', 'P_{ICE}', 'Massa Propulsori', 'Sup. Alare'};
catch
    error('Errore: I nomi delle colonne nel CSV non corrispondono.');
end

% --- 3. IDENTIFICAZIONE CONFIGURAZIONI ---
% A) REFERENCE: BEST FUEL
[~, idx_ref] = min(abs(data.W_block_fuel-298.77));

% B) TARGET: DESIGN SCELTO
target_WS = 300; 
target_phi_cl = 0.1; 
target_phi_cr = 0.1; 
target_phi_de = 0.3; 
target_Hp = 0.3;
tol = 1e-4; 

idx_target = find(abs(data.W_S - target_WS) < tol & ...
                  abs(data.phi_ice_cl - target_phi_cl) < tol & ...
                  abs(data.phi_ice_cr - target_phi_cr) < tol & ...
                  abs(data.phi_ice_de - target_phi_de) < tol & ...
                  abs(data.Hp - target_Hp) < tol, 1);

if isempty(idx_target)
    warning('Design esatto non trovato! Cerco il più vicino al Fuel=118.5 kg.');
    [~, idx_target] = min(abs(data.W_block_fuel - 118.5));
end

% --- 4. ESTRAZIONE E NORMALIZZAZIONE ---
vals_ref = metrics_data(idx_ref, :);
vals_target = metrics_data(idx_target, :);

% Normalizzazione (Reference = 1.0)
vals_norm_ref = vals_ref ./ vals_ref;         
vals_norm_target = vals_target ./ vals_ref;   

% --- 5. PLOT RADAR ---
figure('Name', 'Radar_Comparison', 'Color', 'w', 'Position', [100 100 900 700]); % Un po' più alto
n_metrics = length(metric_labels);
theta = linspace(0, 2*pi, n_metrics + 1); 

rho_ref = [vals_norm_ref, vals_norm_ref(1)];
rho_target = [vals_norm_target, vals_norm_target(1)];

% --- NUOVI COLORI PER LE LINEE (Per non confondere con le % rosse/verdi) ---
col_ref = [0 0.4470 0.7410];    % Blu (Riferimento)
col_tgt = [0.7500 0.9250 0.2980]; % Arancione (Target)

ax = polaraxes;
hold on;

% Plot Linee con NUOVI COLORI
polarplot(theta, rho_ref, '-o', 'LineWidth', 2, ...
    'Color', col_ref, 'MarkerFaceColor', col_ref);

polarplot(theta, rho_target, '-o', 'LineWidth', 3, ...
    'Color', col_tgt, 'MarkerFaceColor', col_tgt);

% --- AGGIUNTA ETICHETTE PERCENTUALI (POSIZIONAMENTO SMART) ---
for i = 1:n_metrics
    val_norm = vals_norm_target(i);
    pct_diff = (val_norm - 1) * 100;
    
    if abs(pct_diff) > 0.1
        txt_str = sprintf('%+.1f%%', pct_diff);
        
        % Colori testo (restano rosso/verde per significato semantico)
        txt_col_neg = [0.2 0.5 0.2]; % Verde scuro (Bene, es. -Peso)
        txt_col_pos = [0.7 0.1 0.1]; % Rosso scuro (Male, es. +Fuel)

        if pct_diff < 0
            txt_col = txt_col_neg;
            base_offset = -0.04; % Di base spingo dentro
        else
            txt_col = txt_col_pos;
            base_offset = 0.04;  % Di base spingo fuori
        end
        
        % --- CORREZIONI MANUALI PER SOVRAPPOSIZIONI ---
        rad_offset = base_offset; 
        
        % 1. Fix per "Block Fuel" (i=1): spingere più in fuori per non coprire l'asse
        if i == 1 && pct_diff > 0
             rad_offset = +.05; 
        end

        % 2. Fix per le etichette in basso (i=6, 7, 8) che facevano mucchio.
        % Le spingo tutte FUORI e le sfalso (staggering).
        if i == 6 % P_ICE
            rad_offset = 0.06;
        elseif i == 7 % Massa Prop.
            rad_offset = 0.06; % La più esterna
        elseif i == 8 % Sup. Alare
            rad_offset = 0.06;
        end
        
        % Allineamento verticale in base all'offset
        if rad_offset > 0
             vertical_align = 'bottom'; % Testo sopra il punto
        else
             vertical_align = 'top';    % Testo sotto il punto
        end
        
        % Plot del testo
        text(theta(i), val_norm + rad_offset, txt_str, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', vertical_align, ...
            'FontSize', 9, 'FontWeight', 'bold', 'Color', txt_col, ...
            'BackgroundColor', 'w', 'Margin', 0.5); 
    end
end

% -- FORMATTAZIONE GRID --
ax.RTick = 0.80 : 0.05 : 1.30;   
labels = cell(size(ax.RTick));
for i = 1:length(ax.RTick)
    val = ax.RTick(i);
    if abs(rem(val, 0.10)) < 0.001 || abs(rem(val, 0.10)) > 0.099
        labels{i} = sprintf('%.1f', val); 
    else
        labels{i} = ''; 
    end
end
ax.RTickLabel = labels;
ax.GridAlpha = 0.25; 
ax.LineWidth = 1.0; 

% Formattazione Assi
ax.ThetaTick = rad2deg(theta(1:end-1));
ax.ThetaTickLabel = metric_labels;
ax.FontSize = 11;
ax.RAxisLocation = 90; 
rlim([0.8 1.15]); % Zoom leggermente allargato per le nuove etichette

% -- LEGENDA (Aggiornata con i nuovi colori) --
str_scelto = sprintf('Design Scelto (W/S=%d, H_P=%.1f, \\Phi=[%.1f, %.1f, %.1f])', ...
    data.W_S(idx_target), data.Hp(idx_target), ...
    data.phi_ice_cl(idx_target), data.phi_ice_cr(idx_target), data.phi_ice_de(idx_target));
str_ref = sprintf('Block Fuel Inferiore (W/S=%d, H_P=%.1f, \\Phi=[%.1f, %.1f, %.1f])', ...
    data.W_S(idx_ref), data.Hp(idx_ref), ...
    data.phi_ice_cl(idx_ref), data.phi_ice_cr(idx_ref), data.phi_ice_de(idx_ref));

legend({str_ref, str_scelto}, ...
    'Location', 'southoutside', 'Orientation', 'vertical', 'FontSize', 11);

title('Confronto configurazione scelta vs. < 2 MW con block fuel inferiore', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'Radar_Comparison.png');