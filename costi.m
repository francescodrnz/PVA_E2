% flight cost
crew_cost = (2*315 + ceil(passeggeri / 50)*77) * inflazione; % [$/h]
fuel_cost = jet_fuel_cost * W_block_fuel*1e-3 / block_time; % [$/h]
electricity_cost = 0.5 * E_batt_inst*1e-3; % [$/mission]

tassa_atterraggio = 7 * WTO_curr*1e-3 / block_time;
tassa_navigazione = 0.4 * range / block_time * sqrt(WTO_curr*1e-3/50);
tassa_terra = 93 * W_payload*1e-3 / block_time;
tax_cost = (tassa_atterraggio + tassa_navigazione + tassa_terra) * inflazione; % [$/h]

flight_cost = crew_cost + fuel_cost + tax_cost; % [$/h]

% manutenzione
W_airframe = (OEW_curr - W_propulsione)*1e-3; % [kg*10^3]
flight_time = block_time - 0.25; % [h]
BEP = 2.451e-14*D(i_cruise)^3-2.846e-9*D(i_cruise)^2+1.838e-4*D(i_cruise)+0.6321;
ADP = function_ADP(V_cruise,OEW_curr,N_prop,BEP);
% airframe
A_labour = (0.09 * W_airframe + 6.7 - 350 / (W_airframe + 75))*...
    ((0.8 + 0.68*flight_time)/block_time)*man_hour_cost;
A_material = (4.2+2.2*flight_time)*(ADP-N_prop*BEP)/block_time;
% engine
C1 = 1.27 - 0.2*BPR^0.2;
C2 = 0.4 * (OPR/20)^1.3 + 0.4;
C3 = 0.032 * N_comp + K_engine;
E_labour = 0.21 * man_hour_cost * C1 * C3 * (1+T_max* 1e-3)^0.4;
E_material = 2.56 * (1+T_max* 1e-3)^0.8 * C1*(C2+C3);

maintenance_cost = A_labour + A_material + N_prop * (E_labour+E_material)...
    * (flight_time + 1.3)/block_time;

CO2_emissions = 3.16 * W_block_fuel;