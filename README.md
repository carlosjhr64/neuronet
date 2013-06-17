# Neuronet 6.0.1

Library to create neural networks.

* Author:	<carlosjhr64@gmail.com>
* Copyright:	2013
* License:	[GPL](http://www.gnu.org/licenses/gpl.html)
* Git Page:	<https://github.com/carlosjhr64/neuronet>

#  Installation

	gem install neuronet

# Synopsis

Given some set of inputs and targets that are Array's of Float's.
Then:

	# data = [ [input, target],  ... }
	# n = input.length
	# t = target.length
	# m = n + t
	# l = data.length
	# Then:
	# Create a general purpose neurnet

	neuronet = Neuronet::ScaledNetwork.new([n, m, t])

	# "Bless" it as a TaoYinYang,
	# a perceptron hybrid with the middle layer
	# initially mirroring the input layer and
	# mirrored by the output layer.

	Neuronet::TaoYinYang.bless(neuronet)

	# The following sets the learning constant
	# to something I think is reasonable.

	neuronet.num(l)

	# Start training

	MANY.times do
	  data.shuffle.each do |input, target|
	    neuronet.exemplar(input, target)
	  end
	end # or until some small enough error

	# See how well the training went

	require 'pp'
	data.each do |input, target|
	  puts "Input:"
	  pp input
	  puts "Output:"
	  neuronet.reset(input) # sets the input values
	  pp neuronet.output # gets the output values
	  puts "Target:"
	  pp target
	end

# Introduction

Neuronet is a pure Ruby 1.9, sigmoid squashed, neural network building library.
It allows one to build a network by connecting one neuron at a time, or a layer at a time,
or up to a full feed forward network that automatically scales the inputs and outputs.

I chose a TaoYinYang'ed ScaledNetwork neuronet for the synopsis because
it will probably handle most anything with 3 or more input variables you'd throw at it.
But there's a lot you can do to the data before throwing it at a neuronet.
And you can build a neuronet specifically to solve a particular kind of problem.
Properly transforming the data and choosing the right neuronet architecture
can greatly reduce the amount of training time the neuronet will require.
A neuronet with the wrong architecture for a problem will be unable to solve it.
Raw data without hints as to what's important in the data will take longer to solve.

As an analogy, think of what you can do with linear regression.
Your raw data might not be linear, but if a transform converts it to a linear form,
you can use linear regression to find the best fit line, and
from that deduce the properties of the untransformed data.
Likewise, if you can transform the data into something the neuronet can solve,
you can by inverse get back the answer you're lookin for.

# Example: Time Series

First, a little motivation...
A common use for a neural-net is to attempt to forecast future set of data points
based on past set of data points, [Time series](http://en.wikipedia.org/wiki/Time_series).
To demonstrate, I'll train a network with the following function:

	f(t) = A + B sine(C + D t), t in [0,1,2,3,...]

I'll set A, B, C, and D to some random number and see
if eventually the network can predict the next set of values based on previous values.
I'll try:

	[f(n),...,f(n+19)] => [f(n+20),...,f(n+24)]

That is... given 20 consecutive values, give the next 5 in the series.
There is no loss, and probably greater generality,
if I set at random the phase (C above), so that for any given random phase we want:

	[f(0),...,f(19)] => [f(20),...,f(24)]

I'll be using [Neuronet::ScaledNetwork](http://rubydoc.info/gems/neuronet/Neuronet/ScaledNetwork).
Also note that the Sine function is entirely defined within a cycle ( 2 Math::PI ) and
so parameters (particularly C) need only to be set within the cycle.
After a lot of testing, I've verified that a 
[Perceptron](http://en.wikipedia.org/wiki/Perceptron) is enough to solve the problem.
The Sine function is [Linearly separable](http://en.wikipedia.org/wiki/Linearly_separable).
Adding hidden layers needlessly adds training time, but does converge.


The gist of the
[example code](https://github.com/carlosjhr64/neuronet/blob/master/examples/sine_series.rb)
is:

	...
	# The constructor
	neuronet = Neuronet::ScaledNetwork.new([INPUTS, OUTPUTS])
	...
	# Setting learning constant
	neuronet.num(1.0)
	...
	# Setting the input values
	neuronet.reset(input)
	...
	# Getting the neuronet's output
	output = neuronet.output
	...
	# Training the target
	neuronet.train!(target)
	...

Heres a sample output:

	f(phase, t) = 3.002 + 3.28*Sin(phase + 1.694*t)
	Cycle step = 0.27

	Iterations:	1738
	Relative Error (std/B): 0.79%	Standard Deviation: 0.026
	Examples:

	Input:	0.522, 1.178, 5.932, 4.104, -0.199, 2.689, 6.28, 2.506, -0.154, 4.276, 5.844, 1.028, 0.647, 5.557, 4.727, 0.022, 2.011, 6.227, 3.198, -0.271
	Target:	3.613, 6.124, 1.621, 0.22, 5.069
	Output:	3.575, 6.101, 1.664, 0.227, 5.028

	Input:	5.265, 5.079, 0.227, 1.609, 6.12, 3.626, -0.27, 3.184, 6.229, 2.024, 0.016, 4.716, 5.565, 0.656, 1.017, 5.837, 4.288, -0.151, 2.493, 6.28
	Target:	2.703, -0.202, 4.091, 5.938, 1.189
	Output:	2.728, -0.186, 4.062, 5.931, 1.216

	Input:	5.028, 0.193, 1.669, 6.14, 3.561, -0.274, 3.25, 6.217, 1.961, 0.044, 4.772, 5.524, 0.61, 1.07, 5.87, 4.227, -0.168, 2.558, 6.281, 2.637
	Target:	-0.188, 4.153, 5.908, 1.135, 0.557
	Output:	-0.158, 4.112, 5.887, 1.175, 0.564


ScaledNetwork automatically scales each input via
[Neuronet::Gaussian](http://rubydoc.info/gems/neuronet/Neuronet/Gaussian),
so the input needs to be many variables and
the output entirely determined by the shape of the input and not it's scale.
That is, two inputs that are different only in scale should
produce outputs that are different only in scale.
The input must have at least three points.

You can tackle many problems just with
[Neuronet::ScaledNetwork](http://rubydoc.info/gems/neuronet/Neuronet/ScaledNetwork)
as described above.
So now that you're hopefully interested and want to go on to exactly how it all works,
I'll describe Neuronet from the ground up.

# STILL EDITING. MOVED A LOT INTO RDOC.

Stuff To Say...

Think output connects to input.
Here, the input flow would be from in to out,
while back-propagation of errors flows from out to in.
If you wanted to train the value of out, out.value,
to be 1.5 with the given value of in set at 0.3, you do as follows:

	puts "(#{in}, #{out})"  # what you've got before (0.0, 0.0)
	in.value = 0.3
	out.train(1.5)
	out.partial # don't forget to update (no need to go deeper than a, so partial)
	puts "(#{in}, #{out})" # (0.3, 0.113022020702079)

Note that with continued training, b should approach it's target value of 1.5.


For example, a three neuron input layer with it's neuron values set as -1, 0, and 1:

	input = Neuronet::InputLayer(3)
	input.set( [-1, 0, 1] )
	puts input.values.join(', ') # [-1.0,0.0,1.0].join(', ')

A Layer object is created as follows:

	# length is the number of neurons in the layer
	layer = Neuronet::Layer.new( length )

So now one can create layers, connect them, train them, and update them (via partial).
A Perceptron is built this way:

	n, m = 3, 3 # building a 3X3 perceptron
	input_layer = Neuronet::InputLayer.new( n )
	output_layer = Neuronet::Layer.new( m )
	output_layer.connect( input_layer )
	# to set the perceptron's input to -0.5,0.25,2.1...
	input_layer.set( [-0.5, 0.25, 2.1] )
	# to train it to -0.1, 0.2, 0.5
	output_layer.train( [-0.1, 0.2, 0.5] )
	output_layer.partial # update!
	# to see its values
	puts output_layer.values.join(', ')



Now we're building complete networks.
To create a feedforward neural network with optional middle layers, ffnn:

	ffnn = Neuronet::FeedForwardNetwork.new([input, <layer1, ...,> output])


Notice that this time I've named the training method train! (with the exclamation mark).
This is because train! automatically does the update as well.
I thought it might be confusing that at the lower level one had to call train and
either partial or update, so I made the distinction.
Neuronet also provides a convenience method exemplar to train input / output pairs.
It's equivalent the following:


Scale

For example:

	scale = Neuronet::Scale.new
	values = [ 1, -3, 5, -2 ]
	scale.set( values )
	mapped = scale.mapped( values )
	puts mapped.join(', ') # 0.0, -1.0, 1.0, -0.75
	puts scale.unmapped( mapped ).join(', ') # 1.0, -3.0, 5.0, -2.0

The mapping is like:

	center = (maximum + minimum) / 2.0 if center.nil? # calculate center if not given
	spread = (maximum - minimum) / 2.0 if spread.nil? # calculate spread if not given
	inputs.map{ |value|   (value - center) / (factor * spread) }

One can change the range of the map to (-1/factor, 1/factor)
where factor is the spread multiplier and force
a (prehaps pre-calculated) value for center and spread.
The constructor is:

	scale = Neuronet::Scale.new( factor=1.0, center=nil, spread=nil )

In the constructor, if the value of center is provided, then
that value will be used instead of it being calculated from the values passed to method set.
Likewise, if spread is provided, that value of spread will be used.

So LogNormal is just Gaussian except that it first pipes values through a logarithm, and
then pipes the output back through exponentiation.

ScaledNetwork


For example, either:

	scaled_network.distribution.set( data_set.flatten )
	data_set.each do |inputs,outputs|
  	# ... do your stuff using scaled_network.set( inputs )
	end

or:

	data_set.each do |inputs,outputs|
	# ... do your stuff using scaled_network.reset( inputs )
	end

Pit Falls

When sub-classing a Neuronet::Scale type class,
make sure mapped\_input, mapped\_output, unmapped\_input,
and unmapped\_output are defined as you intended.
If you don't override them, they will point to the first ancestor that defines them.
I had a bug (in 2.0.0, fixed in 2.0.1) where
I assumed overriding mapped redefined along all it's parent's synonyms...
it does not work that way.
Another pitfall is confusing the input/output flow in connections and back-propagation.
Remember to connect outputs to inputs (out.connect(in)) and
to back-propagate from outputs to inputs (out.train(targets)).


Custom Networks

To demonstrate how this library can build custom networks,
I've created four new classes of feed forward networks.
By the way, I'm completely making these up and was about to call them
HotDog, Taco, Burrito, and Enchilada when I then thought of Tao/Yin/Yang: 

Say something about why "bless".
It's a *prototype* pattern.

In Neuronet, YinYang is a Tao that's been Yin'ed Yang'ed.  :))  
That's a feed forward network of at least three layers with
its output layer also connected directly to the input layer, and
with the output layer initially mirroring the last hidden layer, and
the first hidden layer initially mirroring the input layer.
Note that a particularly interesting YinYang with n inputs and m outputs
would be constructed this way:

	yinyang = Neuronet::YinYang.new( [n, n+m, m] )

Here yinyang's hidden layer (which is both yin and yang)
initially would have the first n neurons mirror the input and
the last m neurons be mirrored by the output.
Another interesting YinYang would be:

	yinyang = Neuronet::YinYang.new( [n, n, n] )

The following code demonstrates what is meant by "mirroring":

	yinyang = Neuronet::YinYang.new( [3, 3, 3] )
	yinyang.reset( [-1,0,1] )
	puts yinyang.in.map{|x| x.activation}.join(', ')
	puts yinyang.yin.map{|x| x.activation}.join(', ')
	puts yinyang.out.map{|x| x.activation}.join(', ')
	puts yinyang.output.join(', ')

Here's the output:

	0.268941421369995, 0.5, 0.731058578630005
	0.442490985892539, 0.5, 0.557509014107461
	0.485626707638021, 0.5, 0.514373292361979
	-0.0575090141074614, 0.0, 0.057509014107461

## Questions?

Email me.

# Theory

## The Biological Description of a Neuron

Usually a neuron is described as being either on or off.
I think it is more useful to describe a neuron as having a pulse rate.
A neuron would either have a high or a low pulse rate.
In absence of any stimuli from neighbohring neurons, the neuron may also have a rest pulse rate.
A neuron receives stimuli from other neurons through the axons that connects them.
These axons communicate to the receiving neuron the pulse rates of the transmitting neurons.
The signal from other neurons are either strengthen or weakened at the synapse, and
might either inhibit or excite the receiving neuron.
Regardless of how much stimuli the neuron gets,
a neuron has a maximum pulse it cannot exceed.

## The Mathematical Model of a Neuron

Since my readers here are probably Ruby programmers, I'll write the math in a Ruby-ish way.
Allow me to sum this way:

	module Enumerable
	  def sum
	    map{|a| yield(a)}.inject(0, :+)
	  end
	end
	[1,2,3].sum{|i| 2*i} == 2+4+6 # => true

Can I convince you that taking the derivative of a function looks like this?

	def d(x)
	  dx = SMALL
	  f = yield(x)
	  (yield(x+dx) - f)/dx
	end
	dfdx = d(a){|x| f(x)}

So the Ruby-ish way to write one of the rules of Calculus is:

	d{|x| Ax^n} == nAx^(n-1)

We won't bother distinguishing integers from floats.
The sigmoid function is:

	def sigmoid(x)
	  1/(1+exp(-x))
	end
	sigmoid(a) == 1/(1+exp(a))

A neuron's pulserate increases with increasing stimulus, so
we need a model that adds up all the stimuli a neuron gets.
The sum of all stimuli we will call the neuron's value.
(I find this confusing, but
it works out that it is this sum that will give us the problem space value.)
To model the neuron's rest pulse, we'll say that it has a bias value, it's own stimuli.
Stimuli from other neurons comes through the connections, so there is a sum over all the connections.
The stimuli from other transmitting neurons is be proportional to their own pulsetates and
the weight the receiving neuron gives them.
In the model we will call the pulserate the neuron's activation.
Lastly, to more closely match the code, a neuron is a node.
This is what we have so far:

	value = bias + connections.sum{|connection| connection.weight * connection.node.activation }

	# or by their biological synonyms

	stimulus = unsquashed_rest_pulse_rate +
	  connections.sum{|connection| connection.weight * connection.neuron.pulserate}

Unsquashed rest pulse rate?  Yeah, I'm about to close the loop here.
As described, a neuron can have a very low pulse rate, effectively zero,
and a maximum pulse which I will define as being one.
The sigmoid function will take any amount it gets and squashes it to a number between zero and one,
which is what we need to model the neuron's behavior.
To get the node's activation (aka neuron's pulserate) from the node's value (aka neuron's stimulus),
we squash the value with the sigmoid function.

	# the node's activation from it's value
	activation = sigmoid(value)

	# or by their biological synonyms

	# the neuron's pulserate from its stimulus
	pulserate = sigmoid(stimulus)

So the "rest pulse rate" is sigmoid("unsquashed rest pulse rate").

There's a lot of really complicated math in understanding how neural networks work.
But if we concentrate on just the part pertinent to the bacpkpropagation code, it's not that bad.
The trick is to do the analysis in the problem space (otherwise things get real ugly).
When we train a neuron, we want the neuron's value to match a target as closely as possible.
The deviation from the target is the error:

	error = target - value

Where does the error come from?
It comes from deviations from the ideal bias and weights the neuron should have.

	target = value + error
	target = bias + bias_error +
	  connections.sum{|connection| (connection.weight + weight_error) * connection.node.activation }
	error = bias_error + connections.sum{|connection| weight_error * connection.node.activation }

Next we assume that the errors are equally likely everwhere,
so that the bias error is expected to be same on average as weight error.
That's where the learning constant comes in.
We need to divide the error equally among all contributors, say 1/N.
Then:

	error = error/N + connections.sum{|connection| error/N * connection.node.activation }

Note that if the equation above represents the entire network, then

	N = 1 + connections.length

So now that we know the error, we can modify the bias and weights.

	bias += error/N
	connection.weight += connection.node.activation * error/N

The Calculus is:

	d{|bias| bias + connections.sum{|connection| connection.weight * connection.node.activation }}
	  == d{|bias| bias}

	d{|connection.weight| bias + connections.sum{|connection| connection.weight * connection.node.activation }}
	  == connection.node.activation * d{|weight| connection.weight }

So what's all the ugly math you'll see elsewhere?
Well, you can try to do the above analysis in neuron space.
Then you're inside the squash function.
I'll just show derivative of the sigmoid function:

	d{|x| sigmoid(x)} ==
	  d{|x| 1/(1+exp(-x))} ==
	  1/(1+exp(-x))^2 * d{|x|(1+exp(-x)} ==
	  1/(1+exp(-x))^2 * d{|x|(exp(-x)} ==
	  1/(1+exp(-x))^2 * d{|x| -x}*exp(-x) ==
	  1/(1+exp(-x))^2 * (-1)*exp(-x) ==
	  -exp(-x)/(1+exp(-x))^2 ==
	  (1 -1 - exp(-x))/(1+exp(-x))^2 ==
	  (1 - (1 + exp(-x)))/(1+exp(-x))^2 ==
	  (1 - 1/sigmoid(x)) * sigmoid^2(x) ==
	  (sigmoid(x) - 1) * sigmoid(x) ==
	  sigmoid(x)*(sigmoid(x) - 1)
	# =>
	d{|x| sigmoid(x)} == sigmoid(x)*(sigmoid(x) - 1)

From there you try to find the errors from the point of view of the activation instead of the value.
But as the code clearly shows, the analysis need not get this deep.

## Learning Constant

One can think of a neural network as a sheet of very elastic rubber
which one pokes and pulls to fit the training data while
otherwise keeping the sheet as smooth as possible.
One concern is that the training data may contain noise, random errors.
So the training of the network should add up the true signal in the data
while canceling out the noise.  This balance is set via the learning constant.


	neuronet.learning
	# Returns the current value of the network's learning constant

	neuronet.learning = float
	# where float is greater than zero but less than one.
	# Sets the global learning constant by an implementation given value

I've not come across any hard rule for the learning constant.
I have my own intuition derived from the behavior of random walks.
The distance away from a starting point in a random walk is
proportional to the square root of the number of steps.
I conjecture that the number of training data points is related to
the optimal learning constant in the same way.
I have come across 0.2 as a good value for the learning constant, which
would mean the proponent of this value was working with a data set size of about 25.
In any case, I've had good results with the following:

	# where number is the number of data points
	neuronet.learning( number )
	1.0 / Math.sqrt( number + 1.0 )

In the case of setting number to 1.0,
the learning constant would be the square root of 1/2.
This would suggest that although we're taking larger steps than half steps,
due to the nature of a random walk, we're approaching the solution in half steps.

## Scaling The Problem

The squashing function, sigmoid, maps real numbers (negative infinity, positive infinity)
to the segment zero to one (0,1).
But for the sake of computation in a neural net,
sigmoid works best if the problem is scaled to numbers
between negative one and positive one (-1, 1).
Study the following table and see if you can see why:

	 x => sigmoid(x)
	 9 => 0.99987...
	 3 => 0.95257...
	 2 => 0.88079...
	 1 => 0.73105...
	 0 => 0.50000...
	-1 => 0.26894...
	-2 => 0.11920...
	-3 => 0.04742...
	-9 => 0.00012...

As x gets much higher than 3, sigmoid(x) gets to be pretty close to just 1, and
as x gets much lower than -3, sigmoid(x) gets to be pretty close to 0.
Note that sigmoid is centered about 0.5 which maps to 0.0 in problem space.
It is for this reason that I suggest the problem be displaced (subtracted)
by it's average to be centered about zero and scaled (divided) by it standard deviation.
Try to get most of the data to fit within sigmoid's central "field of view" (-1, 1).
