% PIFA SAR Analizi - Direkt SAR Dosyalarından Veri Okuma
% Bitirme Projesi - SAR Değerlerini Dosyalardan Okuma ve Sıcaklık Analizi

clear all;
close all;
clc;

%% DOSYA YOLLARI AYARLAMA (Local SAR Dosyaları ile güncellendi ve düzeltildi)
base_path = pwd;
fprintf('Çalışma dizini: %s\n\n', base_path);

% AirPods dosya yolları (Dosya adı "airpodss" olarak düzeltildi)
airpods_files = struct();
% Local SAR dosyaları
airpods_files.sar.mass1g_10mw = fullfile(base_path, 'bose_sonuclar', 'airpodss_localsar_10mw_1g.Local_SAR0000');
airpods_files.sar.mass10g_10mw = fullfile(base_path, 'bose_sonuclar', 'airpodss_localsar_10mw_10g.Local_SAR0000');
airpods_files.sar.mass1g_25mw = fullfile(base_path, 'bose_sonuclar', 'airpodss_localsar_25mw_1gr.Local_SAR0000');
airpods_files.sar.mass10g_25mw = fullfile(base_path, 'bose_sonuclar', 'airpodss_localsar_25mw_10gr.Local_SAR0000');

% Bose dosya yolları
bose_files = struct();
% Local SAR dosyaları
bose_files.sar.mass1g_10mw = fullfile(base_path, 'bose_sonuclar', 'bose_localsar_10mw_1gr.Local_SAR0000');
bose_files.sar.mass10g_10mw = fullfile(base_path, 'bose_sonuclar', 'bose_localsar_10mw_10gr.Local_SAR0000');
bose_files.sar.mass1g_25mw = fullfile(base_path, 'bose_sonuclar', 'bose_localsar_25mw_1g.Local_SAR0000');
bose_files.sar.mass10g_25mw = fullfile(base_path, 'bose_sonuclar', 'bose_localsar_25mw_10gr.Local_SAR0000');

%% DOKU PARAMETRELERİ TANIMLAMA
tissue_params = struct();

% Kas dokusu
tissue_params.muscle.conductivity = 0.8;      % S/m
tissue_params.muscle.density = 1050;          % kg/m³
tissue_params.muscle.specific_heat = 3500;    % J/(kg·K)
tissue_params.muscle.thermal_conductivity = 0.5; % W/(m·K)
tissue_params.muscle.blood_perfusion = 0.005;     % 1/s
tissue_params.muscle.metabolic_heat = 700;        % W/m³

% Yağ dokusu
tissue_params.fat.conductivity = 0.05;
tissue_params.fat.density = 900;
tissue_params.fat.specific_heat = 2300;
tissue_params.fat.thermal_conductivity = 0.2;
tissue_params.fat.blood_perfusion = 0.0005;
tissue_params.fat.metabolic_heat = 400;

% Kemik dokusu
tissue_params.bone.conductivity = 0.08;
tissue_params.bone.density = 1900;
tissue_params.bone.specific_heat = 1300;
tissue_params.bone.thermal_conductivity = 0.4;
tissue_params.bone.blood_perfusion = 0.001;
tissue_params.bone.metabolic_heat = 200;

% Beyin dokusu
tissue_params.brain.conductivity = 0.6;
tissue_params.brain.density = 1040;
tissue_params.brain.specific_heat = 3700;
tissue_params.brain.thermal_conductivity = 0.5;
tissue_params.brain.blood_perfusion = 0.008;
tissue_params.brain.metabolic_heat = 10000;

% Kan parametreleri
blood_temp = 37;      % °C
blood_density = 1050; % kg/m³
blood_specific_heat = 3600; % J/(kg·K)

%% SAR DEĞERLERİNİ DOSYALARDAN OKUMA
fprintf('SAR Dosyalarını Okuma...\n');

