%% Bose PIFA Antenna SAR Analysis - Complete Single File Version
% Bu tek dosya tüm SAR ve E-alan analizini yapar
% Kullanım: MATLAB'da sadece bu dosyayı çalıştırın
% Tarih: 2024
% Proje: Bose PIFA Antenna SAR Analysis

clear; clc; close all;

fprintf('======================================================\n');
fprintf('   Bose PIFA Antenna SAR Analysis - Complete\n');
fprintf('======================================================\n\n');

%% MATLAB Ayarları
% Grafik ayarları
set(0, 'DefaultFigurePosition', [100, 100, 1200, 800]);
set(0, 'DefaultAxesFontSize', 11);
set(0, 'DefaultTextFontSize', 11);
set(0, 'DefaultFigureRenderer', 'painters');
set(0, 'DefaultFigureWindowStyle', 'normal');

%% Dosya Yolları Tanımlaması
fprintf('Dosya yolları kontrol ediliyor...\n');
base_path = pwd; % Mevcut dizin
fprintf('Çalışma dizini: %s\n\n', base_path);

% Veri dosya yapısı
data_files = struct();
data_files.mass1g_10mw.e_field = fullfile(base_path, 'bose_sonuclar', 'bose_1gr_ealan.Mag_E0000');
data_files.mass1g_10mw.sar = fullfile(base_path, 'bose_sonuclar', 'bose_1gr_sar.Average_SAR0000');
data_files.mass10g_10mw.e_field = fullfile(base_path, 'bose_sonuclar', 'bose_10gr_ealan.Mag_E0000');
data_files.mass10g_10mw.sar = fullfile(base_path, 'bose_sonuclar', 'bose_10gr_sar.Average_SAR0000');
data_files.mass1g_25mw.e_field = fullfile(base_path, 'bose_sonuclar', 'bose_10gr_ealan_25mw.Mag_E0000'); % 10gr dosyasını 1gr yerine kullan
data_files.mass1g_25mw.sar = fullfile(base_path, 'bose_sonuclar', 'bose_1gr_sar_25mw.Average_SAR0000');
data_files.mass10g_25mw.e_field = fullfile(base_path, 'bose_sonuclar', 'bose_10gr_ealan_25mw.Mag_E0000');
data_files.mass10g_25mw.sar = fullfile(base_path, 'bose_sonuclar', 'bose_10gr_sar_25mw.Average_SAR0000');

% Dosya varlığını kontrol et
configs = {'mass1g_10mw', 'mass10g_10mw', 'mass1g_25mw', 'mass10g_25mw'};
missing_files = 0;

for i = 1:length(configs)
    config = configs{i};
    e_file = data_files.(config).e_field;
    sar_file = data_files.(config).sar;
    
    if exist(e_file, 'file')
        fprintf('✓ E-field dosyası bulundu: %s\n', config);
    else
        fprintf('✗ E-field dosyası eksik: %s\n', config);
        missing_files = missing_files + 1;
    end
    
    if exist(sar_file, 'file')
        fprintf('✓ SAR dosyası bulundu: %s\n', config);
    else
        fprintf('✗ SAR dosyası eksik: %s\n', config);
        missing_files = missing_files + 1;
    end
end

if missing_files > 0
    fprintf('\nUyarı: %d dosya eksik. Mevcut dosyalarla analiz devam edecek.\n', missing_files);
end

fprintf('\n');

%% VERİ OKUMA VE İSTATİSTİK FONKSİYONLARI - DOSYANIN SONUNDA TANIMLANMIŞ

%% VERİ YÜKLEME İŞLEMİ
fprintf('Veri dosyaları yükleniyor...\n\n');

loaded_data = struct();
statistics = struct();

for i = 1:length(configs)
    config = configs{i};
    fprintf('%s konfigürasyonu yükleniyor...\n', config);
    
    % E-field verilerini yükle
    e_field_file = data_files.(config).e_field;
    e_field_data = read_hfss_data_local(e_field_file);
    loaded_data.(config).e_field = e_field_data;
    statistics.(config).e_field = calculate_stats_local(e_field_data);
    
    % SAR verilerini yükle
    sar_file = data_files.(config).sar;
    sar_data = read_hfss_data_local(sar_file);
    loaded_data.(config).sar = sar_data;
    statistics.(config).sar = calculate_stats_local(sar_data);
    
    fprintf('\n');
