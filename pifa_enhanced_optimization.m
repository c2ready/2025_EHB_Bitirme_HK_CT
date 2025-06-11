%% Enhanced PIFA Optimization for Minimum S11
% This script performs an enhanced optimization of the PIFA antenna
% to achieve the minimum possible S11 value at 2.45 GHz.
% It starts with the AI-optimized dimensions and explores variations
% to find an even better design.

clear;
clc;
close all;

%% --- Target Frequency ---
targetFreq = 2.45e9;  % Target frequency: 2.45 GHz (WiFi/Bluetooth)
fprintf('Target frequency: %.2f GHz\n', targetFreq/1e9);

%% --- Starting Point: AI-Optimized Dimensions ---
% Using the AI-optimized values as a starting point
patchLength_ai = 0.028572;  % 28.57 mm
patchWidth_ai = 0.019052;   % 19.05 mm
patchHeight_ai = 0.009520;  % 9.52 mm
lengthgp_ai = 0.034286;     % 34.29 mm
widthgp_ai = 0.034286;      % 34.29 mm
feedoffset_x_ai = 0.012377; % 12.38 mm

fprintf('\nAI-optimized dimensions (starting point):\n');
fprintf('  Patch Length:      %.2f mm\n', patchLength_ai*1000);
fprintf('  Patch Width:       %.2f mm\n', patchWidth_ai*1000);
fprintf('  Patch Height:      %.2f mm\n', patchHeight_ai*1000);
fprintf('  Ground Plane:      %.2f x %.2f mm\n', lengthgp_ai*1000, widthgp_ai*1000);
fprintf('  Feed Offset:       %.2f mm\n', feedoffset_x_ai*1000);

% Create the AI-optimized antenna for reference
ant_ai = pifa(Length=patchLength_ai, Width=patchWidth_ai, Height=patchHeight_ai, ...
             GroundPlaneLength=lengthgp_ai, GroundPlaneWidth=widthgp_ai, ...
             ShortPinWidth=patchWidth_ai, ...
             FeedOffset=[-patchLength_ai/2 + feedoffset_x_ai 0]);

% Calculate S11 at target frequency for the AI-optimized antenna
S_ai = sparameters(ant_ai, targetFreq);
s11_ai = 20*log10(abs(S_ai.Parameters));
fprintf('  S11 at %.2f GHz:    %.2f dB\n', targetFreq/1e9, s11_ai);

%% --- Define Parameter Ranges for Enhanced Optimization ---
% Define ranges around the AI-optimized values
% Use finer steps for more precise optimization

% Patch length variations (±10% with 11 steps)
patchLength_range = linspace(patchLength_ai*0.9, patchLength_ai*1.1, 11);

% Patch width variations (±10% with 11 steps)
patchWidth_range = linspace(patchWidth_ai*0.9, patchWidth_ai*1.1, 11);

% Patch height variations (±20% with 11 steps)
patchHeight_range = linspace(patchHeight_ai*0.8, patchHeight_ai*1.2, 11);

% Ground plane length variations (±10% with 7 steps)
lengthgp_range = linspace(lengthgp_ai*0.9, lengthgp_ai*1.1, 7);

% Ground plane width variations (±10% with 7 steps)
widthgp_range = linspace(widthgp_ai*0.9, widthgp_ai*1.1, 7);

% Feed offset variations (±30% with 21 steps for finer resolution)
feedoffset_x_range = linspace(feedoffset_x_ai*0.7, feedoffset_x_ai*1.3, 21);

%% --- Enhanced Optimization Strategy ---
% We'll use a sequential optimization approach:
% 1. First optimize feed offset (most critical for impedance matching)
% 2. Then optimize patch length (affects resonant frequency)
% 3. Then optimize patch height (affects bandwidth)
% 4. Then optimize patch width
% 5. Finally optimize ground plane dimensions

fprintf('\n--- Starting Enhanced Optimization ---\n');

% Initialize best parameters with AI-optimized values
best_patchLength = patchLength_ai;
best_patchWidth = patchWidth_ai;
best_patchHeight = patchHeight_ai;
best_lengthgp = lengthgp_ai;
best_widthgp = widthgp_ai;
best_feedoffset_x = feedoffset_x_ai;
best_s11 = s11_ai;

