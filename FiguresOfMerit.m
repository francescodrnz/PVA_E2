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
    P_em   = data.P_em/1000;
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
target_WS = 300;
target_phi_cl = 0.1;
target_phi_cr = 0.1;
target_phi_de = 0.3;
target_Hp = 0.3;

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
scatter(W_batt, W_fuel, 40, P_em, 'filled', 'MarkerFaceAlpha', 0.7); 
colormap(hsv); c = colorbar; c.Label.String = 'Potenza elettrica installata [kW]';
grid on; xlabel('Massa Batterie [kg]'); ylabel('Block Fuel [kg]'); 
title('Trade-off: Fuel vs Batterie');
hold on;
scatter(W_batt(idx_best), W_fuel(idx_best), 250, P_em(idx_best), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
scatter(W_batt(idx_chosen), W_fuel(idx_chosen), 250, P_em(idx_chosen), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
add_text(W_batt(idx_chosen)*1.035, W_fuel(idx_chosen)*1.085, sprintf('Configurazione scelta:\nFuel: +%.0f kg\nBatterie: %.0f kg\nPotenza elettrica: %.0f kW',...
    W_fuel(idx_chosen)-min_fuel, W_batt(idx_chosen)-W_batt(idx_best), P_em(idx_chosen)-P_em(idx_best)));
saveas(1, 'FOM_1_Fuel_Batt.png');


% --- 5. PLOT 2: MTOW vs FUEL ---
figure('Name', '2_MTOW_vs_Fuel', 'Color', 'w');
scatter(MTOW, W_fuel, 40, W_batt, 'filled', 'MarkerFaceAlpha', 0.7);
colormap(parula); c = colorbar; c.Label.String = 'Batt Mass [kg]';
grid on; xlabel('MTOW [kg]'); ylabel('Block Fuel [kg]'); 
% title('Emissioni vs Costi');
hold on;
% scatter(MTOW(idx_best), W_fuel(idx_best), 250, W_batt(idx_best), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
% scatter(MTOW(idx_chosen), W_fuel(idx_chosen), 250, W_batt(idx_chosen), 'p', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
% add_text(MTOW(idx_chosen), W_fuel(idx_chosen), sprintf('Scelto\nMTOW: %.0f kg', MTOW(idx_chosen)));


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
    text(x_grp(end)*.9, y_grp(end)*.85, sprintf('HP=%.1f', curr_hp), 'FontSize', 11, 'Color', [0.4 0.4 0.4]);
end
scatter(P_el, P_ice, 40, W_fuel, 'filled', 'MarkerFaceAlpha', 0.8);
colormap(flipud(hot)); c = colorbar; c.Label.String = 'Block Fuel [kg]';
grid on; xlabel('Potenza Elettrica Totale [W]', 'FontWeight', 'bold');
ylabel('Potenza Termica Totale [W]', 'FontWeight', 'bold');
% title('Power Split', 'FontSize', 12);
delta_P_el = P_el(idx_chosen) - P_el(idx_best);
delta_P_ice = P_ice(idx_chosen) - P_ice(idx_best);




% --- SALVATAGGIO ---
% saveas(2, 'FOM_2_MTOW_Fuel.png');
% saveas(3, 'FOM_3_PowerSplit.png');

disp('Grafici generati. Plot 4 ora raggruppa per strategia Phi.');

%% --- 8. PLOT 5: PARADOSSO TERMICO (P_ice vs Fuel, color by P_em) ---
figure('Name', '5_Thermal_vs_Fuel_ColorPEM', 'Color', 'w');

% Scatter plot: Potenza Termica vs Fuel, colorato per Potenza Elettrica
sc = scatter(P_ice/1000, W_fuel, 60, P_em, 'filled', 'MarkerFaceAlpha', 0.7);

% Estetica assi
grid on;
xlabel('Potenza Termica Installata [kW]', 'FontWeight', 'bold');
ylabel('Block Fuel [kg]', 'FontWeight', 'bold');

% Colorbar: Mostra che il driver è l'elettrificazione
colormap(cool);
c = colorbar; 
c.Label.String = 'Potenza Elettrica Installata [kW]';

hold on;


% Salvataggio
saveas(gcf, 'FOM_5_Thermal_vs_Fuel.png');
fprintf('Grafico Paradosso Termico generato.\n');