end

%% VERİ HAZIRLIĞI - GRAFİK İÇİN
fprintf('Grafik verileri hazırlanıyor...\n');

config_labels = {'1g 10mW', '10g 10mW', '1g 25mW', '10g 25mW'};
sar_max_values = zeros(1, 4);
sar_mean_values = zeros(1, 4);
efield_max_values = zeros(1, 4);
efield_mean_values = zeros(1, 4);

for i = 1:length(configs)
    config = configs{i};
    if isfield(statistics.(config), 'sar') && ~isempty(fieldnames(statistics.(config).sar))
        sar_max_values(i) = statistics.(config).sar.max;
        sar_mean_values(i) = statistics.(config).sar.mean;
    end
    if isfield(statistics.(config), 'e_field') && ~isempty(fieldnames(statistics.(config).e_field))
        efield_max_values(i) = statistics.(config).e_field.max;
        efield_mean_values(i) = statistics.(config).e_field.mean;
    end
end

%% GRAFİK 1: TEMEL KARŞILAŞTIRMA ANALİZİ
fprintf('Temel karşılaştırma grafikleri oluşturuluyor...\n');

figure('Name', 'Bose PIFA - Temel SAR ve E-Field Analizi', 'NumberTitle', 'off');
set(gcf, 'Position', [50, 50, 1600, 1200]);

% Alt grafik 1: SAR Karşılaştırması
subplot(2, 2, 1);
x = 1:4;
width = 0.35;
bar1 = bar(x - width/2, sar_max_values, width, 'FaceColor', [1 0.3 0.3], 'FaceAlpha', 0.8, 'DisplayName', 'Max SAR');
hold on;
bar2 = bar(x + width/2, sar_mean_values, width, 'FaceColor', [0.3 0.7 0.9], 'FaceAlpha', 0.8, 'DisplayName', 'Mean SAR');

