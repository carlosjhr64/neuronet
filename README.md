# Neuronet

* [VERSION 7.0.230323](https://github.com/carlosjhr64/neuronet/releases)
* [github](https://github.com/carlosjhr64/neuronet)
* [rubygems](https://rubygems.org/gems/neuronet)

## DESCRIPTION:

Library to create neural networks.

This is primarily a math project meant to be used to investigate the behavior of
different small neural networks.

## INSTALL:
```console
gem install neuronet
```
## SYNOPSIS:

The library is meant to be read, but here is a motivating example:
```ruby
require 'neuronet'
include Neuronet
# TODO: highly motivating example...
```
## CONTENTS:

* [Neuronet wiki](https://github.com/carlosjhr64/neuronet/wiki)

### Base

* [Requires and autoloads](lib/neuronet.rb)
* [Constants and lambdas](lib/neuronet/constants.rb)
* [Connection](lib/neuronet/connection.rb)
* [Neuron](lib/neuronet/neuron.rb)
* [Layer](lib/neuronet/layer.rb)
* [FeedForward](lib/neuronet/feed_forward.rb)

### Scaled

* [Scale](lib/neuronet/scale.rb)
* [Gaussian](lib/neuronet/gaussian.rb)
* [LogNormal](lib/neuronet/log_normal.rb)
* [ScaledNetwork](lib/neuronet/scaled_network.rb)

### Mods

* [Tao](lib/neuronet/tao.rb)
* [Yin](lib/neuronet/yin.rb)
* [Yang](lib/neuronet/yang.rb)
* [Brahma](lib/neuronet/brahma.rb)
* [Vishnu](lib/neuronet/vishnu.rb)
* [Shiva](lib/neuronet/shiva.rb)
* [Summa](lib/neuronet/summa.rb)
* [Sintezo](lib/neuronet/sintezo.rb)
* [Synthesis](lib/neuronet/synthesis.rb)

### Composites

* [YinYang](lib/neuronet/yin_yang.rb)
* [TaoYinYang](lib/neuronet/tao_yin_yang.rb)
* [NeoYinYang](lib/neuronet/neo_yin_yang.rb)
* [BranmaSynthesis](lib/neuronet/brahma_synthesis.rb)

## LICENSE:

Copyright 2023 CarlosJHR64

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