% SAR değerlerini saklayacak yapı
sar_results = struct();
sar_results.airpods = struct();
sar_results.bose = struct();

% AirPods SAR verilerini oku
fprintf('\n=== AIRPODS SAR DOSYALARI ===\n');
field_names = fieldnames(airpods_files.sar);
for i = 1:length(field_names)
    fname = field_names{i};
    fprintf('İşleniyor: %s\n', fname);
    
    if exist(airpods_files.sar.(fname), 'file')
        % SAR dosyasını oku
        sar_data = read_sar_file(airpods_files.sar.(fname));
        
        if ~isempty(sar_data) && ~isnan(sar_data) && sar_data > 0
            % Okunan SAR değerini tüm doku türleri için kullan
            % (Gerçekte her doku türü için ayrı simülasyon yapılmalı)
            for tissue_name = fieldnames(tissue_params)'
                tissue_name = tissue_name{1};
                sar_results.airpods.(fname).(tissue_name) = sar_data;
            end
            fprintf('  Tüm dokular için okunan SAR: %.4f W/kg\n', sar_data);
        else
            fprintf('  Dosya okunamadı veya geçerli SAR değeri bulunamadı: %s\n', fname);
            % Hata durumunda sıfır SAR ata
            for tissue_name = fieldnames(tissue_params)'
                tissue_name = tissue_name{1};
                sar_results.airpods.(fname).(tissue_name) = 0;
            end
        end
    else
        fprintf('  Dosya bulunamadı: %s\n', airpods_files.sar.(fname));
        % Dosya bulunamadığında sıfır SAR ata
        for tissue_name = fieldnames(tissue_params)'
            tissue_name = tissue_name{1};
            sar_results.airpods.(fname).(tissue_name) = 0;
        end
    end
end

% Bose SAR verilerini oku
fprintf('\n=== BOSE SAR DOSYALARI ===\n');
field_names = fieldnames(bose_files.sar);
for i = 1:length(field_names)
    fname = field_names{i};
    fprintf('İşleniyor: %s\n', fname);
    
    if exist(bose_files.sar.(fname), 'file')
        % SAR dosyasını oku
        sar_data = read_sar_file(bose_files.sar.(fname));
        
        if ~isempty(sar_data) && ~isnan(sar_data) && sar_data > 0
            % Okunan SAR değerini tüm doku türleri için kullan
            for tissue_name = fieldnames(tissue_params)'
                tissue_name = tissue_name{1};
                sar_results.bose.(fname).(tissue_name) = sar_data;
            end
            fprintf('  Tüm dokular için okunan SAR: %.4f W/kg\n', sar_data);
        else
            fprintf('  Dosya okunamadı veya geçerli SAR değeri bulunamadı: %s\n', fname);
            % Hata durumunda sıfır SAR ata
            for tissue_name = fieldnames(tissue_params)'
                tissue_name = tissue_name{1};
                sar_results.bose.(fname).(tissue_name) = 0;
            end
        end
    else
        fprintf('  Dosya bulunamadı: %s\n', bose_files.sar.(fname));
        % Dosya bulunamadığında sıfır SAR ata
        for tissue_name = fieldnames(tissue_params)'
            tissue_name = tissue_name{1};
            sar_results.bose.(fname).(tissue_name) = 0;
        end
    end
end

%% SAR SONUÇLARINI ANALİZ ET VE KARŞILAŞTIR
fprintf('\n=== SAR SONUÇLARI KARŞILAŞTIRMASI ===\n');

devices = {'airpods', 'bose'};
tissue_types = fieldnames(tissue_params);
test_conditions = fieldnames(airpods_files.sar);

% Maksimum SAR değerlerini bul
max_sar_airpods = struct();
max_sar_bose = struct();

