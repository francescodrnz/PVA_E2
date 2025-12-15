%% Script Analisi Multivariata - Impatto Variabili Design su Block Fuel
clc; clearvars; close all;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% --- 2. PREPARAZIONE DATI ---
% Variabile Obiettivo (Target)
Y_target = data.P_em/1000;
Y_label = 'Potenza Elettrica Installata [kW]';

% Variabili di Design (Inputs)
X_data = [data.W_S, data.Hp, data.phi_ice_cl, data.phi_ice_cr, data.phi_ice_de];
var_names = {'W/S', 'H_P', '\Phi_{climb}', '\Phi_{cruise}', '\Phi_{descent}'}; 
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
    
    if n_unique >= 3
        degree = 2; % Massimo grado 2 (parabola) per evitare "onde" irreali
    elseif n_unique == 2
        degree = 1;
    else
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

    % --- FIX LIMITI ASSE X ---
    min_val = min(X_data(:,i));
    max_val = max(X_data(:,i));
    delta = max_val - min_val;
    
    % Se i dati variano, imposta i limiti con un margine del 5%
    if delta > 1e-6
        padding = delta * 0.05; % 5% di margine a dx e sx
        xlim([min_val - padding, max_val + padding]);
    else
        % Se la variabile è costante (delta=0), centriamo la vista
        xlim([min_val - 0.1, max_val + 0.1]);
    end

    % --- MODIFICA INTELLIGENTE DEI TICKS ---
    % Se la variabile ha pochi valori discreti (es. < 10), forza i tick su quei valori
    if n_unique <= 10
        xticks(u_vals); % Imposta i tick esattamente sui dati (es. 280, 300, 325...)
        xtickformat('%.4g'); % Rimuove zeri inutili (es. mostra 0.1 invece di 0.1000)
    else
        % Se sono tanti punti sparsi, lascia fare a MATLAB
        xticks('auto');
    end
    
    % Opzionale: se i numeri si sovrappongono, ruotali leggermente
    % xtickangle(45); 

    xlabel(var_names{i}, 'FontWeight', 'bold');
    
    xlabel(var_names{i}, 'FontWeight', 'bold');
    if i == 1
        ylabel(Y_label, 'FontWeight', 'bold');
    end
    grid on; box on;
    title(['vs ' var_names{i}]);
end


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

% Annotazioni
text(-0.1, num_vars+0.6, '\leftarrow Riduce Potenza Elettrica Installata', 'Color', [0 0.5 0], 'HorizontalAlignment', 'right','FontSize', 14);
text(0.1, num_vars+0.6, 'Aumenta Potenza Elettrica Installata \rightarrow', 'Color', [0.6 0 0], 'HorizontalAlignment', 'left','FontSize', 14);
xline(0, 'k-', 'LineWidth', 1.5);

% --- 5. SALVATAGGIO ---
saveas(1, 'OK_Impact_Trends_P_em.png');
saveas(2, 'OK_Impact_Sensitivity_P_em.png');

disp('Grafici salvati.');