%% --- Step 1: Optimize Feed Offset ---
fprintf('\nOptimizing feed offset...\n');
for feed_x = feedoffset_x_range
    % Skip invalid feed positions
    if feed_x >= best_patchLength
        continue;
    end
    
    % Create antenna with current parameters
    ant_temp = pifa(Length=best_patchLength, Width=best_patchWidth, Height=best_patchHeight, ...
                   GroundPlaneLength=best_lengthgp, GroundPlaneWidth=best_widthgp, ...
                   ShortPinWidth=best_patchWidth, ...
                   FeedOffset=[-best_patchLength/2 + feed_x 0]);
    
    % Calculate S11 at target frequency
    try
        S_temp = sparameters(ant_temp, targetFreq);
        s11_temp = 20*log10(abs(S_temp.Parameters));
        
        fprintf('  Feed offset: %.2f mm, S11: %.2f dB\n', feed_x*1000, s11_temp);
        
        % Update best parameters if better S11 is found
        if s11_temp < best_s11
            best_feedoffset_x = feed_x;
            best_s11 = s11_temp;
        end
    catch
        fprintf('  Feed offset: %.2f mm - Calculation failed\n', feed_x*1000);
    end
end

fprintf('Best feed offset found: %.2f mm (S11: %.2f dB)\n', best_feedoffset_x*1000, best_s11);

%% --- Step 2: Optimize Patch Length ---
fprintf('\nOptimizing patch length...\n');
for p_length = patchLength_range
    % Create antenna with current parameters
    ant_temp = pifa(Length=p_length, Width=best_patchWidth, Height=best_patchHeight, ...
                   GroundPlaneLength=best_lengthgp, GroundPlaneWidth=best_widthgp, ...
                   ShortPinWidth=best_patchWidth, ...
                   FeedOffset=[-p_length/2 + best_feedoffset_x 0]);
    
    % Calculate S11 at target frequency
    try
        S_temp = sparameters(ant_temp, targetFreq);
        s11_temp = 20*log10(abs(S_temp.Parameters));
        
        fprintf('  Patch length: %.2f mm, S11: %.2f dB\n', p_length*1000, s11_temp);
        
        % Update best parameters if better S11 is found
        if s11_temp < best_s11
            best_patchLength = p_length;
            best_s11 = s11_temp;
        end
    catch
        fprintf('  Patch length: %.2f mm - Calculation failed\n', p_length*1000);
    end
end

fprintf('Best patch length found: %.2f mm (S11: %.2f dB)\n', best_patchLength*1000, best_s11);

%% --- Step 3: Optimize Patch Height ---
fprintf('\nOptimizing patch height...\n');
for p_height = patchHeight_range
    % Create antenna with current parameters
    ant_temp = pifa(Length=best_patchLength, Width=best_patchWidth, Height=p_height, ...
                   GroundPlaneLength=best_lengthgp, GroundPlaneWidth=best_widthgp, ...
                   ShortPinWidth=best_patchWidth, ...
                   FeedOffset=[-best_patchLength/2 + best_feedoffset_x 0]);
    
    % Calculate S11 at target frequency
    try
        S_temp = sparameters(ant_temp, targetFreq);
        s11_temp = 20*log10(abs(S_temp.Parameters));
        
        fprintf('  Patch height: %.2f mm, S11: %.2f dB\n', p_height*1000, s11_temp);
        
        % Update best parameters if better S11 is found
        if s11_temp < best_s11
            best_patchHeight = p_height;
            best_s11 = s11_temp;
        end
    catch
        fprintf('  Patch height: %.2f mm - Calculation failed\n', p_height*1000);
    end
end

fprintf('Best patch height found: %.2f mm (S11: %.2f dB)\n', best_patchHeight*1000, best_s11);

%% --- Step 4: Optimize Patch Width ---
fprintf('\nOptimizing patch width...\n');
for p_width = patchWidth_range
    % Create antenna with current parameters
    ant_temp = pifa(Length=best_patchLength, Width=p_width, Height=best_patchHeight, ...
                   GroundPlaneLength=best_lengthgp, GroundPlaneWidth=best_widthgp, ...
                   ShortPinWidth=p_width, ... % ShortPinWidth = Width
                   FeedOffset=[-best_patchLength/2 + best_feedoffset_x 0]);
    
    % Calculate S11 at target frequency
    try
        S_temp = sparameters(ant_temp, targetFreq);
        s11_temp = 20*log10(abs(S_temp.Parameters));
        
        fprintf('  Patch width: %.2f mm, S11: %.2f dB\n', p_width*1000, s11_temp);
        
        % Update best parameters if better S11 is found
        if s11_temp < best_s11
            best_patchWidth = p_width;
            best_s11 = s11_temp;
        end
    catch
        fprintf('  Patch width: %.2f mm - Calculation failed\n', p_width*1000);
    end
