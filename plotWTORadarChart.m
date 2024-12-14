function plotWTORadarChartByHp(data)
% Validate input
if ~isstruct(data)
    error('Input must be a struct containing simulation results');
end

% Extract unique values of design parameters
phi_ice_cl_unique = unique(data.phi_ice_cl);
phi_ice_cr_unique = unique(data.phi_ice_cr);
phi_ice_de_unique = unique(data.phi_ice_de);
Hp_unique = unique(data.Hp);

% Initialize 4D matrix to store mean WTO for each combination
wto_means = zeros(length(phi_ice_cl_unique), ...
    length(phi_ice_cr_unique), ...
    length(phi_ice_de_unique), ...
    length(Hp_unique));

% Calculate mean WTO for each combination
for i = 1:length(phi_ice_cl_unique)
    for j = 1:length(phi_ice_cr_unique)
        for k = 1:length(phi_ice_de_unique)
            for l = 1:length(Hp_unique)
                % Find indices matching the current combination
                idx = (data.phi_ice_cl == phi_ice_cl_unique(i)) & ...
                    (data.phi_ice_cr == phi_ice_cr_unique(j)) & ...
                    (data.phi_ice_de == phi_ice_de_unique(k)) & ...
                    (data.Hp == Hp_unique(l));

                % Calculate mean WTO for this combination
                if any(idx)
                    wto_means(i, j, k, l) = mean(data.WTO(idx));
                else
                    wto_means(i, j, k, l) = NaN; % No data for this combination
                end
            end
        end
    end
end

% Create figure with subplots for each Hp value
figure('Position', [100, 100, 1500, 500]);

for l = 1:length(Hp_unique)
    subplot(1, length(Hp_unique), l);

    % Extract data for this Hp value
    radar_data = squeeze(wto_means(:, :, :, l));

    % Normalize data across phi_ice_de slices
    min_val = min(radar_data(~isnan(radar_data)));
    max_val = max(radar_data(~isnan(radar_data)));
    radar_data_norm = (radar_data - min_val) ./ (max_val - min_val);

    % Plot radar chart for each phi_ice_de value
    hold on;
    for k = 1:length(phi_ice_de_unique)
        % Extract slice for phi_ice_de
        slice_data = radar_data_norm(:, :, k);
        if all(isnan(slice_data(:)))
            continue; % Skip empty slices
        end
        customRadarChart(slice_data, ...
            phi_ice_cr_unique, ...
            phi_ice_cl_unique, ...
            sprintf('Hp = %.1f, \phi_{ice,de} = %.1f', Hp_unique(l), phi_ice_de_unique(k)));
    end
    hold off;
end

% Add a main title
sgtitle('Normalized WTO Radar Chart by Hp', 'FontSize', 16);
end

function customRadarChart(data, x_labels, y_labels, chart_title)
% Number of dimensions
[num_rows, num_cols] = size(data);

% Compute angles for each spoke
angles = linspace(0, 2*pi, num_cols+1);
angles = angles(1:end-1);

% Create polar axes
ax = polaraxes;
hold(ax, 'on');

% Color map
colors = lines(num_rows);

% Plot each data series
for i = 1:num_rows
    % Close the polygon by repeating the first point
    values = [data(i,:), data(i,1)];
    plot_angles = [angles, angles(1)];

    % Polar plot
    polarplot(ax, plot_angles, values, 'LineWidth', 2, 'Color', colors(i,:));
end

% Add labels for axes
ax.ThetaTick = rad2deg(angles);
ax.ThetaTickLabel = arrayfun(@(x) num2str(x), x_labels, 'UniformOutput', false);

% Set title
ax.Title.String = chart_title;
ax.Title.FontSize = 12;

% Create legend
legend(ax, arrayfun(@(x) num2str(x), y_labels, 'UniformOutput', false), ...
    'Location', 'bestoutside');

% Adjust plot properties
ax.FontSize = 8;
hold(ax, 'off');
end