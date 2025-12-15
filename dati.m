% fattori di conversione
ft2m = 0.3048;
m2ft = 1 / ft2m;
sqft2sqm = ft2m*ft2m;
sqm2sqft = 1/sqft2sqm;
lb2kg = 0.45359237;
kg2lb = 1 / lb2kg;
nm2km = 1.852;
km2nm = 1 / nm2km;
mps2kmph = 3.6;
kmph2mps = 1 / mps2kmph;
l2gal = 3.785411784;
ftpmin2mps = ft2m / 60;
kt2mps = nm2km*kmph2mps;
hr2sec = 3600;
sec2hr = 1 / hr2sec;
hp2W = 745.7;
W2hp = 1 / hp2W;
Wh2J = 3600;
J2Wh = 1 / Wh2J;
inflazione = 1.64;

% Dati
AR_des = 11;
t_c_des = 0.15;
lambda_des = 0.5;
Cd0_livello0 = 0.02;
sweep25_des = 0;
rho_SL = IntStandAir_SI(0, 'rho'); % [kg/m^3]
a_SL = IntStandAir_SI(0, 'a'); % [m/s]
rho_cruise = IntStandAir_SI(h_cruise, 'rho'); % [kg/m^3]
a_cruise = IntStandAir_SI(h_cruise, 'a'); % [m/s]
V_cruise = M_des * a_cruise; % [m/s]
visc_dinamica_cruise = IntStandAir_SI(h_cruise, 'mu'); % [kg/(m*s)]
rho_cruise_diversion = IntStandAir_SI(h_cruise_diversion, 'rho'); % [kg/m^3]
a_cruise_diversion = IntStandAir_SI(h_cruise_diversion, 'a'); % [m/s]
V_cruise_diversion = M_cruise_diversion * a_cruise_diversion; % [m/s]


% Matching chart
Vstall = 170; % [km/h]
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
k_polare_livello0 = 1/(pi*AR_des*oswald_livello0); % calcolo Cd

% missione
etaEm = 0.95;
etaGear = 0.98;
etaProp = 0.85;
ROC = ROC * ftpmin2mps; % [m/s]
ROD = ROD * ftpmin2mps; % [m/s]
IAS_climb = IAS_climb * kt2mps; % [m/s]
IAS_descent = IAS_descent * kt2mps; % [m/s]
% diversione
ROC_diversion = ROC_diversion * ftpmin2mps; % [m/s]
ROD_diversion = ROD_diversion * ftpmin2mps; % [m/s]
IAS_climb_diversion = IAS_climb_diversion * kt2mps; % [m/s]
IAS_descent_diversion = IAS_descent_diversion * kt2mps; % [m/s]

% prestazioni
kc = 6.614e-8/J2Wh; % power-specific fuel consumption [kg/(W*h)]
taxi_time = 240; % [s]
takeoff_time = 45; % [s]
a_diversion = 0.0122; % [1/(kg*10^3)]
b_diversion = 15.6357; % ??? no

% pesi
N_prop = 2; % numero propulsori
EMPD = 16*1e3; % [W/kg]
K_nac = 0.14 * lb2kg / hp2W; % [kg/W]
N_serbatoi = 2;
ultimate_load_fact = 3.75;
max_fuel_volume = 1000; % [l]
peso_passeggero = 93; % [kg]

% payload-range chart
fuel_density = 0.785; % [kg/l]

% stabilita
V_H_livello0 = 0.9;
V_V_livello0 = 0.08;
AR_orizz = 6;
t_c_orizz = 0.1;
sweep25_orizz = 29; % [°]
AR_vert = 1.6;
t_c_vert = 0.12;
sweep25_vert = 34; % [°]

% costi
jet_fuel_cost = 686.33; % [$/(kg*10^3)]
man_hour_cost = 55*inflazione; % [$/h]
K_engine = 0.57;
OPR = 32;
BPR = 50;
N_comp = 12;
FED = 12000; % fuel energy density [Wh/kg]
