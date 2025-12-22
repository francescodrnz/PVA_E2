%% SCRIPT ANALISI DETTAGLIATA CONFIGURAZIONE FINALE
% Questo script analizza SOLO la configurazione scelta ("Stella Verde")
% e genera i grafici di missione dettagliati.

clearvars; close all; clc;

% --- 1. CARICAMENTO DATI E REQUISITI ---
requisiti; 
dati; 
fusoliera;

% --- 2. IMPOSTAZIONE VARIABILI DI DESIGN (LA TUA SCELTA) ---
W_S_des     = 300;   % [kg/m^2]
Hp_des      = 0.3;   % Fattore ibridizzazione
phi_ice_cl  = 0.1;
phi_ice_cr  = 0.1;
phi_ice_de  = 0.3;

fprintf('--- AVVIO ANALISI CONFIGURAZIONE FINALE ---\n');
fprintf('W/S: %d | Hp: %.1f | Phi: [%.1f %.1f %.1f]\n', W_S_des, Hp_des, phi_ice_cl, phi_ice_cr, phi_ice_de);

% --- 3. INIZIALIZZAZIONE ---
Cd0 = Cd0_livello0;
k_polare = k_polare_livello0;
WTO_curr = 22767; % [kg] Partiamo dal valore che sappiamo essere giusto per velocizzare
delta_WTO = 1000;
tolleranza = 1; % Tolleranza stretta per massima precisione
iterazioni = 0;
iterazioni_max = 50;

% --- 4. CICLO DI CONVERGENZA (Singolo Punto) ---
while abs(delta_WTO) > tolleranza && iterazioni < iterazioni_max
    
    % Aggiornamento Geometria
    S_ref = WTO_curr / W_S_des; % [m^2]
    S_orizz = 0.3 * S_ref;
    S_vert = 0.2 * S_ref;
    b_ref = sqrt(AR_des * S_ref); 
    c_root = S_ref / ((b_ref - diametro_esterno_fus)/2 * (1 + lambda_des)); 
    MAC = 2/3 * c_root * (1 + lambda_des + lambda_des^2) / (1 + lambda_des); 
    
    % CL Crociera Richiesto
    CL_des = 2 * W_S_des * g / (rho_cruise * V_cruise^2); 
    
    % MATCHING CHART (Ricalcolo Potenza)
    matching_chart_script; 
    P_curr = P_W_des * WTO_curr; 
    
    % AERODINAMICA
    aerodinamica;
    
    % PRESTAZIONI (Qui si generano i vettori time, quota, P_nec, etc!)
    % Nota: Assicurati che lo script 'prestazioni' non abbia clearvars all'inizio
    prestazioni; 
    
    % PESI
    pesi_script;
    
    % Aggiornamento Convergenza
    WTO_precedente = WTO_curr;
    WTO_curr = W_payload + W_fuel + OEW_curr;
    delta_WTO = WTO_curr - WTO_precedente;
    iterazioni = iterazioni + 1;
end

if iterazioni < iterazioni_max
    fprintf('Convergenza raggiunta in %d iterazioni.\n', iterazioni);
    fprintf('MTOW Finale: %.2f kg\n', WTO_curr);
    fprintf('Block Fuel: %.2f kg\n', W_block_fuel);
else
    warning('Attenzione: Convergenza non raggiunta!');
end

%% --- 5. GENERAZIONE GRAFICI DI MISSIONE ---
%% --- 0. POST-PROCESSING DATI PER I GRAFICI ---
% Ricostruzione dei vettori di potenza per il plotting
% (Nel loop principale le componenti ICE ed EM non venivano salvate passo-passo)

% Inizializzazione vettori storici
P_ice_hist = zeros(size(P_nec));
P_em_hist  = zeros(size(P_nec));
SoC_hist   = zeros(size(E_batt)); % State of Charge [%]

