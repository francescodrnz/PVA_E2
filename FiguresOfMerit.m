%% Script per Analisi Figures of Merit (FOM) - E2
clc; clearvars; close all;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% --- 2. ASSEGNAZIONE VARIABILI OUTPUT ---
try
    % Variabili Base
    W_fuel = data.W_block_fuel;    
    W_batt = data.W_battery;       
    MTOW   = data.WTO;             
    WS     = data.W_S;             
    
    % Variabili Potenza
    if ismember('P_em', data.Properties.VariableNames)
        P_el = data.P_em;      
    elseif ismember('P_el_tot', data.Properties.VariableNames)
        P_el = data.P_el_tot;
    elseif ismember('P_em_max', data.Properties.VariableNames)
        P_el = data.P_em_max;
    else
        warning('Colonna P_em non trovata. Uso dummy.'); P_el = W_batt * 1.5; 
    end

    if ismember('P_ice', data.Properties.VariableNames)
        P_ice = data.P_ice;    
    elseif ismember('P_ice_tot', data.Properties.VariableNames)
        P_ice = data.P_ice_tot;
    elseif ismember('P_th_max', data.Properties.VariableNames)
        P_ice = data.P_th_max;
    else
        warning('Colonna P_ice non trovata. Uso dummy.'); P_ice = MTOW * 0.2; 
    end

    % Variabili di Input (Design Parameters)
    in_WS = data.W_S;
    in_Hp = data.Hp;
    in_phi_cl = data.phi_ice_cl;
    in_phi_cr = data.phi_ice_cr;
    in_phi_de = data.phi_ice_de;
    
catch
    warning('Errore lettura colonne. Verifica i nomi nel CSV.');
end

% --- 3. IDENTIFICAZIONE CONFIGURAZIONI ---

% A) BEST FUEL
[min_fuel, idx_best] = min(W_fuel);

% B) DESIGN SCELTO
target_WS = 280;
target_phi_cl = 0.1;
target_phi_cr = 0.1;
target_phi_de = 0.3;
target_Hp = 0.4;

tol = 1e-4;
idx_chosen = find(abs(in_WS - target_WS) < tol & ...
                  abs(in_phi_cl - target_phi_cl) < tol & ...
                  abs(in_phi_cr - target_phi_cr) < tol & ...
                  abs(in_phi_de - target_phi_de) < tol & ...
                  abs(in_Hp - target_Hp) < tol, 1);

if isempty(idx_chosen)
    idx_chosen = idx_best; 
    disp('Design scelto non trovato, uso Best Fuel.');
else
    fprintf('Configurazione Scelta: Riga %d\n', idx_chosen);
end

add_text = @(x, y, txt) text(x + (max(x)-min(x))*0.03, y + (max(y)-min(y))*0.03, txt, ...
    'VerticalAlignment', 'bottom', 'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', 'k');

% --- CREAZIONE GRUPPI PHI PER LE LINEE (PLOT 4) ---
% Creo un identificatore univoco per ogni combinazione di Phi
% Esempio: "0.1_0.1_0.3"
phi_tags = string(in_phi_cl) + "_" + string(in_phi_cr) + "_" + string(in_phi_de);
u_phi_tags = unique(phi_tags);


