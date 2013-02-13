# comptus

## Description
A library for calculating the date of the Easter.

## Dependencies
Ruby 1.8 or later

## License
MIT License (see ./LICENSE)

## Example
```ruby
require 'computus'

# the Easter of 2013
Computus::easter(2013)
#=> 2013-03-31 12:00:00 UTC

# the Pascha of 2013 (Julian calendar)
Computus::pascha(2013)
#=> 2013-04-22 12:00:00 UTC

# the Pascha of 2013 (Gregorian calendar)
Computus::pascha(2013) + Computus::gj_diff(2013) * 86400
#=> 2013-05-05 12:00:00 UTC
```

## Documentation
*   see ./doc/index.html

