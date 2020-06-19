# Transmitter()
---
Currently working on it so chill.
Broad strokes:
- Takes Serial Data
- Converts to Parallel
- Maps to symbol alphabet
- Add virtual carriers
- IFFT each sample vector

Mapping means to an actual sampled sinusoid, and symbol interval will fix subcarrier spacing ... yay. :cold_sweat: Looks like I might need some LaTeX math to help me dance along.

##### Changelog 19/06/2020
The changes have been immense. So I guess I'll document the interface. Heh :unamused: ... fun. The constructor method takes the following arguments:
- `serData`: Serial data from the data source
- `ofdmVariant`: That string used to set carrier mapping.
- `symbolTime`: Duh!
- `centerFreq`: Presently a problem. I'll make that a `TODO:`
- `samplingInterval`: Useful timing parameter for ADC and DAC
- `sigAmp`: Signal absolute gain

The constructor boasts the following methods:

`mapBits(serBits)`
: Maps bits to their corresponding symbols. Thankfully we're working with BPSK. Aside from error rate, I don't see how other techniques would make a difference.
: Returns `serBauds`

`makeParallel(serBauds, subCarrierConfig)`
: Parallels the serial bauds into as many streams as the number of data subcarriers in the chosen OFDM variant.
: Returns `parBauds`

`binBauds(parBauds, ofdmVariant)`
: Rearranges `parBauds` into the correct FFT bins.
: Returns as `binData`

`ofdmMux(binData)`
: On the surface, 'tis one of the more complex functions, but thanks to minimum uncertainty at this stage, is quite simple. Essentially performs the IFFT operation, then adds cyclic prefix and guard interval.
: Returns `baseBandOfdmSig`, the complex OFDM signal with fading protection.

`dac(baseBandOfdmSig, symbolTime, symbCount, samplingInterval)`
: This is one of the more complex functions that just happens to work right so you avoid touching it as much as possible. The function extracts the *In-phase* and *Quadrature* components then converts them into analog signals.
: Returns `baseBandAnalogI`, `baseBandAnalogQ`, and `analogTimeBase`

`freqUpScale(baseBandAnalogI, baseBandAnalogQ, fc, t, Dt, sigAmp)`
: Stop asking stupid questions. It upscales frequency through frequency mixing. The *In-phase* component is multiplied by a sinusoid that's a quadrant out of phase with that by which the *Quadrature* component is multiplied. The two are then added and taken through a High pass filter. This function has a problem with very high center frequencies as might have been mentioned in another doc. I don't know ... I'm tired.
: Returns `passBandSig`
