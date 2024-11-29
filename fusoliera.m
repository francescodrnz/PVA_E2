clearvars;close all;clc;requisiti;dati;
larghezza_sedile = 0.52; % [m]
sedili_fila = 4;
larghezza_corridoio = 0.48; % [m]

diametro_interno_min = larghezza_sedile*sedili_fila+larghezza_corridoio;
diametro_esterno_fus = 2.95; % [m]

numero_file = ceil(passeggeri/sedili_fila);
pitch_sedile = 0.75; % [m]clearvars;close all;clc;dati;requisiti;
lunghezza_file = pitch_sedile*numero_file; % [m]

A_fus = pi*(diametro_esterno_fus/2)^2; % [m^2]
L_n = 1.5*diametro_esterno_fus; % [m] slide 10
L_t = 2.5*diametro_esterno_fus; % [m]

lunghezza_fus = L_n+L_t+lunghezza_file; % [m]

W_cargo = 0; % [kg]