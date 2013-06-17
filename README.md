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

The following is a dislation of notes I had from years ago...  I cite two books:

* [Neural Networks & Fuzzy Logic](http://books.google.com/books/about/C++_Neural_Networks_and_Fuzzy_Logic.html?id=WWY5AAAACAAJ)

by Dr. Valluru B. Rao and Hayagriva V. Rao (1995), and

* [Neural Computing Architectures](http://books.google.com/books?id=ixEbHQAACAAJ&dq=Neural+Computing+Architectures+edited+by+Igor+Aleksander+(1989)&hl=en&sa=X&ei=HTi_UaDpFYaayQHVm4DoBQ&ved=0CDkQ6AEwAA)

edited by Igor Aleksander (1989) which includes "A theory of neural networks" by Eduardo R. Caianiello, and
"Backpropagation in non-feedforward networks" by Luis B. Almeida.


The following is my analysis of the general mathematics of neural networks, which clarity I have not found elsewhere. 

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
