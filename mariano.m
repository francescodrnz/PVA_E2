clearvars; close all;clc;
% 1. Caricamento immagine
originalImage = imread('mariano.jpg'); % Sostituisci con il nome reale del file
grayImage = rgb2gray(originalImage);

% 2. Binarizzazione (Soglia)
% Calcola una soglia automatica per separare lo sfondo (chiaro) dalla figura (scura)
level = graythresh(grayImage); 
binaryMask = imbinarize(grayImage, level);

% Poiché lo sfondo è luminoso (la luce sopra la testa), la maschera sarà 
% 1 per lo sfondo e 0 per la persona. Invertiamola con ~ per avere la persona come "oggetto".
binaryMask = ~binaryMask;

% 3. Pulizia dell'immagine (Morfologia)
% Rimuove il "rumore" (piccoli punti) e riempie i buchi all'interno della sagoma
binaryMask = bwareaopen(binaryMask, 5000); % Rimuove oggetti minori di 5000 pixel
% binaryMask = imfill(binaryMask, 'holes');  % Riempie i buchi (es. occhi, narici)

% 4. Estrazione dei Contorni
[B, L] = bwboundaries(binaryMask, 'noholes');

% 5. Creazione del Grafico
figure;
hold on;
title('Grafico della Sagoma');
xlabel('Pixel X');
ylabel('Pixel Y');

% Itera sui contorni trovati (B) e li disegna
for k = 1:length(B)
    boundary = B{k};
    % boundary(:,2) sono le X (colonne), boundary(:,1) sono le Y (righe)
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end

% Impostazioni visive per matchare l'orientamento dell'immagine
axis equal;           % Mantiene le proporzioni corrette
set(gca, 'YDir', 'reverse'); % Inverte l'asse Y (le immagini hanno l'origine in alto a sx)
grid on;
hold off;