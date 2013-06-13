# Neuronet 5.0.0.alpha.2

Library to create neural networks.

This is **Gold** software, as I understand the
[software release life cycle](http://en.wikipedia.org/wiki/Software_release_life_cycle),
unless of course you find a bug I don't about.

* Author:	<carlosjhr64@gmail.com>
* Copyright:	2013
* License:	[GPL](http://www.gnu.org/licenses/gpl.html)
* Git Page:	<https://github.com/carlosjhr64/neuronet>
* Tutorial:	<https://sites.google.com/site/carlosjhr64/rubygems/neuronet>

##  Installation

	gem install neuronet

## Synopsis

Given some set of inputs and outputs, and
a choice for the number of neurons of the middle layer(say rms), and
some good choice for the learning constant (say rw(N)=1/sqrt(1+N)):

	# data = [ [inputs, outputs],  ... }
	# input = inputs.length
	# output = outputs.length
	# middle = rms(input, output).to_i
	# learning = rw(data.length)
	# Then:

	ffn = Neuronet::ScaledNetwork.new([input, middle, output])
	ffn.learning = learning

	# or
	# ffn = Neuronet::ScaledNetwork.new([input, middle, output], learning)
	# Training:

	data.each do |input, output|
	  ffn.set(input)
	  ffn.train!(output)
	end

	# or
	# data.each{|input, outpu| ffn.exemplar(input, output)}
	# Once trained, you can set inputs and get outputs:

	require 'pp'
	while input = fromsomewhere.gets
	  ffn.set(input)
	  pp ffn.output
	end
