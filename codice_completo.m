clearvars;close all;clc;requisiti;dati;fusoliera;

% variabili di design
% W_S_vect = [280 300 325 350]; % [kg/m^2]
% phi_ice_cl_vect = [0.1 0.3 0.5];
% phi_ice_cr_vect = [0.1 0.2 0.3 0.4 0.5];
% phi_ice_de_vect = [0.1 0.3];
% Hp_vect = [0.1 0.2 0.3 0.4]; % fattore di ibridizzazione
aereo_scelto;

% inizializzazione valori del ciclo
Cd0 = Cd0_livello0;
k_polare = k_polare_livello0;

% inizializzazione ciclo
W_inizializzazione = 10000; % [kg] stima preliminare a caso

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]
iterazioni_max = 1000;

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
                    while abs(delta_WTO) > tolleranza && iterazioni < iterazioni_max
                        % definisco variabili derivate che si aggiornano
                        S_ref = WTO_curr / W_S_des; % [m^2]
                        S_orizz = 0.3*S_ref;
                        S_vert = 0.2*S_ref;
                        b_ref = sqrt(AR_des*S_ref);  % [m]
                        c_root = S_ref/((b_ref-diametro_esterno_fus)/2*(1+lambda_des)); % [m]
                        MAC = 2/3 * c_root * (1+lambda_des+lambda_des^2) / (1+lambda_des); % [m]
                        CL_des = 2*W_S_des*g/(rho_cruise*V_cruise^2); % [] CL di crociera

                        % MATCHING CHART
                        matching_chart_script;
                        P_curr = P_W_des * WTO_curr; % [W] output del matching chart
                        v_rotate = IAS2TAS(IAS_climb, 0);
                        T_max = P_curr / (2*g*v_rotate(2)); % [kg]
                        % AERODINAMICA
                        aerodinamica;

                        % PRESTAZIONI
                        E_curr = CL_des/CD_curr; % efficienza in crociera
                        prestazioni;

                        % PESI
                        pesi_script;

                        % aggiornamento WTO
                        WTO_precedente = WTO_curr;
                        WTO_curr = W_payload + W_fuel + OEW_curr;

                        delta_WTO = WTO_curr - WTO_precedente;
                        iterazioni = iterazioni + 1;
                    end
                    costi;
                    if iterazioni == iterazioni_max
                        fprintf('Mancata convergenza: W_S=%.1f, Hp=%.1f, phi_cl=%.1f, phi_cr=%.1f, phi_de=%.1f\n',...
                            W_S_des, Hp_des, phi_ice_cl, phi_ice_cr, phi_ice_de);
                    end
                    memorizzazione;

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
msg = sprintf('Tutte le configurazioni sono state elaborate con successo!\nTempo totale trascorso: %.2f secondi.', toc(start_time));
msgbox(msg, 'Calcolo completato');


% salvataggio configurazioni
salvataggio;