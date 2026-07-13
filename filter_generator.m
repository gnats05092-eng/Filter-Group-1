function filter_generator()
% --- User Interface Input Prompts ---
disp('=== Passive Filter Parameters Configuration ===');
R = input('Enter Resistance R in Ohms (ex, 1000): ');
C = input('Enter Capacitance C in Farads (ex, 1e-6): ');
L = input('Enter Inductance L in Henries (ex, 0.25): ');
disp('===============================================');

% Calculate frequencies
fc = 1 / (2 * pi * R * C);          % Cutoff for LP and HP
f0 = 1 / (2 * pi * sqrt(L * C));   % Center/Notch frequency for BP and BS

% Display calculated key frequencies to the user
fprintf('\nCalculated Cutoff Frequency (fc) for LP/HP: %.2f Hz\n', fc);
fprintf('Calculated Center Frequency (f0) for BP/BS: %.2f Hz\n\n', f0);

% 1. Low-Pass Filter Transfer Function: 1 / (RC*s + 1)
num_lp = 1;
den_lp = [R*C, 1];
sys_lp = tf(num_lp, den_lp);

% 2. High-Pass Filter Transfer Function: RC*s / (RC*s + 1)
num_hp = [R*C, 0];
den_hp = [R*C, 1];
sys_hp = tf(num_hp, den_hp);

% 3. Series RLC Bandpass Filter Transfer Function: (R/L)*s / (s^2 + (R/L)*s + 1/LC)
num_bp = [R/L, 0];
den_bp = [1, R/L, 1/(L*C)];
sys_bp = tf(num_bp, den_bp);

% 4. Series RLC Bandstop Filter Transfer Function: (s^2 + 1/LC) / (s^2 + (R/L)*s + 1/LC)
num_bs = [1, 0, 1/(L*C)];
den_bs = [1, R/L, 1/(L*C)];
sys_bs = tf(num_bs, den_bs);

% --- Configure Bode Options for Linear Magnitude ---
opts = bodeoptions;
opts.MagUnits = 'abs';
opts.MagScale = 'linear';

% Plot and Compare Responses using the custom configuration
figure('Name', 'Interactive Filter Analysis', 'NumberTitle', 'off');
bodeplot(sys_lp, 'r', sys_hp, 'b', sys_bp, 'g', sys_bs, 'm', opts);
grid on;
legend('Low-Pass (RC)', 'High-Pass (RC)', 'Bandpass (RLC)', 'Bandstop (RLC)');
title('Waveform Analysis Filter Generator');
end