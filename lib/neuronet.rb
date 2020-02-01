# Neuronet module
module Neuronet
  VERSION = '7.0.200201'
  FORMAT  = '%.14g'

  # An artificial neural network uses a squash function
  # to determine the activation value of a neuron.
  # The squash function for Neuronet is the
  # [Sigmoid function](http://en.wikipedia.org/wiki/Sigmoid_function)
  # which sets the neuron's activation value between 1.0 and 0.0.
  # This activation value is often thought of on/off or true/false.
  # For classification problems, activation values near one are considered true
  # while activation values near 0.0 are considered false.
  # In Neuronet I make a distinction between the neuron's activation value and
  # it's representation to the problem.
  # This attribute, activation, need never appear in an implementation of Neuronet, but
  # it is mapped back to it's unsquashed value every time
  # the implementation asks for the neuron's value.
  # One should scale the problem with most data points between -1 and 1,
  # extremes under 2s, and no outbounds above 3s.
  # Standard deviations from the mean is probably a good way to figure the scale of the problem.
  SQUASH = lambda do |unsquashed|
    1.0 / (1.0 + Math.exp(-unsquashed))
  end
  UNSQUASH = lambda do |squashed|
    Math.log(squashed / (1.0 - squashed))
  end

  # I'll want to have a neuron mirror a node later.
  # I derive BZERO and WONE in README.md, but
  # the point here is that values -1, 0, and 1 map back to themselves:
  #   BZERO + WONE*SQUASH[-1.0] #=> -1.0
  #   BZERO + WONE*SQUASH[0.0]  #=> 0.0
  #   BZERO + WONE*SQUASH[1.0]  #=> 1.0
  BZERO = 1.0/(1.0-2.0*SQUASH[1.0])
  WONE  = -2.0*BZERO

  # Although the implementation is free to set all parameters for each neuron,
  # Neuronet by default creates zeroed neurons.
  # Association between inputs and outputs are trained, and
  # neurons differentiate from each other randomly.
  # Differentiation among neurons is achieved by noise in the back-propagation of errors.
  # This noise is provided by rand + rand.
  # I chose rand + rand to give the noise an average value of one and a bell shape distribution.
  NOISE = lambda{|error| error*(rand + rand)}

  # One may choose not to have noise.
  NO_NOISE = IDENTITY = lambda{|error| error}

  class << self; attr_accessor :squash, :unsquash, :bzero, :wone, :noise, :format; end
  self.squash   = SQUASH
  self.unsquash = UNSQUASH
  self.bzero    = BZERO
  self.wone     = WONE
  self.noise    = NOISE
  self.format   = FORMAT

  # In Neuronet, there are two main types of objects: Nodes and Connections.
  # A Node has a value which the implementation can set.
  # A plain Node instance is used primarily as input neurons, and
  # its value is not changed by training.
  # It is a terminal for backpropagation of errors.
  # Nodes are used for the input layer.
  class Node
    class <<self; attr_accessor :label; end
    Node.label = 'a'

    attr_reader :activation, :label
    # A Node is constant (Input)
    alias :update  :activation
    alias :partial :activation

    # The "real world" value of a node is the value of it's activation unsquashed.
    # So, set the activation to the squashed real world value.
    def value=(value)
      @activation = Neuronet.squash[value]
    end

    def initialize(value=0.0)
      self.value = value
      @label = Node.label and Node.label = Node.label.succ
    end

    # The "real world" value is stored as a squashed activation.
    # So for value, return the unsquashed activation.
    def value
      Neuronet.unsquash[@activation]
    end

    # Node is a terminal where backpropagation ends.
    def backpropagate(error, noise=nil)
      # to be over-ridden
      self
    end

    def inspect
      "(#{@label}:" + (Neuronet.format % self.value) + ')'
    end

    def to_s
      "(#{@label}:" + (Neuronet.format % self.value) + ')'
    end
  end

  # Connections between neurons (and nodes) are there own separate objects.
  # In Neuronet, a neuron contains it's bias, and a list of it's connections.
  # Each connection contains it's weight (strength) and connected node.
  class Connection
    attr_accessor :node, :weight
    def initialize(node, weight=0.0)
      @node, @weight = node, weight
    end

    # The value of a connection is the weighted activation of the connected node.
    def value
      @node.activation * @weight
    end

    # Connection#update returns the updated value of a connection,
    # which is the weighted updated activation of
    # the node it's connected to ( weight * node.update ).
    # This method is the one to use
    # whenever the value of the inputs are changed (right after training).
    # Otherwise, both update and value should give the same result.
    # Use Connection#value when back calculations are not needed instead.
    def update
      @node.update * @weight
    end

    # TODO: added purely on symmetry, but what's the use case?
    def partial
      @node.partial * @weight
    end

    # Connection#backpropagate modifies the connection's weight
    # in proportion to the error given and passes that error
    # to its connected node via the node's backpropagate method.
    def backpropagate(error, mu, noise=Neuronet.noise)
      @weight += @node.activation * noise[error/mu]
      @node.backpropagate(error)
      self
    end

    def inspect
      (Neuronet.format % @weight) + @node.inspect
    end

    def to_s
      (Neuronet.format % @weight) + @node.to_s
    end
  end

  # A Neuron is a Node with some extra features.
  # It adds two attributes: connections, and bias.
  # The connections attribute is a list of
  # the neuron's connections to other neurons (or nodes).
  # A neuron's bias is it's kicker (or deduction) to it's activation value,
  # a sum of its connections values.
  class Neuron < Node
    attr_reader :connections
    attr_accessor :bias
    def initialize(value=0.0, bias: 0.0, connections: [])
      super(value)
      @connections = connections
      @bias = bias
    end

    # Updates the activation with the current value of bias and updated values of connections.
    def update
      self.value = @bias + @connections.inject(0.0){|sum, connection| sum + connection.update}
    end

    # For when connections are already updated,
    # Neuron#partial updates the activation with the current values of bias and connections.
    # It is not always necessary to burrow all the way down to the terminal input node
    # to update the current neuron if it's connected neurons have all been updated.
    # The implementation should set it's algorithm to use partial
    # instead of update as update will most likely needlessly update previously updated neurons.
    def partial
      self.value = @bias + @connections.inject(0.0){|sum, connection| sum + connection.value}
    end

    # The backpropagate method modifies
    # the neuron's bias in proportion to the given error and
    # passes on this error to each of its connection's backpropagate method.
    # While updates flows from input to output,
    # back-propagation of errors flows from output to input.
    def backpropagate(error, noise=Neuronet.noise)
      # Adjusts bias according to error and...
      mu = 1.0 + @connections.length
      @bias += noise[error/mu]
      # backpropagates the error to the connections.
      @connections.each{|connection| connection.backpropagate(error, mu, noise)}
      self
    end

    # Connects the neuron to another node.
    # Updates the activation with the new connection.
    # The default weight=0 means there is no initial association.
    # The connect method is how the implementation adds a connection,
    # the way to connect the neuron to another.
    # To connect neuron out to neuron in, for example, it is:
    #	in = Neuronet::Neuron.new
    #	out = Neuronet::Neuron.new
    #	out.connect(in)
    # Think output connects to input.
    def connect(node, weight=0.0)
      @connections.push(Connection.new(node, weight))
      self
    end

    def inspect
      super + (Neuronet.format % @bias) + '[' + @connections.map{|c| c.to_s}.join(',') + ']'
    end
  end

  # Neuronet::InputLayer is an Array of Neuronet::Node's.
  # It can be used for the input layer of a feed forward network.
  class InputLayer < Array
    def initialize(length, inputs=[]) # number of nodes
      super(length)
      0.upto(length-1){|index| self[index] = Neuronet::Node.new inputs[index].to_f}
    end

    # This is where one enters the "real world" inputs.
    def set(inputs)
      0.upto(self.length-1){|index| self[index].value = inputs[index].to_f}
      self
    end

    def values
      self.map{|node| node.value}
    end

   def inspect
     '['+self.map{|node| node.inspect}.join(',')+']'
   end
  end

  # Just a regular Layer.
  # InputLayer is to Layer what Node is to Neuron.
  # But Layer does not sub-class InputLayer(it's different enough).
  class Layer < Array
    def initialize(length)
      super(length)
      0.upto(length-1){|index| self[index] = Neuronet::Neuron.new }
    end

    # Allows one to fully connect layers.
    def connect(layer, weight=[])
      # creates the neuron matrix... note that node can be either Neuron or Node class.
      i = -1
      self.each{|neuron| layer.each{|node| neuron.connect(node, weight[i+=1].to_f) }}
    end

    # updates layer with current values of the previous layer
    def partial
      self.each{|neuron| neuron.partial}
    end

    # Takes the real world targets for each node in this layer
    # and backpropagates the error to each node.
    # Note that the learning constant is really a value
    # that needs to be determined for each network.
    def train(targets, learning, noise=Neuronet.noise)
      0.upto(self.length-1) do |index|
        node = self[index]
        node.backpropagate(learning*(targets[index] - node.value), noise)
      end
      self
    end

    # Returns the real world values of this layer.
    def values
      self.map{|node| node.value}
    end

   def inspect
     '['+self.map{|node| node.inspect}.join(',')+']'
   end
  end

  # A Feed Forward Network
  class FeedForward < Array
    # Whatchamacallits?
    # The learning constant is given different names...
    # often some Greek letter.
    # It's a small number less than one.
    # Ideally, it divides the errors evenly among all contributors.
    # Contributors are the neurons' biases and the connections' weights.
    # Thus if one counts all the contributors as N,
    # the learning constant should be at most 1/N.
    # But there are other considerations, such as how noisy the data is.
    # In any case, I'm calling this N value FeedForward#mu.
    # 1/mu is used for the initial default value for the learning constant.
    def mu
      sum = 1.0
      1.upto(self.length-1) do |i|
        n, m = self[i-1].length, self[i].length
        sum += n + n*m
      end
      return sum
    end
    # Given that the learning constant is initially set to 1/mu as defined above,
    # muk gives a way to modify the learning constant by some factor, k.
    # In theory, when there is no noise in the target data, k can be set to 1.0.
    # If the data is noisy, k is set to some value less than 1.0.
    def muk(k=1.0)
      @learning = k/mu
    end
    # Given that the learning constant can be modified by some factor k with #muk,
    # #num gives an alternate way to express
    # the k factor in terms of some number n greater than 1, setting k to 1/sqrt(n).
    # I believe that the optimal value for the learning constant
    # for a training set of size n is somewhere between #muk(1) and #num(n).
    # Whereas the learning constant can be too high,
    # a low learning value just increases the training time.
    def num(n)
      muk(1.0/(Math.sqrt(n)))
    end

    attr_reader :in, :out
    attr_reader :yin, :yang
    attr_accessor :learning

    # I find very useful to name certain layers:
    #	[0]	@in	Input Layer
    #	[1]	@yin	Typically the first middle layer
    #	[-2]	@yang	Typically the last middle layer
    #	[-1]	@out	Output Layer
    def initialize(layers)
      super(length = layers.length)
      @in = self[0] = Neuronet::InputLayer.new(layers[0])
      (1).upto(length-1){|index|
        self[index] = Neuronet::Layer.new(layers[index])
        self[index].connect(self[index-1])
      }
      @out = self.last
      @yin = self[1] # first middle layer
      @yang = self[-2] # last middle layer
      @learning = 1.0/mu
    end

    def update
      # update up the layers
      (1).upto(self.length-1){|index| self[index].partial}
      self
    end

    def set(inputs)
      @in.set(inputs)
    end

    def train(targets, learning=@learning, noise=Neuronet.noise)
      @out.train(targets, learning, noise)
      self
    end

    # trains an input/output pair
    def exemplar(inputs, targets)
      set(inputs)
      train(targets)
      self
    end

    def input
      @in.values
    end

    def output
      @out.values
    end

    def inspect
      self.map{|layer| layer.inspect}.join("\n")
    end
  end

  # Neuronet::Scale is a class to
  # help scale problems to fit within a network's "field of view".
  # Given a list of values, it finds the minimum and maximum values and
  # establishes a mapping to a scaled set of numbers between minus one and one (-1,1).
  class Scale
    attr_accessor :spread, :center
    attr_writer :init

    # If the value of center is provided, then
    # that value will be used instead of
    # calculating it from the values passed to method set.
    # Likewise, if spread is provided, that value of spread will be used.
    # The attribute @init flags if
    # there is a initiation phase to the calculation of @spread and @center.
    # For Scale, @init is true and the initiation phase calculates
    # the intermediate values @min and @max (the minimum and maximum values in the data set).
    # It's possible for sub-classes of Scale, such as Gaussian, to not have this initiation phase.
    def initialize(factor=1.0,center=nil,spread=nil)
      @factor,@center,@spread = factor,center,spread
      @centered, @spreaded = center.nil?, spread.nil?
      @init = true
    end

    def set_init(inputs)
      @min, @max = inputs.minmax
    end

    # In this case, inputs is unused, but
    # it's there for the general case.
    def set_spread(inputs)
      @spread = (@max - @min) / 2.0
    end

    # In this case, inputs is unused, but
    # it's there for the general case.
    def set_center(inputs)
      @center = (@max + @min) / 2.0
    end

    def set(inputs)
      set_init(inputs)		if @init
      set_center(inputs)	if @centered
      set_spread(inputs)	if @spreaded
    end

    def mapped(inputs)
      factor = 1.0 / (@factor*@spread)
      inputs.map{|value| factor*(value - @center)}
    end
    alias mapped_input mapped
    alias mapped_output mapped

    # Note that it could also unmap inputs, but
    # outputs is typically what's being transformed back.
    def unmapped(outputs)
      factor = @factor*@spread
      outputs.map{|value| factor*value + @center}
    end
    alias unmapped_input unmapped
    alias unmapped_output unmapped
  end

  # "Normal Distribution"
  # Gaussian sub-classes Scale and is used exactly the same way.
  # The only changes are that it calculates the arithmetic mean (average) for center and
  # the standard deviation for spread.
  class Gaussian < Scale
    def initialize(factor=1.0,center=nil,spread=nil)
      super(factor, center, spread)
      self.init = false
    end

    def set_center(inputs)
      self.center = inputs.inject(0.0,:+) / inputs.length
    end

    def set_spread(inputs)
      self.spread = Math.sqrt(inputs.map{|value|
        self.center - value}.inject(0.0){|sum,value|
          value*value + sum} / (inputs.length - 1.0))
    end
  end

  # "Log-Normal Distribution"
  # LogNormal sub-classes Gaussian to transform the values to a logarithmic scale. 
  class LogNormal < Gaussian
    def initialize(factor=1.0,center=nil,spread=nil)
      super(factor, center, spread)
    end

    def set(inputs)
      super( inputs.map{|value| Math::log(value)} )
    end

    def mapped(inputs)
      super( inputs.map{|value| Math::log(value)} )
    end
    alias mapped_input mapped
    alias mapped_output mapped

    def unmapped(outputs)
      super(outputs).map{|value| Math::exp(value)}
    end
    alias unmapped_input unmapped
    alias unmapped_output unmapped
  end

  # ScaledNetwork is a subclass of FeedForwardNetwork.
  # It automatically scales the problem given to it
  # by using a Scale type instance set in @distribution.
  # The attribute, @distribution, is set to Neuronet::Gaussian.new by default,
  # but one can change this to Scale, LogNormal, or one's own custom mapper.
  class ScaledNetwork < FeedForward
    attr_accessor :distribution

    def initialize(layers)
      super(layers)
      @distribution = Gaussian.new
    end

    def train(targets)
      super(@distribution.mapped_output(targets))
    end

    # @param (List of Float) values
    def set(inputs)
      super(@distribution.mapped_input(inputs))
    end

    # ScaledNetwork#reset works just like FeedForwardNetwork's set method,
    # but calls distribution.set( values ) first.
    # Sometimes you'll want to set the distribution
    # with the entire data set and the use set,
    # and then there will be times you'll want to
    # set the distribution with each input and use reset.
    def reset(inputs)
      @distribution.set(inputs)
      set(inputs)
    end

    def output
      @distribution.unmapped_output(super)
    end

    def input
      @distribution.unmapped_input(super)
    end
  end

  # A Perceptron Hybrid,
  # Tao directly connects the output layer to the input layer.
  module Tao
    # Tao's extra connections adds to mu.
    def mu
      sum = super
      sum += self.first.length * self.last.length
      return sum
    end
    # Tao.bless connects the network's output layer to the input layer,
    # extends it with Tao, and modifies the learning constant if needed.
    def self.bless(myself)
      # @out directly connects to @in
      myself.out.connect(myself.in)
      myself.extend Tao
      # Save current learning and set it to muk(1).
      l, m = myself.learning, myself.muk
      # If learning was lower b/4, revert.
      myself.learning = l if l<m
      return myself
    end
  end

  # Yin is a network which has its @yin layer initially mirroring @in.
  module Yin
    # Yin.bless increments the bias of each @yin[i] by BZERO, and
    # the weight of pairing (@yin[i], @in[i]) connections by WONE.
    # This makes @yin initially mirror @in.
    # The pairing is done starting with (@yin[0], @in[0]).
    # That is, starting with (@yin.first, @in.first).
    def self.bless(myself)
      yin = myself.yin
      if yin.length < (in_length = myself.in.length)
        raise "First hidden layer, yin, needs to have at least the same length as input"
      end
      # connections from yin[i] to in[i] are WONE... mirroring to start.
      0.upto(in_length-1) do |index|
        node = yin[index]
        node.connections[index].weight += WONE # +?
        node.bias += BZERO # +?
      end
      return myself
    end
  end

  # Yang is a network which has its @out layer initially mirroring @yang.
  module Yang
    # Yang.bless increments the bias of each @yang[i] by BZERO, and
    # the weight of pairing (@out[i], @yang[i]) connections by WONE.
    # This makes @out initially mirror @yang.
    # The pairing is done starting with (@out[-1], @yang[-1]).
    # That is, starting with (@out.last, @yang.last).
    def self.bless(myself)
      offset = myself.yang.length - (out_length = (out = myself.out).length)
      raise "Last hidden layer, yang, needs to have at least the same length as output" if offset < 0
      # Although the algorithm here is not as described,
      # the net effect to is pair @out.last with @yang.last, and so on down.
      0.upto(out_length-1) do |index|
        node = out[index]
        node.connections[offset+index].weight += WONE # +?
        node.bias += BZERO # +?
      end
      return myself
    end
  end

  # A Yin Yang composite provided for convenience.
  module YinYang
    def self.bless(myself)
      Yang.bless(myself)
      Yin.bless(myself)
      return myself
    end
  end

  # A Tao Yin Yang composite provided for convenience.
  module TaoYinYang
    def self.bless(myself)
      Yang.bless(myself)
      Yin.bless(myself)
      Tao.bless(myself)
      return myself
    end
  end

  # A Tao Yin composite provided for convenience.
  module TaoYin
    def self.bless(myself)
      Yin.bless(myself)
      Tao.bless(myself)
      return myself
    end
  end

  # A Tao Yang composite provided for convenience.
  module TaoYang
    def self.bless(myself)
      Yang.bless(myself)
      Tao.bless(myself)
      return myself
    end
  end

  # Brahma is a network which has its @yin layer initially mirror and "shadow" @in.
  # I'm calling it shadow until I can think of a better name.
  # Note that a Brahma, Yin bless combination overwrite each other and is probably useless.
  module Brahma
    # Brahma.bless increments the weights of pairing even yin (@yin[2*i], @in[i]) connections by WONE.
    # and pairing odd yin (@yin[2*i+1], @in[i]) connections by negative WONE.
    # Likewise the bias with BZERO.
    # This makes @yin initially mirror and shadow @in.
    # The pairing is done starting with (@yin[0], @in[0]).
    # That is, starting with (@yin.first, @in.first).
    def self.bless(myself)
      yin = myself.yin
      if yin.length < 2*(in_length = myself.in.length)
        raise "First hidden layer, yin, needs to be at least twice the length as input"
      end
      # connections from yin[2*i] to in[i] are WONE... mirroring to start.
      # connections from yin[2*i+1] to in[i] are -WONE... shadowing to start.
      0.upto(in_length-1) do |index|
        even = yin[2*index]
        odd = yin[(2*index)+1]
        even.connections[index].weight += WONE # +?
        even.bias += BZERO # +?
        odd.connections[index].weight  -= WONE # +?
        odd.bias -= BZERO # +?
      end
      return myself
    end
  end

  # A Brahma Yang composite provided for convenience.
  module BrahmaYang
    def self.bless(myself)
      Brahma.bless(myself)
      Yang.bless(myself)
      return myself
    end
  end

  # A Brahma Yang composite provided for convenience.
  module TaoBrahma
    def self.bless(myself)
      Brahma.bless(myself)
      Tao.bless(myself)
      return myself
    end
  end

  # A Tao Brahma Yang composite provided for convenience.
  module TaoBrahmaYang
    def self.bless(myself)
      Yang.bless(myself)
      Brahma.bless(myself)
      Tao.bless(myself)
      return myself
    end
  end

end
