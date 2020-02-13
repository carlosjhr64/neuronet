# Neuronet

* [VERSION 7.0.200213](https://github.com/carlosjhr64/neuronet/releases)
* [github](https://github.com/carlosjhr64/neuronet)
* [rubygems](https://rubygems.org/gems/neuronet)

## DESCRIPTION:

Library to create neural networks.

This is primarily a math project
meant to be used to investigate the behavior
of different small neural networks.

## INSTALL:

    gem install neuronet

## SYNOPSIS:

Note that the user really needs to read the library, neuronet.rb.
But here is a very quick usage example:

```ruby
require 'neuronet'
include Neuronet

# srand seed for this demo
srand '5o0zhyybrqn8f4kj0b7spx22zcr0cyletmz8h53vi3o2xpr4my'.to_i(36)

def random
  100.0*((rand + rand + rand) - (rand + rand + rand))
end

def rounded(values)
  values.map{|value| '%.3g' % value}
end

input_target = [
  [[random, random, random],  [random, random, random]],
  [[random, random, random],  [random, random, random]],
  [[random, random, random],  [random, random, random]],
]

# Create a 3,3,3 network
nn = ScaledNetwork.new [3, 3, 3]

# Need to set distribution
nn.distribution.set input_target.flatten

# Train...
nn.pairs(input_target) do # while
  not input_target.all?{|input, target| rounded(target) == rounded(nn*input)}
end

# Verifying the first input/target/output values
input = input_target[0][0]
target = input_target[0][1]
output = nn*input
rounded(input)  #=> ["-11", "-27.8", "-97.3"]
rounded(target) #=> ["-157", "75.1", "-108"]
rounded(output) #=> ["-157", "75.1", "-108"]
```

[There's a lot more...](https://github.com/carlosjhr64/neuronet/blob/master/MORE.md)

## LICENSE:

Copyright 2020 carlosjhr64

Permission is hereby granted, free of charge,
to any person obtaining a copy of this software and
associated documentation files (the "Software"),
to deal in the Software without restriction,
including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and
to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS",
WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
