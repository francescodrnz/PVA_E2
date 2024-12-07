clearvars;close all;clc;requisiti;dati;fusoliera;

% ciclo principale
% definisco vettori delle variabili di design
W_S_vect = [250 300 350]; % [kg/m^2]
phi_ice_cl_vect = [0.1 0.3 0.5];
phi_ice_cr_vect = [0.1 0.2 0.3 0.4 0.5];
phi_ice_de_vect = [0.1 0.3];
Hp_vect = [0.1 0.2 0.3 0.4]; % fattore di ibridizzazione

% inizializzazione valori del ciclo
Cd0 = Cd0_livello0;
k_polare = k_polare_livello0;
V_H = V_H_livello0;
V_V = V_V_livello0;
S_orizz = S_orizz_livello0;
S_vert = S_vert_livello0;

% inizializzazione ciclo
W_inizializzazione = 10000; % [kg] stima preliminare a caso

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]

% Preallocazione degli array per memorizzare i risultati
preallocazione;

f = waitbar(0,'Please wait...');
indice_config = 1;
start_time = tic;
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
                    while abs(delta_WTO) > tolleranza && iterazioni < 100
                        % definisco variabili derivate che si aggiornano
                        S_ref = WTO_curr / W_S_des; % [m^2]
                        b_ref = sqrt(AR_des*S_ref);  % [m]
                        c_root = S_ref/((b_ref-diametro_esterno_fus)/2*(1+lambda_des)); % [m]
                        MAC = 2/3 * c_root * (1+lambda_des+lambda_des^2) / (1+lambda_des); % [m]
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

                        stabilita;

                        % aggiornamento WTO
                        WTO_precedente = WTO_curr;
                        WTO_curr = W_payload + W_fuel + OEW_curr;

                        delta_WTO = WTO_curr - WTO_precedente;
                        iterazioni = iterazioni + 1;
                    end
                    if iterazioni == 100
                        fprintf('Configurazione scartata per mancata convergenza: W_S=%f, Hp=%f\n', W_S_des, Hp_des);
                    end

                    if all(phi_em <= 1) && all(phi_em >= 0) && b_ref <= 36
                        % Memorizzazione dei risultati dopo la convergenza
                        indice_contatore = indice_contatore+1;
                        W_S_des_memo(indice_contatore) = W_S_des;
                        W_S_max_memo(indice_contatore) = W_S_max;
                        WTO_memo(indice_contatore) = WTO_curr;
                        S_ref_memo(indice_contatore) = S_ref;
                        b_ref_memo(indice_contatore) = b_ref;
                        croot_memo(indice_contatore) = c_root;
                        S_vert_memo(indice_contatore) = S_vert;
                        S_orizz_memo(indice_contatore) = S_orizz;
                        CL_des_memo(indice_contatore) = CL_des;
                        E_curr_memo(indice_contatore) = E_curr;
                        P_curr_memo(indice_contatore) = P_curr;
                        P_tot_memo(indice_contatore) = P_tot;
                        P_ice_memo(indice_contatore) = P_ice;
                        P_em_memo(indice_contatore) = P_em;
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
                        phi_ice_cl_memo(indice_contatore) = phi_ice_cl;
                        phi_ice_cr_memo(indice_contatore) = phi_ice_cr;
                        phi_ice_de_memo(indice_contatore) = phi_ice_de;
                        Hp_memo(indice_contatore) = Hp_des;
                        W_batt_memo(indice_contatore) = W_batt;
                        E_batt_memo(indice_contatore) = E_batt_inst;
                        ADP_memo(indice_contatore) = function_ADP(V_cruise,OEW_curr,2,2.451e-14*D(i_cruise)^3-2.846e-9*D(i_cruise)^2+1.838e-4*D(i_cruise)+0.6321);

                    end
                    % waitbar
                    if mod(indice_config, 3) == 0
                        elapsed_time = toc(start_time);
                        est_total_time = elapsed_time / indice_config * num_configurazioni;
                        time_left = est_total_time - elapsed_time;
                        waitbar(indice_config / num_configurazioni, f, ...
                            sprintf('Progress: %.1f%% - Time left: %.2f sec', (indice_config / num_configurazioni) * 100, time_left));
                    end
                    indice_config = indice_config + 1;
                end
            end
        end
    end
end
close(f);
msg = sprintf('Tutte le configurazioni sono state elaborate con successo!\nTempo totale trascorso: %.2f secondi.', elapsed_time);
msgbox(msg, 'Calcolo completato');


% salvataggio configurazioni
data = struct( ...
    'W_S', W_S_des_memo(1:indice_contatore), ...
    'W_S_max', W_S_max_memo(1:indice_contatore), ...
    'WTO', WTO_memo(1:indice_contatore), ...
    'S', S_ref_memo(1:indice_contatore), ...
    'b', b_ref_memo(1:indice_contatore), ...
    'c_root', croot_memo(1:indice_contatore), ...
    'S_vert', S_vert_memo(1:indice_contatore), ...
    'S_orizz', S_orizz_memo(1:indice_contatore), ...
    'CL_crociera', CL_des_memo(1:indice_contatore), ...
    'E_crociera', E_curr_memo(1:indice_contatore), ...
    'P_curr', P_curr_memo(1:indice_contatore), ...
    'P_tot', P_tot_memo(1:indice_contatore), ...
    'P_ice', P_ice_memo(1:indice_contatore), ...
    'P_em', P_em_memo(1:indice_contatore), ...
    'phi_ice_cl', phi_ice_cl_memo(1:indice_contatore), ...
    'phi_ice_cr', phi_ice_cr_memo(1:indice_contatore), ...
    'phi_ice_de', phi_ice_de_memo(1:indice_contatore), ...
    'Hp', Hp_memo(1:indice_contatore), ...
    'E_batt_inst', E_batt_memo(1:indice_contatore), ...
    'OEW', OEW_memo(1:indice_contatore), ...
    'W_wing', W_wing_memo(1:indice_contatore), ...
    'W_fus', W_fus_memo(1:indice_contatore), ...
    'W_tail', W_tail_memo(1:indice_contatore), ...
    'W_LG', W_LG_memo(1:indice_contatore), ...
    'W_propuls', W_propuls_memo(1:indice_contatore), ...
    'W_fuelsys', W_fuelsys_memo(1:indice_contatore), ...
    'W_hydr', W_hydr_memo(1:indice_contatore), ...
    'W_elec', W_elec_memo(1:indice_contatore), ...
    'W_antiice', W_antiice_memo(1:indice_contatore), ...
    'W_instr', W_instr_memo(1:indice_contatore), ...
    'W_avionics', W_avionics_memo(1:indice_contatore), ...
    'W_engine_sys', W_engine_sys_memo(1:indice_contatore), ...
    'W_furn', W_furn_memo(1:indice_contatore), ...
    'W_services', W_services_memo(1:indice_contatore), ...
    'W_crew', W_crew_memo(1:indice_contatore), ...
    'W_battery', W_batt_memo(1:indice_contatore), ...
    'W_fuel', W_fuel_memo(1:indice_contatore), ...
    'V_fuel', W_fuel_memo(1:indice_contatore) / 0.8, ...
    'W_block_fuel', W_block_fuel_memo(1:indice_contatore), ...
    'W_payload', W_payload_memo(1:indice_contatore), ...
    'ADP', ADP_memo(1:indice_contatore) ...
    );
writetable(struct2table(data), 'dati_convergenza.csv');
