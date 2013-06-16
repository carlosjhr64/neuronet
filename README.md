# Neuronet 5.0.0

Library to create neural networks.

* Author:	<carlosjhr64@gmail.com>
* Copyright:	2013
* License:	[GPL](http://www.gnu.org/licenses/gpl.html)
* Git Page:	<https://github.com/carlosjhr64/neuronet>

##  Installation

	gem install neuronet

## Synopsis

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

## Introduction

Neuronet is a pure Ruby 1.9, sigmoid squashed, neural network building library.
It allows one to build a network by connecting one neuron at a time, or a layer at a time,
or up to a full feed forward network that automatically scales the inputs and outputs.

I chose a TaoYinYang'ed ScaledNetwork neuronet for the synopsis because
it'll probably handle most anything you'd throw at it.
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

# RANDOM NOTES I'M STILL EDITING BELOW...

## Example: Time Series

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

I'll be using Neuronet::ScaledNetwork.
Also note that the Sine function is entirely defined within a cycle ( 2 Math::PI ) and
so parameters (particularly C) need only to be set within the cycle.
After a lot of testing, I've verified that a 
[Perceptron](http://en.wikipedia.org/wiki/Perceptron) is enough to solve the problem.
The Sine function is [Linearly separable](http://en.wikipedia.org/wiki/Linearly_separable).
Adding hidden layers needlessly adds training time, but does converge.


The gist of the
[example code](https://github.com/carlosjhr64/neuronet/blob/master/examples/sine_series.rb)
is:

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


ScaledNetwork automatically scales each input via Neuronet::Gaussian,
so the input needs to be many variables and
the output entirely determined by the shape of the input and not it's scale.
That is, two inputs that are different only in scale should
produce outputs that are different only in scale.
The input must have at least three points.

You can tackle many problems just with Neuronet::ScaledNetwork as described above.
So now that you're hopefully interested and want to go on to exactly how it all works,
I'll describe Neuronet from the ground up.

## Squashing Function

An artificial neural network uses an activation function that determines the activation value of a neuron.  This activation value is often thought of on/off or true/false.  Neuronet uses a sigmoid function to set the neuron's activation value between 1.0 and 0.0.  For classification problems, activation values near one are considered true while activation values near 0.0 are considered false.  In Neuronet I make a distinction between the neuron's activation value and it's representation to the problem.  In the case of a true or false problem, the neuron's value is either true or false, while it's activation is between 1.0 and 0.0.  This attribute, activation, need never appear in an implementation of Neuronet, but it is mapped back to it's unsquashed value every time the implementation asks for the neuron's value.

Neuronet.squash( unsquashed )
1.0 / ( 1.0 + Math.exp( -unsquashed ) )

Neuronet.unsquashed( squashed )
Math.log( squashed / ( 1.0 - squashed ) )

## Learning Constant


One can think of a neural network as a sheet of very elastic rubber which one pokes and pulls to fit the training data while otherwise keeping the sheet as smooth as possible.  You don't want to hammer this malleable sheet too hard.  One concern is that the training data may contain noise, random errors.  So the training of the network should add up the true signal in the data while canceling out the noise.  This balance is set via the learning constant.

Neuronet.default_learning
Sets the global learning constant to 0.1

Neuronet.learning
Returns the current value of the global learning constant

Neuronet.learning=( float ) # where float is greater than zero but less than one.
Sets the global learning constant by an implementation given value

I've not come across any hard rule for the learning constant.  I have my own intuition derived from the behavior of random walks.  The distance away from a starting point in a random walk is proportional to the square root of the number of steps.  I conjecture that the number of training data points is related to the optimal learning constant in the same way.  I have come across 0.2 as a good value for the learning constant, which would mean the proponent of this value was working with a data set size of about 25.  In any case, I've had good results with the following:

Neuronet.set_suggested_learning( number ) # where number is the number of data points
1.0 / Math.sqrt( number + 1.0 )

In the case of setting number to 1.0, the learning constant would be the square root of 1/2.  This would suggest that although we're taking larger steps than half steps, due to the nature of a random walk, we're approaching the solution in half steps.

## Noise

The literature I've read (probably outdated by now) would have one create a neural network with random weights and hope that training it will converge to a solution.  I've never really believed that to be a correct way.  Although the implementation is free to set all parameters for each neuron, Neuronet by default creates zeroed neurons.  Association between inputs and outputs are trained, and neurons differentiate from each other randomly.  Differentiation among neurons is achieved by noise in the back-propagation of errors.  This noise is provided by:

Neuronet.noise
rand + rand

I choose rand + rand to give the noise an average value of one and a bell shape.

## Node

A neuron is a node.  In Neuronet, Neuronet::Neuron subclasses Neuronet::Node.  A node has a value which the implementation can set.  A Node object is created via:
Neuronet::Node.new( value=0.0 )
and responds to the following methods:
value=( float )
value
to_f
to_s
The above methods work just as expected:

node = Neuronet::Node.new
a = node.value # sets a to 0.0
node.value = 1.37
b = node.value # sets b to 1.37
puts node # because to_s is called implicitly, puts sees "0.0".
c = a + node.to_f # that's c = 0.0 + 1.37

But if you look at the code for Neuronet::Node, you'll see that value is not stored, but it's calculated activation is.  The implementation can get this value via the attribute reader:
activation
In Neuronet, a node is a constant neuron whose value is not changed by training, backpropagation of errors.  It is used for inputs.  It's used as a terminal where updates and back-propagations end.  For this purpose, it provides the following methods:
train( target=nil, learning=nil ) # returns nil
backpropagate( error ) # returns nil
update # returns activation
I consider these methods private.  I can't think of a reason they'd appear in the implementation.  Likewise, the implementation should not have to bother with activation.

## Scaling The Problem

It's early to be talking about scaling the problem, but since I just covered how to set values to a node above, it's a good time to start thinking about scale.
The squashing function, sigmoid, maps real numbers (negative infinity, positive infinity) to the segment zero to one (0,1).  But for the sake of computation in a neural net, sigmoid works best if the problem is scaled to numbers between negative one and positive one (-1, 1).  Study the following table and see if you can see why:

	x  => sigmoid(x)
	9  => 0.99987...
	3  => 0.95257...
	2  => 0.88079...
	1  => 0.73105...
	0  => 0.50000...
	-1 => 0.26894...
	-2 => 0.11920...
	-3 => 0.04742...
	-9 => 0.00012...

So as x gets much higher than 3, sigmoid(x) gets to be pretty close to just 1, and as x gets much lower than -3, sigmoid(x) gets to be pretty close to 0.  Also note that sigmoid is centered about 0.5 which maps to 0.0 in problem space.  It is for this reason that I suggest the problem be displaced (subtracted) by it's average to be centered about zero and scaled (divided) by it standard deviation.  For non gaussian data where outbounds are expected, you should probably scale by a multiple of the standard deviation so that most of the data fits within sigmoid's "field of view" (-1, 1).

## Connection

This is where I think Neuronet gets it's architecture really right!  Connections between neurons (and nodes) are there own separate objects.  In other codes I've seen this is not abstracted out.  In Neuronet, a neuron contains it's bias, and a list of it's connections.  Each connection contains it's weight (strength) and connected terminal node.  Given a terminal, node, a connection is created as follows:
connection = Neuronet::Connection.new( node, weight=0.0 )
So a neuron connected to the given terminal node would have the created connection in its connections list.  This will be discussed below under the topic Neuron.  The object, connection, responds to the following methods:

value
update
backpropagate( error )
The value of a connection is the weighted activation of the node it's connected to ( weight node.activation ).  Similarly, update is the updated value of a connection, which is the weighted updated activation of the node it's connected to ( weight*node.update ).  The method update is the one to use whenever the value of the inputs are changed (or right after training).  Otherwise, both update and value should give the same result with value avoiding the unnecessary back calculations.  The method backpropagate modifies the connection's weight in proportion to the error given and passes that error to its connected node via the node's backpropagate.
I hope you're getting this and feeling a sense of eureka.  :)

## Neuron

Neuronet::Neuron is a Neuronet::Node with some extra features.  It adds two attributes: connections, and bias.  As mentioned above, connections is a list, aka Array, of the neuron's connections to other neurons (or nodes).  A neuron's bias is it's kicker (or deduction) to it's activation value as a sum of its connections values.  So a neuron's updated value is set as:

	self.value = @bias + @connections.inject(0.0){|sum,connection| sum + connection.update}

If you're not familiar with ruby's Array::inject method, it's the Ruby way of doing summations.  It's really cool once you get the gist of it.  Checkout:
Jay Field's Thoughts on Ruby: inject
Induction ( for_all )
But that's a digression...  Here's how an implementation creates a new neuron:
neuron = Neuronet::Neuron.new( bias=0.0 )
There's an attribute accessor for @bias, and an attribute reader for @connections.  The object, neuron, responds to the following methods:

	update
	partial
	backpropagate( error )
	train( target, learning=Neuronet.learning )
	connect( node, weight=0.0 )

The update method sets the neuron's value as described above.  The partial method sets the neuron's value without calling the connections update methods as follows:

	self.value = @bias + @connections.inject(0.0){|sum,connection| sum + connection.value}

It's not necessary to burrow all the way down to update the current neuron if it's connected neurons have all been updated.  The implementation should set it's algorithm to use partial instead of update as update will most likely needlessly update previously updated neurons.  The backpropagate method modifies the neuron's bias in proportion to the given error and passes on this error to each of its connection's backpropagate method.  The connect method is how the implementation adds a connection, the way to connect the neuron to another.  To connect neuron out to neuron in, for example, it is:

	in = Neuronet::Neuron.new
	out = Neuronet::Neuron.new
	out.connect(in)

Think output connects to input.  Here, the input flow would be from in to out, while back-propagation of errors flows from out to in.  If you wanted to train the value of out, out.value, to be 1.5 with the given value of in set at 0.3, you do as follows:

	puts "(#{in}, #{out})"  # what you've got before (0.0, 0.0)
	in.value = 0.3
	out.train(1.5)
	out.partial # don't forget to update (no need to go deeper than a, so partial)
	puts "(#{in}, #{out})" # (0.3, 0.113022020702079)

Note that with continued training, b should approach it's target value of 1.5.

## InputLayer

What follows next in lib/neuronet.rb's code is motivated by feedforward neural networks, and Neuronet eventually gets to build one.  Neuronet::InputLayer is an Array of Neuronet::Node's.  An input layer of a given length (number of nodes) is created as follows:
input = Neuronet::InputLayer.new( length )
The object, input, responds to a couple of methods (on top of those from Array):
set( input )
values
For example, a three neuron input layer with it's neuron values set as -1, 0, and 1:

	input = Neuronet::InputLayer(3)
	input.set( [-1, 0, 1] )
	puts input.values.join(', ') # [-1.0,0.0,1.0].join(', ')

## Layer

In Neuronet, InputLayer is to Layer what Node is to Neuron.  Layer is an Array of Neurons.  A Layer object is created as follows:

	layer = Neuronet::Layer.new( length ) # length is the number of neurons in the layer

The Layer object responds to the following methods:

	connect( layer, weight=0.0 )
	partial
	train( targets, learning=Neuronet.learning )
	values

So now one can create layers, connect them, train them, and update them (via partial).  A Perceptron is built this way:

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


## FeedForwardNetwork

Now we're building complete networks.  To create a feedforward neural network with optional middle layers, ffnn:
ffnn = Neuronet::FeedForwardNetwork.new( [input, <layer1, ...,> output], learning=Neuronet.learning )
The FeedForwardNetwork object, ffnn, responds to the following methods:

	learning=( learning_constant ) # to explicitly set a learning constant
	update
	set( inputs )
	train!( targets, learning=@learning )
	exemplar( inputs, targets, learning=@learning ) # trains an input/output pair
	values(layer) # layer's values
	input # in (first layer's) values
	output # out (last layer's) values
	And has the following attribute readers:
	in # input (first) layer
	out # output (last) layer

Notice that this time I've named the training method train! (with the exclamation mark).  This is because train! automatically does the update as well.  I thought it might be confusing that at the lower level one had to call train and either partial or update, so I made the distinction.
Neuronet also provides a convenience method exemplar to train input / output pairs.  It's equivalent the following:

ffnn.set( inputs ); ffnn.train!( targets );

## Scale

Neuronet::Scale is a class to help scale problems to fit within a network's "field of view".  Given a list of values, it finds the minimum and maximum values and establishes a mapping to a scaled set of numbers between minus one and one (-1,1).  For example:

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

One can change the range of the map to (-1/factor, 1/factor) where factor is the spread multiplier and force a (prehaps pre-calculated) value for center and spread.  The constructor is:
scale = Neuronet::Scale.new( factor=1.0, center=nil, spread=nil )
In the constructor, if the value of center is provided, then that value will be used instead of it being calculated from the values passed to method set.  Likewise, if spread is provided, that value of spread will be used.
There are two attribute accessors:

	spread
	center

One attribute writer:

	init

In the code, the attribute @init flags if there is a initiation phase to the calculation of @spread and @center.  For Scale, @init is true and the initiation phase calculates the intermediate values @min and @max (the minimum and maximum values in the data set).  It's possible for subclasses of Scale, such as Gaussian, to not have this initiation phase.
An instance, scale, of class Scale will respond to the following methods considered to be public:

	set( inputs )
	mapped_input
	mapped_output
	unmapped_input
	unmapped_output

In Scale, mapped_input and mapped_output are synonyms of mapped, but in general this symmetry may be broken.  Likewise, unmapped_input and unmapped_output are synonyms of unmapped.
Scale also provides the following methods which are considered private:

	set_init( inputs )
	set_spread( inputs )
	set_center( inputs )
	mapped( inputs )
	unmapped( outputs )

Except maybe for mapped and unmapped, there should be no reason for the implementation to call these directly.  These are expected to be overridden by subclasses.  For example, in Gaussian, set_spread calculates the standard deviation and set_center calculates the mean (average), while set_init is skipped by setting @init to false.

## Gaussian

In Neuronet, Gaussian subclasses Scale and is used exactly the same way.  The only changes are that it calculates the arithmetic mean (average) for center and the standard deviation for spread.  The following private methods are overridden to provide that effect:

	set_center( inputs )
	inputs.inject(0.0,:+) / inputs.length
	set_spread( inputs )
	Math.sqrt( inputs.map{|value| self.center - value}.inject(0.0){|sum,value| value*value + sum} / (inputs.length - 1.0) )

## LogNormal

Neuronet::LogNormal subclasses Neuronet::Gaussian to transform the values to a logarithmic scale.  It overrides the following methods:

	set( inputs )
	super( inputs.map{|value| Math::log(value)} )
	mapped(inputs)
	super( inputs.map{|value| Math::log(value)} )
	unmapped(inputs)
	super( inputs.map{|value| Math::exp(value)} )

So LogNormal is just Gaussian except that it first pipes values through a logarithm, and then pipes the output back through exponentiation.

## ScaledNetwork

So now we're back to where we started.  In Neuronet, ScaledNetwork is a subclass of FeedForwardNetwork.  It automatically scales the problem given to it by using a Scale type instance, Gaussian by default.  It adds on attribute accessor:
distribution
The attribute, distribution, is set to Neuronet::Gausian.new by default, but one can change this to Scale, LogNormal, or one's own custom mapper.
ScaledNetwork also adds one method:
reset( values )
This method, reset, works just like FeedForwardNetwork's set method, but calls distribution.set( values ) first.  Sometimes you'll want to set the distribution with the entire data set and the use set, and then there will be times you'll want to set the distribution with each input and use reset.  For example, either:

	scaled_network.distribution.set( data_set.flatten )
	data_set.each do |inputs,outputs|
  	# ... do your stuff using scaled_network.set( inputs )
	end

or:

	data_set.each do |inputs,outputs|
	# ... do your stuff using scaled_network.reset( inputs )
	end

## Pit Falls

When sub-classing a Neuronet::Scale type class, make sure mapped\_input, mapped\_output, unmapped\_input, and unmapped\_output are defined as you intended.  If you don't override them, they will point to the first ancestor that defines them.  I had a bug (in 2.0.0, fixed in 2.0.1) where I assumed overriding mapped redefined along all it's parent's synonyms... it does not work that way.
Another pitfall is confusing the input/output flow in connections and back-propagation.  Remember to connect outputs to inputs (out.connect(in)) and to back-propagate from outputs to inputs (out.train(targets)).

## Custom Networks

To demonstrate how this library can build custom networks, I've created four new classes of feed forward networks.  By the way, I'm completely making these up and was about to call them HotDog, Taco, Burrito, and Enchilada when I then thought of Tao/Yin/Yang: 
Tao

In Neuronet, Tao is a three or more layered feed forward neural network with it's output and input connected directly.  It effectively makes it a hybrid perceptron.  It subclasses ScaledNetwork.
Yin

In Neuronet, Yin is a Tao with the first hidden layer, hereby called yin, initially set to have corresponding neuron pairs with it's input layer's with weights set to 1.0 and bias 0.5.  This makes yin initially mirror the input layer.  The correspondence is done between the first  neurons in the yin layer and the input layer.

## Yang

In Neuronet, Yang is a Tao with it's output layer connected to the last hidden layer, hereby called yang,  such that corresponding neuron pairs have weights set to 1.0 and bias 0.5.  This makes output initially mirror yang.  The correspondence is done between the last neurons in the yang layer and the output layer.
YinYang

In Neuronet, YinYang is a Tao that's been Yin'ed Yang'ed.  :))  
That's a feed forward network of at least three layers with its output layer also connected directly to the input layer, and with the output layer initially mirroring the last hidden layer, and the first hidden layer initially mirroring the input layer.  Note that a particularly interesting YinYang with n inputs and m outputs would be constructed this way:

	yinyang = Neuronet::YinYang.new( [n, n+m, m] )

Here yinyang's hidden layer (which is both yin and yang) initially would have the first n neurons mirror the input and the last m neurons be mirrored by the output.  Another interesting YinYang would be:

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


## Notes I had on my old ynot2day

My sources are Neural Networks & Fuzzy Logic by Dr. Valluru B. Rao and Hayagriva V. Rao (1995), and Neural Computing Architectures edited by Igor Aleksander (1989) which includes "A theory of neural networks" by Eduardo R. Caianiello and "Backpropagation in non-feedforward networks" by Luis B. Almeida. The following is my analysis of the general mathematics of neural networks, which clarity I have not found elsewhere. 

First, let me define my notation. I hate to reinvent the wheel (well, actually, it is kind of fun to do so), but I do not know the standard math notation when using straight ASCII typed from a normal keyboard. So I define the notation for sumation, differentiation, the sigmoid function, and the exponential function given as Exp{}. Indexes to vectors and arrays are bracketed with []. Objects acted on by functions are bracketed by {}. Grouping of variables/objects is achieved with (). I also use () to include parameters that modify a function.

Definition of Sum:

Sum(j=1 to 3){A[j]} = A[1]+A[2]+A[3] 
Sum(i=0 to N){f[i]} = f[i]+...+f[N]

Definition of Dif:

Dif(x){x^n} = n*x^(n-1) 
Dif(y){f{u}} = Dif(u){f{u}}*Dif(y){u}

Definition of Sig:

Sig{z} = 1/(1+Exp{-z})

Next, I describe a mathematical model of a neuron. Usually a neuron is described as being either on or off. I believe it more usefull to describe a neuron as having a pulse rate. A boolean (true or false) neuron would either have a high or a low pulse rate. In absence of any stimuli from neighbohring neurons, the neuron may also have a rest pulse rate. The rest pulse rate is due to the the bias of a neuron. A neuron receives stimuli from other neurons through the axons that connect them. These axons communicate to the receiving neuron the pulse rates of the transmitting neurons. The signal from other neurons are either strengthen or weakened at the synapse, and might either inhibit or excite the receiving neuron. The sum of all these signals is the activation of the receiving neuron. The activation of a neuron determines the neuron's actual response (its pulse rate), which the neuron then transmits to other neurons through its axons. Finally, a neuron has a maximum pulse rate which I map to 1, and a minimum pulse rate of 0.

Let the bias of a neuron be b[], the activation, y[], the response, x[], and the weights, w[,]. The pulse rate of a receiving neuron, r, is related to its activation which is related to the pulse rates of the other transmitting neurons, t, by the following equations:

x[r] = Sig{ y[r] } 
y[r] = b[r] + Sum(All t){ w[r,t] * x[t] } 
x[r] = Sig{ b[r] + Sum(All t){w[r,t] * x[t]} }

Next I try to derive the learning rule of the neural network. Somehow, a neuron can be trained to become more or less sensitive to stimuli from another neuron and to become more or less sensitive in general. That is, we can change the neuron's bias and synaptic weights. To do it right, I need an estimate of the error in the neuron's pulse and relate this to the correction needed in the bias and each synaptic weight. This type of error analysis is usually aproximated through differentiation. What is the error in the pulse rate due to an error in a synaptic weight?

Dif(w[r,t]){x[r]} = Dif(y[r]){Sig{y[r]}}*Dif(w[r,t]){y[r]}} 

Dif(z){Sig{z}} = -Exp{-z}/(1+Exp{-z})^2 
= (1-1-Exp{-z})/(1+Exp{-z})^2 
= (1-(1+Exp{-z}))/(1+Exp{-z})^2 
= 1/(1+Exp{-z})^2 - 1/(1+Exp{-z}) 
= Sig{z}^2 - Sig{z} 
= Sig{z}*(Sig{z}-1)  # <== THIS HAS TO BE WRONG! Looking for D{f}=f(1-f)

Dif(y[r]){Sig{y[r]}} = Sig{y[r]}*(Sig{y[r]}-1) = 
= x[r]*(x[r]-1) 

Dif(w[r,t]){y[r]} = Dif(w[r,t]){Sum(t){w[r,t]*x[t]}} = x[t] 

Dif(w[r,t]){x[r]} = x[r] * (x[r]-1) * x[t]

Let X[r] be the correct pulse rate. The error in the pulse rate is the difference between the correct value and the actual computation, e[r]=X[r]-x[r]. Let dx[r,t] be the error in x[r] due to weight w[r,t]. Consider that dx[r,t]/dw[r,t] aproximates Dif(w[r,t]){x[r]}.

dx[r,t]/dw[r,t] = Dif(w[r,t]){x[r]} 
dx[r,t] = x[r] * (x[r]-1) * x[t] * dw[r,t]

Then e[r] is the sum of all errors, dx[r,t].

e[r] = Sum(t){ dx[r,t] } = 
= Sum(t=1 to N){ x[r]*(x[r]-1)*x[t]*dw[r,t] }

Straight Algebra thus far. Now the tricky part... I have related the error in a neuron's pulse to the sum of the errors in the neurons receiving synapses. What I really want is to relate it to a particular synapse. This information is lost in the sum, and I must rely on statistical chance. Let me first pretend I know that the error partitions itself among the synapses with distribution u[i,j].

e[r] = Sum(t=1 to N){ u[r,t] e[r] } 
u[r,t] * e[r] = x[r] * (x[r]-1) * x[t] * dw[r,t]

The average value of u[r,t] is probably 1/N. In any case, the point is that this average is a small number less than 1. We use an equi-partition hypothesis and assume that each dw[r,t] is equally likely to be the source of error. Let u[r,t] ~ u, a small number, for all r and t. The best estimate of dw[r,t] becomes:

u * e[r] = x[r] * (x[r]-1) * x[t] * dw[r,t] 
dw[r,t] = u * e[r] / ( x[r] * (x[r]-1) * x[t] ) ???

If u~1/N was not tricky, then consider this. x[] is meant to converge to either 0 or 1. That is x[] is meant to be boolean. Note how the above equation for dw[i,j] could not really work if x[] truly were 0 or 1. But x[] is a fuzzy variable never really achieving 0 or 1.

How do I conclude that... dw[r,t]=u * x[r] * (1-x[r]) * x[t] * e[r] ...which is the correct learning rule?

This is the part of the Neural Net jargon I have not been able to bring to my level. I believe the answer is buried in what is being called transposition of linear networks. My analysis is correct up to this:

u * e[r] = x[r] * (x[r]-1) * x[t] * dw[r,t]

This equation relates the error in the pulse of neuron to the error in the synaptic weight between the transmiting neuron, t, and the receiving neuron, r. I believe the transposition of linear networks states that the relationship remains the same when back propagating the error in the neural pulse to the the synaptic weight. That is, we do not invert the multiplication factor. This seems intuitive, but I admit I am confused by the paradox in the algebra above. Thus...

The Learning Rule for the (0,1) sigmoid neuron 
dw[r,t] = x[r] * (x[r]-1) * x[t] * u * e[r]

The derivation for the correction to the bias is analogous. Note that the x[t] factor does not appear in this case.

db[r] = Dif(b[r]){x[r]} * u * e[r] 
= x[r]*(x[r]-1)*Dif(b[r]){br} * u * e[r] = x[r]*(x[r]-1)*1 * u * e[r] 
db[r] = x[r]*(x[r]-1) * u * e[r]

I was able to arrive at an estimate to the correction needed for the output neuron's synaptic weight and bias. I knew what the output was suppose to be, X[r], and the actual computation, x[r]. The error of the output neuron, e[r], was X[r]-x[r]. But what if the neuron was not an output neuron? I need to propagate back the error of the output neuron (and later for the general receiving neuron) to each of its transmitting neuron. The error of a transmitting neuron is assigned to be the sum of all errors propagated back from all of its receiving neurons.

e[t] = Sum(r){ x[r] * (x[r]-1) * x[t] * u * e[r] }

Then, when we get to adjusting the transmitting neuron we will have an estimate of its pulse error. These are the learning equations for the general neural network:

dw[r,t] = Dif(w[r,t]){x[r]} * u * e[r] 
db[r] = Dif(b[r]){x[r]} * u * e[r]

The above equations give the correction to the synaptic weight and neural bias once we are given the error in a neuron. Next, we need to propagate back the known errors in the output through the network.

e[t] = X[t] - x[t] if the i'th neuron is also the output. 
e[t] = Sum(r){ w[r,t] * e[r] * Dif(b[r]){x[r]} } for the rest.

Note how I sent the errors from the receiving neurons to the transmitting neuron. I hope this explains the theory well. I distilled it from the above sources.


## Notes from reading neuronet

For some Neuronet::FeedForward object, obj:

	obj.output
	obj.out.values
	obj.out.map{|node| node.to_f}
	obj.out.map{|node| node.value}
	obj.out.map{|node| unsquash(node.activation)}
	obj.out.map{|node| bias+connections }

	O[i] = b + Sum(1,J){|j| W[i,j] Squash(I[j])}

	100 +/- 1 = 50 + sum[1,50]{|j| w[i,j]I[j]}
	de = 1/100
	b += b*de

If we say that the value of some output is

	Output[o] = Bias[o] + Sum{ Connection[m,o] }

has some error E

	Target[o] = Output[o] + E

Then there is an e such that

	Output[o](1+e) = Output[o] + E
	  (1+e) = (Output[o] + E)/Output[o]
	  1+e = 1 + E/Output[o]
	  e = E/Output[o]

And Target can be set as

	Target[o] = (Bias[o] + Sum{ Connection[m,o] })(1+e)
	Target[o] = Bias[o](1+e) + Sum{ Connection[m,o] }(1+e)

Assumping equipartition in error,
we might then suggest the following correction to Bias:

	Bias[o] = Bias[o](1+e)
	  Bias[o] = Bias[o]+Bias[o]e
	  Bias[o] += Bias[o]e


	Remember that:
	D{squash(u)} = squash(u)*(1-squash(u))*D{u}

	@activation = squash( @bias + @connections...)
	D{ @activation } = D{ squash( @bias + @connections...) }
	D{ @activation } = @activation*(1-@activation) D{ @bias + @connections... }
	Just the part due to bias...
	D.bias{ @activation } = @activation*(1-@activation) D{ @bias }
	D.bias{ @activation } / (@activation*(1-@activation)) = D{ @bias }
	Just the part due to connection...
	D.connection{ @activation } = @activation*(1-@activation) D{ @connections... }

	D
