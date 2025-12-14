%% Script Analisi Multivariata - Impatto Variabili Design su Block Fuel
clc; clearvars; close all;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% --- 2. PREPARAZIONE DATI ---
% Variabile Obiettivo (Target)
Y_target = data.P_ice;
Y_label = 'Potenza Termica [W]';

% Variabili di Design (Inputs)
X_data = [data.W_S, data.Hp, data.phi_ice_cl, data.phi_ice_cr, data.phi_ice_de, data.W_block_fuel];
var_names = {'W/S', 'H_P', '\Phi_{climb}', '\Phi_{cruise}', '\Phi_{descent}', 'Block Fuel [kg]'}; 
num_vars = length(var_names);


% --- 3. PLOT 1: SCATTER PLOT MATRIX (Trend diretti) ---
figure('Name', 'Impact_Trends', 'Color', 'w', 'Position', [100 100 1200 400]);

for i = 1:num_vars
    subplot(1, num_vars, i);
    
    % Scatter dei punti
    scatter(X_data(:,i), Y_target, 30, 'filled', 'MarkerFaceAlpha', 0.4, ...
        'MarkerFaceColor', [0 0.4 0.7]);
    
    hold on;
    
    % --- FITTING ADATTIVO (Fix Warning) ---
    % Controlla quanti valori unici ci sono per questa variabile
    u_vals = unique(X_data(:,i));
    n_unique = length(u_vals);
    
    if n_unique >= 5
        % Se ho abbastanza punti, uso una parabola (grado 2) per vedere curvature
        degree = 4;
    elseif n_unique >= 4
        % Se ho abbastanza punti, uso una parabola (grado 2) per vedere curvature
        degree = 3;
    elseif n_unique >= 3
        % Se ho abbastanza punti, uso una parabola (grado 2) per vedere curvature
        degree = 2;
    elseif n_unique == 2
        % Se ho solo 2 punti (es. 0.1 e 0.3), uso una retta (grado 1)
        degree = 1;
    else
        % Caso degenere (variabile costante), grado 0
        degree = 0; 
    end
    
    if n_unique > 1
        % Calcolo fit
        [p_fit, S, mu] = polyfit(X_data(:,i), Y_target, degree); 
        
        % Genero punti per il plot della linea
        x_range = linspace(min(X_data(:,i)), max(X_data(:,i)), 50);
        
        % Valuto fit (con scaling automatico per stabilità numerica se necessario)
        % Nota: polyfit con 3 output gestisce scaling automaticamente se usato con polyval
        y_fit = polyval(p_fit, x_range, S, mu);
        
        plot(x_range, y_fit, 'r-', 'LineWidth', 2);
    end
    
    xlabel(var_names{i}, 'FontWeight', 'bold');
    if i == 1
        ylabel(Y_label, 'FontWeight', 'bold');
    end
    grid on; box on;
    title(['vs ' var_names{i}]);
end
sgtitle('Trend diretti: Come ogni variabile influenza il consumo', 'FontSize', 14);


% --- 4. PLOT 2: SENSITIVITY ANALYSIS (Correlazione) ---
figure('Name', 'Sensitivity_Bar', 'Color', 'w');

correlations = zeros(1, num_vars);
for i = 1:num_vars
    % Correlazione lineare di Pearson
    correlations(i) = corr(X_data(:,i), Y_target);
end

b = barh(correlations);
b.FaceColor = 'flat';

% Colorazione condizionale
for i = 1:num_vars
    if correlations(i) > 0
        b.CData(i,:) = [0.8 0.2 0.2]; % Rosso (Aumenta Fuel -> Male)
    else
        b.CData(i,:) = [0.2 0.7 0.2]; % Verde (Riduce Fuel -> Bene)
    end
end

yticks(1:num_vars);
yticklabels(var_names);
grid on; box on;
xlim([-1 1]); % Forza asse da -1 a 1 per vedere la magnitudo
xlabel('Coefficiente di Correlazione', 'FontWeight', 'bold');
title('Analisi di Sensibilità sul Block Fuel', 'FontSize', 14);

% Annotazioni
text(-0.1, num_vars+0.6, '\leftarrow Riduce Potenza Termica Installata', 'Color', [0 0.5 0], 'HorizontalAlignment', 'right','FontSize', 14);
text(0.1, num_vars+0.6, 'Aumenta Potenza Termica Installata \rightarrow', 'Color', [0.6 0 0], 'HorizontalAlignment', 'left','FontSize', 14);
xline(0, 'k-', 'LineWidth', 1.5);

% --- 5. SALVATAGGIO ---
saveas(1, 'Impact_Trends_P_ice.png');
saveas(2, 'Impact_Sensitivity_P_ice.png');

disp('Grafici generati senza warning di fitting.');