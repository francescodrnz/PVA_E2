clearvars;close all;clc;requisiti;dati;

W_S = 0.01:1:450; % range di valutazione
S_ref = 90; % [m^2]
WTO = W_S * S_ref; % [kg]
Cd0 = 0.02;
k_polare = k_polare_livello0;


% CL clean
CLmax_2D_clean = 1.5; % controllare
CLmax_3D_clean = 0.9*CLmax_2D_clean*cosd(sweep25_des);

% CL flapped
Sflap = 0.7*S_ref;
deltaCL_flap_2D = 1.35; % fowler flap
deltaCL_flap_3D = 0.92*deltaCL_flap_2D*Sflap/S_ref*cosd(sweep25_des);

CL_max_flapped = CLmax_3D_clean + deltaCL_flap_3D;

% Stall Speed
W_S_max = 0.5*rho_SL*(1.136*Vstall*kmph2mps)^2*CL_max_flapped/g; % [kg/m^2]

% decollo
a1 = b10 + b11*CL_max_flapped + b12*CL_max_flapped^2;
a2 = b20 + b21*CL_max_flapped + b22*CL_max_flapped^2;
P_W_decollo = a1*W_S + a2*W_S.^2; % [W/kg]

% Climb
C_D_flap = 0.9 * 0.3^1.38 * Sflap/S_ref * sind(15)^2; % check: cflap/c
C_D_LG = 2.92e-03*(WTO*kg2lb).^0.785/(S_ref*sqm2sqft);
% first segment
gamma1 = atan(0/100);
P_W_climb_1 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.2*Vstall*kmph2mps)^3  ./ W_S .* ( (Cd0 + C_D_flap + C_D_LG) + ...
      k_polare * (2 * W_S*g / (rho_SL * (1.2*Vstall*kmph2mps)^2) * cos(gamma1)).^2) + ...
      (1.2*Vstall*kmph2mps) * sin(gamma1)); % [W/kg = m^2/s^3]
% second segment
gamma2 = atan(2.4/100);
P_W_climb_2 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.2*Vstall*kmph2mps)^3  ./ W_S .* ( (Cd0 + C_D_flap) + ...
      k_polare * (2 * W_S*g / (rho_SL * (1.2*Vstall*kmph2mps)^2) * cos(gamma2)).^2) + ...
      (1.2*Vstall*kmph2mps) * sin(gamma2)); % [W/kg = m^2/s^3]
% third segment
gamma3 = atan(1.2/100);
P_W_climb_3 = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.25*Vstall*kmph2mps)^3  ./ W_S .* ( (Cd0) + ...
      k_polare * (2 * W_S*g / (rho_SL * (1.25*Vstall*kmph2mps)^2) * cos(gamma3)).^2) + ...
      (1.25*Vstall*kmph2mps) * sin(gamma3)); % [W/kg = m^2/s^3]

P_W_climb = max(max(P_W_climb_1,P_W_climb_2),P_W_climb_3);


% Landing climb
vLdgClimb = 1.23*Vstall;
gammaLdgClimb = atan(3.2/100);
P_W_LdgClimb = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.25*Vstall*kmph2mps)^3  ./ W_S .* ( (Cd0) + ...
      k_polare * (2 * W_S*g / (rho_SL * (vLdgClimb*kmph2mps)^2) * cos(gammaLdgClimb)).^2) + ...
      (vLdgClimb*kmph2mps) * sin(gammaLdgClimb)); % [W/kg = m^2/s^3]

% Approach climb
vAppClimb = 1.41*Vstall;
gammaAppClimb = atan(2.1/100);
C_D_flap = 0.9 * (1/4.1935)^1.38 * Sflap/S_ref * sind(30)^2;
P_W_AppClimb = 1 / (kOEI * etaP) * ...
      (0.5 * rho_SL * (1.25*Vstall*kmph2mps)^3  ./ W_S .* ( (Cd0) + ...
      k_polare * (2 * W_S*g / (rho_SL * (vAppClimb*kmph2mps)^2) * cos(gammaAppClimb)).^2) + ...
      (vAppClimb*kmph2mps) * sin(gammaAppClimb)); % [W/kg = m^2/s^3]


% Cruise
P_W_cruise = ((0.5*rho_cruise*V_cruise^3) ./ (etaPCruise*W_S)) .* ...
    (Cd0 + k_polare * (2*W_S*g/(rho_cruise*V_cruise^2)).^2); % [W/kg]
P_W_cruise = P_W_cruise/(rho_cruise/rho_SL)^0.75; % riferisco il matching chart al SL % anche in E1 ^0.75?


figure;
hold on;
grid on;
ylim([0 400]);
xline(W_S_max, 'LineWidth', 2);
plot(W_S, P_W_decollo, 'b','Color', 'b', 'LineWidth', 2);
plot(W_S, P_W_climb, 'b','Color', 'r', 'LineWidth', 2);
plot(W_S, P_W_LdgClimb, 'b','Color', 'k', 'LineWidth', 2);
plot(W_S, P_W_AppClimb, 'b','Color', 'c', 'LineWidth', 2);
plot(W_S, P_W_cruise, 'b','Color', 'g', 'LineWidth', 2);

condizione_cruise = P_W_cruise > P_W_decollo & ...
       P_W_cruise > P_W_climb & ...
       P_W_cruise > P_W_LdgClimb & ...
       P_W_cruise > P_W_AppClimb;
condizione_decollo = P_W_decollo > P_W_cruise & ...
       P_W_decollo > P_W_climb & ...
       P_W_decollo > P_W_LdgClimb & ...
       P_W_decollo > P_W_AppClimb;
x = [interp1(P_W_cruise, W_S, 400), W_S(condizione_cruise), W_S(condizione_decollo) W_S_max, W_S_max];
y = [400, interp1(W_S(condizione_cruise), P_W_cruise(condizione_cruise), W_S(condizione_cruise)), ...
    interp1(W_S(condizione_decollo), P_W_decollo(condizione_decollo), W_S(condizione_decollo)), ...
    interp1(W_S, P_W_decollo, W_S_max), 400];
fill(x, y, [0.7 0.7 0.7], 'FaceAlpha', 0.6);

legend('Stall Speed', 'Takeoff', 'Climb', 'Landing Climb', 'Approach Climb', 'Cruise', 'Regione accettabile');

%%
% design point
P_W_des = max([P_W_decollo, P_W_climb, P_W_LdgClimb, P_W_AppClimb, P_W_cruise]);