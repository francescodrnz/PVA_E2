% CL clean
CLmax_2D_clean = 1.5; % controllare
sweep25 = 0;
CLmax_3D_clean = 0.9*CLmax_2D_clean*cosd(sweep25);

% CL flapped
Sflap = 0.7*S_ref;
deltaCL_flap_2D = 1.35; % fowler flap
deltaCL_flap_3D = 0.92*deltaCL_flap_2D*Sflap/S_ref*cosd(sweep25);

CL_max_flapped = CLmax_3D_clean + deltaCL_flap_3D;

W_S_max = 0.5*rho_SL*(1.136*Vstall*kmph2mps)^2*CL_max_flapped/g; % [kg/m^2]


% decollo
a1 = b10 + b11*CL_max_flapped + b12*CL_max_flapped^2;
a2 = b20 + b21*CL_max_flapped + b22*CL_max_flapped^2;
P_W_decollo = a1*W_S_des + a2*W_S_des^2; % [W/kg]

% Climb
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S_ref * sind(30)^2; % check: cflap/c
C_D_LG = 4.09e-03*(m_TO*kg2lb)^0.785/(S_ref*sqm2sqft);
CD0 = 0.02;
% first segment
gamma1 = atan(0/100);
P_W_cl_1 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.2*Vstall*kmph2mps)^3  / W_S_des * ( CD0 + ...
      k_polare_livello0 * (2 * W_S_des / (rho_SL * (1.2*Vstall*kmph2mps)^2 * cos(gamma1)))^2) + ...
      (1.2*Vstall*kmph2mps) * sin(gamma)); %check, aggiungere velocità corretta
% second segment
gamma2 = atan(2.4/100);
thrust_ratio2 = 2*(0.5*rho_SL*(1.2*Vstall*kmph2mps)^2/(W_S_des*g)*((CD0_clean+C_D_flap) + k_polare*(2*(W_S_des*g)*cos(gamma2)/(rho_SL*(1.2*Vstall*kmph2mps)^2))^2) + sin(gamma2));
% third segment
gamma3 = atan(1.2/100);

