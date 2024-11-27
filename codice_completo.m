clearvars;close all;clc;requisiti;dati;%fusoliera;

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
W_inizializzazione = 12000; % [kg] stima preliminare a caso

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]

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
                    while abs(delta_WTO) > tolleranza
                        % definisco variabili derivate che si aggiornano
                        S_ref = WTO_curr / W_S_des; % [m^2]
                        b_ref = sqrt(AR_des*S_ref);  % [m]
                        standard_mean_chord_ala = b_ref/AR_des; % [m]
                        V_cruise = M_des*a_cruise; % [m/s]
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

% visualizzazione configurazioni
% con matrice:
Matrix_DVs = [W_S_des_memo' WTO_memo']; % DVs: design variables, mette tutte le combinazioni in matrice
% altri modi:
array2table

struct2table