% Capacità totale batteria (dall'ultimo step utile o input)
E_batt_total_capacity = max(E_batt)/0.8; 
if E_batt_total_capacity == 0, E_batt_total_capacity = 1; end % Evita div/0

% Ricostruzione logica basata sugli indici di fase
% 1. Taxi Out
idx = 1:i_taxi_out;
P_em_hist(idx)  = P_nec(idx); % Full electric
P_ice_hist(idx) = 0;

% 2. Takeoff
idx = (i_taxi_out+1):i_take_off;
% Al decollo è tutto full (approssimazione grafica basata sul tuo script)
% P_nec qui è P_em_inst + P_ice_inst
P_em_hist(idx)  = P_em; 
P_ice_hist(idx) = P_ice; 

% 3. Climb
idx = (i_take_off+1):i_climb;
P_ice_hist(idx) = phi_ice_cl * P_ice;
P_em_hist(idx)  = max(0, P_nec(idx) - P_ice_hist(idx));

% 4. Cruise
idx = (i_climb+1):i_cruise;
P_ice_hist(idx) = phi_ice_cr * P_ice;
P_em_hist(idx)  = max(0, P_nec(idx) - P_ice_hist(idx));

% 5. Descent
idx = (i_cruise+1):i_descent;
P_ice_hist(idx) = phi_ice_de * P_ice;
P_em_hist(idx)  = max(0, P_nec(idx) - P_ice_hist(idx));

% 6. Taxi In
idx = (i_descent+1):i_taxi_in;
P_em_hist(idx)  = P_nec(idx); % Full electric
P_ice_hist(idx) = 0;

% 7. Diversion (Climb + Cruise + Descent/Loiter)
idx = (i_taxi_in+1):length(P_nec);
P_ice_hist(idx) = P_nec(idx); % Full thermal
P_em_hist(idx)  = 0;

% Calcolo SoC (State of Charge inverso, visto che E_batt cresce nel tuo script)
% Assumo che E_batt sia l'energia CONSUMATA.
SoC_hist = 100 * (1 - E_batt ./ E_batt_total_capacity);

%% --- 1. eDEFINIZIONE STILI E COLORI ---
% Palette colori professionale
col_ice   = [0.8500 0.3250 0.0980]; % Arancione
col_em    = [0.4660 0.6740 0.1880]; % Verde
col_tot   = [0 0.4470 0.7410];      % Blu
col_fuel  = [0.6350 0.0780 0.1840]; % Rosso scuro
col_soc   = [0.9290 0.6940 0.1250]; % Giallo ocra
col_alt   = [0.4 0.4 0.4];          % Grigio scuro

% Indici di fine fase per disegnare le linee verticali
phase_indices = [i_taxi_out, i_take_off, i_climb, i_cruise, i_descent, i_taxi_in];
phase_names   = {'Taxi', 'TO', 'Climb', 'Cruise', 'Descent', 'Taxi'};

%% --- 2. GRAFICO MISSIONE STANDARD (A4 VERTICALE + PHI ANALYSIS) ---
% Troncamento dei dati
end_std = i_taxi_in;
t_std   = time(1:end_std) ./ 3600; % Tempo in ore

% --- IMPOSTAZIONE FIGURA VERTICALE (Simil A4) ---
% Position: [left, bottom, width, height] -> Stretto e Alto
fig1 = figure('Name', 'Analisi Missione Standard', 'Color', 'w', 'Position', [100 50 900 1100]);
t = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

% =========================================================================
% TILE 1: PROFILO DI MISSIONE (QUOTA E MASSA)
% =========================================================================
nexttile;

% Asse Sinistro: Quota
yyaxis left
area(t_std, quota(1:end_std), 'FaceColor', [0.94 0.94 0.94], 'EdgeColor', 'none', ...
    'HandleVisibility', 'off'); hold on;
plot(t_std, quota(1:end_std), 'Color', col_alt, 'LineWidth', 1.5, 'HandleVisibility', 'off');
ylabel('Quota [m]', 'FontWeight', 'bold');
ylim([0, h_cruise * 1.6]); % Spazio per le etichette
grid on; 
ax = gca; ax.YColor = 'k'; % Asse nero classico

% Asse Destro: Massa
yyaxis right
plot(t_std, W(1:end_std), 'Color', col_fuel, 'LineWidth', 2);
ylabel('Massa Velivolo [kg]', 'FontWeight', 'bold', 'Color', col_fuel);
ax = gca; ax.YColor = col_fuel;
xlim([0, t_std(end)]);

title('\textbf{Profilo di Missione e Fasi di Volo}', 'Interpreter', 'latex', 'FontSize', 12);

% --- Etichette Fasi (Sopra la quota) ---
yyaxis left
y_label_pos = h_cruise * 1.25; 
for k = 1:length(phase_indices)
    idx_ph = phase_indices(k);
    if k == 1, t_start = 0; else, t_start = time(phase_indices(k-1))/3600; end
    t_end = time(idx_ph)/3600;
    t_mid = (t_start + t_end) / 2;
    
    if k < length(phase_indices)
        xline(t_end, '--k', 'Alpha', 0.2, 'HandleVisibility', 'off');
    end
    
    text(t_mid, y_label_pos, phase_names{k}, 'HorizontalAlignment', 'center', ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2], ...
        'BackgroundColor', 'w', 'EdgeColor', [0.8 0.8 0.8], 'Margin', 3, 'Clipping', 'off');
