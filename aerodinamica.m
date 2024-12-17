f_lambda = 0.0524*lambda_des^4-0.15*lambda_des^3+0.1659*lambda_des^2-0.0706*lambda_des+0.0119; % formula interpolativa
oswald = cosd(sweep25_des)/(1+AR_des*f_lambda);
k_polare = 1/(pi*AR_des*oswald);

% Cd0
Reynolds_1metro = V_cruise/(visc_dinamica_cruise/rho_cruise);
% ala
cF_ala = 0.455/(log10(Reynolds_1metro*MAC)^2.58+(1+0.144*M_des)^0.65); % coefficiente d'attrito equivalente
FF_ala = (1+0.6/0.5*t_c_des+100*t_c_des^4)*(1.34*M_des^0.18*cosd(sweep25_des)^0.28); % fattore di forma
Q_ala = 1.0; % fattore di interferenza
Swet_ala = S_ref*(1.997+0.52*t_c_des); % superficie bagnata
% fusoliera
cF_fus = 0.455/(log10(Reynolds_1metro*lunghezza_fus)^2.58+(1+0.144*M_des)^0.65);
f_fus = (lunghezza_fus*m2ft)/sqrt(4/pi*A_fus*sqm2sqft); % fattore geometrico
FF_fus = (1+60/f_fus^3+f_fus/400);
Q_fus = 1.0;
% stimo fusoliera come semisfera + cilindro + trapezio
Swet_fus = pi*(diametro_esterno_fus^2/2+...
    diametro_esterno_fus*(lunghezza_fus-diametro_esterno_fus/2-L_t))+...
    (diametro_esterno_fus+pi)*L_t/2; % diametro posteriore 1 metro
% piani di coda
% orizzontali
b_orizz = sqrt(AR_orizz*S_orizz); % [m]
cF_orizz = 0.455/(log10(Reynolds_1metro*b_orizz/AR_orizz)^2.58+(1+0.144*M_des)^0.65);
FF_orizz = (1+0.6/0.5*t_c_orizz+100*t_c_orizz^4)*(1.34*M_des^0.18*cosd(sweep25_orizz)^0.28);
Q_orizz = 1.05;
Swet_orizz = S_orizz*(1.997+0.52*t_c_orizz);
% verticale
b_vert = sqrt(AR_vert * S_vert); % [m]
cF_vert = 0.455/(log10(Reynolds_1metro*b_vert/AR_vert)^2.58+(1+0.144*M_des)^0.65);
FF_vert = (1+0.6/0.5*t_c_vert+100*t_c_vert^4)*(1.34*M_des^0.18*cosd(sweep25_vert)^0.28);
Q_vert = 1.05;
Swet_vert = S_vert*(1.997+0.52*t_c_vert);
% nacelle
D_nac = 0.04*sqrt(P_curr/(2*V_cruise*g)*kg2lb)*ft2m; % [m]
L_nac = 0.07*sqrt(P_curr/(2*V_cruise*g)*kg2lb)*ft2m; % [m] da formula
A_nac = pi*(D_nac/2)^2;
cF_nac = 0.455/(log10(Reynolds_1metro*L_nac)^2.58+(1+0.144*M_des)^0.65); 
f_nac = (L_nac*m2ft)/sqrt(4/pi*A_nac*sqm2sqft); % fattore geometrico
FF_nac = (1+60/f_nac^3+f_nac/400);
Q_nac = 1.0;
Swet_nac = pi*D_nac*L_nac;

Cd0 = (cF_ala*FF_ala*Q_ala*Swet_ala + cF_fus*FF_fus*Q_fus*Swet_fus + cF_orizz*FF_orizz*Q_orizz*Swet_orizz + ...
    cF_vert*FF_vert*Q_vert*Swet_vert + cF_nac*FF_nac*Q_nac*Swet_nac) / S_ref;


% drag raise
Cdw = 0; % per assunto, Mach bassi

% indotto
Cdi = k_polare * CL_des^2;


% totale
CD_curr = Cd0 + Cdw + Cdi;