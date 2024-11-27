% ricalcolare potenze con Hp
P_tot = P_curr / (etaGear*etaProp);
P_em = Hp_des * P_tot / etaEm; % [W] potenza elettrica installata
P_ice = P_tot - P_em;

dt = 5; % [s]
% initial conditions
W_start = WTO_curr; % [kg]
x_start = 0; % [m]
z_start = 0; % [m]
% inizializzazione
n_step = 2*ceil(taxi_time/dt) + ceil(takeoff_time/dt) + ceil(h_cruise/(ROC*dt)) + 1 + ceil(range/(V_cruise*dt))+1; % eccesso, la crociera è meno del range
n_step_climb = ceil(h_cruise/(ROC*dt))+1;
P_nec = zeros(n_step, 1);
CL = zeros(n_step, 1);
CD = zeros(n_step, 1);
D = zeros(n_step, 1);
W = zeros(n_step, 1);
W(1) = W_start;
W_dot = zeros(n_step, 1);
time = zeros(n_step, 1);
time(1) = 0;
E_batt = zeros(n_step, 1);
E_batt_dot = zeros(n_step, 1);
phi_em = zeros(n_step, 1);

% taxi out
i_taxi_out = 0;
phi_ice_taxi = 0; % taxi-out e -in full electric
while time(i_taxi_out + 1) < taxi_time
    i_taxi_out = i_taxi_out + 1;

    P_nec(i_taxi_out) = 0.07 * P_tot / etaEm; % [W], full electric
    % consumo batteria
    E_batt_dot(i_taxi_out) = - P_nec(i_taxi_out);
    E_batt(i_taxi_out + 1) = E_batt(i_taxi_out) + E_batt_dot(i_taxi_out) * dt * sec2hr; % [W*h]
    phi_em(i_taxi_out) = P_nec(i_taxi_out) / P_em;
    % consumo carburante
    W_dot(i_taxi_out) = - phi_ice_taxi * kc * P_ice;
    W(i_taxi_out + 1) = W(i_taxi_out) + W_dot(i_taxi_out) * dt; % [kg]

    time(i_taxi_out+1) = time(i_taxi_out) + dt;

end

% take off
i_take_off = i_taxi_out;
phi_ice_takeoff = 1; % full power al decollo
phi_el_takeoff = 1; % full power al decollo
while (time(i_take_off + 1) - time(i_taxi_out + 1)) < takeoff_time
    i_take_off = i_take_off + 1;

    P_nec(i_take_off) = (P_em + P_ice);
    % consumo batteria
    E_batt_dot(i_take_off) = - phi_el_takeoff * P_em;
    E_batt(i_take_off + 1) = E_batt(i_take_off) + E_batt_dot(i_take_off) * dt * sec2hr; % [W*h]
    phi_em(i_take_off) = 1;
    % consumo carburante
    W_dot(i_take_off) = - kc * phi_ice_takeoff * P_ice / (hr2sec); % [kg/s]
    W(i_take_off + 1) = W(i_take_off) + W_dot(i_take_off) * dt; % [kg]

    time(i_take_off+1) = time(i_take_off) + dt;
end

% climb: constant IAS and ROC
i_climb = i_take_off;
gamma_climb = atan(ROC/IAS_climb);
Vx_climb = IAS_climb * cos(gamma_climb); % [m/s]
P_ice_cl = phi_ice_cl * P_ice; % [W]

z = z_start;

while z < h_cruise
    i_climb = i_climb + 1;
    [Temp, a, press, rho] = atmosisa(z);


    CL(i_climb) = 2*(W(i_climb)*g/S_ref) / (rho*IAS_climb^2);
    CD(i_climb) = Cd0 + k_polare * CL(i_climb)^2;
    D(i_climb) = 1/2*rho*S_ref*IAS_climb^2*CD(i_climb);

    P_fly = D(i_climb)*IAS_climb + IAS_climb*W(i_climb)*sin(gamma_climb); % [W]
    P_nec(i_climb) = P_fly/(etaGear*etaProp); % [W]

    % consumo batteria
    E_batt_dot(i_climb) = - (P_nec(i_climb)/etaEm - P_ice_cl);
    E_batt(i_climb + 1) = E_batt(i_climb) + E_batt_dot(i_climb) * dt * sec2hr; % [W*h]
    phi_em(i_climb) = - E_batt_dot(i_climb) / P_em;
    % consumo carburante
    W_dot(i_climb) = - kc * P_ice_cl/ hr2sec; % [kg/s]
    W(i_climb + 1) = W(i_climb) + W_dot(i_climb) * dt * sec2hr; % [kg]

    z = z + ROC * dt; % [m]
    time(i_climb+1) = time(i_climb) + dt;

end

% cruise
x = x_start + Vx_climb * time(i_climb+1);

i_cruise = i_climb;

while x < range % range in metri
    i_cruise = i_cruise + 1;

    CL(i_cruise) = 2*(W(i_cruise)*g/S)/(rho*V^2); % W si aggiorna
    CD(i_cruise) = Cd0+k*CL(i_cruise)^2;
    D(i_cruise) = 1/2*rho*S*V^2*CD(i_cruise);

    % equazione costitutiva
    W_dot(i_cruise) = -kc*(D(i_cruise)/g)/3600; % [kg/s]
    % problema di eulero
    W(i_cruise+1) = W(i_cruise) + W_dot(i_cruise)*dt;
    x = x + V*dt;

    time(i_cruise+1) = time(i_cruise)+dt;
end

CL(i_cruise+1) = 2*(W(i_cruise+1)*g/S)/(rho*V^2); % W si aggiorna
CD(i_cruise+1) = Cd0+k*CL(i_cruise+1)^2;
D(i_cruise+1) = 1/2*rho*S*V^2*CD(i_cruise+1);
T(i_cruise+1) = D(i_cruise+1);