% --- 4. PLOT 1: FUEL vs BATTERIE ---
figure('Name', '1_Fuel_vs_Batt', 'Color', 'w');
scatter(W_batt, W_fuel, 40, MTOW, 'filled', 'MarkerFaceAlpha', 0.7); 
colormap(jet); c = colorbar; c.Label.String = 'MTOW [kg]';
grid on; xlabel('Massa Batterie [kg]'); ylabel('Block Fuel [kg]'); 
title('Trade-off: Fuel vs Batterie');
hold on;
scatter(W_batt(idx_best), W_fuel(idx_best), 250, MTOW(idx_best), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
scatter(W_batt(idx_chosen), W_fuel(idx_chosen), 250, MTOW(idx_chosen), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
add_text(W_batt(idx_chosen), W_fuel(idx_chosen), sprintf('Scelto\nFuel: +%.0f kg', W_fuel(idx_chosen)-min_fuel));


% --- 5. PLOT 2: MTOW vs FUEL ---
figure('Name', '2_MTOW_vs_Fuel', 'Color', 'w');
scatter(MTOW, W_fuel, 40, W_batt, 'filled', 'MarkerFaceAlpha', 0.7);
colormap(parula); c = colorbar; c.Label.String = 'Batt Mass [kg]';
grid on; xlabel('MTOW [kg]'); ylabel('Block Fuel [kg]'); 
title('Ambiente vs Costi');
hold on;
scatter(MTOW(idx_best), W_fuel(idx_best), 250, W_batt(idx_best), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
scatter(MTOW(idx_chosen), W_fuel(idx_chosen), 250, W_batt(idx_chosen), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
add_text(MTOW(idx_chosen), W_fuel(idx_chosen), sprintf('Scelto\nMTOW: %.0f kg', MTOW(idx_chosen)));


% --- 6. PLOT 3: POTENZA TERMICA vs ELETTRICA (LINEE HP) ---
figure('Name', '3_Power_Split', 'Color', 'w');
hold on;
u_Hp = unique(in_Hp);
for i = 1:length(u_Hp)
    curr_hp = u_Hp(i);
    idx_grp = find(abs(in_Hp - curr_hp) < 1e-4);
    x_grp = P_el(idx_grp); y_grp = P_ice(idx_grp);
    [x_grp, sort_ord] = sort(x_grp); y_grp = y_grp(sort_ord);
    plot(x_grp, y_grp, '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
    % text(x_grp(end), y_grp(end), sprintf(' Hp=%.1f', curr_hp), 'FontSize', 8, 'Color', [0.4 0.4 0.4]);
end
scatter(P_el, P_ice, 40, W_fuel, 'filled', 'MarkerFaceAlpha', 0.8);
colormap(flipud(hot)); c = colorbar; c.Label.String = 'Block Fuel [kg]';
grid on; xlabel('Potenza Elettrica Totale [kW]', 'FontWeight', 'bold');
ylabel('Potenza Termica Totale [kW]', 'FontWeight', 'bold');
title('Power Split (Linee a Hp cost)', 'FontSize', 12);
scatter(P_el(idx_best), P_ice(idx_best), 250, W_fuel(idx_best), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
scatter(P_el(idx_chosen), P_ice(idx_chosen), 250, W_fuel(idx_chosen), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
delta_P_el = P_el(idx_chosen) - P_el(idx_best);
delta_P_ice = P_ice(idx_chosen) - P_ice(idx_best);
txt_str = sprintf('Scelto:\n\\Delta P_{el}: %.0f kW\n\\Delta P_{ice}: %.0f kW', delta_P_el, delta_P_ice);
add_text(P_el(idx_chosen), P_ice(idx_chosen), txt_str);


% --- 7. PLOT 4: SIZING ELETTRICO (LINEE PHI STRATEGY) ---
figure('Name', '4_Electric_Sizing', 'Color', 'w');
hold on;

% Disegno linee per ogni combinazione di Phi (Strategia Energetica)
% Colori diversi per le linee per distinguerle leggermente o grigio uniforme
for i = 1:length(u_phi_tags)
    curr_tag = u_phi_tags(i);
    idx_grp = find(phi_tags == curr_tag);
    
    x_grp = W_batt(idx_grp);
    y_grp = P_el(idx_grp);
    
    % Ordina per avere linee pulite
    [x_grp, sort_ord] = sort(x_grp);
    y_grp = y_grp(sort_ord);
    
    % Disegna linea solo se ci sono almeno 2 punti
    if length(x_grp) > 1
        plot(x_grp, y_grp, '-.', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8);
        
        % Etichetta (opzionale, magari solo per alcune per non affollare)
        % Mostriamo solo Phi Crociera che è il driver principale dell'energia
        % Recupero il valore di phi_cr dal primo elemento del gruppo
        val_phi_cr = in_phi_cr(idx_grp(1));
        
        % Metto etichetta solo alla fine della linea
        text(x_grp(end), y_grp(end), sprintf(' \\Phi_{cr}=%.1f', val_phi_cr), ...
             'FontSize', 7, 'Color', [0.3 0.3 0.3], 'VerticalAlignment', 'middle');
    end
end

scatter(W_batt, P_el, 40, MTOW, 'filled', 'MarkerFaceAlpha', 0.8);
colormap(jet); c = colorbar; c.Label.String = 'MTOW [kg]';
grid on;
xlabel('Massa Batterie (Energia) [kg]', 'FontWeight', 'bold');
ylabel('Potenza Elettrica (Power) [kW]', 'FontWeight', 'bold');
title('Sizing Elettrico: Linee a Strategia (\Phi) costante', 'FontSize', 12);

scatter(W_batt(idx_best), P_el(idx_best), 250, MTOW(idx_best), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
scatter(W_batt(idx_chosen), P_el(idx_chosen), 250, MTOW(idx_chosen), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
add_text(W_batt(idx_chosen), P_el(idx_chosen), 'Scelto');


% --- SALVATAGGIO ---
saveas(1, 'FOM_1_Fuel_Batt.png');
saveas(2, 'FOM_2_MTOW_Fuel.png');
saveas(3, 'FOM_3_PowerSplit.png');
saveas(4, 'FOM_4_ElecSizing.png');

disp('Grafici generati. Plot 4 ora raggruppa per strategia Phi.');