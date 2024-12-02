% da sistemare
W_zero_fuel = OEW_curr; % [kg]
W_zero_fuel_lb = W_zero_fuel*kg2lb; % [lb]
WTO_curr_lb = WTO_curr*kg2lb; % [lb]
S_ref_ft = S_ref * sqm2sqft; % [ft]
W_S_des_lbsqft = W_S_des*kg2lb/sqm2sqft; % [lb/ft^2]

% ala
Iw = (ultimate_load_fact*AR_des^1.5*(W_zero_fuel_lb/WTO_curr_lb)^0.5*(1+2*lambda_des)*...
    W_S_des_lbsqft*S_ref_ft^1.5*10^(-6))/(t_c_des*cosd(sweep25_des)^2*(1+lambda_des)); % wing gemoetry index
if S_ref_ft >= 900
    W_wing = (0.93*Iw+6.44*S_ref_ft+390)*lb2kg; % [kg]
else
    W_wing = (4.24*Iw+0.57*S_ref_ft)*lb2kg; % [kg]
end

% coda (T-tail)
W_tail = (6.39*(Sorizz_Sref+Svert_Sref)*S_ref_ft)*lb2kg; % [kg]

% fusoliera
W_fus = 1.35*((lunghezza_fus*m2ft)*(diametro_esterno_fus*m2ft))^1.28*lb2kg; % [kg]

% carrello
W_LG_param = 0.0395*WTO_curr_lb; % [lb] parametro
W_LG_strutt = W_LG_param*(0.45+23.1e-8*WTO_curr_lb); % [lb]
W_LG_freni = W_LG_param*(0.268-8.12e-8*WTO_curr_lb); % [lb]
W_LG_pneum = W_LG_param*(0.152-8.38e-8*WTO_curr_lb); % [lb]
W_LG_contr = W_LG_param*(0.13-6.56e-8*WTO_curr_lb); % [lb]
W_LG = (W_LG_strutt + W_LG_freni + W_LG_pneum + W_LG_contr) * lb2kg; % [kg]

% propulsione
W_ice = N_prop*(P_ice/N_prop-12970)/3878; % [kg]
W_emot = P_em / EMPD; % [kg]
W_nac = K_nac*(P_em + P_ice)*lb2kg; % [kg] nacelle
W_propeller = lb2kg*0.1256*N_prop*(12.0546*(P_em + P_ice)*W2hp/N_prop)^0.782; % [kg]
W_propulsione = W_nac + W_ice + W_emot + W_propeller; % [kg]

% battery
W_batt = E_batt_inst / (0.8*BED); % kg

% fuel system
W_fuelsys = 2.71*(b_ref*m2ft/cosd(sweep25_des)*N_serbatoi)^0.956*lb2kg; % [kg]

% hydraulic system
S_ref_hydr = S_ref_ft*(1+1.44*(Sorizz_Sref+Svert_Sref)); % [ft^2] superficie per sistema idraulico
if S_ref_hydr <= 3000
    W_hydraulic = (45+1.318*S_ref_hydr)*lb2kg; % [kg]
else
    W_hydraulic = (18.7*S_ref_hydr^0.712-1620)*lb2kg; % [kg]
end

% electric system
W_elec = (16.2*passeggeri+110)*lb2kg; % [kg]

% pneumatic system
W_pneumatic = 26.2*passeggeri^0.944*lb2kg; % [kg]

% anti-icing system
W_antiice = 0.238*S_ref_ft*lb2kg; % [kg]

% instruments: thrust + fuel + other
W_instr = ((0.00145*(D(i_climb+1)/g*kg2lb)/2 + 30)*2 + ...
    0.00714*max_fuel_volume*l2gal+34 + ...
    1.872*passeggeri+128)*lb2kg; % [kg]

% avionics
W_avionics = (2.8*passeggeri + 2320)*lb2kg; % [kg]

% engine system
W_engine_sys = 133*N_prop*lb2kg; % [kg]

% furnishings
W_furn = (62.3*passeggeri+290)*lb2kg; % [kg]

% services
W_services = (2.529*passeggeri*(range*km2nm/M_des)^0.225)*lb2kg; % [kg]

% crew: piloti + assistenti
W_crew = (2*225 + ceil(passeggeri / 50)*155)*lb2kg; % [kg]

OEW_curr = W_wing + W_tail + W_fus + W_LG + W_propulsione + W_fuelsys + W_hydraulic + ...
    W_elec + W_pneumatic + W_antiice + W_instr + W_avionics + W_engine_sys + W_furn + W_services + W_crew; % [kg]

W_payload = passeggeri*peso_passeggero + W_cargo; % [kg]