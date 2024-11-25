dt = 5; % [s]
% initial conditions
W_start = WTO_curr; % [kg]
x_start = 0; % [m]
% inizializzazione
i_cruise = 0; % contatore dello step di eulero
% condizione di arresto: range di crociera (range - salita - discesa)
range_cruise = range; % - salita - discesa, non lo facciamo per ora
n_step = ceil(range/(V*dt))+1;
CL = zeros(n_step,1);
CD = zeros(n_step,1);
D = zeros(n_step,1);
T = zeros(n_step,1);
W = zeros(n_step,1);
W(1) = W_start;
W_dot = zeros(n_step,1);
x = x_start;
time = zeros(n_step,1);
time(1) = 600;
W_fuel = zeros(n_step,1);
W_fuel_dot = zeros(n_step,1);
fuel_fraction = 0.5;
W_fuel(1) = fuel_fraction*W(1);

% climb
z_start = 0;
i_climb = 0;
gamma_climb = atan(ROC/IAS_climb);

z = z_start;

while z < h_cruise
    i_climb = i_climb + 1;

    p_fly = 0.5*rho_SL*IAS_climb^3*CD_curr*S_ref + IAS_climb*W(i_climb)*sin(gamma_climb); % [W]
    p_nec = p_fly/(etaGear*etaProp); % [W]

end

while x < range_cruise
    i_cruise = i_cruise + 1;

    CL(i_cruise) = 2*(W(i_cruise)*g/S)/(rho*V^2); % W si aggiorna
    CD(i_cruise) = Cd0+k*CL(i_cruise)^2;
    D(i_cruise) = 1/2*rho*S*V^2*CD(i_cruise);
    T(i_cruise) = D(i_cruise);

    % equazione costitutiva
    W_dot(i_cruise) = -kc*(T(i_cruise)/g)/3600; % [kg/s] T thrust, me la ricavo dalla resistenza, vado a ritroso, occhio a unità di misura
    % problema di eulero
    W(i_cruise+1) = W(i_cruise) + W_dot(i_cruise)*dt;
    x = x + V*dt;

    time(i_cruise+1) = time(i_cruise)+dt;

    W_fuel_dot(i_cruise) = -W_dot(i_cruise);
    W_fuel(i_cruise+1) = W_fuel(i_cruise)+W_fuel_dot(i_cruise)*dt;
end

    CL(i_cruise+1) = 2*(W(i_cruise+1)*g/S)/(rho*V^2); % W si aggiorna
    CD(i_cruise+1) = Cd0+k*CL(i_cruise+1)^2;
    D(i_cruise+1) = 1/2*rho*S*V^2*CD(i_cruise+1);
    T(i_cruise+1) = D(i_cruise+1);