### Simulation of BER for OFDM Variant in a Fading Channel
---

This code runs a simulation for an OFDM communication system derived from IEEE 802.11. The code is mostly single use but in my wiser moments some life saving generalizations were made so crafting an API out of it should be short work ('Tis my pride and joy) should soumeone feel so inclined.

##### How to run
That's easy. Run `main.m` in MATLAB. That's actually easier than trying to understand `Interface.m`.
- It'll ask you for the number of transmit bits. This one's your choice, based on your available RAM (and patience)
- Next it'll ask you for the OFDM variant to simulate. Option 3 is the interesting one to which we will return shortly.
- Finally it'll ask for K in dB. This is the log of the ratio of *peak specular (line-of-sight) power* to *multi-path power*. Any number is acceptable.

Then you'll get a lovely figure containing the BER curves, and the BER data should be saved to `simData.mat`. This becomes important later when we go curve-fitting.

##### Custom Variant
Choosing this option will allow you to set the following OFDM parameters:
- Sub-carrier configuration (placement of data, virtual and pilot sub-carriers)
- Cyclic prefix
- Guard Interval
- Symbol duration
- Nominal center frequency

You'll notice that there are two passband features among what's being configured here. Yes, at some point in the project's history, passband transmission was being simulated, but that feature has been superficially regressed for these reasons (I love my itemized lists):
- Crazy memory usage (I could barely simulate 2E5 bits without crashing MATLAB on 8GiB. Getting 'Out of memory' was a relief)
- BER performance was identical.
- Passband simulation wasn't explicitly stated in our project scope.

Regardless, passband was quite the learning experience. The curious aren't *outrightly* discouraged. Passband features can be easily activated by some slight tweaking of `Interface.m`.

### Curve Fitting
---
Mmmkay ... This is difficult to confess. Curves were fitted manually. You'll find that story on `curveFit.m`. There's room for improvement, but inspiration came about the same time as the deadline. The accompanying `scriptCurveFit.m` plots the theoretical curves against the simulated. The interesting one was Rician fitting being the fluid little thing that it is thanks to K.

##### Rician fitting
The manner in which this was achieved:
- Got BER curves for integer Ks from 0 to 10.
- Manually fitted Q functions to these curves.
- Curve fitted the Q function coefficients against K to get a fluid(?) function for Rician BERs.

The full report will be linked ... somewhere. 
