%relazione costitutiva del turboprop cambia dal turbofan: W_dot = -kc *
%P_ice (in turbofan era W_dot = -c*T)

% cruise
while x < range_cruise % range in metri
    %P_nec = P_fly/(etaGb*etaP), P_fly = T*V, T=D, D = ... come turbofan
    P_ice(i_cruise) = phi_ice_cruise * P_ice_inst;


    W_dot(i_cruise) = -kc * P_ice(i_cruise); %P_ice noto da phi_ice e P_tot
    W(i_cruise+1) = W(i_cruise) + W_dot(i_cruise)*dt;

    %parte elettrica
    P_emot(i_cruise) = P_nec(i_cruise) - P_ice(i_cruise);
    P_batt(i_cruise) = P_emot(i_cruise) / etaEm;
    % poi eulero per energia richiesta alla batteria
    E_batt(i_cruise+1) = E_batt(i_cruise) + P_batt(i_cruise)*dt; % energia richiesta alle batterie, parte da zero

    x = x + V_cruise * dt; % [m]
end