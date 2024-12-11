% Unified Radar Chart for Aircraft Configuration Analysis
% Load the specific CSV file
data = readtable('dati_convergenza_2024-12-11_15-36-48.csv');

% Unique W_S and Hp values
unique_W_S = unique(data.W_S);
unique_Hp = unique(data.Hp);

% Parameters to compare
compare_params = {
    'WTO', 'Take-off Weight [kg]';
    'b', 'Wing Span [m]';
    'S', 'Wing Reference Area [m^2]';
    'CL_crociera', 'Cruise Lift Coefficient'; 
    'E_crociera', 'Cruise Efficiency';
    'P_tot', 'Total Power [W]';
    'W_block_fuel', 'Block Fuel Weight [kg]';
    'W_battery', 'Battery Weight [kg]'
};

% Number of parameters to compare
num_params = size(compare_params, 1);

% Create base colors for unique W_S values
base_colors = lines(length(unique_W_S)); % Generate distinct base colors

% Loop through parameters
for param_idx = 1:num_params
    % Current parameter details
    param_name = compare_params{param_idx, 1};
    param_label = compare_params{param_idx, 2};
    
    % Create a new figure for each parameter
    figure('Position', [100, 100, 1600, 1200]);

    % Create polar axes for this figure
    ax = polaraxes;
    hold on;

    % Legends for tracking
    legend_handles = [];
    legend_names = {};

    % Loop through each W_S value
    for w_s_idx = 1:length(unique_W_S)
        current_W_S = unique_W_S(w_s_idx);
        
        % Generate shades for the current W_S based on Hp
        num_shades = length(unique_Hp);
        color_shades = interp1([0, 1], [base_colors(w_s_idx, :); 1, 1, 1], linspace(0, 1, num_shades));

        % Loop through each Hp value
        for hp_idx = 1:length(unique_Hp)
            current_Hp = unique_Hp(hp_idx);
            
            % Filter data for current W_S and Hp
            w_s_hp_data = data(data.W_S == current_W_S & data.Hp == current_Hp, :);
            
            % Extract values for different ice protection configurations
            config_values = [];
            config_labels = {};
            
            % Group by ice protection parameters
            unique_configs = unique(table(w_s_hp_data.phi_ice_cl, w_s_hp_data.phi_ice_cr, w_s_hp_data.phi_ice_de), 'rows');
            
            for config_row = 1:size(unique_configs, 1)
                % Find matching configurations
                matching_rows = w_s_hp_data.phi_ice_cl == unique_configs{config_row, 1} & ...
                                w_s_hp_data.phi_ice_cr == unique_configs{config_row, 2} & ...
                                w_s_hp_data.phi_ice_de == unique_configs{config_row, 3};
                
                % Aggregate values (using mean if multiple rows match)
                config_values(config_row) = mean(w_s_hp_data{matching_rows, param_name});
                
                % Create config label
                config_labels{config_row} = sprintf('φ_{cl}:%.1f φ_{cr}:%.1f φ_{de}:%.1f', ...
                    unique_configs{config_row, 1}, ...
                    unique_configs{config_row, 2}, ...
                    unique_configs{config_row, 3});
            end
            
            % Check if config_values is non-empty before proceeding
            if isempty(config_values)
                continue;  % Skip this combination if no values exist
            end

            % Normalize values for radar chart
            norm_values = (config_values - min(config_values)) ./ (max(config_values) - min(config_values));
            
            % Ensure that there is more than one value to form a radar chart
            if length(norm_values) > 1
                % Create radar plot
                num_configs = length(norm_values);
                
                % Ensure uniform angles for the radar chart
                angles = linspace(0, 2*pi, num_configs + 1); % +1 to close the polygon
                plot_values = [norm_values, norm_values(1)];

                % Plot using the current shade
                ph = polarplot(ax, angles, plot_values, 'LineWidth', 2, 'Color', color_shades(hp_idx, :));
                polarplot(ax, angles, plot_values, 'o', 'MarkerFaceColor', color_shades(hp_idx, :), 'MarkerSize', 8);
                
                % Store legend handle
                legend_handles(end+1) = ph;
                legend_names{end+1} = sprintf('W/S = %d kg/m², Hp = %.1f m', current_W_S, current_Hp);
            end
        end
    end

    % Set polar plot properties
    title(param_label, 'FontSize', 12);
    rlim([0 1]);
    
    % Set theta labels
    thetaticks(ax, linspace(0, 360, num_configs + 1));
    thetaticklabels(ax, config_labels);
    
    % Add legend
    legend(legend_handles, legend_names, 'Location', 'best', 'FontSize', 8);

    % Save the figure for each parameter
    saveas(gcf, sprintf('radar_chart_%s.png', param_name));
    close(gcf);

    disp(['Radar chart for ' param_label ' has been generated and saved.']);
end

disp('All radar charts have been generated and saved.');