end

% =========================================================================
% TILE 2: STRATEGIA ENERGETICA (STACKED AREA PLOT)
% =========================================================================
nexttile;
hold on; grid on;

% --- Calcolo Dati ---
P_tot_inst = P_ice_hist(1:end_std) + P_em_hist(1:end_std);
phi_em_inst = (P_em_hist(1:end_std) ./ P_em); % Frazione 0-1
phi_em_inst(isnan(phi_em_inst)) = 0; 

% --- ASSE SINISTRO: POTENZE (STACKED) ---
yyaxis left

% Preparo la matrice per lo stacked plot: [Colonna1_Sotto, Colonna2_Sopra]
% Colonna 1: ICE (Arancione)
% Colonna 2: EM (Verde, che si somma sopra)
Y_stack = [P_ice_hist(1:end_std), P_em_hist(1:end_std)] ./ 1000;

% Creazione Stacked Area
h_area = area(t_std, Y_stack, 'EdgeColor', 'none');

% Stile Area 1 (Sotto - Termica)
h_area(1).FaceColor = col_ice;
h_area(1).FaceAlpha = 0.6; % Leggera trasparenza

% Stile Area 2 (Sopra - Elettrica)
h_area(2).FaceColor = col_em;
h_area(2).FaceAlpha = 0.6;

% Aggiungo linee di contorno per definizione (opzionale ma bello)
% Linea di confine tra ICE ed EM
plot(t_std, P_ice_hist(1:end_std)/1000, 'Color', col_ice, 'LineWidth', 1.5);
% Linea Totale (Bordo superiore)
p_tot = plot(t_std, P_tot_inst/1000, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);

ylabel('Potenza [kW]', 'FontWeight', 'bold');
ylim([0, 6600]); 
ax = gca; ax.YColor = 'k';

% --- ASSE DESTRO: PHI EM ---
yyaxis right
p_phi = plot(t_std, phi_em_inst, '-.', 'Color', [0.2 0.5 0.2], 'LineWidth', 1.5);
ylabel('Frazione Potenza Elettrica \Phi_{EM}', 'FontWeight', 'bold', 'Color', [0.2 0.5 0.2]);
ax = gca; ax.YColor = [0.2 0.5 0.2];
ylim([0, 1]); 

% --- FIX GRIGLIA "INVISIBLE" ---
% Definisco i ticks esatti che voglio vedere (0, 0.2, 0.4...)
phi_ticks = 0 : 0.2 : 1.0;
yticks(phi_ticks); % Forza i numeri sull'asse

