# Neuronet 5.0.0

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

Given some set of inputs and outputs.
And a choice for the number of neurons of the middle layer, say 1+rms.
And some good choice for the learning constant, say rw(N)=1/sqrt(1+N).
Then:

	# data = [ [input, output],  ... }
	# n = input.length
	# o = output.length
	# m = 1+rms(n, o).to_i
	# l = rw(data.length)
	# Then:

	ffn = Neuronet::ScaledNetwork.new([n, m, o])
	ffn.learning = l

	# or
	# ffn = Neuronet::ScaledNetwork.new([n, m, o], l)
	# Training:

	MANY.times do
	  data.shuffle.each do |input, output|
	    ffn.reset(input)
	    ffn.train!(output)
	  end
	end # or until some small enough error

	# or
	# data.each{|input, output| ffn.exemplar(input, output)}
	# Once trained, you can set inputs and get outputs:

	require 'pp'
	while input = fromsomewhere.gets
	  ffn.reset(input)
	  pp ffn.output
	end

## Upgrades

Version 5 is not compatible with earlier versions, but
it's easy to edit a program to upgrade.
Mainly, the API no longer uses splats.
So for example, where before you might have had #method(*array), you now use #method(array).
Also, a Marshal load of a previous version will need to have the learning constant set with #learning=.
