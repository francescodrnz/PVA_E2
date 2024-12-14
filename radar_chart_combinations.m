% Clear workspace and load data
clc;
close all;
clearvars;
data = loadMostRecentCSV();

% Parameters to visualize
parametri = {'WTO', 'OEW', 'E_crociera', 'W_battery', 'W_block_fuel', 'P_tot', 'ADP', 'flight_cost', 'maintenance_cost'};
% Titoli personalizzati per i grafici
titoli_personalizzati = {
    'Peso totale al decollo (WTO)', ...
    'Peso operativo vuoto (OEW)', ...
    'Efficienza in crociera (E_{crociera})', ...
    'Peso delle batterie (W_{battery})', ...
    'Peso del carburante blocco (W_{block\_fuel})', ...
    'Potenza totale (P_{tot})', ...
    'ADP', ...
    'Costo del volo (flight\_cost)', ...
    'Costo di manutenzione (maintenance\_cost)'
    };

% Find unique combinations of W_S and Hp
WS_Hp_combinations = unique([data.W_S, data.Hp], 'rows');

% Find unique phi_ice combinations for radar chart axes
phi_ice_combinations = unique([data.phi_ice_cl, data.phi_ice_cr, data.phi_ice_de], 'rows');

% Create radar charts for each parameter
for param_idx = 1:length(parametri)
    % Prepare values for this parameter
    param_values = zeros(size(WS_Hp_combinations, 1), size(phi_ice_combinations, 1));

    % Populate values for each W_S, Hp combination and phi_ice combination
    for ws_hp_idx = 1:size(WS_Hp_combinations, 1)
        for phi_ice_idx = 1:size(phi_ice_combinations, 1)
            % Find matching rows
            match_idx = find(...
                data.W_S == WS_Hp_combinations(ws_hp_idx, 1) & ...
                data.Hp == WS_Hp_combinations(ws_hp_idx, 2) & ...
                data.phi_ice_cl == phi_ice_combinations(phi_ice_idx, 1) & ...
                data.phi_ice_cr == phi_ice_combinations(phi_ice_idx, 2) & ...
                data.phi_ice_de == phi_ice_combinations(phi_ice_idx, 3));

            % Calculate mean for this specific configuration
            if ~isempty(match_idx)
                param_values(ws_hp_idx, phi_ice_idx) = mean(data.(parametri{param_idx})(match_idx));
            else
                % If no matching data, set to NaN
                param_values(ws_hp_idx, phi_ice_idx) = NaN;
            end
        end
    end

    % Normalize values across all configurations
    max_val = max(param_values(:));
    min_val = min(param_values(:));

    % Normalize to [0, 1] range, handling potential zero range
    if max_val ~= min_val
        param_values_normalized = (param_values - min_val) / (max_val - min_val);
    else
        % If all values are the same, set to 1
        param_values_normalized = ones(size(param_values));
    end
    % % Normalizza i valori rispetto al massimo, senza usare il minimo
    % if max_val ~= 0
    %     param_values_normalized = param_values / max_val;
    % else
    %     % Caso eccezionale se tutti i valori sono zero
    %     param_values_normalized = zeros(size(param_values));
    % end

    % Create radar chart
    figure;
    ax = polaraxes;
    hold(ax, 'on');

    % Prepare theta values for plotting
    num_axes = size(phi_ice_combinations, 1);
    theta = linspace(0, 2*pi, num_axes + 1);

    % Color map for W_S, Hp combinations
    cmap = lines(size(WS_Hp_combinations, 1));

    % Legend labels
    legend_labels = cell(size(WS_Hp_combinations, 1), 1);

    % Plot each W_S, Hp combination
    for ws_hp_idx = 1:size(WS_Hp_combinations, 1)
        % Find non-NaN indices
        valid_indices = find(~isnan(param_values_normalized(ws_hp_idx, :)));

        if ~isempty(valid_indices)
            % Prepare plot values for non-NaN points
            plot_theta = theta(valid_indices);
            plot_values = param_values_normalized(ws_hp_idx, valid_indices);

            % Close the polygon by connecting first and last point
            plot_theta = [plot_theta, plot_theta(1)];
            plot_values = [plot_values, plot_values(1)];

            % Plot the configuration
            h = polarplot(ax, plot_theta, plot_values, '-o', ...
                'LineWidth', 2, ...
                'Color', cmap(ws_hp_idx, :), ...
                'MarkerFaceColor', cmap(ws_hp_idx, :));

            % Create legend label
            legend_labels{ws_hp_idx} = sprintf('W_S=%.1f, Hp=%.1f', ...
                WS_Hp_combinations(ws_hp_idx, 1), WS_Hp_combinations(ws_hp_idx, 2));
        end
    end

    % Set axis labels to phi_ice combinations
    phi_ice_labels = cell(size(phi_ice_combinations, 1) + 1, 1);
    for i = 1:size(phi_ice_combinations, 1)
        phi_ice_labels{i} = sprintf('φ_{cl}:%.1f φ_{cr}:%.1f φ_{de}:%.1f', ...
            phi_ice_combinations(i, 1), ...
            phi_ice_combinations(i, 2), ...
            phi_ice_combinations(i, 3));
    end
    phi_ice_labels{end} = phi_ice_labels{1}; % Repeat first label to close the polygon

    set(ax, 'ThetaTick', rad2deg(theta(valid_indices)))
    set(ax, 'ThetaTickLabel', phi_ice_labels(valid_indices));

    title(ax, titoli_personalizzati{param_idx});

    % Add legend
    legend(ax, legend_labels(~cellfun('isempty', legend_labels)), 'Location', 'best');

    hold(ax, 'off');
end