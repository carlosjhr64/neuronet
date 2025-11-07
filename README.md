# Neuronet

* [VERSION 8.0.251107](https://github.com/carlosjhr64/neuronet/releases)
* [github](https://www.github.com/carlosjhr64/neuronet)
* [rubygems](https://rubygems.org/neuronet)

## DESCRIPTION

Library to create neural networks.

Features perceptron, MLP, and deep feed forward networks.
Uses a logistic squash function.

## INSTALL
```console
$ gem install neuronet
```
* Required Ruby version: `>= 3.4`

## SYNOPSIS

The library is meant to be read, but here are some quick bits:
```ruby
require 'neuronet'

# Perceptron
# It can mirror, equivalent to "copy":
np = Neuronet::Perceptron.new(3, 3)
np.output_layer.mirror
values = np * [-1, 0, 1] #=> [-1.0, 0.0, 1.0]
# It can anti-mirror, equivalent to "not":
np.output_layer.mirror(-1)
values = np * [-1, 0, 1] #=> [1.0, 0.0, -1.0]

# MPL: Multi-Layer(3) Perceptron
# It can "and".
# In this example, NoisyMiddleNeuron is needed to differentiate the neurons:
mlp = Neuronet::MLP.new(2, 4, 1,
                        middle_neuron: Neuronet::NoisyMiddleNeuron)
mlp.output_layer.average
nju = mlp.expected_nju.ceil.to_f #=> 4.0
pairs = [
  [[1, 1], [1]],
  [[-1, 1], [-1]],
  [[1, -1], [-1]],
  [[-1, -1], [-1]],
]
while pairs.any? { |input, target| (mlp * input).map(&:round) != target }
  mlp.pairs(pairs, nju) # Training...
end
(mlp * [1, 1]).map(&:round)   #=> [1]
(mlp * [-1, 1]).map(&:round)  #=> [-1]
(mlp * [1, -1]).map(&:round)  #=> [-1]
(mlp * [-1, -1]).map(&:round) #=> [-1]

# To export to a file:
#     mlp.export_to_file(filename)
# To import from a file:
#     mlp.import_from_file(filename)
# These will export/import the network's biases and weights.
```
## HELP

When reading the library, this is order the order I would read it:

* [Neuron](lib/neuronet/neuron.rb)
* [Layer](lib/neuronet/layer.rb)
* [Feed Forward](lib/neuronet/feed_forward.rb)

Once you understand these files, the rest should all make sense.
For some math on neural networks,
see the [Wiki](https://github.com/carlosjhr64/neuronet/wiki).

## LICENSE

Copyright (c) 2025 CarlosJHR64

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

## [CREDITS](CREDITS.md)
