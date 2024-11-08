clearvars;close all;clc;dati;requisiti;fusoliera;

% ciclo principale
% definisco vettori delle variabili di design
W_S_vect = [150 200 250 300]; % [kg/m^2]
AR_vect = [7 8 9 10 11]; % []
t_c_vect = [0.12 0.14]; % []
M_vect = [0.38 0.40 0.42]; % []
taper_ratio_vect = [0.48 0.50 0.53]; % []
%...altri vettori ma senza esagerare

% primo blocco: matching chart per avere T/W, servono alcuni valori della
% polare che non abbiamo.
Cd0_livello0 = 0.017; %valore che ho usato per fare il matching chart preliminare
Cd0 = Cd0_livello0; % inizializzo valore del ciclo
k_polare = k_polare_livello0;
% altri...

% inizializzazione ciclo
W_inizializzazione = 10000; % [kg] stima preliminare a caso

% parametri ciclo convergenza
indice_contatore = 0;
tolleranza = 25; % [kg]

% ciclo di dimensionamento
for i_W_S = 1:length(W_S_vect)
    for i_AR = 1:length(AR_vect)
        for i_t_c = 1:length(t_c_vect)
            for i_M = 1:length(M_vect)
                for i_taper = 1:length(taper_ratio_vect)
                    % step 1: dichiarare variabili di design che si aggiornano
                    W_S_des = W_S_vect(i_W_S);
                    AR_des = AR_vect(i_AR);
                    t_c_des = t_c_vect(i_t_c);
                    M_des = M_vect(i_M);
                    lambda_des = taper_ratio_vect(i_taper);

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
                        matching_chart;
                        T_curr = thrust_ratio_des * WTO_curr; % [kg] output del matching chart
                        % AERODINAMICA
                        aerodinamica;
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

% visualizzazione configurazioni
% con matrice:
Matrix_DVs = [W_S_des_memo' WTO_memo']; % DVs: design variables, mette tutte le combinazioni in matrice
% altri modi:
array2table

struct2table

