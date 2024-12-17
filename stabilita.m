% Parametri di intervallo (fattori moltiplicativi)
x_CG_fus_factor_max = [0.42, 0.52]; % intervallo per il fattore di x_CG_fus
x_LE_wing_factor_max = [0.42, 0.52]; % intervallo per il fattore di x_LE_wing
x_CG_tail_factor_max = [0.90, 0.96]; % intervallo per il fattore di x_CG_tail
step_x = 0.01;
V_H_max = 1.35; % intervallo per V_H
V_V_max = 0.14; % intervallo per V_V

% Fattori moltiplicativi iniziali
x_CG_fus_factor = 0.42; % inizialmente il fattore di x_CG_fus
x_LE_wing_factor = 0.42; % inizialmente il fattore di x_LE_wing
x_CG_tail_factor = 0.90; % inizialmente il fattore di x_CG_tail

% Stime delle masse
m_fus = OEW_curr + W_payload - W_wing - W_tail - W_propulsione; % kg
x_CG_wing = (x_LE_wing_factor * lunghezza_fus) + 0.25 * c_root + (0.35 * b_ref - diametro_esterno_fus) / 2 * tand(sweep25_des);
x_CG_eng = (x_LE_wing_factor * lunghezza_fus) + 0.4 * L_nac;
x_CG_aircraft_MZFW = (x_CG_fus_factor * lunghezza_fus * m_fus + x_CG_wing * W_wing + x_CG_eng * W_propulsione + ...
    x_CG_tail_factor * lunghezza_fus * W_tail) / (OEW_curr + W_payload);

tail_arm = (x_CG_tail_factor * lunghezza_fus) - x_CG_aircraft_MZFW;
S_orizz = V_H * S_ref * MAC / tail_arm;
S_vert = V_V * S_ref * b_ref / tail_arm;

% Ciclo per stabilità
max_iterations = 500; % Numero massimo di iterazioni per evitare loop infiniti
iteration = 0;
step_H = 0.05; % passo di incremento per V_H 
step_V = 0.005; % passo di incremento per V_V

while iteration < max_iterations
    % Verifica delle condizioni di stabilità
    x_CG_aircraft_MTOW = (x_CG_fus_factor * lunghezza_fus * m_fus + x_CG_wing * (W_wing + W_fuel) + x_CG_eng * W_propulsione + ...
        x_CG_tail_factor * lunghezza_fus * W_tail) / (WTO_curr);
    tail_arm_MTOW = (x_CG_tail_factor * lunghezza_fus) - x_CG_aircraft_MTOW;
    V_H_MTOW = (S_orizz * tail_arm_MTOW) / (S_ref * MAC);
    V_V_MTOW = (S_vert * tail_arm_MTOW) / (S_ref * b_ref);

    condizioneV = (V_V_MTOW > 0.14 || V_V_MTOW < 0.08);
    condizioneH = (V_H_MTOW > 1.35 || V_H_MTOW < 0.8);
    
    % Se entrambe le condizioni sono soddisfatte, esci dal ciclo
    if ~condizioneV && ~condizioneH
        break;
    end

    % Modifica V_H e V_V se necessario
    if condizioneV
        V_V = min(V_V_max, V_V + step_V);
    end
    
    if condizioneH
        V_H = min(V_H_max, V_H + step_H);
    end

    % Se V_H o V_V sono fuori dal loro range, modifica i fattori moltiplicativi
    if V_V == V_V_max && V_H == V_H_max
        x_CG_fus_factor = min(x_CG_fus_factor_max, x_CG_fus_factor + step_x);
        x_LE_wing_factor = min(x_LE_wing_factor_max, x_LE_wing_factor + step_x);
        x_CG_tail_factor = min(x_CG_tail_factor_max, x_CG_tail_factor + step_x);
    end

    % Ricalcola i nuovi valori di superficie orizzontale e verticale
    tail_arm = (x_CG_tail_factor * lunghezza_fus) - x_CG_aircraft_MZFW;
    S_orizz = V_H * S_ref * MAC / tail_arm;
    S_vert = V_V * S_ref * b_ref / tail_arm;
    
    % Incremente il contatore di iterazioni
    iteration = iteration + 1;
end

% Verifica finale per evitare loop infiniti
if iteration == max_iterations
    disp('Attenzione: numero massimo di iterazioni raggiunto.');
end
