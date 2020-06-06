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
