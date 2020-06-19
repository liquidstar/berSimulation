# DataSource()
---
Takes the arguments:
- `bitCount`

I feel like there should be more but oh well. As long as it works. Should generate a row vector of `bitCount` elements. Simple, right?

### Testing
---
I'm feeling self righteous so I intent to evaluate my work on the fly, or even before the fly when I finally get the gift of foresight. (It'll come, lil' dog, it'll come...)
- Check that `bitCount` matches the passed argument. (:unamused:duh!)
- Check that the vector contains only ones and zeros. I'm electing to be fully pedantic. EVerything follows literature review, so mapping comes after parallel conversion.

##### Update 19/06/2020
I'm tempted to put the functionality of reading an actual file. To our supervisor, dull code and graphs suffice, but I'll be selling to a multitude which might include Mr. Oloo. That's a secondary concern, however. For that, the `main.m` interface becomes fairly complex.
