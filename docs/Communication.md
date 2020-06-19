# Class Communication()
---
Takes the following arguments:
- Number of bits to transmit.
- Symbol Duration //TODO
- Number of subcarriers //TODO
- Type of fading //TODO
- Signal power // Gotta have a way to vary SNR for the BER curve

The communication class is the simulation engine. Ideally doesn't result in any screen output, only data structure and algorithms.

### Initialization
The constructor creates all communication elements, essentially running the entire simulation to conclusion. Individual class documentation to follow.

!!! caution Note
MATLAB class files are ... odd. Ideally, I'd put the methods inside the `classdef` block and I'll try to find a way, but for now, I'm using the file isolation to isolate the methods... which incidentally aren't inside the class. weird, huh?
!!!

So far there's no algorithmic magic inside Communication, that's in the other elements. Heck, I'm even going to create an evaluator class to avoid making the engine do anything other than create objects. If I can achieve stack overflow I will brag about it and then kill myself with a blunt spoon.

##### Changelog 19/06/2020
Hmmm ... My humor is wasted on these docs seeing as I'm the only one reading them, and writing them :grimacing:. We move regardless. At present, the communication system is functional ona fundamental level. It takes the following parameters:

`bitCount`
: This gets passed to the `DataSource()` class. If the purpose of that class is lost on you, just fuck right off.
`ofdmVariant`
: This is a steal on a major scale for me. Basically, it's a vector of characters defining the subcarrier mapping of the OFDM variant to be used. Needless to say, it makes for excellent flexibility. The guard interval and cyclic prefix department could profit immensely from such an improvement.
`symbolTime`
: Another big steal. These were issues I was griping about now becoming my strengths. If you can't figure what this is, just go away.
`centerFreq`
: This is a problem at the moment. The program functions as it does because the carrier frequency is actually fc/(2*pi). I don't wanna talk about it.
`samplingInterval`
: This is and ADC/DAC parameter, I think. Uncertain because I've called that term `Dt` everywhere else.
`channelType`
: A string (the immutable type) stating the type of channel to be simulated.
`sigAmp`
: The signal absolute gain. I had a noise gain entry, then I thought it was gratuitous and removed it. Not sure it even got to a commit.
`speculardB`
: This is a Rician Fading special, though I'm considering rolling Rayleigh into it as well. 'Tis a matter of setting a certain variable to zero or otherwise.
