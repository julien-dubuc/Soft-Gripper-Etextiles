% =========================================================================
% PROJECT: LOCK & RELEASE - TEST 3 BAR CHART GENERATOR
% AUTHOR: Julien DUBUC
% =========================================================================
clear; clc; close all;

%% 1. DONNÉES DU TEST 3
% Moyennes calculées manuellement à partir de tes données
force_means = [4.4, 2.4]; % [Compliant, R&P] moyenne force (N)
force_std   = [1.14, 0.55]; % Écart-types calculés

current_means = [179.6, 186.8]; % Moyenne courant (mA)
current_std   = [13.6, 38.6]; % Écart-types calculés

%% 2. CRÉATION DU GRAPHIQUE (Force de maintien)
figure('Color', [1 1 1], 'Position', [100, 100, 700, 500]);

% --- Figure 1: Force de maintien ---
subplot(2,1,1);
b1 = bar([1, 2], force_means, 0.6, 'FaceColor', 'flat');
b1.CData(1,:) = [0 0.447 0.741]; % Bleu pour Compliant
b1.CData(2,:) = [0.85 0.325 0.098]; % Rouge pour R&P
hold on;
errorbar([1, 2], force_means, force_std, 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Force (N)');
set(gca, 'XTickLabel', {'Compliant', 'Rack & Pinion'});
title('Maximum Passive Pull-out Force (0W)');
grid on;

% --- Figure 2: Courant de déverrouillage ---
subplot(2,1,2);
b2 = bar([1, 2], current_means, 0.6, 'FaceColor', 'flat');
b2.CData(1,:) = [0 0.447 0.741];
b2.CData(2,:) = [0.85 0.325 0.098];
hold on;
errorbar([1, 2], current_means, current_std, 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Current (mA)');
set(gca, 'XTickLabel', {'Compliant', 'Rack & Pinion'});
title('Peak Unlocking Current');
grid on;
