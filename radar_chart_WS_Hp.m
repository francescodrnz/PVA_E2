clc;
close all;
clearvars;
data = loadMostRecentCSV();
W_S_vect = unique(data.W_S);
Hp_vect = unique(data.Hp);

% Estrazione dei valori da visualizzare
labels = {'WTO', 'S', 'OEW', 'E_{cruise}', 'W_{battery}', 'W_{block fuel}', 'P_{tot}', 'P_{ice}', 'P_{em}', 'ADP', 'flight cost', 'maintenance cost'};
values = [data.WTO, data.S, data.OEW, data.E_crociera, data.W_battery, data.W_block_fuel,...
    data.P_tot, data.P_ice, data.P_em, data.ADP, data.flight_cost, data.maintenance_cost];

% Creare una matrice per i valori medi
values_mean_all = zeros(length(W_S_vect) * length(Hp_vect), size(values, 2));  % Spazio per le medie

% Indice per la matrice dei valori medi
index = 1;

% Iterazione sui valori di W_S e Hp
for i_W_S = 1:length(W_S_vect)
    for i_Hp = 1:length(Hp_vect)
        % Trova gli indici delle configurazioni per la combinazione di W_S e Hp
        idx = find(data.W_S == W_S_vect(i_W_S) & data.Hp == Hp_vect(i_Hp));

        if ~isempty(idx) % Se ci sono configurazioni per questa combinazione
            % Calcolare la media dei valori per questa combinazione di W_S e Hp
            values_mean_all(index, :) = mean(values(idx, :), 1);  % Media per parametro (colonna)
            index = index + 1;
        end
    end
end

% Normalizzazione

% Creare una matrice per i valori normalizzati
values_normalized = zeros(size(values_mean_all));  % Matrice per i valori normalizzati

% Normalizzare i valori medi per ogni parametro (colonna)
for i = 1:size(values_mean_all, 2)  % Per ogni parametro (colonna)
    max_val = max(values_mean_all(:, i));  % Troviamo il massimo di ogni colonna
    if max_val ~= 0  % Evitare divisione per zero
        values_normalized(:, i) = values_mean_all(:, i) / max_val;  % Normalizziamo dividendo per il massimo
    else
        values_normalized(:, i) = values_mean_all(:, i);  % Se il massimo è zero, non fare nulla
    end
end

% Creazione del radar chart con polar axes
figure;

% Definire gli angoli per ciascun parametro (12 parametri = 12 angoli)
theta = linspace(0, 2*pi, numel(labels)+1); % +1 per chiudere il grafico

% Aggiungi i valori normalizzati per "chiudere" il ciclo del grafico
values_normalized = [values_normalized, values_normalized(:,1)];

% Impostazione delle coordinate polari
ax = polaraxes;
hold on;

% Definire una mappa di colori unica per ogni combinazione di W_S e Hp
cmap = lines(length(W_S_vect) * length(Hp_vect));  % Usa la colormap 'lines' per colori distinti

% Variabile per memorizzare gli handle delle curve per la legenda
legend_handles = [];

% Iterazione sui valori di W_S e Hp per tracciare le curve
index = 1;
for i_W_S = 1:length(W_S_vect)
    for i_Hp = 1:length(Hp_vect)
        % Trova gli indici per la combinazione di W_S e Hp
        idx = find(data.W_S == W_S_vect(i_W_S) & data.Hp == Hp_vect(i_Hp));

        if ~isempty(idx) % Se ci sono configurazioni per questa combinazione
            % Aggiungere la curva per questa combinazione di W_S e Hp
            h = polarplot(ax, theta, values_normalized(index, :), '-o', 'LineWidth', 2, ...
                'Color', cmap(index, :), 'DisplayName', sprintf('W_S = %.1f, Hp = %.1f', W_S_vect(i_W_S), Hp_vect(i_Hp)));
            legend_handles = [legend_handles, h]; % Aggiungi l'handle alla legenda
            index = index + 1;
        end
    end
end

% Aggiungere le etichette e altre personalizzazioni
set(ax, 'ThetaTickLabel', labels); % Etichette sugli assi
title(ax, 'Confronto delle configurazioni di design');

% Legenda, solo per le curve effettivamente disegnate
legend(legend_handles, 'Location', 'Best');

hold off;
