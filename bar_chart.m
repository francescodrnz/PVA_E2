%% BAR CHART AUTOMATICO DA CSV (Stile Report)
clc; close all;

% 1. Caricamento e Selezione (Identico a sopra)
data = loadMostRecentCSV(); 
[~, idx_best] = min(data.W_block_fuel);
target_fuel = 118.5; 
[~, idx_scelto] = min(abs(data.W_block_fuel - target_fuel));

% 2. Preparazione Dati
% Categorie per l'asse X
cats_names = {'MTOW', 'Block Fuel', 'Massa Batterie', 'P Elettrica', 'P Termica'};
cats = categorical(cats_names);
cats = reordercats(cats, cats_names);

% Estrazione Valori
raw_scelto = [data.WTO(idx_scelto), data.W_block_fuel(idx_scelto), data.W_battery(idx_scelto), ...
              data.P_em(idx_scelto), data.P_ice(idx_scelto)];
          
raw_best   = [data.WTO(idx_best), data.W_block_fuel(idx_best), data.W_battery(idx_best), ...
              data.P_em(idx_best), data.P_ice(idx_best)];

% Normalizzazione
y_ref = raw_scelto ./ raw_scelto; % Tutto 1
y_best = raw_best ./ raw_scelto;  % Rapporto

% Matrice per il bar chart
Y = [y_ref; y_best]'; 

% 3. Plotting
figure('Color', 'w', 'Position', [100 100 900 500]);
b = bar(cats, Y, 'grouped');

% Colori
b(1).FaceColor = '#77AC30'; % Verde (Scelto)
b(2).FaceColor = '#A2142F'; % Rosso (Best Fuel)

ylabel('Valore Normalizzato (Scelto = 1.0)');
title('Confronto Prestazionale: Scelto vs Minimo Fuel');
legend({'Design Scelto', 'Minimo Fuel'}, 'Location', 'northeast');
grid on; ylim([0.8 1.25]);

% 4. Aggiunta Etichette Percentuali
% Calcola le percentuali di differenza
diff_perc = (y_best - 1) * 100;

% Posiziona il testo sopra le barre rosse (la seconda serie, b(2))
xtips = b(2).XEndPoints;
ytips = b(2).YEndPoints;

for i = 1:length(diff_perc)
    label = sprintf('%+.1f%%', diff_perc(i));
    
    % Posizionamento dinamico (sopra o sotto la barra se negativa)
    val_pos = ytips(i) + 0.02; 
    col_text = 'k'; % Nero default
    
    % Se la differenza è positiva (peggiore, es. Peso), testo rosso
    % Se negativa (migliore, es. Fuel), testo verde scuro o nero
    if diff_perc(i) > 0
        col_text = '#A2142F'; % Rosso scuro
    elseif diff_perc(i) < 0
         val_pos = ytips(i) - 0.05; % Metti sotto se scende troppo (opzionale)
    end
    
    text(xtips(i), val_pos, label, ...
        'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'FontSize', 10, 'Color', col_text);
end

% Linea di riferimento a 1.0
yline(1.0, '--k', 'Alpha', 0.5);