for tissue_idx = 1:length(tissue_types)
    tissue_name = tissue_types{tissue_idx};
    
    % AirPods için maksimum SAR
    max_sar_airpods.(tissue_name) = 0;
    max_condition_airpods = '';
    
    for cond_idx = 1:length(test_conditions)
        condition = test_conditions{cond_idx};
        if isfield(sar_results.airpods, condition) && ...
           isfield(sar_results.airpods.(condition), tissue_name)
            current_sar = sar_results.airpods.(condition).(tissue_name);
            if current_sar > max_sar_airpods.(tissue_name)
                max_sar_airpods.(tissue_name) = current_sar;
                max_condition_airpods = condition;
            end
        end
    end
    
    % Bose için maksimum SAR
    max_sar_bose.(tissue_name) = 0;
    max_condition_bose = '';
    
    for cond_idx = 1:length(test_conditions)
        condition = test_conditions{cond_idx};
        if isfield(sar_results.bose, condition) && ...
           isfield(sar_results.bose.(condition), tissue_name)
            current_sar = sar_results.bose.(condition).(tissue_name);
            if current_sar > max_sar_bose.(tissue_name)
                max_sar_bose.(tissue_name) = current_sar;
                max_condition_bose = condition;
            end
        end
    end
    
    fprintf('\n%s Dokusu:\n', upper(tissue_name));
    fprintf('  AirPods Maks SAR: %.4f W/kg (%s)\n', ...
        max_sar_airpods.(tissue_name), max_condition_airpods);
    fprintf('  Bose Maks SAR: %.4f W/kg (%s)\n', ...
        max_sar_bose.(tissue_name), max_condition_bose);
    
    % Karşılaştırma
    if max_sar_airpods.(tissue_name) > max_sar_bose.(tissue_name) && max_sar_bose.(tissue_name) > 0
        diff_percent = ((max_sar_airpods.(tissue_name) - max_sar_bose.(tissue_name)) / ...
                        max_sar_bose.(tissue_name)) * 100;
        fprintf('  AirPods %.1f%% daha yüksek SAR\n', diff_percent);
    elseif max_sar_bose.(tissue_name) > max_sar_airpods.(tissue_name) && max_sar_airpods.(tissue_name) > 0
        diff_percent = ((max_sar_bose.(tissue_name) - max_sar_airpods.(tissue_name)) / ...
                        max_sar_airpods.(tissue_name)) * 100;
        fprintf('  Bose %.1f%% daha yüksek SAR\n', diff_percent);
    else
        fprintf('  Karşılaştırma yapılamadı (sıfır veya eşit değerler)\n');
    end
end

%% SICAKLIK ARTIŞI HESAPLAMALARI
fprintf('\n=== SICAKLIK ARTIŞI ANALİZİ ===\n');

exposure_times = [60, 300, 600, 1800]; % saniye (1, 5, 10, 30 dakika)
temp_results = struct();

for device_idx = 1:length(devices)
    device_name = devices{device_idx};
    temp_results.(device_name) = struct();
    
    fprintf('\n%s İÇİN SICAKLIK ARTIŞLARI:\n', upper(device_name));
    
    for tissue_idx = 1:length(tissue_types)
        tissue_name = tissue_types{tissue_idx};
        tissue_props = tissue_params.(tissue_name);
        
        if device_idx == 1
            max_sar = max_sar_airpods.(tissue_name);
        else
            max_sar = max_sar_bose.(tissue_name);
        end
        
        fprintf('\n  %s Dokusu (SAR: %.4f W/kg):\n', upper(tissue_name), max_sar);
        
        for time_idx = 1:length(exposure_times)
            exp_time = exposure_times(time_idx);
            
            if max_sar > 0
                temp_rise = solve_bioheat_equation(max_sar, tissue_props, exp_time);
            else
                temp_rise = 0;
            end
            
            temp_results.(device_name).(tissue_name)(time_idx) = temp_rise;
            
            fprintf('    %d dakika: %.3f °C\n', exp_time/60, temp_rise);
        end
    end
end

