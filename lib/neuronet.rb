# Neuronet module
module Neuronet
  VERSION = '6.0.0'

  # The squash function for Neuronet is the sigmoid function.
  # One should scale the problem with most data points between -1 and 1,
  # extremes under 2s, and no outbounds above 3s.
  # Standard deviations from the mean is probably a good way to figure the scale of the problem.
  def self.squash(unsquashed)
    1.0 / (1.0 + Math.exp(-unsquashed))
  end

  def self.unsquash(squashed)
    Math.log(squashed / (1.0 - squashed))
  end

  # By default, Neuronet builds a zeroed network.
  # Noise adds random fluctuations to create a search for minima.
  def self.noise
    rand + rand
  end

  # A Node, used for the input layer.
  class Node
    attr_reader :activation
    # A Node is constant (Input)
    alias update activation

    # The "real world" value of a node is the value of it's activation unsquashed.
    def value=(val)
      @activation = Neuronet.squash(val)
    end

    def initialize(val=0.0)
      self.value = val
    end

    # The "real world" value is stored as a squashed activation.
    def value
      Neuronet.unsquash(@activation)
    end

    # Node is a terminal where backpropagation ends.
    def backpropagate(error)
      # to be over-ridden
      nil
    end
  end

  # A weighted connection to a neuron (or node).
  class Connection
    attr_accessor :node, :weight
    def initialize(node, weight=0.0)
      @node, @weight = node, weight
    end

    # The value of a connection is the weighted activation of the connected node.
    def value
      @node.activation * @weight
    end

    # Updates and returns the value of the connection.
    # Updates the connected node.
    def update
      @node.update * @weight
    end

    # Adjusts the connection weight according to error and
    # backpropagates the error to the connected node.
    def backpropagate(error)
      @weight += @node.activation * error * Neuronet.noise
      @node.backpropagate(error)
    end
  end

  # A Neuron with bias and connections
  class Neuron < Node
    attr_reader :connections
    attr_accessor :bias
    def initialize(bias=0.0)
      super(bias)
      @connections = []
      @bias = bias
    end

    # Updates the activation with the current value of bias and updated values of connections.
    def update
      self.value = @bias + @connections.inject(0.0){|sum,connection| sum + connection.update}
    end

    # Updates the activation with the current values of bias and connections
    # For when connections are already updated.
    def partial
      self.value = @bias + @connections.inject(0.0){|sum,connection| sum + connection.value}
    end

    # Adjusts bias according to error and
    # backpropagates the error to the connections.
    def backpropagate(error)
      @bias += error * Neuronet.noise
      @connections.each{|connection| connection.backpropagate(error)}
    end

    # Connects the neuron to another node.
    # Updates the activation with the new connection.
    # The default weight=0 means there is no initial association
    def connect(node, weight=0.0)
      @connections.push(Connection.new(node,weight))
      update
    end
  end

  # This is the Input Layer
  class InputLayer < Array
    def initialize(length) # number of nodes
      super(length)
      0.upto(length-1){|index| self[index] = Neuronet::Node.new }
    end

    # This is where one enters the "real world" inputs.
    def set(inputs)
      0.upto(self.length-1){|index| self[index].value = inputs[index]}
    end
  end

  # Just a regular Layer
  class Layer < Array
    def initialize(length)
      super(length)
      0.upto(length-1){|index| self[index] = Neuronet::Neuron.new }
    end

    # Allows one to fully connect layers.
    def connect(layer, weight=0.0)
      # creates the neuron matrix... note that node can be either Neuron or Node class.
      self.each{|neuron| layer.each{|node| neuron.connect(node,weight) }}
    end

    # updates layer with current values of the previous layer
    def partial
      self.each{|neuron| neuron.partial}
    end

    # Takes the real world targets for each node in this layer
    # and backpropagates the error to each node.
    # Note that the learning constant is really a value
    # that needs to be determined for each network.
    def train(targets, learning)
      0.upto(self.length-1) do |index|
        node = self[index]
        node.backpropagate(learning*(targets[index] - node.value))
      end
    end

    # Returns the real world values of this layer.
    def values
      self.map{|node| node.value}
    end
  end

  # A Feed Forward Network
  class FeedForward < Array
    # Whatchamacallits?
    def mu
      sum = 1.0
      1.upto(self.length-1) do |i|
        n, m = self[i-1].length, self[i].length
        sum += n + n*m
      end
      return sum
    end
    def muk=(k)
      @learning = k/mu
    end
    def num=(n)
      @learning = 1.0/(Math.sqrt(1.0+n) * mu)
    end

    attr_reader :in, :out
    attr_reader :yin, :yang
    attr_accessor :learning
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
    end

    def set(inputs)
      @in.set(inputs)
      update
    end

    def train!(targets)
      @out.train(targets, @learning)
      update
    end

    # trains an input/output pair
    def exemplar(inputs, targets)
      set(inputs)
      train!(targets)
    end

    def input
      @in.values
    end

    def output
      @out.values
    end
  end

  # Scales the problem
  class Scale
    attr_accessor :spread, :center
    attr_writer :init

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

  # Normal Distribution
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

  # Log-Normal Distribution
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

  # Series Network for similar input/output values
  class ScaledNetwork < FeedForward
    attr_accessor :distribution

    def initialize(layers)
      super(layers)
      @distribution = Gaussian.new
    end

    def train!(targets)
      super(@distribution.mapped_output(targets))
    end

    # @param (List of Float) values
    def set(inputs)
      super(@distribution.mapped_input(inputs))
    end

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

  # A Perceptron Hybrid
  class Tao < ScaledNetwork
    def mu
      sum = super
      sum += self.first.length * self.last.length
      return sum
    end
    def initialize(layers)
      raise "Tao needs to be at least 3 layers" if layers.length < 3
      super(layers)
      # @out directly connects to @in
      self.out.connect(self.in)
    end
  end

  # A Tao with @in initially tied to @yin
  class Yin < Tao
    def self.reweigh(myself)
      yin = myself.yin
      if yin.length < (in_length = myself.in.length)
        raise "First hidden layer, yin, needs to have at least the same length as input"
      end
      # connections from yin[i] to in[i] are 1... mirroring to start.
      0.upto(in_length-1) do |index|
        node = yin[index]
        node.connections[index].weight = 1.0
        node.bias = -0.5
      end
    end

    def initialize(layers)
      super(layers)
      Yin.reweigh(self)
    end
  end

  # A Tao with yang initially tied to output
  class Yang < Tao
    def self.reweigh(myself)
      offset = myself.yang.length - (out_length = (out = myself.out).length)
      raise "Last hidden layer, yang, needs to have at least the same length as output" if offset < 0
      0.upto(out_length-1) do |index|
        node = out[index]
        node.connections[offset+index].weight = 1.0
        node.bias = -0.5
      end
    end

    def initialize(layers)
      super(layers)
      Yang.reweigh(self)
    end
  end

  # A Tao Yin-Yang-ed  :))
  class YinYang < Tao
    def initialize(layers)
      super(layers)
      Yin.reweigh(self)
      Yang.reweigh(self)
    end
  end

  def self.tao(ffn)
    ffn.out.connect(ffn.in)
    def ffn.mu
      super + self.out.length*self.in.length
    end
  end
end