% Disegno le linee della griglia MANUALMENTE sopra tutto
% ':' = tratteggiata, Alpha = trasparenza
yline(phi_ticks, ':', 'Color', [0.2 0.5 0.2], 'LineWidth', 0.8, 'Alpha', 0.6);

% --- ANNOTAZIONI ---
phases_to_label = {'Climb', 'Cruise', 'Descent'};
phi_vals = [phi_ice_cl, phi_ice_cr, phi_ice_de];

yyaxis left % Torno a sx per il testo
for k = 1:length(phase_indices)
    current_phase = phase_names{k};
    if ismember(current_phase, phases_to_label)
        val_idx = find(strcmp(phases_to_label, current_phase));
        val_phi = phi_vals(val_idx);
        
        if k == 1, t_s = 0; else, t_s = time(phase_indices(k-1))/3600; end
        t_m = (t_s + time(phase_indices(k))/3600) / 2;
        
        % Posiziono la scritta "dentro" l'area arancione (più elegante)
        p_ice_local = mean(P_ice_hist( (time > t_s*3600) & (time < time(phase_indices(k))) )) / 1000;
        
        text(t_m, p_ice_local * 0.5, sprintf('\\Phi^{ICE} = %.1f', val_phi), ...
            'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold', ...
            'Color', 'w', 'EdgeColor', 'none'); % Testo bianco su sfondo arancione
    end
end

% Legenda personalizzata
% Uso h_area(1) e h_area(2) per mostrare i quadratini colorati
legend([h_area(1), h_area(2), p_tot, p_phi], ...
    {'Potenza Termica', 'Potenza Elettrica (Stacked)', 'Potenza Totale', '\Phi_{EM}'}, ...
    'Location', 'north', 'FontSize', 9, 'Orientation', 'horizontal');

title('\textbf{Strategia di Erogazione della Potenza}', 'Interpreter', 'latex', 'FontSize', 12);
xlim([0, t_std(end)]);

% Linee verticali
for k = 1:length(phase_indices)-1
    xline(time(phase_indices(k))/3600, '--k', 'Alpha', 0.2, 'HandleVisibility', 'off');
end

% =========================================================================
% TILE 3: CONSUMI (FUEL vs SOC) + BOX TOTALI
% =========================================================================
nexttile;

% --- Calcolo Totali ---
tot_fuel_kg = W(1) - W(end_std);
tot_batt_kwh = E_batt(end_std) / 1000; % Wh -> kWh

% --- ASSE SINISTRO: FUEL ---
yyaxis left
fuel_consumed = W(1) - W(1:end_std);
plot(t_std, fuel_consumed, 'Color', col_fuel, 'LineWidth', 2);
ylabel('Fuel Consumato [kg]', 'FontWeight', 'bold', 'Color', col_fuel);
ylim([0 320])
ax = gca; ax.YColor = col_fuel;
grid on; hold on;

% Boxino FUEL (Rosso) - Posizionato in alto a destra (dove finisce la curva)
text(t_std(end)*.95, tot_fuel_kg*.85, ...
    sprintf('\\textbf{Tot: %.1f kg}', tot_fuel_kg), ...
    'Interpreter', 'latex', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ... % Appoggia sopra la linea
    'FontSize', 10, ...
    'Color', col_fuel, ...
    'BackgroundColor', 'w', ...
    'EdgeColor', col_fuel, ...
    'Margin', 3);

% --- ASSE DESTRO: BATTERIA ---
yyaxis right
plot(t_std, SoC_hist(1:end_std), 'Color', col_em, 'LineWidth', 2);
ylabel('SoC Batteria [%]', 'FontWeight', 'bold', 'Color', col_em, 'Interpreter', 'none');
ax = gca; ax.YColor = col_em;
ylim([0 100]);

