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
