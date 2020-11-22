# Receiver()
---
This class and Transmitter have suffered most heavily from regression of the passband features. But the infrastructure will remain as a monument to entropy, and for the benefit of anyone who inherits it.

It contains information about the OFDM variant, and the channel transfer function (for equalization). The events from the entry of the signal into the receiver are:
	- Channel Equalization
	- Stripping of guard interval and cyclic prefix
	- FFT operation (Demultiplexing)
	- Pilot synchronization
	- BPSK demodulation
This is the one class I feel I might have over-programmed. With the benefit of hindsight, attempting to detect the guard interval might be too much for an undergrad project. But I'm me. It just needs the supervisor's scrutiny. If it passes, all is well.