%% GÜVENLİK LİMİTLERİ KONTROLÜ
fprintf('\n=== GÜVENLİK LİMİTLERİ KONTROLÜ ===\n');
fcc_limit = 1.6; % W/kg (Amerika)
icnirp_limit = 2.0; % W/kg (Avrupa)

fprintf('FCC Limiti: %.1f W/kg\n', fcc_limit);
fprintf('ICNIRP Limiti: %.1f W/kg\n', icnirp_limit);

for device_idx = 1:length(devices)
    device_name = devices{device_idx};
    fprintf('\n%s GÜVENLİK DURUMU:\n', upper(device_name));
    
    for tissue_idx = 1:length(tissue_types)
        tissue_name = tissue_types{tissue_idx};
        
        if device_idx == 1
            max_sar = max_sar_airpods.(tissue_name);
        else
            max_sar = max_sar_bose.(tissue_name);
        end
        
        % Güvenlik durumu
        if max_sar > icnirp_limit
            status = 'ICNIRP LİMİTİ AŞIMI!';
            color = 'KIRMIZI';
        elseif max_sar > fcc_limit
            status = 'FCC LİMİTİ AŞIMI';
            color = 'SARI';
        else
            status = 'GÜVENLİ';
            color = 'YEŞİL';
        end
        
        fprintf('  %-8s: %.4f W/kg - %s (%s)\n', ...
            upper(tissue_name), max_sar, status, color);
    end
end

%% GRAFİK ÇİZİMLERİ
fprintf('\nGrafik çizimleri oluşturuluyor...\n');

% Şekil 1: Cihaz karşılaştırması - SAR değerleri
figure(1);
clf;

tissue_names_plot = upper(tissue_types);
airpods_sar_plot = zeros(1, length(tissue_types));
bose_sar_plot = zeros(1, length(tissue_types));

for i = 1:length(tissue_types)
    tissue_name = tissue_types{i};
    airpods_sar_plot(i) = max_sar_airpods.(tissue_name);
    bose_sar_plot(i) = max_sar_bose.(tissue_name);
end

x = 1:length(tissue_types);
width = 0.35;

b = bar(x, [airpods_sar_plot', bose_sar_plot']);
b(1).FaceColor = [0.2 0.6 1.0];
b(2).FaceColor = [1.0 0.4 0.2];
hold on;

% Güvenlik limitlerini çiz
yline(fcc_limit, 'r--', 'FCC Limit (1.6 W/kg)', 'LineWidth', 2);
yline(icnirp_limit, 'm-.', 'ICNIRP Limit (2.0 W/kg)', 'LineWidth', 2);

xlabel('Doku Türü');
ylabel('Maksimum SAR (W/kg)');
title('AirPods vs Bose - Maksimum SAR Karşılaştırması');
set(gca, 'XTick', x, 'XTickLabel', tissue_names_plot);
legend({'AirPods', 'Bose', 'FCC Limit', 'ICNIRP Limit'}, 'Location', 'northwest');
grid on;
box on;
hold off;

% Şekil 2: Sıcaklık artışı karşılaştırması
figure(2);
clf;

for i=1:length(tissue_types)
    subplot(2, 2, i);
    tissue_name = tissue_types{i};
    if isfield(temp_results.airpods, tissue_name) && isfield(temp_results.bose, tissue_name)
        airpods_temps = temp_results.airpods.(tissue_name);
        bose_temps = temp_results.bose.(tissue_name);
        plot(exposure_times/60, airpods_temps, 'b-o', 'LineWidth', 2, 'DisplayName', 'AirPods');
        hold on;
        plot(exposure_times/60, bose_temps, 'r-s', 'LineWidth', 2, 'DisplayName', 'Bose');
    end
    xlabel('Zaman (dakika)');
    ylabel('Sıcaklık Artışı (°C)');
    title(upper(tissue_name));
    legend('Location', 'best');
    grid on;
    box on;