% Değer etiketleri ekle
for i = 1:length(sar_max_values)
    if sar_max_values(i) > 0
        text(i - width/2, sar_max_values(i) + 0.02*max(sar_max_values), ...
             sprintf('%.3f', sar_max_values(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
    if sar_mean_values(i) > 0
        text(i + width/2, sar_mean_values(i) + 0.02*max(sar_mean_values), ...
             sprintf('%.4f', sar_mean_values(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
end

xlabel('Konfigürasyon', 'FontWeight', 'bold');
ylabel('SAR (W/kg)', 'FontWeight', 'bold');
title('SAR Değerleri Karşılaştırması', 'FontWeight', 'bold', 'FontSize', 14);
set(gca, 'XTickLabel', config_labels);
xtickangle(45);
legend('show', 'Location', 'best');
grid on; grid minor;

% Alt grafik 2: E-field Karşılaştırması
subplot(2, 2, 2);
bar1 = bar(x - width/2, efield_max_values, width, 'FaceColor', [0.5 0.9 0.5], 'FaceAlpha', 0.8, 'DisplayName', 'Max E-field');
hold on;
bar2 = bar(x + width/2, efield_mean_values, width, 'FaceColor', [0.9 0.5 0.9], 'FaceAlpha', 0.8, 'DisplayName', 'Mean E-field');

% Değer etiketleri ekle
for i = 1:length(efield_max_values)
    if efield_max_values(i) > 0
        text(i - width/2, efield_max_values(i) + 0.02*max(efield_max_values), ...
             sprintf('%.1f', efield_max_values(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
    if efield_mean_values(i) > 0
        text(i + width/2, efield_mean_values(i) + 0.02*max(efield_mean_values), ...
             sprintf('%.2f', efield_mean_values(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
end

xlabel('Konfigürasyon', 'FontWeight', 'bold');
ylabel('E-field (V/m)', 'FontWeight', 'bold');
title('E-field Büyüklük Karşılaştırması', 'FontWeight', 'bold', 'FontSize', 14);
set(gca, 'XTickLabel', config_labels);
xtickangle(45);
legend('show', 'Location', 'best');
grid on; grid minor;

% Alt grafik 3: Güç Seviyesi Etkisi
subplot(2, 2, 3);
power_labels = {'1g Ortalaması', '10g Ortalaması'};
power_10mw = [sar_max_values(1), sar_max_values(2)];
power_25mw = [sar_max_values(3), sar_max_values(4)];

x_power = 1:2;
bar1 = bar(x_power - width/2, power_10mw, width, 'FaceColor', [0.7 0.9 0.8], 'FaceAlpha', 0.8, 'DisplayName', '10mW');
hold on;
bar2 = bar(x_power + width/2, power_25mw, width, 'FaceColor', [1 0.7 0.7], 'FaceAlpha', 0.8, 'DisplayName', '25mW');

% Değer etiketleri ekle
for i = 1:length(power_10mw)
    if power_10mw(i) > 0
        text(i - width/2, power_10mw(i) + 0.02*max([power_10mw, power_25mw]), ...
             sprintf('%.3f', power_10mw(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
    if power_25mw(i) > 0
        text(i + width/2, power_25mw(i) + 0.02*max([power_10mw, power_25mw]), ...
             sprintf('%.3f', power_25mw(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
end

xlabel('Kütle Ortalaması Yöntemi', 'FontWeight', 'bold');
ylabel('Max SAR (W/kg)', 'FontWeight', 'bold');
title('Güç Seviyesi Etkisi SAR Üzerinde', 'FontWeight', 'bold', 'FontSize', 14);
set(gca, 'XTickLabel', power_labels);
legend('show');
grid on; grid minor;

% Alt grafik 4: Kütle Ortalaması Etkisi
subplot(2, 2, 4);
mass_labels = {'10mW', '25mW'};
mass_1g = [sar_max_values(1), sar_max_values(3)];
mass_10g = [sar_max_values(2), sar_max_values(4)];

x_mass = 1:2;
bar1 = bar(x_mass - width/2, mass_1g, width, 'FaceColor', [0.9 0.7 0.9], 'FaceAlpha', 0.8, 'DisplayName', '1g ortalaması');
hold on;
bar2 = bar(x_mass + width/2, mass_10g, width, 'FaceColor', [0.6 0.8 0.9], 'FaceAlpha', 0.8, 'DisplayName', '10g ortalaması');

% Değer etiketleri ekle
for i = 1:length(mass_1g)
    if mass_1g(i) > 0
        text(i - width/2, mass_1g(i) + 0.02*max([mass_1g, mass_10g]), ...
             sprintf('%.3f', mass_1g(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
    if mass_10g(i) > 0
        text(i + width/2, mass_10g(i) + 0.02*max([mass_1g, mass_10g]), ...
             sprintf('%.3f', mass_10g(i)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 9);
    end
end

xlabel('Güç Seviyesi', 'FontWeight', 'bold');
ylabel('Max SAR (W/kg)', 'FontWeight', 'bold');
title('Kütle Ortalaması Etkisi SAR Üzerinde', 'FontWeight', 'bold', 'FontSize', 14);
set(gca, 'XTickLabel', mass_labels);
legend('show');
grid on; grid minor;

sgtitle('Bose PIFA Antenna - Temel SAR ve E-Field Analizi', 'FontWeight', 'bold', 'FontSize', 18);

% Grafik 1'i kaydet
saveas(gcf, 'bose_temel_analiz.png');
fprintf('✓ Temel analiz grafiği kaydedildi: bose_temel_analiz.png\n');

%% GRAFİK 2: DAĞILIM VE İSTATİSTİKSEL ANALİZ
fprintf('Dağılım analizi grafikleri oluşturuluyor...\n');

figure('Name', 'Bose PIFA - Dağılım ve İstatistiksel Analiz', 'NumberTitle', 'off');
set(gcf, 'Position', [100, 100, 1600, 1200]);

% Renkler
colors = {[1 0.6 0.6], [0.4 0.4 1], [0.6 1 0.6], [1 1 0.4]};

% Alt grafik 1: SAR Histogramları
subplot(2, 2, 1);
hold on;

for i = 1:length(configs)
    config = configs{i};
    if ~isempty(loaded_data.(config).sar)
        % Hızlı çizim için veri örnekleme
        data = loaded_data.(config).sar;
        if length(data) > 5000
            sample_idx = randperm(length(data), 5000);
            data = data(sample_idx);
        end
        
        histogram(data, 50, 'FaceColor', colors{i}, 'FaceAlpha', 0.7, ...
                 'DisplayName', config_labels{i}, 'Normalization', 'probability');
    end
end

xlabel('SAR (W/kg)', 'FontWeight', 'bold');
ylabel('Olasılık', 'FontWeight', 'bold');
title('SAR Dağılım Histogramları', 'FontWeight', 'bold', 'FontSize', 14);
legend('show', 'Location', 'best');
grid on; grid minor;

% Alt grafik 2: E-field Histogramları
subplot(2, 2, 2);
hold on;

for i = 1:length(configs)
    config = configs{i};
    if ~isempty(loaded_data.(config).e_field)
        % Hızlı çizim için veri örnekleme
        data = loaded_data.(config).e_field;
        if length(data) > 5000
            sample_idx = randperm(length(data), 5000);
            data = data(sample_idx);
        end
        
        histogram(data, 50, 'FaceColor', colors{i}, 'FaceAlpha', 0.7, ...
                 'DisplayName', config_labels{i}, 'Normalization', 'probability');
    end
end

xlabel('E-field (V/m)', 'FontWeight', 'bold');
ylabel('Olasılık', 'FontWeight', 'bold');
title('E-field Dağılım Histogramları', 'FontWeight', 'bold', 'FontSize', 14);
legend('show', 'Location', 'best');
grid on; grid minor;

% Alt grafik 3: SAR Box Plotları
subplot(2, 2, 3);
sar_data_matrix = [];
group_labels = {};

for i = 1:length(configs)
    config = configs{i};
    if ~isempty(loaded_data.(config).sar)
        % Box plot için veri örnekleme
        data = loaded_data.(config).sar;
        if length(data) > 2000
            sample_idx = randperm(length(data), 2000);
            data = data(sample_idx);
        end
        
        sar_data_matrix = [sar_data_matrix; data];
        group_labels = [group_labels; repmat({config_labels{i}}, length(data), 1)];
    end
end

if ~isempty(sar_data_matrix)
    boxplot(sar_data_matrix, group_labels);
    ylabel('SAR (W/kg)', 'FontWeight', 'bold');
    title('SAR Dağılım Box Plot', 'FontWeight', 'bold', 'FontSize', 14);
    xtickangle(45);
    grid on; grid minor;
end

% Alt grafik 4: SAR vs E-field Scatter Plot
subplot(2, 2, 4);
hold on;

for i = 1:length(configs)
    config = configs{i};
    if ~isempty(loaded_data.(config).sar) && ~isempty(loaded_data.(config).e_field)
        sar_data = loaded_data.(config).sar;
        efield_data = loaded_data.(config).e_field;
        
        % Scatter plot için veri örnekleme
        min_length = min(length(sar_data), length(efield_data));
        if min_length > 1000
            sample_idx = randperm(min_length, 1000);
            sar_data = sar_data(sample_idx);
            efield_data = efield_data(sample_idx);
        end
        
        scatter(efield_data, sar_data, 20, colors{i}, 'filled', 'DisplayName', config_labels{i}, 'MarkerFaceAlpha', 0.6);
    end
end

xlabel('E-field (V/m)', 'FontWeight', 'bold');
ylabel('SAR (W/kg)', 'FontWeight', 'bold');
title('SAR vs E-field Korelasyonu', 'FontWeight', 'bold', 'FontSize', 14);
legend('show', 'Location', 'best');
grid on; grid minor;

sgtitle('Bose PIFA Antenna - Dağılım ve İstatistiksel Analiz', 'FontWeight', 'bold', 'FontSize', 18);

% Grafik 2'yi kaydet
saveas(gcf, 'bose_dagilim_analizi.png');
fprintf('✓ Dağılım analizi grafiği kaydedildi: bose_dagilim_analizi.png\n');

%% GRAFİK 3: GÜVENLİK VE UYGUNLUK ANALİZİ
fprintf('Güvenlik ve uygunluk analizi grafikleri oluşturuluyor...\n');

figure('Name', 'Bose PIFA - Güvenlik ve Uygunluk Analizi', 'NumberTitle', 'off');
set(gcf, 'Position', [150, 150, 1600, 1200]);

% Güvenlik limitleri
safety_limits = struct();
safety_limits.FCC_USA = 1.6;
safety_limits.ICNIRP_EU = 2.0;
safety_limits.IC_Canada = 1.6;

% Alt grafik 1: SAR vs Güvenlik Limitleri
subplot(2, 2, 1);
bar_handle = bar(1:4, sar_max_values, 'FaceColor', [0.7 0.9 1], 'FaceAlpha', 0.8, 'EdgeColor', 'black');

hold on;
% Güvenlik limit çizgileri ekle
yline(safety_limits.FCC_USA, '--r', 'LineWidth', 2, 'DisplayName', sprintf('FCC (ABD): %.1f W/kg', safety_limits.FCC_USA));
yline(safety_limits.ICNIRP_EU, '--g', 'LineWidth', 2, 'DisplayName', sprintf('ICNIRP (AB): %.1f W/kg', safety_limits.ICNIRP_EU));
yline(safety_limits.IC_Canada, '--b', 'LineWidth', 2, 'DisplayName', sprintf('IC (Kanada): %.1f W/kg', safety_limits.IC_Canada));

% Değer etiketleri ekle
for i = 1:length(sar_max_values)
    if sar_max_values(i) > 0
        text(i, sar_max_values(i) + 0.05, sprintf('%.3f', sar_max_values(i)), ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
end

xlabel('Konfigürasyon', 'FontWeight', 'bold');
ylabel('Max SAR (W/kg)', 'FontWeight', 'bold');
title('SAR vs Uluslararası Güvenlik Limitleri', 'FontWeight', 'bold', 'FontSize', 14);
set(gca, 'XTickLabel', config_labels);
xtickangle(45);
legend('show', 'Location', 'best');
grid on; grid minor;

% Alt grafik 2: Güç Ölçekleme Analizi
subplot(2, 2, 2);
scaling_factors = [];
scaling_labels = {};

% Ölçekleme faktörlerini hesapla (25mW / 10mW)
if sar_max_values(1) > 0 && sar_max_values(3) > 0
    scaling_factors(end+1) = sar_max_values(3) / sar_max_values(1);
    scaling_labels{end+1} = '1g Kütle';
end

if sar_max_values(2) > 0 && sar_max_values(4) > 0
    scaling_factors(end+1) = sar_max_values(4) / sar_max_values(2);
    scaling_labels{end+1} = '10g Kütle';
end

if ~isempty(scaling_factors)
    bar_handle = bar(1:length(scaling_factors), scaling_factors, 'FaceColor', [1 0.8 0.4], 'FaceAlpha', 0.8, 'EdgeColor', 'black');
    hold on;
    
    % Teorik ölçekleme çizgisi
    theoretical_scaling = 2.5; % 25mW / 10mW = 2.5
    yline(theoretical_scaling, '--r', 'LineWidth', 2, 'DisplayName', sprintf('Teorik Lineer: %.1f', theoretical_scaling));
    
    % Değer etiketleri ekle
    for i = 1:length(scaling_factors)
        text(i, scaling_factors(i) + 0.05, sprintf('%.2f', scaling_factors(i)), ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    xlabel('Konfigürasyon', 'FontWeight', 'bold');
    ylabel('Ölçekleme Faktörü (25mW/10mW)', 'FontWeight', 'bold');
    title('Güç Ölçekleme Analizi', 'FontWeight', 'bold', 'FontSize', 14);
    set(gca, 'XTickLabel', scaling_labels);
    legend('show');
    grid on; grid minor;
end

% Alt grafik 3: Uygunluk Durumu
subplot(2, 2, 3);
fcc_limit = safety_limits.FCC_USA;
compliance_percentages = (fcc_limit - sar_max_values) ./ fcc_limit * 100;
compliance_percentages = max(0, compliance_percentages); % Negatif değerleri sıfırla

% Uygunluğa göre renklendirme
bar_colors = zeros(length(compliance_percentages), 3);
for i = 1:length(compliance_percentages)
    if compliance_percentages(i) > 0
        bar_colors(i, :) = [0.5 1 0.5]; % Uygun için yeşil
    else
        bar_colors(i, :) = [1 0.5 0.5]; % Uygun değil için kırmızı
    end
end

for i = 1:length(compliance_percentages)
    bar(i, compliance_percentages(i), 'FaceColor', bar_colors(i, :), 'FaceAlpha', 0.8, 'EdgeColor', 'black');
    hold on;
end

% Değer etiketleri ekle
for i = 1:length(compliance_percentages)
    text(i, compliance_percentages(i) + 2, sprintf('%.1f%%', compliance_percentages(i)), ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

xlabel('Konfigürasyon', 'FontWeight', 'bold');
ylabel('Güvenlik Marjı (%)', 'FontWeight', 'bold');
title(sprintf('Güvenlik Uygunluk Durumu\n(%.1f W/kg FCC limitine göre)', fcc_limit), 'FontWeight', 'bold', 'FontSize', 14);
set(gca, 'XTickLabel', config_labels);
xtickangle(45);
grid on; grid minor;

% Alt grafik 4: Özet Tablosu
subplot(2, 2, 4);
axis off;

% Özet tablo verilerini oluştur
table_data = cell(5, 5); % 5 satır (başlık + 4 config), 5 sütun
table_data{1, 1} = 'Konfigürasyon';
table_data{1, 2} = 'Max SAR (W/kg)';
table_data{1, 3} = 'Max E-field (V/m)';
table_data{1, 4} = 'FCC Uygun?';
table_data{1, 5} = 'Güvenlik Marjı (%)';

for i = 1:4
    table_data{i+1, 1} = config_labels{i};
    table_data{i+1, 2} = sprintf('%.3f', sar_max_values(i));
    table_data{i+1, 3} = sprintf('%.1f', efield_max_values(i));
         if sar_max_values(i) < fcc_limit
         table_data{i+1, 4} = '✓ Evet';
     else
         table_data{i+1, 4} = '✗ Hayır';
     end
    table_data{i+1, 5} = sprintf('%.1f%%', compliance_percentages(i));
end

% Tabloyu göster
text(0.1, 0.9, 'Analiz Özet Tablosu', 'FontWeight', 'bold', 'FontSize', 14, 'Units', 'normalized');

for row = 1:5
    for col = 1:5
        y_pos = 0.8 - (row-1)*0.12;
        x_pos = 0.05 + (col-1)*0.18;
        
        if row == 1
            text(x_pos, y_pos, table_data{row, col}, 'FontWeight', 'bold', 'FontSize', 10, 'Units', 'normalized');
        else
            text(x_pos, y_pos, table_data{row, col}, 'FontSize', 10, 'Units', 'normalized');
        end
    end
end

sgtitle('Bose PIFA Antenna - Güvenlik ve Uygunluk Analizi', 'FontWeight', 'bold', 'FontSize', 18);

% Grafik 3'ü kaydet
saveas(gcf, 'bose_guvenlik_analizi.png');
fprintf('✓ Güvenlik analizi grafiği kaydedildi: bose_guvenlik_analizi.png\n');

%% DETAYLI RAPOR YAZDIR
fprintf('\n');
fprintf('===============================================\n');
fprintf('  DETAYLI SAR VE E-FIELD ANALİZ RAPORU\n');
fprintf('===============================================\n\n');

for i = 1:length(configs)
    config = configs{i};
    fprintf('Konfigürasyon: %s\n', config_labels{i});
    fprintf('----------------------------------------\n');
    
    if isfield(statistics.(config), 'sar') && ~isempty(fieldnames(statistics.(config).sar))
        sar_stats = statistics.(config).sar;
        fprintf('SAR İstatistikleri:\n');
        fprintf('  Max SAR: %.4f W/kg\n', sar_stats.max);
        fprintf('  Mean SAR: %.4f W/kg\n', sar_stats.mean);
        fprintf('  Min SAR: %.4f W/kg\n', sar_stats.min);
        fprintf('  Std SAR: %.4f W/kg\n', sar_stats.std);
        fprintf('  Veri Noktası: %d\n', sar_stats.count);
    end
    
    if isfield(statistics.(config), 'e_field') && ~isempty(fieldnames(statistics.(config).e_field))
        efield_stats = statistics.(config).e_field;
        fprintf('E-field İstatistikleri:\n');
        fprintf('  Max E-field: %.4f V/m\n', efield_stats.max);
        fprintf('  Mean E-field: %.4f V/m\n', efield_stats.mean);
        fprintf('  Min E-field: %.4f V/m\n', efield_stats.min);
        fprintf('  Std E-field: %.4f V/m\n', efield_stats.std);
    end
    
    fprintf('\n');
end

%% TEMEL ANALIZLER
fprintf('===============================================\n');
fprintf('  TEMEL ANALİZLER\n');
fprintf('===============================================\n');

try
    % Güç seviyesi etkileri
    if sar_max_values(1) > 0 && sar_max_values(3) > 0
        power_increase_1g = ((sar_max_values(3) / sar_max_values(1)) - 1) * 100;
        fprintf('• Güç artışı etkisi (1g): %.1f%% SAR artışı 10mW''den 25mW''ye\n', power_increase_1g);
    end
    
    if sar_max_values(2) > 0 && sar_max_values(4) > 0
        power_increase_10g = ((sar_max_values(4) / sar_max_values(2)) - 1) * 100;
        fprintf('• Güç artışı etkisi (10g): %.1f%% SAR artışı 10mW''den 25mW''ye\n', power_increase_10g);
    end
    
    % Kütle ortalaması etkileri
    if sar_max_values(1) > 0 && sar_max_values(2) > 0
        mass_effect_10mw = ((sar_max_values(2) / sar_max_values(1)) - 1) * 100;
        fprintf('• Kütle ortalaması etkisi (10mW): %.1f%% değişim 1g''den 10g''ye\n', mass_effect_10mw);
    end
    
    if sar_max_values(3) > 0 && sar_max_values(4) > 0
        mass_effect_25mw = ((sar_max_values(4) / sar_max_values(3)) - 1) * 100;
        fprintf('• Kütle ortalaması etkisi (25mW): %.1f%% değişim 1g''den 10g''ye\n', mass_effect_25mw);
    end
    
    % Güvenlik uygunluğu
    all_compliant = all(sar_max_values < fcc_limit);
         if all_compliant
         fprintf('• Tüm konfigürasyonlar FCC limitine (%.1f W/kg) uygun: %s\n', fcc_limit, 'Evet');
     else
         fprintf('• Tüm konfigürasyonlar FCC limitine (%.1f W/kg) uygun: %s\n', fcc_limit, 'Hayır');
     end
    fprintf('• En yüksek SAR değeri: %.3f W/kg\n', max(sar_max_values));
    
catch ME
    fprintf('• Tüm analizler hesaplanamadı: %s\n', ME.message);
end

fprintf('\n===============================================\n');
fprintf('  ANALİZ TAMAMLANDI\n');
fprintf('===============================================\n');
fprintf('Oluşturulan dosyalar:\n');
fprintf('• bose_temel_analiz.png - Temel karşılaştırma grafikleri\n');
fprintf('• bose_dagilim_analizi.png - Dağılım ve istatistiksel analiz\n');
fprintf('• bose_guvenlik_analizi.png - Güvenlik ve uygunluk analizi\n\n');

fprintf('🎉 MATLAB SAR Analizi başarıyla tamamlandı!\n');
fprintf('📊 Grafikleri incelemek için PNG dosyalarını açın.\n');
fprintf('📋 Detaylı sonuçlar yukarıda yazdırıldı.\n\n'); 

%% VERİ OKUMA FONKSİYONU (Bu dosya içinde tanımlanmış)
function data = read_hfss_data_local(filepath)
    try
        if exist(filepath, 'file')
            [~, filename, ~] = fileparts(filepath);
            fprintf('  %s okunuyor...\n', filename);
            
            % Dosyayı aç
            fileID = fopen(filepath, 'r');
            if fileID == -1
                error('Dosya açılamıyor: %s', filepath);
            end
            
            % Veri değerlerini oku
            data_values = [];
            line_count = 0;
            header_skipped = 0;
            
            while ~feof(fileID)
                line = fgetl(fileID);
                line_count = line_count + 1;
                
                % İlk 3 satırı header olarak atla (Average_SAR, part, coordinates)
                if line_count <= 3
                    continue;
                end
                
                % Boş satırları atla
                if ~ischar(line) || isempty(strtrim(line))
                    continue;
                end
                
                % Sayısal değer çıkarmaya çalış
                line_str = strtrim(line);
                try
                    % Direkt sayısal dönüşüm dene
                    numeric_val = str2double(line_str);
                    if ~isnan(numeric_val) && isfinite(numeric_val)
                        data_values(end+1) = numeric_val; %#ok<AGROW>
                    else
                        % Alternatif: str2num kullan
                        line_data = str2num(line_str); %#ok<ST2NM>
                        if ~isempty(line_data)
                            data_values(end+1) = line_data(1); %#ok<AGROW>
                        end
                    end
                catch
                    % Hata durumunda devam et
                    continue;
                end
            end
            
            fclose(fileID);
            
            if ~isempty(data_values)
                data = data_values(:); % Sütun vektörüne çevir
                fprintf('    %d veri noktası başarıyla yüklendi (Max: %.6f)\n', length(data), max(data));
            else
                fprintf('    Uyarı: Dosyada sayısal veri bulunamadı\n');
                data = [];
            end
            
        else
            fprintf('    Hata: Dosya bulunamadı - %s\n', filepath);
            data = [];
        end
        
    catch ME
        fprintf('    Dosya okuma hatası %s: %s\n', filepath, ME.message);
        data = [];
        if exist('fileID', 'var') && fileID ~= -1
            fclose(fileID);
        end
    end
end

%% İSTATİSTİK HESAPLAMA FONKSİYONU (Bu dosya içinde tanımlanmış)
function stats = calculate_stats_local(data)
    if isempty(data)
        stats = struct();
        return;
    end
    
    % NaN ve sonsuz değerleri kaldır
    data = data(isfinite(data));
    
    if isempty(data)
        stats = struct();
        return;
    end
    
    % Temel istatistikleri hesapla
    stats.max = max(data);
    stats.min = min(data);
    stats.mean = mean(data);
    stats.std = std(data);
    stats.median = median(data);
    stats.count = length(data);
    
    % Yüzdelik değerler
    try
        stats.p95 = prctile(data, 95);
        stats.p05 = prctile(data, 5);
        stats.p75 = prctile(data, 75);
        stats.p25 = prctile(data, 25);
    catch
        % Eski MATLAB versiyonları için alternatif
        sorted_data = sort(data);
        n = length(sorted_data);
        stats.p95 = sorted_data(round(0.95 * n));
        stats.p05 = sorted_data(round(0.05 * n));
        stats.p75 = sorted_data(round(0.75 * n));
        stats.p25 = sorted_data(round(0.25 * n));
    end
    
    % Varyasyon katsayısı
    if stats.mean > 0
        stats.cv = stats.std / stats.mean * 100; % %
    else
        stats.cv = NaN;
    end
    
    % Aralık ve çeyrekler arası aralık
    stats.range = stats.max - stats.min;
    stats.iqr = stats.p75 - stats.p25;
end 