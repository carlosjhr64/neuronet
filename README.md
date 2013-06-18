# Neuronet 6.0.1

Library to create neural networks.

* Gem:		<https://rubygems.org/gems/neuronet>
* Git:		<https://github.com/carlosjhr64/neuronet>
* Author:	<carlosjhr64@gmail.com>
* Copyright:	2013
* License:	[GPL](http://www.gnu.org/licenses/gpl.html)

##  Installation

	gem install neuronet

## Synopsis

Given some set of inputs (of at least length 3) and
targets that are Array's of Float's.  Then:

	# data = [ [input, target],  ... }
	# n = input.length # > 3
	# t = target.length
	# m = n + t
	# l = data.length
	# Then:
	# Create a general purpose neuronet

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
	    neuronet.reset(input)
	    neuronet.train!(target)
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

## Introduction

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

As an analogy, think of what you can do with
[linear regression](http://en.wikipedia.org/wiki/Linear_regression).
Your raw data might not be linear, but if a transform converts it to a linear form,
you can use linear regression to find the best fit line, and
from that deduce the properties of the untransformed data.
Likewise, if you can transform the data into something the neuronet can solve,
you can by inverse get back the answer you're lookin for.

# Examples

## Time Series

A common use for a neural-net is to attempt to forecast future set of data points
based on past set of data points, [Time series](http://en.wikipedia.org/wiki/Time_series).
To demonstrate, I'll train a network with the following function:

	f(t) = A + B sine(C + D t), t in [0,1,2,3,...]

I'll set A, B, C, and D with random numbers and see
if eventually the network can predict the next set of values based on previous values.
I'll try:

	[f(n),...,f(n+19)] => [f(n+20),...,f(n+24)]

That is... given 20 consecutive values, give the next 5 in the series.
There is no loss, and probably greater generality,
if I set at random the phase (C above), so that for any given random phase we want:

	[f(0),...,f(19)] => [f(20),...,f(24)]

I'll be using [Neuronet::ScaledNetwork](http://rubydoc.info/gems/neuronet/Neuronet/ScaledNetwork).
Also note that the Sine function is entirely defined within a cycle ( 2 Math::PI ) and
so parameters (particularly C) need only to be set within this cycle.
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

# Component Architecture

## Nodes and Neurons

[Nodes](http://rubydoc.info/gems/neuronet/Neuronet/Node)
are used to set inputs while
[Neurons](http://rubydoc.info/gems/neuronet/Neuronet/Neuron)
are used for outputs and middle layers.
It's easy to create and connect Nodes and Neurons.
You can assemble custom neuronets one neuron at a time.
Too illustrate, here's a simple network that adds two random numbers.

	require 'neuronet'
	include Neuronet

	def random
	  rand - rand
	end

	# create the input nodes
	a = Node.new
	b = Node.new

	# create the output neuron
	sum = Neuron.new

	# and a neuron on the side
	adjuster = Neuron.new

	# connect the adjuster to a and b
	adjuster.connect(a)
	adjuster.connect(b)

	# connect sum to a and b
	sum.connect(a)
	sum.connect(b)
	# and to the adjuster
	sum.connect(adjuster)

	# The learning constant is about...
	learning = 0.1

	# Train the tiny network
	10_000.times do
	  a.value = x = random
	  b.value = y = random
	  target = x+y
	  output = sum.update
	  sum.backpropagate(learning*(target-output))
	end

	# Let's see how well the training went
	10.times do
	  a.value = x = random
	  b.value = y = random
	  target = x+y
	  output = sum.update
	  puts "#{x.round(3)} + #{y.round(3)} = #{target.round(3)}"
	  puts "  Neuron says #{output.round(3)}, #{(100.0*(target-output)/target).round(2)}% error."
	end


Here's a sample output:

	0.003 + -0.413 = -0.41
	  Neuron says -0.413, -0.87% error.
	-0.458 + 0.528 = 0.07
	  Neuron says 0.07, -0.45% error.
	0.434 + -0.125 = 0.309
	  Neuron says 0.313, -1.43% error.
	-0.212 + 0.34 = 0.127
	  Neuron says 0.131, -2.83% error.
	-0.364 + 0.659 = 0.294
	  Neuron says 0.286, 2.86% error.
	0.045 + 0.323 = 0.368
	  Neuron says 0.378, -2.75% error.
	0.545 + 0.901 = 1.446
	  Neuron says 1.418, 1.9% error.
	-0.451 + -0.486 = -0.937
	  Neuron says -0.944, -0.77% error.
	-0.008 + 0.219 = 0.211
	  Neuron says 0.219, -3.58% error.
	0.61 + 0.554 = 1.163
	  Neuron says 1.166, -0.25% error.

Note that the tiny neuronet has a limit on how precisely it can match the target, and
even after a million times training it won't do any beter than when it trains a few thousands.
[code](https://github.com/carlosjhr64/neuronet/blob/master/examples/neurons.rb)


## InputLayer and Layer

Instead of working with individual neurons, you can work with layers.
Here we build a [Perceptron](http://en.wikipedia.org/wiki/Perceptron):

	in = InputLayer.new(9)
	out = Layer.new(1)
	out.connect(in)

When making connections keep in mind "outputs connects to inputs",
not the other way around.
You can set the input values and update this way:

	in.set([1,2,3,4,5,6,7,8,9])
	out.partial

Partial means the update wont travel further than the current layer,
which is all we have in this case anyways.
You get the output this way:

	output = out.output # returns an array of values

You train this way:

	target = [1] #<= whatever value you want in the array
	learning = 0.1
	out.train(target, learning)

## FeedForward Network

Most of the time, you'll just use a network created with the
[FeedForward](http://rubydoc.info/gems/neuronet/Neuronet/FeedForward) class,
or a modified version or subclass of it.
Here we build a neuronet with four layers.
The input layer has four neurons, and the output has three.
Then we train it with a list of inputs and targets
using the method [#exemplar](http://rubydoc.info/gems/neuronet/Neuronet/FeedForward:exemplar):

	neuronet = Neuronet::FeedForward.new([4,5,6,3])
	LIST.each do |input, target|
	  neuronet.exemplar(input, target)
	  # you could also train this way:
	  # neuronet.set(input)
	  # neuronet.train!(target)
	end

The first layer is the input layer and the last layer is the output layer.
Neuronet also names the second and second last layer.
The second layer is called yin.
The second last layer is called yang.
For the example above, we can check their lengths.

	puts neuronet.in.length #=> 4
	puts neuronet.yin.length #=> 5
	puts neuronet.yang.length #=> 6
	puts neuronet.out.length #=> 3
	
## Tao, Yin, and Yang

Tao
:	The absolute principle underlying the universe,
	combining within itself the principles of yin and yang and
	signifying the way, or code of behavior,
	that is in harmony with the natural order.

Perceptrons are already very capable and quick to train.
By connecting the input layer to the output layer of a multilayer FeedForward network,
you'll get the Perceptron solution quicker while the middle layers work on the harder problem.
You can do that this way:

	neronet.out.connect(neuronet.in)

But giving that a name, [Tao](http://rubydoc.info/gems/neuronet/Neuronet/Tao),
and using a prototype pattern to modify the instance is more fun:

	Tao.bless(neuronet)

Yin
:	The passive female principle of the universe, characterized as female and
	sustaining and associated with earth, dark, and cold.

Initially FeedForward sets the weights of all connections to zero.
That is, there is no association made from input to ouput.
Changes in the inputs have no effect on the output.
Training begins the process that sets the weights to associate the two.
But you can also manually set the initial weights.
One useful way to initially set the weigths is to have one layer mirror another.
The [Yin](http://rubydoc.info/gems/neuronet/Neuronet/Yin) bless makes yin mirror the input.

	Yin.bless(neuronet)

Yang
:	The active male principle of the universe, characterized as male and
	creative and associated with heaven, heat, and light.

One the other hand, the [Yang](http://rubydoc.info/gems/neuronet/Neuronet/Yang)
bless makes the output mirror yang.

	Yang.bless(neuronet)

Bless
:	Pronounce words in a religious rite, to confer or invoke divine favor upon.

The reason Tao, Yin, and Yang are not classes onto themselves is that
you can combine these, and a protoptype pattern (bless) works better in this case.
Bless is the keyword used in [Perl](http://www.perl.org/) to create objects,
so it's not without precedent.
To combine all three features, Tao, Yin, and Yang, do this:

	Tao.bless Yin.bless Yang.bless neuronet

To save typing, the library provides the possible combinations.
For example:

	TaoYinYang.bless neuronet

# Scaling The Problem

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

## Scale, Gaussian, and Log Normal

Neuronet provides three classes to help scale the problem space.
[Neuronet::Scale](http://rubydoc.info/gems/neuronet/Neuronet/Scale)
is the simplest most straight forward.
It finds the range and center of a list of values, and
linearly tranforms it to a range of (-1,1) centered at 0.
For example:

	scale = Neuronet::Scale.new
	values = [ 1, -3, 5, -2 ]
	scale.set( values )
	mapped = scale.mapped( values )
	puts mapped.join(', ') # 0.0, -1.0, 1.0, -0.75
	puts scale.unmapped( mapped ).join(', ') # 1.0, -3.0, 5.0, -2.0

The mapping is the following:

	center = (maximum + minimum) / 2.0 if center.nil? # calculate center if not given
	spread = (maximum - minimum) / 2.0 if spread.nil? # calculate spread if not given
	inputs.map{ |value|   (value - center) / (factor * spread) }

One can change the range of the map to (-1/factor, 1/factor)
where factor is the spread multiplier and force
a (perhaps pre-calculated) value for center and spread.
The constructor is:

	scale = Neuronet::Scale.new( factor=1.0, center=nil, spread=nil )

In the constructor, if the value of center is provided, then
that value will be used instead of it being calculated from the values passed to method set.
Likewise, if spread is provided, that value of spread will be used.

[Neuronet::Gaussian](http://rubydoc.info/gems/neuronet/Neuronet/Gaussian)
works the same way, except that it uses the average value of the list given
for the center, and the standard deviation for the spread.

And [Neuronet::LogNormal](http://rubydoc.info/gems/neuronet/Neuronet/LogNormal)
is just like Gaussian except that it first pipes values through a logarithm, and
then pipes the output back through exponentiation.

## ScaledNetwork

[Neuronet::ScaledNetwork](http://rubydoc.info/gems/neuronet/Neuronet/ScaledNetwork)
automates the problem space scaling.
You can choose to do your scaling over the entire data set if you think
the relative scale of the individual inputs matter.
For example if in the problem one apple is good but two is to many...
In that case do this:

	scaled_network.distribution.set( data_set.flatten )
	data_set.each do |inputs,outputs|
  	# ... do your stuff using scaled_network.set( inputs )
	end

If on the other hand the scale of the individual inputs is not the relevant feature,
you can you your scaling per individual input.
For example a small apple is an apple, and so is the big one.  They're both apples.
Then do this:

	data_set.each do |inputs,outputs|
	# ... do your stuff using scaled_network.reset( inputs )
	end

Note that in the first case you are using
[#set](http://rubydoc.info/gems/neuronet/Neuronet/ScaledNetwork:set)
and in the second case you are using
[#reset](http://rubydoc.info/gems/neuronet/Neuronet/ScaledNetwork:reset).

# Pit Falls

When sub-classing a Neuronet::Scale type class,
make sure mapped\_input, mapped\_output, unmapped\_input,
and unmapped\_output are defined as you intended.
If you don't override them, they will point to the first ancestor that defines them.
Overriding #mapped does not piggyback the aliases and
they will continue to point to the original #mapped method.

Another pitfall is confusing the input/output flow in connections and back-propagation.
Remember to connect outputs to inputs (out.connect(in)) and
to back-propagate from outputs to inputs (out.train(targets)).

# Interesting Custom Networks

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

## Backpropagation of Errors

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

Next we assume that the errors are equally likely everywhere,
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

# Questions?

Email me!