% Boxino BATTERIA (Verde) - Posizionato in basso a destra (dove finisce la curva)
% Lo alzo leggermente (coord Y = 10%) per non farlo toccare terra
text(t_std(end)*.95, 12, ...
    sprintf('\\textbf{Uso: %.1f / %.1f kWh}', tot_batt_kwh, E_batt_total_capacity/1000), ...
    'Interpreter', 'latex', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10, ...
    'Color', col_em, ...
    'BackgroundColor', 'w', ...
    'EdgeColor', col_em, ...
    'Margin', 3);

% Linee verticali
for k = 1:length(phase_indices)-1
    xline(time(phase_indices(k))/3600, '--k', 'Alpha', 0.2, 'HandleVisibility', 'off');
end

xlabel('Tempo di missione [h]', 'FontWeight', 'bold');
xlim([0, t_std(end)]);
title('\textbf{Consumi Energetici: Batteria e Carburante}', 'Interpreter', 'latex', 'FontSize', 12);

% --- SALVATAGGIO ---
exportgraphics(fig1, 'Analisi_Missione_Standard.png', 'Resolution', 300);
fprintf('Grafico Missione Standard (Verticale A4 + Phi + Totali) salvato.\n');

%% --- 3. GRAFICO DIVERSIONE ---
% Indici per la diversione
start_div = i_taxi_in + 1;
end_div   = length(time);

if end_div > start_div
    t_div = (time(start_div:end_div) - time(start_div)) ./ 60; % Tempo diversione in MINUTI
    
    fig2 = figure('Name', 'Analisi Diversione', 'Color', 'w', 'Position', [150 150 1000 500]);
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % --- PLOT D1: Profilo di Volo Diversione ---
    nexttile;profi
    area(t_div, quota(start_div:end_div), 'FaceColor', [0.95 0.95 0.95], 'EdgeColor', col_tot, 'LineWidth', 1.5);
    hold on;
    yline(h_cruise_diversion, '--', 'Color', [0.5 0.5 0.5], 'Label', 'Quota Crociera Div.');
    
    % Evidenzio il Loiter se presente
    if z_loiter_trigger > 0
        yline(z_loiter_trigger, ':', 'Color', 'r', 'LineWidth', 1.5, 'Label', 'Quota Loiter');
    end
    
    grid on;
    xlabel('Tempo dall''inizio diversione [min]', 'FontWeight', 'bold');
    ylabel('Quota [m]', 'FontWeight', 'bold');
    title('\textbf{Profilo di Volo: Diversione + Loiter}', 'Interpreter', 'latex');
    xlim([0, t_div(end)]);
    
    % --- PLOT D2: Consumo Fuel vs Potenza Termica ---
    nexttile;
    
    % ASSE SINISTRO: FUEL (Rosso)
    yyaxis left
    fuel_cons_div = W(start_div) - W(start_div:end_div);
    plot(t_div, fuel_cons_div, 'Color', col_fuel, 'LineWidth', 2);
    ylabel('Carburante Consumato [kg]', 'FontWeight', 'bold', 'Color', col_fuel);
    ax = gca; ax.YColor = col_fuel;
    ylim([0, max(fuel_cons_div)*1.2]); % Un po' di margine in alto
    
    hold on;
    % Evidenzio consumo totale testuale
    text(t_div(end)*0.05, max(fuel_cons_div)*0.95, ...
        sprintf('Fuel Totale: %.1f kg', max(fuel_cons_div)), ...
        'BackgroundColor', 'w', 'EdgeColor', col_fuel, 'Color', col_fuel, 'FontSize', 9);
    
    % ASSE DESTRO: POTENZA ICE (Arancione)
    yyaxis right
    % Recupero la potenza termica (in Diversione è Full Thermal, quindi P_ice = P_nec)
    P_div_kw = P_ice_hist(start_div:end_div) ./ 1000; 
    plot(t_div, P_div_kw, '-.', 'Color', col_ice, 'LineWidth', 1.5);
    ylabel('Potenza Motori Termici (ICE) [kW]', 'FontWeight', 'bold', 'Color', col_ice);
    ax = gca; ax.YColor = col_ice;
    
    grid on;
    xlabel('Tempo dall''inizio diversione [min]', 'FontWeight', 'bold');
    title('\textbf{Consumo Carburante e Potenza Erogata}', 'Interpreter', 'latex');
    xlim([0, t_div(end)]);
    
    % Legenda combinata
    legend({'Carburante [kg]', 'Potenza ICE [kW]'}, 'Location', 'northeast', 'Orientation', 'horizontal');
    
    exportgraphics(fig2, 'Analisi_Diversione.png', 'Resolution', 300);
