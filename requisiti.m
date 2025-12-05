% matricola 256693
H_req = 319;
L_req = 693;
passeggeri = round(30+15*L_req/999); % = 40
range = 300+300*(H_req-319)/43 *1.852; % [km] = 300 nm
BED = 400+200*L_req/999; % [W*h/kg] = 538.7
BFL = 1100; % [m]

% missione
IAS_climb = 170; % [kt]
ROC = 900; % [ft/min]
M_des = 0.4;
h_cruise = 6100; % [m]
IAS_descent = 220; % [kt]
ROD = -1100; % [ft/min]
range_cruise = (range-144)*1.852; % [km]
% diversione
IAS_climb_diversion = 150; % [kt]
ROC_diversion = 600; % [ft/min]
M_cruise_diversion = 0.27;
h_cruise_diversion = 3050; % [m]
IAS_descent_diversion = 150; % [kt]
ROD_diversion = -1100; % [ft/min]
range_cruise_diversion = 120*1.852; % [km]
loiter_duration = 30*60; % [s]