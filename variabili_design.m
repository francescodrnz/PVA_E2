function [W_S_vect, phi_ice_cl_vect, phi_ice_cr_vect, phi_ice_de_vect, Hp_vect] = variabili_design(case_selector)
% GET_DESIGN_VECTORS Restituisce i vettori di progetto in base al caso selezionato.
%
% Input:
%   case_selector : intero 1, 2, o 3
%       1 -> Spazio Originale
%       2 -> Aereo Scelto
%       3 -> Spazio Espanso
%
% Output:
%   Restituisce i vettori W_S, phi_ice (cl, cr, de) e Hp corrispondenti.

    switch case_selector
        case 1
            %% SPAZIO ORIGINALE
            W_S_vect = [280 300 325 350];        % [kg/m^2]
            phi_ice_cl_vect = [0.1 0.3 0.5];
            phi_ice_cr_vect = [0.1 0.2 0.3 0.4 0.5];
            phi_ice_de_vect = [0.1 0.3];
            Hp_vect = [0.1 0.2 0.3 0.4];         % fattore di ibridizzazione

        case 2
            %% AEREO SCELTO
            W_S_vect = [300];                    % [kg/m^2]
            phi_ice_cl_vect = [0.1];
            phi_ice_cr_vect = [0.1];
            phi_ice_de_vect = [0.3];
            Hp_vect = [0.3];                     % fattore di ibridizzazione

        case 3
            %% SPAZIO ESPANSO
            W_S_vect = [280 290 300 310 320 330]; % [kg/m^2]
            phi_ice_cl_vect = [0.1 0.2 0.3];
            phi_ice_cr_vect = [0.1 0.12 0.15 0.2];
            phi_ice_de_vect = [0.1 0.2 0.3 0.4];
            Hp_vect = [0.25 0.30 0.35 0.4 0.5];   % fattore di ibridizzazione

        otherwise
            error('Selezione non valida. Inserire 1, 2 o 3.');
    end
end