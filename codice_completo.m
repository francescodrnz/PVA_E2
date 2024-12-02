tic
clearvars;close all;clc;requisiti;dati;fusoliera;

% ciclo principale
% definisco vettori delle variabili di design
W_S_vect = [250 300 350]; % [kg/m^2]
phi_ice_cl_vect = [0.1 0.3 0.5];
phi_ice_cr_vect = [0.1 0.2 0.3 0.4 0.5];
phi_ice_de_vect = [0.1 0.3];
Hp_vect = [0.1 0.2 0.3 0.4]; % fattore di ibridizzazione

% primo blocco: matching chart per avere T/W, servono alcuni valori della
% polare che non abbiamo.
Cd0 = Cd0_livello0; % inizializzo valore del ciclo
k_polare = k_polare_livello0;

% inizializzazione ciclo
W_inizializzazione = 10000; % [kg] stima preliminare a caso

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]

% Preallocazione degli array per memorizzare i risultati
preallocazione;

% ciclo di dimensionamento
for i_W_S = 1:length(W_S_vect)
    for i_Hp = 1:length(Hp_vect)
        for i_phi_ice_cl = 1:length(phi_ice_cl_vect)
            for i_phi_ice_cr = 1:length(phi_ice_cr_vect)
                for i_phi_ice_de = 1:length(phi_ice_de_vect)
                    % step 1: dichiarare variabili di design che si aggiornano
                    W_S_des = W_S_vect(i_W_S);
                    Hp_des = Hp_vect(i_Hp);
                    phi_ice_cl = phi_ice_cl_vect(i_phi_ice_cl);
                    phi_ice_cr = phi_ice_cr_vect(i_phi_ice_cr);
                    phi_ice_de = phi_ice_de_vect(i_phi_ice_de);

                    % ciclo di convergenza sul peso
                    delta_WTO = 1000; % [kg] inizializzazione per entrare nel while
                    WTO_curr = W_inizializzazione;
                    iterazioni = 0;
                    while abs(delta_WTO) > tolleranza && iterazioni < 1000
                        % definisco variabili derivate che si aggiornano
                        S_ref = WTO_curr / W_S_des; % [m^2]
                        b_ref = sqrt(AR_des*S_ref);  % [m]
                        standard_mean_chord_ala = b_ref/AR_des; % [m]
                        CL_des = 2*W_S_des*g/(rho_cruise*V_cruise^2); % [] CL di crociera

                        % MATCHING CHART
                        matching_chart_script;
                        P_curr = P_W_des * WTO_curr; % [W] output del matching chart
                        % AERODINAMICA
                        aerodinamica;

                        % PRESTAZIONI
                        E_curr = CL_des/CD_curr; % CD_curr da aerodinamica cd0+cdi+cdw
                        prestazioni;

                        % PESI
                        pesi_script;

                        % aggiornamento WTO
                        WTO_precedente = WTO_curr;
                        WTO_curr = W_payload + W_fuel + OEW_curr;

                        delta_WTO = WTO_curr - WTO_precedente;
                        iterazioni = iterazioni + 1;
                    end

                    if all(phi_em <= 1)
                        % Memorizzazione dei risultati dopo la convergenza
                        indice_contatore = indice_contatore+1;
                        W_S_des_memo(indice_contatore) = W_S_des;
                        W_S_max_memo(indice_contatore) = W_S_max;
                        WTO_memo(indice_contatore) = WTO_curr;
                        CL_des_memo(indice_contatore) = CL_des;
                        E_curr_memo(indice_contatore) = E_curr;
                        P_curr_memo(indice_contatore) = P_curr;
                        P_tot_memo(indice_contatore) = P_tot;
                        P_ice_memo(indice_contatore) = P_ice;
                        P_em_memo(indice_contatore) = P_em;
                        S_ref_memo(indice_contatore) = S_ref;
                        OEW_memo(indice_contatore) = OEW_curr;
                        W_wing_memo(indice_contatore) = W_wing;
                        W_fus_memo(indice_contatore) = W_fus;
                        W_tail_memo(indice_contatore) = W_tail;
                        W_LG_memo(indice_contatore) = W_LG;
                        W_propuls_memo(indice_contatore) = W_propulsione;
                        W_fuelsys_memo(indice_contatore) = W_fuelsys;
                        W_hydr_memo(indice_contatore) = W_hydraulic;
                        W_elec_memo(indice_contatore) = W_elec;
                        W_antiice_memo(indice_contatore) = W_antiice;
                        W_instr_memo(indice_contatore) = W_instr;
                        W_avionics_memo(indice_contatore) = W_avionics;
                        W_engine_sys_memo(indice_contatore) = W_engine_sys;
                        W_furn_memo(indice_contatore) = W_furn;
                        W_services_memo(indice_contatore) = W_services;
                        W_crew_memo(indice_contatore) = W_crew;
                        W_fuel_memo(indice_contatore) = W_fuel;
                        W_block_fuel_memo(indice_contatore) = W_block_fuel;
                        W_payload_memo(indice_contatore) = W_payload;
                    end
                end
            end
        end
    end
end
toc
tic
% Creazione della tabella
T = array2table([W_S_des_memo(1:indice_contatore), W_S_max_memo(1:indice_contatore), 
    WTO_memo(1:indice_contatore), CL_des_memo(1:indice_contatore), ...
    E_curr_memo(1:indice_contatore), P_curr_memo(1:indice_contatore), ...
    P_tot_memo(1:indice_contatore), P_ice_memo(1:indice_contatore), ...
    P_em_memo(1:indice_contatore),...
    S_ref_memo(1:indice_contatore), OEW_memo(1:indice_contatore), ...
    W_wing_memo(1:indice_contatore), W_fus_memo(1:indice_contatore), ...
    W_tail_memo(1:indice_contatore), W_LG_memo(1:indice_contatore), ...
    W_propuls_memo(1:indice_contatore), W_fuelsys_memo(1:indice_contatore), ...
    W_hydr_memo(1:indice_contatore), W_elec_memo(1:indice_contatore), ...
    W_antiice_memo(1:indice_contatore), W_instr_memo(1:indice_contatore), ...
    W_avionics_memo(1:indice_contatore), W_engine_sys_memo(1:indice_contatore), ...
    W_furn_memo(1:indice_contatore), W_services_memo(1:indice_contatore), ...
    W_crew_memo(1:indice_contatore), W_fuel_memo(1:indice_contatore), W_fuel_memo(1:indice_contatore)/0.8, ...
    W_block_fuel_memo(1:indice_contatore), W_payload_memo(1:indice_contatore)], ...
    'VariableNames', {'W/S', 'W/S max', 'WTO', 'CL_crociera', ...
                      'E_crociera', 'P_curr','P_tot','P_ice','P_em', 'S', 'OEW', 'W_wing', 'W_fus', 'W_tail', 'W_LG', ...
                      'W_propuls', 'W_fuelsys', 'W_hydr', 'W_elec', 'W_antiice', ...
                      'W_instr', 'W_avionics', 'W_engine_sys', 'W_furn', ...
                      'W_services', 'W_crew', 'W_fuel', 'V_fuel', 'W_block_fuel', 'W_payload'});
% Salvataggio della tabella in un file .csv
writetable(T, 'dati_convergenza.csv');
toc