end

fprintf('Best patch width found: %.2f mm (S11: %.2f dB)\n', best_patchWidth*1000, best_s11);

%% --- Step 5: Optimize Ground Plane Dimensions ---
fprintf('\nOptimizing ground plane dimensions...\n');
for gp_length = lengthgp_range
    for gp_width = widthgp_range
        % Create antenna with current parameters
        ant_temp = pifa(Length=best_patchLength, Width=best_patchWidth, Height=best_patchHeight, ...
                       GroundPlaneLength=gp_length, GroundPlaneWidth=gp_width, ...
                       ShortPinWidth=best_patchWidth, ...
                       FeedOffset=[-best_patchLength/2 + best_feedoffset_x 0]);
        
        % Calculate S11 at target frequency
        try
            S_temp = sparameters(ant_temp, targetFreq);
            s11_temp = 20*log10(abs(S_temp.Parameters));
            
            fprintf('  Ground plane: %.2f x %.2f mm, S11: %.2f dB\n', ...
                    gp_length*1000, gp_width*1000, s11_temp);
            
            % Update best parameters if better S11 is found
            if s11_temp < best_s11
                best_lengthgp = gp_length;
                best_widthgp = gp_width;
                best_s11 = s11_temp;
            end
        catch
            fprintf('  Ground plane: %.2f x %.2f mm - Calculation failed\n', ...
                    gp_length*1000, gp_width*1000);
        end
    end
end

fprintf('Best ground plane dimensions found: %.2f x %.2f mm (S11: %.2f dB)\n', ...
        best_lengthgp*1000, best_widthgp*1000, best_s11);

%% --- Create Final Optimized Antenna ---
fprintf('\n=== FINAL ENHANCED OPTIMIZATION RESULTS ===\n');
fprintf('Improvement over AI-optimized design: %.2f dB\n', s11_ai - best_s11);
fprintf('\nOptimized Dimensions:\n');
fprintf('  Patch Length:      %.2f mm\n', best_patchLength*1000);
fprintf('  Patch Width:       %.2f mm\n', best_patchWidth*1000);
fprintf('  Patch Height:      %.2f mm\n', best_patchHeight*1000);
fprintf('  Ground Plane:      %.2f x %.2f mm\n', best_lengthgp*1000, best_widthgp*1000);
fprintf('  Feed Offset:       %.2f mm\n', best_feedoffset_x*1000);
fprintf('  S11 at %.2f GHz:   %.2f dB\n', targetFreq/1e9, best_s11);

% Create the final optimized antenna
ant_final = pifa(Length=best_patchLength, Width=best_patchWidth, Height=best_patchHeight, ...
                GroundPlaneLength=best_lengthgp, GroundPlaneWidth=best_widthgp, ...
                ShortPinWidth=best_patchWidth, ...
                FeedOffset=[-best_patchLength/2 + best_feedoffset_x 0]);

%% --- Analyze Final Optimized Antenna ---
% Display the antenna geometry
figure;
show(ant_final);
title('Enhanced Optimized PIFA Geometry');

% Define frequency range for analysis
freq = linspace(2.3e9, 2.6e9, 101); % Range around 2.45 GHz

% Calculate S-parameters over the frequency range
S_final = sparameters(ant_final, freq);

% Plot S11 vs Frequency
figure;
rfplot(S_final);
title(sprintf('Enhanced Optimized PIFA S11 (%.2f dB @ %.2f GHz)', best_s11, targetFreq/1e9));
grid on;
hold on;

% Add marker at the target frequency
[~, targetFreqIndex] = min(abs(freq - targetFreq));
s11_at_target = 20*log10(abs(S_final.Parameters(1,1,targetFreqIndex)));
plot(targetFreq/1e9, s11_at_target, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, ...
     'DisplayName', 'Target Frequency');

% Add -10 dB threshold line
plot(freq./1e9, -10*ones(size(freq)), 'r--', 'LineWidth', 1.0, ...
     'DisplayName', '-10 dB Threshold');

