# Channel()
---
Takes the following parameters:
	- Transmitter object
	- SNR value in dB
	- K in dB
	- Channel Model
Channel model determines the treatment to which the transmitter signal(found in the object) will be subjected. In detail:

### type = "gauss"
Additive white Gaussian Noise is added. The Gaussian distribution describes a population with a variance of 1 and mean of zero. The noise is complex as it also introduces phase drift.
It's additive, so it's directly added to the signal and gives the receiver a bad day.

### type = "rayl"
The Rayleigh Probability density function describes the distribution of the magnitudes of complex random Gaussian variables. This makes it quite simple to model, since we're being honest.

### type = "rice"
This is a messier version of the Rayleigh distribution, made so by the non-centrality introduced by K. le sigh ... Why can't I type math here? Know what? just copy this stuff into a TeX compiler:
So we have the non-centrality parameter *s*:
$$s = \sqrt{\frac{K}{K+1}}$$
$$\sigma = \frac{1}{K+1}$$
Taking $\alpha + j\beta$ as a vector of complex random Gaussian distributed variables, Rician fading is modeled as:
$$\text{Rician} = s + \sigma (\text{Rayleigh})$$

###### Note
For each of the fadings, the fading coefficient is multiplied by the transmitted signal, and **then** AWGN is effected onto them.