end

%% --- 4. ANALISI IMPATTO AMBIENTALE ---
fprintf('\n--- CALCOLO METRICHE AMBIENTALI ---\n');

% --- 1. DATI & COSTANTI ---
EI_CO2 = 3.16;          % [kg CO2 / kg Fuel] Emission Index standard Jet-A1
Energy_Density_Fuel = 43.1; % [MJ/kg] Densità energetica specifica Kerosene
N_pax = 40;             % Numero passeggeri
Range_km = range + 0; % [km] Assumiamo il range di progetto (556 km) 
% Nota: se range_cruise è in km bene, se in nm converti: range_cruise*1.852

% --- 2. CALCOLI PER IL TUO AEREO (Hybrid) ---
Fuel_Hybrid_kg = W_block_fuel;              % [kg] Calcolato dalla missione
CO2_Hybrid_total = Fuel_Hybrid_kg * EI_CO2; % [kg] Totale CO2
% Metrica Specifica
CO2_Hybrid_specific = (CO2_Hybrid_total * 1000) / (N_pax * Range_km); % [g/pax/km]

% Analisi Energia Totale (Fuel + Batt)
Energy_Fuel_MJ = Fuel_Hybrid_kg * Energy_Density_Fuel; 
Energy_Batt_MJ = (E_batt(end_std) / 1000) * 3.6; % kWh -> MJ (1 kWh = 3.6 MJ)
Energy_Total_MJ = Energy_Fuel_MJ + Energy_Batt_MJ;

% --- 3. DEFINIZIONE BENCHMARK (Turboprop Convenzionale - ATR 42-600) ---
% Fonte: ATR 42-600 Factsheet (300 nm mission) -> Block Fuel ~800 kg
Fuel_Ref_kg = 802;          % [kg] Dato ufficiale ATR per 300 nm
Pax_max_ATR = 48;
Load_Factor_Ref = 1.0;     % Fattore di carico realistico (85%)
Pax_Ref_Actual = Pax_max_ATR * Load_Factor_Ref; % ~34 passeggeri

CO2_Ref_total = Fuel_Ref_kg * EI_CO2;     % 802 * 3.16 = 2534 kg CO2
% Calcolo specifico con Load Factor realistico
CO2_Ref_specific = (CO2_Ref_total * 1000) / (Pax_Ref_Actual * Range_km); 
Energy_Ref_MJ = Fuel_Ref_kg * Energy_Density_Fuel; % Tutto dal fuel

% Calcolo Riduzione
Reduction_CO2 = (1 - CO2_Hybrid_specific / CO2_Ref_specific) * 100;

fprintf('Emissioni CO2 Totali: %.1f kg (Hybrid) vs %.1f kg (Ref)\n', CO2_Hybrid_total, CO2_Ref_total);
fprintf('Metrica Specifica:    %.1f g/pax/km (Hybrid) vs %.1f g/pax/km (Ref)\n', CO2_Hybrid_specific, CO2_Ref_specific);
fprintf('RIDUZIONE STIMATA:    %.1f%%\n', Reduction_CO2);

