% stima baricentro @MZFW, x = 0 sul muso
% fusoliera
x_CG_fus = 0.45 * lunghezza_fus; % [m]
m_fus = OEW_curr + W_payload - W_wing - W_tail - W_propulsione; % [kg]
% ala
x_LE_wing = 0.45*lunghezza_fus; % [m]
x_CG_wing = x_LE_wing + 0.25*c_root + (0.35*b_ref-diametro_esterno_fus)/2*tand(sweep25_des); % [m]
% motori
x_CG_eng = x_LE_wing + 0.4 * L_nac; % [m]
% coda
x_CG_tail = 0.92 * lunghezza_fus; % [m]

x_CG_aircraft_MZFW = (x_CG_fus * m_fus + x_CG_wing * W_wing + x_CG_eng * W_propulsione + ...
    x_CG_tail * W_tail) / (OEW_curr + W_payload);

tail_arm = x_CG_tail - x_CG_aircraft_MZFW;
S_orizz = V_H * S_ref * MAC / tail_arm;
S_vert = V_V * S_ref * b_ref / tail_arm;

% check @MTOW
x_CG_aircraft_MTOW = (x_CG_fus * m_fus + x_CG_wing * (W_wing + W_fuel) + x_CG_eng * W_propulsione + ...
    x_CG_tail * W_tail) / (OEW_curr + W_payload);

tail_arm_MTOW = x_CG_tail - x_CG_aircraft_MZFW;
V_H_MTOW = (S_orizz * tail_arm_MTOW) / (S_ref * MAC);
V_V_MTOW = (S_vert * tail_arm_MTOW) / (S_ref * b_ref);

condizioneV = (V_V_MTOW > 0.14 || V_V_MTOW < 0.08);
condizioneH = (V_H_MTOW > 1.35 || V_H_MTOW < 0.8);
step_H = 0.01; % passo di incremento per V_H
step_V = 0.005; % passo di incremento per V_V
while condizioneV && condizioneH
    if V_V_MTOW > 0.14
        V_V = V_V - step_V;
    elseif V_V_MTOW < 0.08
        V_V = V_V + step_V;
    end
    S_vert = V_V * S_ref * b_ref / tail_arm;
    V_V_MTOW = (S_vert * tail_arm_MTOW) / (S_ref * b_ref);


    if V_H_MTOW > 1.35
        V_H = V_H - step_H;
    elseif V_H_MTOW < 0.8
        V_H = V_H + step_H;
    end
    S_orizz = V_H * S_ref * MAC / tail_arm;
    V_H_MTOW = (S_orizz * tail_arm_MTOW) / (S_ref * MAC);
end