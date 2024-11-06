% CL clean
CLmax_2D_clean = 1.5; % controllare
sweep25 = 0;
CLmax_3D_clean = 0.9*CLmax_2D_clean*cosd(sweep25);

% CL flapped
Sflap_S = 0.7;
deltaCL_flap_2D = 1.35; % fowler flap
deltaCL_flap_3D = 0.92*deltaCL_flap_2D*Sflap_S*cosd(sweep25);

CL_max_flapped = CLmax_3D_clean + deltaCL_flap_3D;

W_S_max = 0.5*rho_SL*(1.136*Vstall*kmph2mps)^2*CL_max_flapped/g; % [kg/m^2]


% decollo
a1 = b10 + b11*CL_max_flapped + b12*CL_max_flapped^2;
a2 = b20 + b21*CL_max_flapped + b22*CL_max_flapped^2;
P_W_decollo = a1*W_S_des + a2*W_S_des^2; % [W/kg]