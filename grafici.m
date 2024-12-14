close all;clc;clearvars;
data = loadMostRecentCSV();
W_S_vect = unique(data.W_S);

% potenza installata = f(block fuel)
figure;
hold on;

cmap = lines(length(W_S_vect)); % colori

for i = 1:length(W_S_vect)
    idx = data.W_S == W_S_vect(i);
    
    % Scatter plot
    scatter(data.W_block_fuel(idx), data.P_tot(idx), 50, cmap(i, :), 'filled', ...
        'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
    
    % Verifica che ci siano abbastanza dati per la regressione
    if sum(idx) > 1 % Assicurati di avere più di un dato per fare la regressione
        % Calcolo della linea di tendenza
        coeffs = polyfit(data.W_block_fuel(idx), data.P_tot(idx), 1); % Regressione lineare
        block_fuel_fit = linspace(min(data.W_block_fuel(idx)), max(data.W_block_fuel(idx)), 100);
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
    idx = (data.W_S == W_S_vect(i)); % Trova i dati per W_S specifico
    if any(idx) % Controlla se ci sono dati validi per questo W_S
        % Scatter plot
        scatter(data.WTO(idx), data.W_block_fuel(idx), 50, cmap(i, :), 'filled', ...
            'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
        
        % Calcolo della linea di tendenza
        coeffs = polyfit(data.WTO(idx), data.W_block_fuel(idx), 1); % Regressione lineare
        WTO_fit = linspace(min(data.WTO(idx)), max(data.WTO(idx)), 100);
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
    idx = data.W_S == W_S_vect(i);
    
    % Scatter plot Block Fuel vs Peso delle Batterie
    scatter(data.W_battery(idx), data.W_block_fuel(idx), 50, cmap(i, :), 'filled', ...
        'DisplayName', sprintf('W_S = %d', W_S_vect(i)));
    
    % Verifica che ci siano abbastanza dati per la regressione
    if sum(idx) > 1
        % Calcolo della linea di tendenza
        coeffs = polyfit(data.W_battery(idx), data.W_block_fuel(idx), 1); % Regressione lineare
        W_batt_fit = linspace(min(data.W_battery(idx)), max(data.W_battery(idx)), 100);
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