clearvars;close all;clc;requisiti;dati;%fusoliera;

% ciclo principale
% definisco vettori delle variabili di design
W_S_vect = [200 250 300]; % [kg/m^2]
AR_vect = [7 8 9 10 11]; % []
t_c_vect = [0.12 0.14]; % []
M_vect = [0.38 0.40 0.42]; % []
taper_ratio_vect = [0.48 0.50 0.53]; % []
phi_ice_vect = [0.40 0.50 0.60 0.70 0.80 0.90]; % frazione istantanea potenza termica
p_ice_perc_vect = [0.6 0.7 0.8 0.9]; % percentuale di potenza termica installata
sweep25_des = 0;

% primo blocco: matching chart per avere T/W, servono alcuni valori della
% polare che non abbiamo.
Cd0 = Cd0_livello0; % inizializzo valore del ciclo
k_polare = k_polare_livello0;

% inizializzazione ciclo
W_inizializzazione = 15000; % [kg] stima preliminare a caso

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]

% ciclo di dimensionamento
for i_W_S = 1:length(W_S_vect)
    for i_AR = 1:length(AR_vect)
        for i_t_c = 1:length(t_c_vect)
            for i_M = 1:length(M_vect)
                for i_taper = 1:length(taper_ratio_vect)
                    for i_p_ice = 1:length(p_ice_perc_vect)
                        for i_phi_ice = 1:length(phi_ice_vect)
                            % step 1: dichiarare variabili di design che si aggiornano
                            W_S_des = W_S_vect(i_W_S);
                            AR_des = AR_vect(i_AR);
                            t_c_des = t_c_vect(i_t_c);
                            M_des = M_vect(i_M);
                            lambda_des = taper_ratio_vect(i_taper);
                            p_ice_perc = p_ice_perc_vect(i_p_ice);
                            phi_ice_des = phi_ice_vect(i_phi_ice);

                            % ciclo di convergenza sul peso
                            delta_WTO = 1000; % [kg] inizializzazione per entrare nel while
                            WTO_curr = W_inizializzazione;
                            while abs(delta_WTO) > tolleranza
                                % definisco variabili derivate che si aggiornano
                                S_ref = WTO_curr / W_S_des; % [m^2]
                                b_ref = sqrt(AR_des*S_ref);  % [m]
                                standard_mean_chord_ala = b_ref/AR_des; % [m]
                                V_cruise = M_des*a_cruise; % [m/s]
                                CL_des = 2*W_S_des*g/(rho_cruise*V_cruise^2); % [] CL di crociera


                                % script delle varie parti

                                % MATCHING CHART
                                matching_chart_script;
                                P_curr = P_W_des * WTO_curr; % [W] output del matching chart
                                % AERODINAMICA
                                aerodinamica;
                                prestazioni;
                                % PESI
                                pesi_script;


                                % PRESTAZIONI
                                E_curr = CL_des/CD_curr; % CD_curr da aerodinamica cd0+cdi+cdw
                                script_prestazioni; % frazioni di peso, fuel fraction, W_fuel/WTO.. codice task 2

                                WTO_precedente = WTO_curr;
                                WTO_curr = Wpayload + Wfuel + OEW_curr;

                                delta_WTO = WTO_curr - WTO_precedente;

                            end

                            indice_contatore = indice_contatore+1;
                            W_S_des_memo(indice_contatore) = W_S_des; % _memo per le variabili da salvare
                            WTO_memo(indice_contatore) = WTO_curr;
                            % A_R_des_memo, t_c, M.... tutte le variabili di
                            % interesse
                        end
                    end
                end
            end
        end
    end
end

% visualizzazione configurazioni
% con matrice:
Matrix_DVs = [W_S_des_memo' WTO_memo']; % DVs: design variables, mette tutte le combinazioni in matrice
% altri modi:
array2table

struct2table

