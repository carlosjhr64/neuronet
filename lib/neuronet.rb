# Neuronet module
module Neuronet
  VERSION = '5.0.0.alpha.1'

  # The squash function for Neuronet is the sigmoid function.
  # One should scale the problem with most data points between -1 and 1, extremes under 2s, and no outbounds above 3s.
  # Standard deviations from the mean is probably a good way to figure the scale of the problem.
  def self.squash(unsquashed)
    1.0 / (1.0 + Math.exp( -unsquashed ))
  end

  def self.unsquash(squashed)
    Math.log( squashed / (1.0 - squashed) )
  end

  DEFAULT_LEARNING = 0.1
  @@learning = DEFAULT_LEARNING
  def self.default_learning
    @@learning = DEFAULT_LEARNING
  end

  def self.learning
    @@learning
  end

  def self.learning=(learning)
    @@learning =  learning
  end

  def self.random_walk(number)
    1.0 / Math.sqrt(number+1.0)
  end

  # This is a suggested learning constant, based on the number of exemplars.
  def self.set_suggested_learning(number)
    @@learning = Neuronet.random_walk(number)
  end

  # By default, Neuronet builds a zeroed network.
  # Noise adds random fluctuations to create a search for minima.
  def self.noise
    rand + rand
  end

  # A Node
  class Node
    attr_reader :activation
    # A Node is constant (Input)
    alias update activation

    def initialize(val=0.0)
      self.value = val
    end

    def value=(val)
      @activation = Neuronet.squash(val)
    end

    def value
      Neuronet.unsquash(@activation)
    end
    alias to_f value

    def to_s
      value.to_s
    end

    # Node is a terminal where training and backpropagation ends.
    def train(target=nil, learning=nil)
      # to be over-ridden
      nil
    end
    alias backpropagate train
  end

  # A Connection
  class Connection
    attr_accessor :node, :weight
    def initialize(node, weight=0.0)
      @node, @weight = node, weight
    end

    def value
      @node.activation * @weight
    end

    def update
      @node.update * @weight
    end

    def backpropagate(error)
      @weight += @node.activation * error * Neuronet.noise
      @node.backpropagate(error)
    end
  end

  # A Neuron
  class Neuron < Node
    attr_reader :connections
    attr_accessor :bias
    def initialize(bias=0.0)
      super
      @connections = []
      @bias = bias
    end

    def update
      self.value = @bias + @connections.inject(0.0){|sum,connection| sum + connection.update}
    end

    # partial update, don't always need to burrow down to the terminal
    def partial
      self.value = @bias + @connections.inject(0.0){|sum,connection| sum + connection.value}
    end

    def backpropagate(error)
      # distribute the error evenly among contributors
      biased = Neuronet.squash(@bias)
      de = error / ( biased + @connections.inject(0.0){|sum,connection| sum + connection.node.activation } )
      @bias += biased * de * Neuronet.noise
      @connections.each{|connection| connection.backpropagate(de)}
    end

    # note that although the weights are modified, activation is not updated until update is called....
    def train( target, learning=Neuronet.learning )
      backpropagate( learning * (target - self.value) )
    end

    # The default weight=0 means there is no initial association
    def connect( node, weight=0.0 )
      @connections.push( Connection.new(node,weight) )
      update
    end
  end

  # This is the Input Layer
  class InputLayer < Array
    def initialize(length) # number of nodes
      super(length)
      0.upto(length-1){|index| self[index] = Neuronet::Node.new }
    end

    def set(inputs)
      0.upto(self.length-1){|index| self[index].value = inputs[index]}
    end

    def values
      self.map{|node| node.to_f}
    end
  end

  # Just a regular Layer
  class Layer < Array
    def initialize(length)
      super(length)
      0.upto(length-1){|index| self[index] = Neuronet::Neuron.new }
    end

    def connect(layer, weight=0.0)
      # creates the neuron matrix... note that node can be either Neuron or Node class.
      self.each{|neuron| layer.each{|node| neuron.connect(node,weight) }}
    end

    # updates layer with current values of the previous layer
    def partial
      self.each{|neuron| neuron.partial}
    end

    def train(targets, learning=Neuronet.learning)
      0.upto(self.length-1){|index| self[index].train(targets[index], learning) }
    end

    def values
      self.map{|node| node.to_f}
    end
  end

  # A Feed Forward Network
  class FeedForwardNetwork < Array
    attr_reader :in, :out
    attr_accessor :learning
    def initialize(layers, learning=Neuronet.learning)
      super( length = layers.length )
      @learning = learning
      @in = self[0] = Neuronet::InputLayer.new(layers[0])
      (1).upto(length-1){|index|
        self[index] = Neuronet::Layer.new(layers[index])
        self[index].connect(self[index-1])
      }
      @out = self.last
    end

    def update
      # update up the layers
      (1).upto(self.length-1){|index| self[index].partial}
    end

    def set(inputs)
      @in.set(inputs)
      update
    end

    def train!(targets, learning=@learning)
      @out.train(targets, learning)
      update
    end

    # trains an input/output pair
    def exemplar(inputs,targets, learning=@learning)
      set(inputs)
      train!(targets, learning)
    end

    def values(layer)
      self[layer].values
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
    def initialize(*parameters)
      super
      self.init = false
    end

    def set_center(inputs)
      self.center = inputs.inject(0.0,:+) / inputs.length
    end

    def set_spread(inputs)
      self.spread = Math.sqrt( inputs.map{|value| self.center - value}.inject(0.0){|sum,value| value*value + sum} / (inputs.length - 1.0) )
    end
  end

  # Log-Normal Distribution
  class LogNormal < Gaussian
    def initialize(*parameters)
      super
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
  class ScaledNetwork < FeedForwardNetwork
    attr_accessor :distribution

    def initialize(*parameters)
      super
      @distribution = Gaussian.new
    end

    def train!(targets, learning=@learning)
      super(@distribution.mapped_output(targets), learning)
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
    attr_reader :yin, :yang
    def initialize(*parameters)
      raise "Tao needs to be at least 3 layers" if layers.length < 3
      super
      # @out directly connects to @in
      self.out.connect(self.in)
      @yin = self[1] # first middle layer
      @yang = self[-2] # last middle layer, may be yin.
    end
  end

  # A Tao with @in initially tied to @yin
  class Yin < Tao
    def self.reweigh(myself)
      yin = myself.yin
      raise "First hidden layer, yin, needs to have at least the same length as input" if yin.length < (in_length = myself.in.length)
      # connections from yin[i] to in[i] are 1... mirroring to start.
      0.upto(in_length-1) do |index|
        node = yin[index]
        node.connections[index].weight = 1.0
        node.bias = -0.5
      end
    end

    def initialize(*parameters)
      super
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

    def initialize(*parameters)
      super
      Yang.reweigh(self)
    end
  end

  # A Tao Yin-Yang-ed  :))
  class YinYang < Tao
    def initialize(*parameters)
      super
      Yin.reweigh(self)
      Yang.reweigh(self)
    end
  end
end
