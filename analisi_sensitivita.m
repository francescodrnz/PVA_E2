%% Script Analisi Multivariata - Visualizzazione Discrete Main Effects
clc; clearvars; close all;

% --- 0. IMPOSTAZIONI GRAFICHE ---
fig_width = 1100;
fig_height = 350;
fig_pos = [100, 100, fig_width, fig_height];

% --- 1. CONFIGURAZIONE ---
% Nota: 'S' invece di 'S_ref' come richiesto
target_fields = {'P_em', 'P_ice', 'W_block_fuel', 'S'}; 

y_labels = { ...
    'Potenza Elettrica [kW]', ...
    'Potenza Termica [kW]', ...
    'Block Fuel [kg]', ...
    'Superficie Alare [m^2]' ...
};
annotation_names = {'Potenza Elettrica', 'Potenza Termica', 'Block Fuel', 'Superficie Alare'};
file_suffixes = {'P_em', 'P_ice', 'Block_Fuel', 'S_ref'};
scaling_factors = [1000, 1000, 1, 1]; 

% --- 2. CARICAMENTO DATI ---
data = loadMostRecentCSV();

X_data = [data.W_S, data.Hp, data.phi_ice_cl, data.phi_ice_cr, data.phi_ice_de];
var_names = {'W/S', 'H_P', '\Phi_{climb}', '\Phi_{cruise}', '\Phi_{descent}'}; 
num_vars = length(var_names);
num_targets = length(target_fields);

