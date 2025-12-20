%% Script Analisi Correlazione Completa - Tutte le Variabili
clc; clearvars; close all;

% --- 1. CARICAMENTO DATI ---
data = loadMostRecentCSV();

% --- 2. CONFIGURAZIONE: VARIABILI DA ESCLUDERE ---
% Aggiungi qui i nomi delle colonne che NON vuoi analizzare
% Esempio: {'iter_index', 'P_curr', 'CO2'}
excluded_vars = {'PhiClimb','PhiDescent','PhiCruise','H_P','CaricoAlare','VFuel', 'CO2','PREE','S_orizz', 'S_vert', 'flight_cost','n','electricity_cost','maintenance_cost','ADP','DOC', 'P_curr', 'cRoot', 'b', 'EBattInst'}; % <--- MODIFICA QUI

% --- 3. PULIZIA E PREPARAZIONE DATI ---
% Rimuoviamo le variabili escluse manualmente
if ~isempty(excluded_vars)
    data = removevars(data, intersect(data.Properties.VariableNames, excluded_vars));
end

var_names = data.Properties.VariableNames;

% Filtro numerico (mantengo solo colonne con numeri)
numeric_vars = varfun(@isnumeric, data, 'OutputFormat', 'uniform');
data_numeric = data(:, numeric_vars);

% Rimuovo costanti (varianza ~ 0) per evitare NaN nella correlazione
std_vals = std(table2array(data_numeric));
data_clean = data_numeric(:, std_vals > 1e-6); 

var_names_clean = data_clean.Properties.VariableNames;
X = table2array(data_clean);

fprintf('Variabili analizzate: %d (Escluse: %d)\n', ...
    length(var_names_clean), length(excluded_vars));


% --- 4. CALCOLO MATRICE DI CORRELAZIONE ---
R = corr(X, 'Rows', 'complete'); 

% Copia per clustering (piena)
R_full = R; 

% Maschera Triangolare per plot pulito (NaN sopra la diagonale)
R_triang = R;
R_triang(triu(true(size(R)), 1)) = NaN;


% --- 5. VISUALIZZAZIONE HEATMAP (Standard) ---
figure('Name', 'Correlation_Matrix', 'Color', 'w', 'Position', [50 50 1200 900]);
    % Definizione Colormap Divergente Personalizzata (Rosso - Bianco - Blu)
    % Questa fa "sparire" visivamente i valori bassi (bianco) e risalta gli alti
    len = 256; 
    red = [0.70, 0.13, 0.13];   % Rosso mattone
    blue = [0.00, 0.45, 0.74];  % Blu MATLAB
    white = [1, 1, 1];
    
    % Gradiente Rosso -> Bianco
    map1 = [linspace(red(1), white(1), len/2)', ...
            linspace(red(2), white(2), len/2)', ...
            linspace(red(3), white(3), len/2)'];
    
    % Gradiente Bianco -> Blu
    map2 = [linspace(white(1), blue(1), len/2)', ...
            linspace(white(2), blue(2), len/2)', ...
            linspace(white(3), blue(3), len/2)'];
    
    custom_map = [map1; map2];

h = heatmap(var_names_clean, var_names_clean, R_triang);
h.Title = 'Matrice di Correlazione (Triangolare Inferiore)';
h.Colormap = custom_map; 
h.ColorLimits = [-1 1]; 
h.GridVisible = 'off';
h.MissingDataColor = 'w'; 
h.MissingDataLabel = ''; 
h.FontSize = 8; 

annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
    'String', '1.0 = Correlazione Positiva Perfetta | -1.0 = Correlazione Negativa Perfetta', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontSize', 10, 'FontWeight', 'bold');


% --- 6. CLUSTERING VARIABILI (Sorted Heatmap) ---
% Riordina le variabili per mettere vicine quelle correlate
try
    % Calcolo distanza (1 - |R|)
    dist = 1 - abs(R_full); 
    dist(isnan(dist)) = 0;
    
    % Linkage gerarchico
    vec_dist = squareform(dist - diag(diag(dist)));
    Z = linkage(vec_dist, 'average');
    
    % Ordine ottimale delle foglie (variabili)
    leafOrder = optimalleaforder(Z, vec_dist);
    
    % Nomi riordinati
    sorted_names = var_names_clean(leafOrder);
    
    % Matrice riordinata
    R_sorted = R_full(leafOrder, leafOrder);
    
    % Applico maschera triangolare anche qui
    R_sorted_triang = R_sorted;
    R_sorted_triang(triu(true(size(R_sorted)), 1)) = NaN;
    
    % Plot 2: Matrice Ordinata
    figure('Name', 'Sorted_Correlation_Matrix', 'Color', 'w', 'Position', [100 100 1200 900]);
    h2 = heatmap(sorted_names, sorted_names, R_sorted_triang); 
    h2.Title = 'Matrice Correlazione (Parametri Aggregati)';
    h2.Colormap = custom_map;
    h2.ColorLimits = [-1 1];
    h2.FontSize = 8;
    h2.GridVisible = 'off';
    h2.MissingDataColor = 'w'; 
    h2.MissingDataLabel = '';

    saveas(2, 'Correlation_Matrix_Sorted.png');
    disp('Clustering completato con successo.');
    
catch ME
    warning('Clustering fallito. Errore: %s', ME.message);
end


% --- 7. SALVATAGGIO ---
saveas(1, 'Correlation_Matrix_Triangular.png');