end

sgtitle('Doku Türlerine Göre Sıcaklık Artışı Karşılaştırması');

% Şekil 3: Test koşullarına göre SAR dağılımı
figure(3);
clf;

test_conditions_clean = {'1g-10mW', '10g-10mW', '1g-25mW', '10g-25mW'};
colors_devices = [0.2 0.6 1.0; 1.0 0.4 0.2]; % Mavi, Kırmızı

for tissue_idx = 1:length(tissue_types)
    subplot(2, 2, tissue_idx);
    tissue_name = tissue_types{tissue_idx};
    
    airpods_values = zeros(1, length(test_conditions));
    bose_values = zeros(1, length(test_conditions));
    
    for cond_idx = 1:length(test_conditions)
        condition = test_conditions{cond_idx};
        if isfield(sar_results.airpods, condition) && ...
           isfield(sar_results.airpods.(condition), tissue_name)
            airpods_values(cond_idx) = sar_results.airpods.(condition).(tissue_name);
        end
        if isfield(sar_results.bose, condition) && ...
           isfield(sar_results.bose.(condition), tissue_name)
            bose_values(cond_idx) = sar_results.bose.(condition).(tissue_name);
        end
    end
    
    x_bar = 1:length(test_conditions);
    
    b_dev = bar(x_bar, [airpods_values', bose_values']);
    b_dev(1).FaceColor = colors_devices(1,:);
    b_dev(2).FaceColor = colors_devices(2,:);
    
    xlabel('Test Koşulu');
    ylabel('SAR (W/kg)');
    title(sprintf('%s Dokusu', upper(tissue_name)));
    set(gca, 'XTick', x_bar, 'XTickLabel', test_conditions_clean, 'XTickLabelRotation', 45);
    if tissue_idx == 1
        legend({'AirPods', 'Bose'},'Location', 'best');
    end
    grid on;
    box on;
end

sgtitle('Test Koşullarına Göre SAR Dağılımı');

%% ÖZET RAPOR
fprintf('\n=== ÖZET RAPOR ===\n');
fprintf('En yüksek SAR değerleri:\n');

overall_max_sar = 0;
overall_max_device = 'N/A';
overall_max_tissue = 'N/A';

for device_idx = 1:length(devices)
    device_name = devices{device_idx};
    fprintf('\n%s:\n', upper(device_name));
    
    for tissue_idx = 1:length(tissue_types)
        tissue_name = tissue_types{tissue_idx};
        
        if device_idx == 1
            max_sar = max_sar_airpods.(tissue_name);
        else
            max_sar = max_sar_bose.(tissue_name);
        end
        
        fprintf('  %-8s: %.4f W/kg\n', upper(tissue_name), max_sar);
        
        if max_sar > overall_max_sar
            overall_max_sar = max_sar;
            overall_max_device = device_name;
            overall_max_tissue = tissue_name;
        end
    end
end

fprintf('\nGENEL MAKSİMUM:\n');
fprintf('Cihaz: %s\n', upper(overall_max_device));
fprintf('Doku: %s\n', upper(overall_max_tissue));
fprintf('SAR: %.4f W/kg\n', overall_max_sar);

fprintf('\nAnaliz tamamlandı!\n');

%% ===== FONKSIYON TANIMLARI =====