% --- 3. CICLO ANALISI ---
for k = 1:num_targets
    
    current_field = target_fields{k};
    current_label = y_labels{k};
    current_anno  = annotation_names{k};
    current_suffix = file_suffixes{k};
    current_scale = scaling_factors(k);
    
    % Check esistenza campo (per sicurezza, visto il cambio nome)
    field_exists = false;
    if istable(data)
        % Se è una tabella, controlla nei nomi delle variabili
        field_exists = ismember(current_field, data.Properties.VariableNames);
    elseif isstruct(data)
        % Se è una struct, usa isfield
        field_exists = isfield(data, current_field);
    end

    if ~field_exists
        warning('Campo "%s" non trovato in data. Salto.', current_field);
        continue;
    end
    
    Y_target = data.(current_field) / current_scale;
    
    fprintf('Generazione Main Effects (%s)...\n', current_anno);
    
    % --- IDENTIFICAZIONE VARIABILE DOMINANTE (per colorazione) ---
    correlations_temp = zeros(1, num_vars);
    for j = 1:num_vars
        correlations_temp(j) = corr(X_data(:,j), Y_target);
    end
    [~, idx_dom] = max(abs(correlations_temp));
    
    dom_vals_raw = X_data(:, idx_dom); 
    dom_name = var_names{idx_dom};
    
    % Discretizzazione dei colori
    % Troviamo i valori unici della variabile dominante
    unique_dom_vals = unique(dom_vals_raw);
    n_colors = length(unique_dom_vals);
    
    % Mappiamo ogni punto a un indice intero (1, 2, 3...)
    [~, ~, color_indices] = unique(dom_vals_raw);
    
    % --- PLOT 1: MAIN EFFECTS (Discreto) ---
    f1 = figure('Name', ['Trends_' current_suffix], 'Color', 'w', 'Position', fig_pos);
    
    % Definisco la colormap personalizzata (es. parula o jet discretizzato)
    % Usiamo 'jet' o 'parula' campionato in N punti esatti
    custom_cmap = parula(n_colors); 
    colormap(custom_cmap);
    
    for i = 1:num_vars
        subplot(1, num_vars, i);
        
        x_curr = X_data(:,i);
        u_vals_x = unique(x_curr);
        
        hold on;
        
        % 1. Scatter "Ghost" colorato discretamente
        % Usiamo 'color_indices' come valore per il colore (CData)
        scatter(x_curr, Y_target, 25, color_indices, 'filled', ...
            'MarkerFaceAlpha', 0.6);
        
        % 2. Calcolo Statistiche (Media e Std)
        means = zeros(size(u_vals_x));
        stds = zeros(size(u_vals_x));
        
        for u = 1:length(u_vals_x)
            mask = (x_curr == u_vals_x(u));
            means(u) = mean(Y_target(mask));
            stds(u) = std(Y_target(mask));
        end
        
        % 3. Plot Linea Media e Area Incertezza
        if length(u_vals_x) > 1
            % Area Std Dev (Grigia trasparente)
            fill([u_vals_x; flipud(u_vals_x)], ...
                 [means - stds; flipud(means + stds)], ...
                 [0.2 0.2 0.2], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
             
            % Linea Media (Nera solida)
            plot(u_vals_x, means, 'k-o', 'LineWidth', 1.5, ...
                'MarkerFaceColor', 'k', 'MarkerSize', 3);
        else
            plot(u_vals_x, means, 'ko', 'LineWidth', 1.5);
        end
        
        % Formatting assi
        min_v = min(x_curr); max_v = max(x_curr); delta = max_v - min_v;
        if delta > 1e-6, pad = delta * 0.1; xlim([min_v - pad, max_v + pad]); 
        else, xlim([min_v - 0.1, max_v + 0.1]); end
        
        if length(u_vals_x) <= 6
            xticks(u_vals_x); xtickformat('%.4g'); 
        else
            xticks('auto');
        end
        
        xlabel(var_names{i}, 'FontWeight', 'bold');
        if i == 1
            ylabel(current_label, 'FontWeight', 'bold', 'FontSize', 9);
        end
        grid on; box on;
        title(['vs ' var_names{i}], 'FontSize', 10);
    end
    
    % --- GESTIONE COLORBAR DISCRETA ---
    % Posiziono la colorbar manualmente a destra
    c = colorbar('Position', [0.93 0.15 0.01 0.7]);
    
    % Imposto i limiti della colorbar per centrare i colori
    caxis([1, n_colors]);
    
    % Etichette della colorbar (valori esatti della variabile dominante)
    if n_colors <= 10
        c.Ticks = 1:n_colors; % Un tick per ogni colore
        % Creo etichette stringa dai valori numerici
        c.TickLabels = arrayfun(@(x) sprintf('%.2g', x), unique_dom_vals, 'UniformOutput', false);
    end
    c.Label.String = dom_name; % Nome variabile dominante
    
    set(f1, 'PaperPositionMode', 'auto');
    saveas(f1, ['Impact_MainEffects_' current_suffix '.png']);
    
    % --- PLOT 2: SENSITIVITY (Bar Plot) ---
    f2 = figure('Name', ['Sensitivity_' current_suffix], 'Color', 'w', 'Position', fig_pos);
    correlations = corr(X_data, Y_target);
    b = barh(correlations);
    b.FaceColor = 'flat';
    for i = 1:num_vars
        if correlations(i) > 0, b.CData(i,:) = [0.8 0.2 0.2]; 
        else, b.CData(i,:) = [0.2 0.7 0.2]; end
    end
    yticks(1:num_vars); yticklabels(var_names);
    grid on; box on; xlim([-1 1]); 
    xlabel('Coefficiente Correlazione', 'FontWeight', 'bold');
    
    % Annotazioni
    text(-0.05, num_vars+0.6, ['\leftarrow Riduce ' current_anno], ...
        'Color', [0 0.5 0], 'HorizontalAlignment', 'right','FontSize', 12);
    text(0.05, num_vars+0.6, ['Aumenta ' current_anno ' \rightarrow'], ...
        'Color', [0.6 0 0], 'HorizontalAlignment', 'left','FontSize', 12);
    xline(0, 'k-', 'LineWidth', 1);
    
    set(f2, 'PaperPositionMode', 'auto');
    saveas(f2, ['Impact_Sensitivity_' current_suffix '.png']);
    
    % Chiudo le figure come richiesto
    close(f1); 
    close(f2);
end

disp('Elaborazione completata. Grafici salvati e chiusi.');