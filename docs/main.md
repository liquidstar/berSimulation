# Main
---
Here, I document the interface, which depending on my level of ambition will either be a couple of console prompts or a full blown MATLAB app. I'm frankly more interested in the latter, though I am certain that I'd have to go it alone. :smirk: Tell me something new, lol.

#### Update 26-07-2020
Due to matters of prudence in memory utilization, most of this had to be rewritten. The transmitter was taking up 1.2 GiB of RAM. That's a single instance. So, that has been changed. There is only one `Transmitter()` instance. And it holds a bare minimum of attributes. Naturally the `Communication()` class has been deprecated as a matter of expediency. It held too many failed hopes. In its place is `Transmission()`.

Something else is new. Now all CLI elements are being handled by `Interface()` class. I'll admit I feel a little proud of the outcome. That is until the venerated supervisor decided to throw another test at it that completely fails. Hopefully that is not going to happen.

A major functional plus: *Now Cyclic prefix and Guard Interval* are programmable variables. I hadn't realized just how much the simulation had been designed for IEEE 802.11. But now it genuinely fits its own description ... simulation of an **OFDM Variant** hah. With hindsight, I'm shocked at how we managed to get away with such a vague title. I suppose a lecturer's sponsorship goes a long way.
