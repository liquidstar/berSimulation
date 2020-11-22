# Main
---
#### Update 26-07-2020
Due to matters of prudence in memory utilization, most of this had to be rewritten. The transmitter was taking up 1.2 GiB of RAM. That's a single instance. So, that has been changed. There is only one `Transmitter()` instance. And it holds a bare minimum of attributes. Naturally the `Communication()` class has been deprecated as a matter of expediency. It held too many failed hopes. In its place is `Transmission()`.

Something else is new. Now all CLI elements are being handled by `Interface()` class. I'll admit I feel a little proud of the outcome. That is until the venerable supervisor decides to throw another test at it that completely fails. Hopefully that is not going to happen.

A major functional plus: *Now Cyclic prefix and Guard Interval* are programmable variables. I hadn't realized just how much the simulation had been designed for IEEE 802.11. But now it genuinely fits its own description ... simulation of an **OFDM Variant** hah.

##### Note
This script calls all Interface.m, which collects and validates user input. Then it does:
	- Sets the range of SNRs to be simulated.
	- Sets the channel models to be simulated.
	- Initializes transmitter()
	- Initializes the evaluator()
	- Creates transmission() for each SNR
	- Saves simulation data to a file.
