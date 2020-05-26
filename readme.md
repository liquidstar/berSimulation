# Overdue Readme
---
So I've finally decided to start working. This isn't the proudest I've been of myself. This needs to get done.

### Directory structure
---
You'll notice theres a 'deprecated/' directory. That was before I felt cool and decided to go OOP. But I strongly feel OOP will make life easier, that is when I'm finally accustomed to typing `comm.transmitter.parData` a thousand times. Notice the weird directory name '+ofdm/'. That shouldn't be changed. It's referenced in the code. It's how I call all other classes from within the communication class. It occurs to me that I should explain how I intend it all to work.

### Program structure
---
The big idea is to create a communication instance (object) whose properties are the component objects of the OFDM communication system. That is `comm = Communication(args, ...)` will end up creating the following:
- A `DataSource(bitCount)`
- A `Transmitter(args, ...)`
- A `Channel(args, ...)`
- A `Receiver(args, ...)`
- An `Evaluator(args, ...)`

Functionality is entirely dependent on the stage of completion. But scaffolding will ideally be ever present. That's what I'm telling myself to excuse my needless delays. It's probably wiser to create a separate 'docs/' directory to go into details.

