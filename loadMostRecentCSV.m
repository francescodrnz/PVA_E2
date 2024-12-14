function data = loadMostRecentCSV()
file_pattern = 'dati_convergenza_*.csv'; % Modello di ricerca per i file CSV
files = dir(file_pattern); % Trova tutti i file che corrispondono al modello

if isempty(files)
    error('Nessun file trovato con il modello "%s".', file_pattern);
end

% Ordina i file per data di modifica (dal più recente al più vecchio)
[~, idx] = sort([files.datenum], 'descend');
latest_file = files(idx(1)).name;

% Carica il file CSV più recente
data = readtable(latest_file);

fprintf('Caricato il file più recente: %s\n', latest_file);
end