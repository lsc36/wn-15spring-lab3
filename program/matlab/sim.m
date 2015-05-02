%{
SEGMENT_START = 1;

rx = read_complex_binary(['../trace/recv_signal.bin']);

rx = rx(SEGMENT_START:SEGMENT_START+4800 - 1);
rx_ant = rx;
itsave(['../sim/sig.it'],'rx',rx);

itload('../sim/simout.it')
simrx = simrx(SEGMENT_START:SEGMENT_START+4800 - 1);

cf = 1;
figure(cf,'Position',[16,16,1600,900]);
plot(real(simrx).^2);
hold on;
plot(real(rx).^2,'r');
raw_title = sprintf( 'Raw Signals %d', i );
title(raw_title);

pause(inf);
%}

function simrx = sim()
addpath("/usr/local/share/itpp/");
itload('../sim/simout.it')
