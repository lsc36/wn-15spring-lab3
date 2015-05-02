#include <itpp/itcomm.h>
using namespace itpp;
int main()
{
	/*TDL_Channel my_channel;
	double norm_dopp = 0.1;
	my_channel.set_norm_doppler(norm_dopp);
	int nrof_samples = 10000;
	cmat ch_coeffs;
	my_channel.generate(nrof_samples, ch_coeffs);
	it_file ff("rayleigh_test.it");
	ff << Name("ch_coeffs") << ch_coeffs;
	ff.close();*/

	it_file ff;
	cvec sig,out;

	ff.open("sig.it");
	ff >> Name("rx") >> sig;
	ff.close();
	
	TDL_Channel rayleigh_ch;
	double norm_dopp = 0.0002;
	rayleigh_ch.set_norm_doppler(norm_dopp);
	out = rayleigh_ch.filter(sig);
	std::cout << out << std::endl;

	it_file of("simout.it");
	of << Name("simrx") << out;
	of.close();

	return 0;
}

