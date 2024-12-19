clc; close all;
% Calcoli punto C
W_fuel_max = max_fuel_volume*fuel_density;
W_fuel_mission_max = W_fuel_max/1.05 - W_fuel_diversion;
% cruise
x_cruise_C = 0;
W_fuel_cruise_max = W_fuel_mission_max - W_fuel_climb - W_fuel_descent;
W_start_cruise = W(i_climb + 1);
W_curr = W_start_cruise;
W_fuel_cruise = 0;
E_batt_curr = E_batt(i_climb + 1);
while W_fuel_cruise < W_fuel_cruise_max

    CL = 2*(W_curr*g/S_ref) / (rho_cruise*V_cruise^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho_cruise*S_ref*V_cruise^2*CD;

    P_nec = D*V_cruise/(etaGear*etaProp); % [W]

    if E_batt_curr < E_batt(i_cruise + 1)
        % consumo batteria
        E_batt_dot = (P_nec - P_ice_cr)/etaEm;
        E_batt_curr = E_batt_curr + E_batt_dot * dt * sec2hr; % [W*h]
        % consumo carburante
        W_fuel_dot = kc * P_ice_cr / hr2sec; % [kg/s]
        W_fuel_cruise = W_fuel_cruise + W_fuel_dot * dt; % [kg]
        W_curr = W_curr - W_fuel_dot * dt;
    else
        if P_nec <= P_ice
            W_fuel_dot = kc * P_nec / hr2sec; % [kg/s]
            W_fuel_cruise = W_fuel_cruise + W_fuel_dot * dt; % [kg]
            W_curr = W_curr - W_fuel_dot * dt;
        else
            disp('potenza termica non sufficiente');
        end
    end
    x_cruise_C = x_cruise_C + V_cruise*dt;

end

% Calcoli punto D
WTO_D = 2*225*lb2kg + W_fuel_max + OEW_curr - (WTO_curr - W(i_take_off + 1)); % peso dopo decollo, solo piloti
E_batt_curr = E_batt(i_take_off + 1);
range_D = 0;
%climb
z_curr = 0;
W_curr = WTO_D;
W_fuel_curr = W_fuel_max - (WTO_curr - W(i_take_off + 1));
while z_curr < h_cruise
    rho = IntStandAir_SI(z, 'rho');
    conversione_IAS = IAS2TAS(IAS_climb, z);
    TAS = conversione_IAS(2);
    gamma_climb = atan(ROC/TAS);
    range_D = range_D + TAS * cos(gamma_climb) * dt; % [m]
    CL = 2*(W_curr*g/S_ref) / (rho*TAS^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho*S_ref*TAS^2*CD;

    P_fly = D*TAS + TAS*W_curr*sin(gamma_climb);
    P_nec = P_fly/(etaGear*etaProp);
    E_batt_dot = (P_nec - P_ice_cl)/etaEm;
    E_batt_curr = E_batt_curr + E_batt_dot*dt*sec2hr;
    W_dot = - kc * P_ice_cl / hr2sec;
    W_curr = W_curr + W_dot;
    W_fuel_curr = W_fuel_curr + W_dot;

    z_curr = z_curr + ROC * dt;
end
% cruise
while 0.67*(W_fuel_diversion + W_fuel_descent) < W_fuel_curr
    CL = 2*(W_curr*g/S_ref) / (rho_cruise*TAS^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho_cruise*S_ref*TAS^2*CD;

    P_nec = D*V_cruise/(etaGear*etaProp);
    if E_batt_curr < 1.01*E_batt(i_cruise + 1)
        % consumo batteria
        E_batt_dot = (P_nec - P_ice_cr)/etaEm;
        E_batt_curr = E_batt_curr + E_batt_dot * dt * sec2hr; % [W*h]
        % consumo carburante
        W_dot = - kc * P_ice_cr / hr2sec; % [kg/s]
        W_fuel_curr = W_fuel_curr + W_dot * dt; % [kg]
        W_curr = W_curr + W_dot * dt;
    else
        W_dot = - kc * P_nec / hr2sec; % [kg/s]
        W_fuel_curr = W_fuel_curr + W_dot * dt; % [kg]
        W_curr = W_curr + W_dot * dt;
    end
    range_D = range_D + V_cruise * dt;
end
% descent
z = h_cruise;
while z > 0
    rho = IntStandAir_SI(z, 'rho');
    conversione_IAS = IAS2TAS(IAS_descent, z);
    TAS = conversione_IAS(2);
    gamma_descent = atan(ROD/TAS);
    range_D = range_D + TAS * cos(gamma_descent) * dt;

    CL = 2*(W_curr*g/S_ref) / (rho*TAS^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho*S_ref*TAS^2*CD;

    P_fly = D*TAS + TAS*W_curr*sin(gamma_descent);
    P_nec = P_fly/(etaGear*etaProp);
    E_batt_dot = (P_nec - P_ice_de)/etaEm;
    E_batt_curr = E_batt_curr + E_batt_dot*dt*sec2hr;
    W_dot = - kc * P_ice_de / hr2sec;
    W_curr = W_curr + W_dot;
    W_fuel_curr = W_fuel_curr + W_dot;

    z = z + ROD * dt;
end
% diversion
z_curr = 0;
while z_curr < h_cruise_diversion
    rho = IntStandAir_SI(z, 'rho');
    conversione_IAS = IAS2TAS(IAS_climb_diversion, z);
    TAS = conversione_IAS(2);
    gamma_climb = atan(ROC/TAS);
    CL = 2*(W_curr*g/S_ref) / (rho*TAS^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho*S_ref*TAS^2*CD;

    P_fly = D*TAS + TAS*W_curr*sin(gamma_climb);
    P_nec = P_fly/(etaGear*etaProp);
    W_dot = - kc * P_nec / hr2sec;
    W_curr = W_curr + W_dot;
    W_fuel_curr = W_fuel_curr + W_dot;

    z_curr = z_curr + ROC_diversion * dt;
end
% cruise
x_cruise_diversion = 0;
while x_cruise_diversion < range_cruise_diversion*1e3
    CL = 2*(W_curr*g/S_ref) / (rho_cruise_diversion*TAS^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho_cruise_diversion*S_ref*TAS^2*CD;

    P_nec = D*V_cruise/(etaGear*etaProp);

    W_dot = - kc * P_nec / hr2sec; % [kg/s]
    W_fuel_curr = W_fuel_curr + W_dot * dt; % [kg]
    W_curr = W_curr + W_dot * dt;

    x_cruise_diversion = x_cruise_diversion + V_cruise * dt;
end
% descent
z = h_cruise_diversion;
while z > 0
    rho = IntStandAir_SI(z, 'rho');
    conversione_IAS = IAS2TAS(IAS_descent_diversion, z);
    TAS = conversione_IAS(2);
    gamma_descent = atan(ROD_diversion/TAS);

    CL = 2*(W_curr*g/S_ref) / (rho*TAS^2);
    CD = Cd0 + k_polare * CL^2;
    D = 1/2*rho*S_ref*TAS^2*CD;

    P_fly = D*TAS + TAS*W_curr*sin(gamma_descent);
    P_nec = P_fly/(etaGear*etaProp);
    W_dot = - kc * P_nec / hr2sec;
    W_curr = W_curr + W_dot;
    W_fuel_curr = W_fuel_curr + W_dot;

    z = z + ROD_diversion * dt;
end
W_fuel_curr
E_batt_curr-E_batt_inst
% Diagramma payload-range

% Valori di payload e range nei punti del diagramma
payloadA = passeggeri * peso_passeggero; % Payload massimo
rangeA = 0;

payloadB = passeggeri * peso_passeggero; % Payload massimo
rangeB = range; % Range da requisito

payloadC = WTO_curr - (W_fuel_max + OEW_curr + W_crew); % Payload ridotto al punto C
rangeC = (x_climb + x_cruise_C + x_descent)/1000; % [km] Range al punto C con massimo fuel

payloadD = 0; % Nessun payload, solo fuel
rangeD = range_D/1000; % Range massimo senza payload

figure;
plot([rangeA, rangeB, rangeC, rangeD], [payloadA, payloadB, payloadC, payloadD], '-o', 'Color', 'b',  'LineWidth', 2);
xlabel('Range (km)');
ylabel('Payload (kg)');
title('Diagramma Payload-Range');
grid on;
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.MinorGridLineStyle = ':';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';