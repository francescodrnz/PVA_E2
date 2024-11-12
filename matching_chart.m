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
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S_ref * sind(15)^2; % check: cflap/c
C_D_LG = 2.92e-03*(WTO_curr*kg2lb)^0.785/(S_ref*sqm2sqft);
% first segment
gamma1 = atan(0/100);
P_W_climb_1 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.2*Vstall*kmph2mps)^3  / W_S_des * ( (Cd0 + C_D_flap + C_D_LG) + ...
      k_polare * (2 * W_S_des*g / (rho_SL * (1.2*Vstall*kmph2mps)^2) * cos(gamma1))^2) + ...
      (1.2*Vstall*kmph2mps) * sin(gamma1)); % [W/kg = m^2/s^3]
% second segment
gamma2 = atan(2.4/100);
P_W_climb_2 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.2*Vstall*kmph2mps)^3  / W_S_des * ( (Cd0 + C_D_flap) + ...
      k_polare * (2 * W_S_des*g / (rho_SL * (1.2*Vstall*kmph2mps)^2) * cos(gamma2))^2) + ...
      (1.2*Vstall*kmph2mps) * sin(gamma2)); % [W/kg = m^2/s^3]
% third segment
gamma3 = atan(1.2/100);
P_W_climb_3 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.25*Vstall*kmph2mps)^3  / W_S_des * ( (Cd0) + ...
      k_polare * (2 * W_S_des*g / (rho_SL * (1.25*Vstall*kmph2mps)^2) * cos(gamma3))^2) + ...
      (1.25*Vstall*kmph2mps) * sin(gamma3)); % [W/kg = m^2/s^3]

P_W_climb = max([P_W_climb_1,P_W_climb_2,P_W_climb_3]);


% Landing climb
vLdgClimb = 1.23*Vstall;
gammaLdgClimb = atan(3.2/100);
P_W_LdgClimb = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.25*Vstall*kmph2mps)^3  / W_S_des * ( (Cd0) + ...
      k_polare * (2 * W_S_des*g / (rho_SL * (vLdgClimb*kmph2mps)^2) * cos(gammaLdgClimb))^2) + ...
      (vLdgClimb*kmph2mps) * sin(gammaLdgClimb)); % [W/kg = m^2/s^3]

% Approach climb
vAppClimb = 1.41*Vstall;
gammaAppClimb = atan(2.1/100);
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S_ref * sind(30)^2;
P_W_AppClimb = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.25*Vstall*kmph2mps)^3  / W_S_des * ( (Cd0) + ...
      k_polare * (2 * W_S_des*g / (rho_SL * (vAppClimb*kmph2mps)^2) * cos(gammaAppClimb))^2) + ...
      (vAppClimb*kmph2mps) * sin(gammaAppClimb)); % [W/kg = m^2/s^3]


% Cruise
P_W_cruise = ((0.5*rho_cruise*(V_cruise*kmph2mps)^3) / (etaPCruise*W_S_des)) * ...
    (Cd0 + k_polare * (2*W_S_des*g/(rho_cruise*(V_cruise*kmph2mps)^2))^2); % [W/kg]
P_W_cruise = P_W_cruise/(rho_cruise/rho_SL)^0.75; % riferisco il matching chart al SL % anche in E1 ^0.75?


% design point
P_W_des = max([P_W_decollo, P_W_climb, P_W_LdgClimb, P_W_AppClimb, P_W_cruise]);