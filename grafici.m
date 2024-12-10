close all;clc;

% potenza installata = f(block fuel)
figure;
hold on;

cmap = [1 1 0; 0 1 0; 0 0 1; 1 0 0]; % colori

for i = 1:length(W_S_vect)
    idx = W_S_des_memo == W_S_vect(i);
    
    % Scatter plot
    scatter(W_block_fuel_memo(idx), P_tot_memo(idx), 50, cmap(i, :), 'filled', ...
        'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
    
    % Verifica che ci siano abbastanza dati per la regressione
    if sum(idx) > 1 % Assicurati di avere più di un dato per fare la regressione
        % Calcolo della linea di tendenza
        coeffs = polyfit(W_block_fuel_memo(idx), P_tot_memo(idx), 1); % Regressione lineare
        block_fuel_fit = linspace(min(W_block_fuel_memo(idx)), max(W_block_fuel_memo(idx)), 100);
        P_tot_fit = polyval(coeffs, block_fuel_fit);
        
        % Disegna la linea di tendenza (tratteggiata)
        plot(block_fuel_fit, P_tot_fit, 'Color', cmap(i, :), 'LineWidth', 1.5, 'LineStyle', '--', ...
            'DisplayName', sprintf('Trend W_S = %d', W_S_vect(i)));
    end
end

xlabel('Block Fuel [kg]');
ylabel('Potenza Installata [W]');
title('Potenza Installata vs Block Fuel suddivisa per W/S');
legend('Location', 'best');
grid on;
hold off;

%% block fuel = f(MTOW)
figure;
hold on;

for i = 1:length(W_S_vect)
    idx = (W_S_des_memo == W_S_vect(i)); % Trova i dati per W_S specifico
    if any(idx) % Controlla se ci sono dati validi per questo W_S
        % Scatter plot
        scatter(WTO_memo(idx), W_block_fuel_memo(idx), 50, cmap(i, :), 'filled', ...
            'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
        
        % Calcolo della linea di tendenza
        coeffs = polyfit(WTO_memo(idx), W_block_fuel_memo(idx), 1); % Regressione lineare
        WTO_fit = linspace(min(WTO_memo(idx)), max(WTO_memo(idx)), 100);
        block_fuel_fit = polyval(coeffs, WTO_fit);
        
        % Disegna la linea di tendenza
        plot(WTO_fit, block_fuel_fit, 'Color', cmap(i, :), 'LineWidth', 1.5, 'LineStyle', '--', ...
            'DisplayName', sprintf('Trend W_S = %d', W_S_vect(i)));
    end
end

% Aggiungere etichette e legenda
xlabel('WTO [kg]');
ylabel('Block Fuel [kg]');
title('Block Fuel vs WTO suddivisa per W_S con Linea di Tendenza');
legend('Location', 'best');
grid on;
hold off;

%% block fuel = f(W_batt)

figure;
hold on;

for i = 1:length(W_S_vect)
    idx = W_S_des_memo == W_S_vect(i);
    
    % Scatter plot Block Fuel vs Peso delle Batterie
    scatter(W_batt_memo(idx), W_block_fuel_memo(idx), 50, cmap(i, :), 'filled', ...
        'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
    
    % Verifica che ci siano abbastanza dati per la regressione
    if sum(idx) > 1
        % Calcolo della linea di tendenza
        coeffs = polyfit(W_batt_memo(idx), W_block_fuel_memo(idx), 1); % Regressione lineare
        W_batt_fit = linspace(min(W_batt_memo(idx)), max(W_batt_memo(idx)), 100);
        W_block_fuel_fit = polyval(coeffs, W_batt_fit);
        
        % Disegna la linea di tendenza (tratteggiata)
        plot(W_batt_fit, W_block_fuel_fit, 'Color', cmap(i, :), 'LineWidth', 1.5, 'LineStyle', '--', ...
            'DisplayName', sprintf('Trend W_S = %d', W_S_vect(i)));
    end
end

% Aggiungi etichette e legenda
xlabel('Peso delle Batterie (kg)');
ylabel('Block Fuel (kg)');
legend('show');
title('Block Fuel vs Peso delle Batterie');
legend('Location', 'best');
grid on;
hold off;