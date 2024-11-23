% fattori di conversione
ft2m = 0.3048;
m2ft = 1 / ft2m;
sqft2sqm = ft2m*ft2m;
sqm2sqft = 1/sqft2sqm;
lb2kg = 0.45359237;
kg2lb = 1 / lb2kg;
nm2km = 1.852;
mps2kmph = 3.6;
kmph2mps = 1 / mps2kmph;
l2gal = 3.785411784;
ftpmin2mps = ft2m / 60;
kt2mps = nm2km*kmph2mps;

% Dati
rho_SL = 1.225; % [kg/m^3]
a_SL = 340.3; % [m/s]
h_cruise = 20000*ft2m; % [m]
rho_cruise = 0.6527; % [kg/m^3]
a_cruise = 316.0; % [m/s]
visc_dinamica_cruise = 1.5984e-5; % [kg/(m*s)]

%dati di test
S_ref = 55.2;
b = (24.7-2.88);
AR = b^2/S_ref;
Cd0_livello0 = 0.02;

% Matching chart
Vstall = 180; % [km/h]
g = 9.81; % [m/s^2]
b10 = 0.2792;
b11 = -0.03285;
b12 = -0.007541;
b20 = 0.01076;
b21 = -0.007067;
b22 = 0.001276;
kOEI = 1/2; % motori operativi / motori totali
etaP = 0.75; % efficienza elica
etaPCruise = 0.85; % efficienza elica in crociera
oswald_livello0 = 0.8; % fattore di Oswald
k_polare_livello0 = 1/(pi*AR*oswald_livello0); % calcolo Cd

% missione
etaEm = 0.95;
etaGear = 0.98;
ROC = ROC * ftpmin2mps; % [m/s]
ROD = ROD * ftpmin2mps; % [m/s]
IAS_climb = IAS_climb * kt2mps; % [m/s]
IAS_descent = IAS_descent * kt2mps; % [m/s]