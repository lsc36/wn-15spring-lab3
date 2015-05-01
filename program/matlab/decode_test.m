% unction [] = decode()
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
figure(cf);

rx = read_complex_binary(['../trace/recv_signal.bin']);
rx = rx(SEGMENT_START:SEGMENT_START+4800 - 1);
rx_ant = rx;
save(['../trace/recv_signal.mat'], 'rx');

plot(real(rx_ant).^2);
raw_title = sprintf( 'Raw Signals %d', i );
title(raw_title);

[lts_ind payload_ind] = pkt_detection(rx_ant, LTS_CORR_THRESH);
lts_ind	%display the lts you find
payload_ind %display the payload_ind

pause(inf)

% =================================================================
% CFO correction
% 	-- Use the first antenna to compute CFO --
% =================================================================
function [rx_ant] = cfo_correction(rx_ant, lts_ind)
global ANT_CNT FFT_OFFSET 
% Extract LTS (not yet CFO corrected)
rx_lts = rx_ant(lts_ind:lts_ind+159, 1);
rx_lts1 = rx_lts(-64+-FFT_OFFSET + [97:160]);
rx_lts2 = rx_lts(-FFT_OFFSET + [97:160]);

% Calculate coarse CFO est
rx_cfo_est_lts = mean(unwrap(angle(rx_lts1 .* conj(rx_lts2))));
rx_cfo_est_lts = rx_cfo_est_lts/(2*pi*64);

%Apply CFO correction to raw Rx waveform
rx_cfo_corr_t = exp(1i*2*pi*rx_cfo_est_lts*[0:length(rx_ant(:,1))-1]');
rx_ant = rx_ant .* repmat(rx_cfo_corr_t, 1, ANT_CNT);

% =================================================================
% initiate settings
% =================================================================
function [] = init_stat()
