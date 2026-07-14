
% --- User Interface Input Prompts for Components ---
disp('=== Passive Filter Parameters Configuration ===');
R = input('Enter Resistance R in Ohms (e.g., 1000): ');
C = input('Enter Capacitance C in Farads (e.g., 1e-6): ');
L = input('Enter Inductance L in Henries (e.g., 0.25): ');

% --- User Interface Input Prompts for the Varying Sinusoid ---
disp(' ');
disp('=== Chirp Sinusoid Frequency Vector Configuration ===');
f_start = input('Enter Starting Frequency in Hz (e.g., 10): ');
f_end   = input('Enter Ending Frequency in Hz (e.g., 1000): ');
t_duration = input('Enter Signal Duration in seconds (e.g., 0.5): ');
disp('===============================================');

% --- Build Time and Varying Frequency Vectors ---
% Sampling frequency must be at least 20x higher than the highest frequency
fs = max(10000, f_end * 20); 
dt = 1 / fs;
t = 0:dt:t_duration; % Time vector from 0 to total duration

% Create a sinusoidal signal that varies linearly in frequency from start to finish
input_signal = sin(2 * pi * (f_start + (f_end - f_start) * t / (2 * t_duration)) .* t);

% --- Define Transfer Functions ---
sys_lp = tf(1, [R*C, 1]);
sys_hp = tf([R*C, 0], [R*C, 1]);
sys_bp = tf([R/L, 0], [1, R/L, 1/(L*C)]);
sys_bs = tf([1, 0, 1/(L*C)], [1, R/L, 1/(L*C)]);

% --- Interactive Menu Selection ---
filter_options = {'Low-Pass Filter Only', ...
    'High-Pass Filter Only', ...
    'Bandpass Filter Only', ...
    'Bandstop Filter Only'};

choice = menu('Select the Filter to Simulate:', filter_options);

% Assign selected system model based on user menu choice
switch choice
    case 1, sys_active = sys_lp; filter_name = 'Low-Pass';
    case 2, sys_active = sys_hp; filter_name = 'High-Pass';
    case 3, sys_active = sys_bp; filter_name = 'Bandpass';
    case 4, sys_active = sys_bs; filter_name = 'Bandstop';
    otherwise
        disp('Simulation canceled by user.');
        return;
end

% --- Simulate the System Response ---
output_signal = lsim(sys_active, input_signal, t);

% --- Plot Waveforms in Separated Graphs ---
figure('Name', ['Separated Waveforms: ' filter_name], 'NumberTitle', 'off');

% Subplot 1: Input Voltage Waveform (Top)
subplot(2, 1, 1);
plot(t, input_signal, 'b-', 'LineWidth', 1.2);
grid on;
ylabel('Voltage (V)');
title(sprintf('Input Voltage Waveform (Vin) - Chirp: %.0f Hz to %.0f Hz', f_start, f_end));
legend('Input Signal', 'Location', 'best');

% Subplot 2: Output Voltage Waveform (Bottom)
subplot(2, 1, 2);
plot(t, output_signal, 'r-', 'LineWidth', 1.2);
grid on;
xlabel('Time (seconds)');
ylabel('Voltage (V)');
title(sprintf('%s Filter: Output Voltage Waveform (Vout)', filter_name));
legend('Filtered Output', 'Location', 'best');

% Link the X-axes together so zooming/panning on one updates the other instantly
linkaxes(get(gcf, 'Children'), 'x');
