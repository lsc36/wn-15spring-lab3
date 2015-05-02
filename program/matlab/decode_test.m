graphics_toolkit('gnuplot')

%function [] = decode()
evalin('caller','clear all'); 
close all;

global ANT_CNT LTS_LEN SYM_LEN NUM_SYM FFT_OFFSET LTS_CORR_THRESH

DO_CFO_CORRECTION = 1;	% Enable CFO estimation/correction
DO_PHASE_TRACK = 1; % Enable phase tracking
LTS_LEN = 160;
NUM_LTS = 2;
NUM_SYM = 50;
NUM_AC = 0;
LTS_CORR_THRESH = 0.6;
FFT_OFFSET = 1;		% Number of CP samples to use in FFT (on average)
ANT_CNT = 1;
SEGMENT_START = 1;

% OFDM params
SC_IND_DATA   = [2:7 9:21 23:27 39:43 45:57 59:64]; % Data subcarrier indices
N_SC = 64;          % Number of subcarriers
CP_LEN = 16;        % Cyclic prefix length
SYM_LEN = N_SC + CP_LEN;

% Read tx samples

load('../trace/src_data_1.mat');

% Read recv samples 
cf = 1;
figure(cf,'Position',[16,16,1600,900]);

%rx = read_complex_binary(['../trace/recv_signal.bin']);
rx = sim();
rx = rx(SEGMENT_START:SEGMENT_START+4800 - 1);
rx_ant = rx;
save(['../trace/recv_signal.mat'], 'rx');

plot(real(rx_ant).^2);
raw_title = sprintf( 'Raw Signals %d', i );
title(raw_title);
hold on;

[lts_ind payload_ind] = pkt_detection(rx_ant, LTS_CORR_THRESH);
lts_ind	%display the lts you find
payload_ind %display the payload_ind

% CFO correction
if(DO_CFO_CORRECTION)
	rx_ant = cfo_correction(rx_ant, lts_ind);
end
plot(real(rx_ant).^2,'r');
hold off;

% Re-extract LTS for channel estimate
cf = cf + 1;
figure(cf);
lts_f = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1];
H_ant_lts = zeros(N_SC, ANT_CNT);

rx_lts = rx_ant(lts_ind:lts_ind + LTS_LEN*NUM_LTS - 1);
SC_OFDM = [LTS_LEN - N_SC + 1:LTS_LEN] - FFT_OFFSET;
rx_lts1 = rx_lts(SC_OFDM - N_SC);
rx_lts2 = rx_lts(SC_OFDM);
rx_lts3 = rx_lts(SC_OFDM + N_SC);
rx_lts4 = rx_lts(SC_OFDM + N_SC*2);

rx_lts1_f = fft(rx_lts1);
rx_lts2_f = fft(rx_lts2);
rx_lts3_f = fft(rx_lts3);
rx_lts4_f = fft(rx_lts4);

H_lts1 = rx_lts1_f./ lts_f.';
H_lts2 = rx_lts1_f./ lts_f.';
H_lts3 = rx_lts1_f./ lts_f.';
H_lts4 = rx_lts1_f./ lts_f.';

H_ant_lts = (rx_lts1_f + rx_lts2_f + rx_lts3_f + rx_lts4_f)/4./lts_f.';
H = H_ant_lts;
hold on;
x = [-32:31];
plot(x, real(fftshift(H_lts1)),'r');
%{
plot(x, real(fftshift(H_lts2)),'g');
plot(x, real(fftshift(H_lts3)),'b');
plot(x, real(fftshift(H_lts4)),'k');
%}
plot(x, real(fftshift(H)),'b');
%plot(x, imag(fftshift(H)),'b');
hold off;
grid on;
axis([min(x)+5 max(x)-5 -1.1*max(abs(H)) 1.1*max(abs(H))])
title('Channel Estimates (I-Q)');
xlabel('Subcarrier Index');



rx_ant = rx_ant(payload_ind:payload_ind + SYM_LEN * NUM_SYM - 1);
SC_OFDM = [SYM_LEN - N_SC + 1:SYM_LEN] - FFT_OFFSET;

% Calculate channel estimate
cf = cf + 1;
figure(cf);
H_ant = zeros(N_SC, ANT_CNT);
SC_OFDM = [SYM_LEN - N_SC + 1:SYM_LEN] - FFT_OFFSET;

rx_t1 = rx_ant(SC_OFDM);
rx_t2 = rx_ant(SC_OFDM + SYM_LEN);
rx_t3 = rx_ant(SC_OFDM + 2*SYM_LEN);
rx_f1 = fft(rx_t1);
rx_f2 = fft(rx_t2);
rx_f3 = fft(rx_t3);

H_ant = (rx_f1 + rx_f2 + rx_f3)./ tx_mod_data / 3;
H = H_ant;
hold on;
x = [-32:31];
plot(x, real(fftshift(H)),'r');
plot(x, imag(fftshift(H)),'b');
hold off;
grid on;
axis([min(x)+5 max(x)-5 -1.1*max(abs(H)) 1.1*max(abs(H))])
title('Channel Estimates (I-Q)');
xlabel('Subcarrier Index');

pause(inf)
