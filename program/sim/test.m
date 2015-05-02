addpath("/usr/local/share/itpp/");

itload("rayleigh_test.it")
size(ch_coeffs)
figure(1); clf;
semilogy(abs(ch_coeffs(1:200)))

pause(inf);
