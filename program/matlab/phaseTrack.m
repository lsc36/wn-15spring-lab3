function rx_out = phaseTrack(rx_in, tx_in, cf)
    % figure(cf) can use to plot process of phaseTrack
    % TODO

    rx_buf = rx_in;
    tx_buf = tx_in;

    % hint 1: find your pilot index according to signal_generator.m
    % >> pilot_idx = ___;

    pilot_idx = [8 22 44 58];   %Pilot subcarrier indices
    ph_pilot = rx_buf(pilot_idx) ./ tx_buf(pilot_idx);

    line = polyfit(transpose(pilot_idx - 32),angle(ph_pilot),1);
    fix = line * [(-31:32);ones(1,64)];
    rx_out = rx_buf .* transpose(exp(-(1i * fix)));

    plot(rx_buf(pilot_idx),'o');
    plot(rx_out(pilot_idx),'or');

    % hint 2: the phase shift is linear!
    %         there is a matlab function called "regress"
    % phase_shift is in unit [radian] 
    % phase_shift_regressed = ___ ;  % should be complex values!!

    % hint 3: Use phase_shift_regressed to remove SFO
    % rx_out = rx_in ./ ...
end