% Add AI-optimized S11 for comparison
S_ai_freq = sparameters(ant_ai, freq);
plot(freq./1e9, 20*log10(abs(squeeze(S_ai_freq.Parameters))), '--', ...
     'LineWidth', 1.0, 'DisplayName', 'AI-Optimized');

legend('show');
ylim([-30 0]);
xlabel('Frequency (GHz)');
ylabel('S11 (dB)');
hold off;

% Plot VSWR vs Frequency
figure;
vswr_data = vswr(ant_final, freq);
plot(freq/1e9, vswr_data);
title('Enhanced Optimized PIFA VSWR');
grid on;
hold on;

% Add marker at the target frequency
vswr_at_target = vswr_data(targetFreqIndex);
plot(targetFreq/1e9, vswr_at_target, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5, ...
     'DisplayName', 'Target Frequency');

% Add VSWR = 2 threshold line (approximately -10 dB in S11)
plot(freq./1e9, 2*ones(size(freq)), 'r--', 'LineWidth', 1.0, ...
     'DisplayName', 'VSWR = 2 Threshold');

legend('show');
ylim([1 5]);
xlabel('Frequency (GHz)');
ylabel('VSWR');
hold off;

% Plot 3D Radiation Pattern
figure;
pattern(ant_final, targetFreq);
title(sprintf('Enhanced Optimized PIFA Radiation Pattern at %.2f GHz', targetFreq/1e9));

% Calculate and display bandwidth (frequency range where S11 < -10 dB)
s11_mag_db = 20*log10(abs(squeeze(S_final.Parameters)));
below_threshold_indices = find(s11_mag_db < -10);

if ~isempty(below_threshold_indices)
    min_freq_index = min(below_threshold_indices);
    max_freq_index = max(below_threshold_indices);
    bandwidth = freq(max_freq_index) - freq(min_freq_index);
    center_freq = (freq(max_freq_index) + freq(min_freq_index))/2;
    
    fprintf('\nBandwidth (S11 < -10 dB): %.2f MHz (%.1f%% of center frequency)\n', ...
            bandwidth/1e6, bandwidth/center_freq*100);
    fprintf('Frequency Range: %.2f - %.2f GHz\n', ...
            freq(min_freq_index)/1e9, freq(max_freq_index)/1e9);
else
    fprintf('\nWarning: No frequencies found where S11 < -10 dB in the analyzed range.\n');
end

%% --- Generate MATLAB Code for the Final Optimized Antenna ---
fprintf('\n--- MATLAB Code for the Enhanced Optimized PIFA ---\n');
fprintf('Copy and paste the following code to recreate the optimized antenna:\n\n');

fprintf('%% --- Enhanced Optimized PIFA Parameters ---\n');
fprintf('patchLength = %.6f;  %% %.2f mm\n', best_patchLength, best_patchLength*1000);
fprintf('patchWidth = %.6f;   %% %.2f mm\n', best_patchWidth, best_patchWidth*1000);
fprintf('patchHeight = %.6f;  %% %.2f mm\n', best_patchHeight, best_patchHeight*1000);
fprintf('lengthgp = %.6f;     %% %.2f mm\n', best_lengthgp, best_lengthgp*1000);
fprintf('widthgp = %.6f;      %% %.2f mm\n', best_widthgp, best_widthgp*1000);
fprintf('feedoffset_x = %.6f; %% %.2f mm\n\n', best_feedoffset_x, best_feedoffset_x*1000);

fprintf('%% --- Create Enhanced Optimized PIFA Antenna ---\n');
fprintf('ant = pifa(Length=patchLength, Width=patchWidth, Height=...\n');
fprintf('    patchHeight, GroundPlaneLength=lengthgp, GroundPlaneWidth=...\n');
fprintf('    widthgp, ShortPinWidth=patchWidth, ...\n');
fprintf('    FeedOffset=[-patchLength/2 + feedoffset_x 0]);\n\n');

fprintf('%% --- Display Antenna ---\n');
fprintf('figure;\n');
fprintf('show(ant);\n');
fprintf('title(''Enhanced Optimized PIFA'');\n\n');

fprintf('%% --- Calculate and Plot S11 ---\n');
fprintf('freq = linspace(2.3e9, 2.6e9, 101);\n');
fprintf('s = sparameters(ant, freq);\n');
fprintf('figure;\n');
fprintf('rfplot(s);\n');
fprintf('title(''S11 for Enhanced Optimized PIFA'');\n');
fprintf('grid on;\n');
