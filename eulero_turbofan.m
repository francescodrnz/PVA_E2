% prestazioni turbofan con eulero, crociera
clearvars; close all; clc;

% input data
Cd0 = 0.02;
AR = 9;
oswald = 0.8;
k = 1/(pi*AR*oswald);
S = 122.4; % [m^2]
M = 0.8;
h = 11000; % [m]
rho = 0.3639; % [kg/m^3]
a = 295.07; % [m/s]
V = M*a; % [m/s]
c = 0.5; % [kg/(kg*h)]
% in teoria bisognerebbe fare sensibilità al dt, ma non lo facciamo
dt = 5; % [s], va già bene nell'ordine di qualche secondo
range = 5000 * 1000; % [m]
g = 9.81; % [m/s^2]

% initial conditions
W_start = 74000; % [kg]
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

tic
while x < range_cruise

    i_cruise = i_cruise + 1;

    CL(i_cruise) = 2*(W(i_cruise)*g/S)/(rho*V^2); % W si aggiorna
    CD(i_cruise) = Cd0+k*CL(i_cruise)^2;
    D(i_cruise) = 1/2*rho*S*V^2*CD(i_cruise);
    T(i_cruise) = D(i_cruise);

    % equazione costitutiva
    W_dot(i_cruise) = -c*(T(i_cruise)/g)/3600; % [kg/s] T thrust, me la ricavo dalla resistenza, vado a ritroso, occhio a unità di misura
    % problema di eulero
    W(i_cruise+1) = W(i_cruise) + W_dot(i_cruise)*dt;
    x = x + V*dt;

    time(i_cruise+1) = time(i_cruise)+dt;

    W_fuel_dot(i_cruise) = -W_dot(i_cruise);
    W_fuel(i_cruise+1) = W_fuel(i_cruise)+W_fuel_dot(i_cruise)*dt;
end
toc
%alcune variabili non vengono ricalcolate all'ultimo step, le aggiungo dopo
%il ciclo
    CL(i_cruise+1) = 2*(W(i_cruise+1)*g/S)/(rho*V^2); % W si aggiorna
    CD(i_cruise+1) = Cd0+k*CL(i_cruise+1)^2;
    D(i_cruise+1) = 1/2*rho*S*V^2*CD(i_cruise+1);
    T(i_cruise+1) = D(i_cruise+1);


figure;
grid on;
plot(time/(60*dt),W)