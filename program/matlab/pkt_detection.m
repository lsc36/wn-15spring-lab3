function [lts_ind payload_ind] = pkt_detection(rx_ant, THRESH_LTS_CORR)
LTS_LEN = 160;

% Long preamble (LTS) for CFO and channel estimation
lts_f = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1];
lts_t = ifft(lts_f, 64);

d_lts_t = repmat(lts_t,1,4);
maxc = -inf;
strip = rx_ant(32:end - 32);
for i = 1:(length(strip) - 255)
    xc = corr(d_lts_t,strip(i:i + 255));
    if real(xc) > maxc
	maxc = real(xc);
	off = i - 1;
    end
end;

maxc
assert(maxc >= THRESH_LTS_CORR);

lts_ind = off;
payload_ind = off + 64 * 4 + 32 * 2;

% Hint 1:
% Complex cross correlation of Rx waveform with time-domain LTS 

% Skip early and late samples
%lts_corr = lts_corr(32:end-32);

% Hint 2:
% Get the lts_ind and payload_ind
% Don't forget that "You have skip early and late samples"