% SAR dosyası okuma fonksiyonu (Başlık bilgilerini atlayacak şekilde güncellendi)
function sar_value = read_sar_file(filename)
    sar_value = NaN; % Başlangıç değeri
    try
        if ~exist(filename, 'file')
            warning('Dosya bulunamadı: %s', filename);
            return;
        end
        
        fid = fopen(filename, 'rt');
        if fid == -1
            warning('Dosya açılamadı: %s', filename);
            return;
        end
        
        data_values = [];
        start_reading = false; % Veri okuma bayrağı

        while ~feof(fid)
            line = fgetl(fid);
            
            % Eğer "coordinates" satırını bulduysak, bir sonraki satırdan itibaren okumaya başla
            if start_reading
                numbers_on_line = sscanf(line, '%f');
                if ~isempty(numbers_on_line)
                    % Genellikle SAR değeri en sonda olur, bu en güvenli yaklaşımdır.
                    data_values = [data_values; numbers_on_line(end)];
                end
            end
            
            % "coordinates" kelimesini içeren satırı bul ve bayrağı ayarla
            if contains(lower(line), 'coordinates')
                start_reading = true;
            end
        end
        fclose(fid);
        
        % Veri kontrolü ve işleme
        if ~isempty(data_values)
            % Sadece geçerli sayısal değerleri al (NaN ve Inf hariç)
            valid_numbers = data_values(~isnan(data_values) & ~isinf(data_values));
            
            if ~isempty(valid_numbers)
                % Ayıklanan tüm değerlerin maksimumunu al
                sar_value = max(valid_numbers(:));
                
                fprintf('    Dosya okundu: %d geçerli veri noktası bulundu, Maks SAR: %.4f W/kg\n', ...
                    numel(valid_numbers), sar_value);
                    
            else
                sar_value = 0;
                fprintf('    Uyarı: Dosyada geçerli sayısal SAR verisi bulunamadı.\n');
            end
        else
            sar_value = 0;
            fprintf('    Uyarı: Dosya boş veya "coordinates" sonrası okunabilir veri içermiyor.\n');
        end
        
    catch ME
        warning('Dosya okuma hatası (%s): %s', filename, ME.message);
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        sar_value = NaN;
    end
end


% Biyoisı denklemi çözücüsü (Pennes Bioheat Equation)
function temp_rise = solve_bioheat_equation(sar_value, tissue_type, exposure_time)
    % Bu fonksiyon, Pennes Biyoisı denkleminin iletim (k∇²T) ve metabolik ısı (Q_m)
    % terimlerini ihmal eden basitleştirilmiş bir analitik çözümünü kullanır.
    % Zamana bağlı sıcaklık artışını hesaplar.
    
    if sar_value <= 0 || exposure_time <= 0
        temp_rise = 0;
        return;
    end
    
    % Doku ve kan parametreleri
    rho = tissue_type.density;          % Doku yoğunluğu (kg/m³)
    c = tissue_type.specific_heat;      % Özgül ısı (J/(kg·K))
    wb = tissue_type.blood_perfusion;   % Kan perfüzyonu (1/s)
    rho_b = 1050;                       % Kan yoğunluğu (kg/m³)
    c_b = 3600;                         % Kan özgül ısısı (J/(kg·K))
    
    % Kan perfüzyonunun varlığına göre hesaplama
    if wb > 0
        % Kan perfüzyonu varsa: Sıcaklık, denge durumuna eksponansiyel olarak yaklaşır.
        
        % Denge durumundaki (sonsuz zamandaki) sıcaklık artışı:
        % ΔT_steady = (Q_sar) / (ω_b * ρ_b * c_b) = (SAR * ρ) / (ω_b * ρ_b * c_b)
        temp_steady = (sar_value * rho) / (wb * rho_b * c_b);
        
        % Termal zaman sabiti (sistem yanıt hızını belirler)
        tau = (rho * c) / (wb * rho_b * c_b);
        
        % Belirtilen maruziyet süresi sonundaki sıcaklık artışı
        temp_rise = temp_steady * (1 - exp(-exposure_time / tau));
        
    else
        % Kan perfüzyonu yoksa (wb = 0): Sıcaklık lineer olarak artar.
        % Denklem ρc(∂T/∂t) = Q_sar haline gelir, bu da ∂T/∂t = SAR/c demektir.
        % İntegrali alındığında: ΔT = (SAR/c) * t
        temp_rise = (sar_value / c) * exposure_time;
    end
end