% --- 4. GRAFICO REPORT AMBIENTALE (FIXED) ---
fig_env = figure('Name', 'Impatto Ambientale', 'Color', 'w', 'Position', [150 150 1000 500]);

% FIX: 'large' -> 'loose' (compatibile con la tua versione)
t_env = tiledlayout(1, 2, 'TileSpacing', 'loose', 'Padding', 'compact');

% --- PLOT A: CONFRONTO EMISSIONI (Bar Chart) ---
nexttile;
data_co2 = [CO2_Ref_specific, CO2_Hybrid_specific];
b = bar(data_co2, 'FaceColor', 'flat');
b.CData(1,:) = [0.6 0.6 0.6]; % Grigio (Reference)
b.CData(2,:) = [0.2 0.6 0.3]; % Verde (Hybrid)

ylabel('Emissioni Specifiche [g CO_2 / pax \cdot km]', 'FontWeight', 'bold');
xticklabels({'ATR-42 600', 'Velivolo Ibrido'});
grid on;
title('\textbf{Confronto Emissioni di $CO_2$}', 'Interpreter', 'latex', 'FontSize', 12);

% Aggiungo etichette sopra le barre
text(1, CO2_Ref_specific, sprintf('%.0f g', CO2_Ref_specific), ...
    'Vert', 'bottom', 'Horiz', 'center', 'FontWeight', 'bold');
text(2, CO2_Hybrid_specific, sprintf('%.0f g', CO2_Hybrid_specific), ...
    'Vert', 'bottom', 'Horiz', 'center', 'FontWeight', 'bold', 'Color', [0.2 0.6 0.3]);

% Freccia Riduzione (Testo semplice posizionato a metà)
mid_y = (CO2_Ref_specific + CO2_Hybrid_specific)/2;
text(1.85, mid_y, sprintf('\\bf\\downarrow -%.1f%%', Reduction_CO2), ...
    'Horiz', 'center', 'Color', [0.2 0.6 0.3], 'FontSize', 14);


% --- PLOT B: MIX ENERGETICO (Stacked Bar Orizzontale) ---
nexttile;
% Creo matrice: [Fuel, Battery] per Ref e Hybrid
data_energy = [Energy_Ref_MJ, 0; Energy_Fuel_MJ, Energy_Batt_MJ]; 
% Normalizzo a 100% per vedere il mix
data_energy_perc = (data_energy ./ sum(data_energy, 2)) * 100;

b_mix = barh(data_energy_perc, 'stacked');
b_mix(1).FaceColor = [0.8 0.3 0.3]; % Rosso (Fuel)
b_mix(2).FaceColor = [0.2 0.7 0.4]; % Verde (Batteria)

xlabel('Ripartizione Energia Totale Utilizzata [%]', 'FontWeight', 'bold');
yticklabels({'ATR-42 600', 'Hybrid Design'});
xlim([0 100]);
legend({'Energia da Carburante', 'Energia da Batterie'}, 'Location', 'southoutside');
title('\textbf{Energy Source Mix}', 'Interpreter', 'latex', 'FontSize', 12);

% Aggiungo percentuali sulle barre (Hybrid)
% Fuel
text(data_energy_perc(2,1)/2, 2, sprintf('%.0f%%', data_energy_perc(2,1)), ...
    'Color', 'w', 'FontWeight', 'bold', 'Horiz', 'center');
text(50, 1, sprintf('%.0f%%', 100), ...
    'Color', 'w', 'FontWeight', 'bold', 'Horiz', 'center');
% Batt
text(data_energy_perc(2,1) + data_energy_perc(2,2)/2, 2, sprintf('%.0f%%', data_energy_perc(2,2)), ...
    'Color', 'k', 'FontWeight', 'bold', 'Horiz', 'center');

% --- SALVATAGGIO ---
exportgraphics(fig_env, 'Analisi_Impatto_Ambientale.png', 'Resolution', 300);
fprintf('Grafico Ambientale salvato.\n');