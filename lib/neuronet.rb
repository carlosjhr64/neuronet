# Neuronet module
module Neuronet
  VERSION = '7.0.230219'
  FORMAT  = '%.14g'

  # An artificial neural network uses a squash function to determine the
  # activation value of a neuron. The squash function for Neuronet is the
  # [Sigmoid function](http://en.wikipedia.org/wiki/Sigmoid_function)
  # which sets the neuron's activation value between 1.0 and 0.0. This
  # activation value is often thought of on/off or true/false. For
  # classification problems, activation values near one are considered true
  # while activation values near 0.0 are considered false. In Neuronet I make a
  # distinction between the neuron's activation value and it's representation to
  # the problem. This attribute, activation, need never appear in an
  # implementation of Neuronet, but it is mapped back to it's unsquashed value
  # every time the implementation asks for the neuron's value. One should scale
  # the problem with most data points between -1 and 1, extremes under 2s, and
  # no outbounds above 3s. Standard deviations from the mean is probably a good
  # way to figure the scale of the problem.
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
  # Neuronet by default creates zeroed neurons. Association between inputs and
  # outputs are trained, and neurons differentiate from each other randomly.
  # Differentiation among neurons is achieved by noise in the back-propagation
  # of errors. This noise is provided by rand + rand. I chose rand + rand to
  # give the noise an average value of one and a bell shape distribution.
  NOISE = ->(error){error*(rand + rand)}

  # One may choose not to have noise.
  NO_NOISE = IDENTITY = ->(error){error}

  class << self
    attr_accessor :squash, :unsquash, :bzero, :wone, :noise, :format
  end
  self.squash   = SQUASH
  self.unsquash = UNSQUASH
  self.bzero    = BZERO
  self.wone     = WONE
  self.noise    = NOISE
  self.format   = FORMAT

  class << self; attr_accessor :maxw, :maxb, :maxv; end
  self.maxw     = 9.0
  self.maxb     = 18.0
  self.maxv     = 36.0

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
    alias update activation
    alias partial activation

    # The "real world" value of a node is the value of it's activation
    # unsquashed. So, set the activation to the squashed real world value.
    def value=(value)
      if value.abs > Neuronet.maxv
        value = value.positive? ? Neuronet.maxv : -Neuronet.maxv
      end
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
    def backpropagate(_error)
      # to be over-ridden
      self
    end

    def inspect
      @label + ':' + (Neuronet.format % value)
    end

    def to_s
      @label
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

    # The value of a connection is
    # the weighted activation of the connected node.
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
    def backpropagate(error, mu)
      # mu divides the error among the neuron's constituents!
      @weight += @node.activation * Neuronet.noise[error/mu]
      if @weight.abs > Neuronet.maxw
        @weight = @weight.positive? ? Neuronet.maxw : -Neuronet.maxw
      end
      @node.backpropagate(error)
      self
    end

    def inspect
      (Neuronet.format % @weight) + '*' + @node.inspect
    end

    def to_s
      (Neuronet.format % @weight) + '*' + @node.to_s
    end
  end

  # A Neuron is a Node with some extra features.
  # It adds two attributes: connections, and bias.
  # The connections attribute is a list of
  # the neuron's connections to other neurons (or nodes).
  # A neuron's bias is it's kicker (or deduction) to it's activation value,
  # a sum of its connections values.
  class Neuron < Node
    attr_reader :connections, :mu
    attr_accessor :bias

    def mu!
      # mu is entirely based on a sum of external activations and
      # only needs to be reset when these external activations change.
      @mu = 1.0 + @connections.sum{|connection| connection.node.activation}
    end

    def initialize(value=0.0, bias: 0.0, connections: [])
      super(value)
      @connections, @bias = connections, bias
      @mu = nil # to be set later
    end

    # Updates the activation with the current value of bias and updated values
    # of connections.
    def update
      value = @bias + @connections.sum(&:update)
      mu!
      self.value = value
    end
    # For when connections are already updated, Neuron#partial updates the
    # activation with the current values of bias and connections. It is not
    # always necessary to burrow all the way down to the terminal input node to
    # update the current neuron if it's connected neurons have all been updated.
    # The implementation should set it's algorithm to use partial instead of
    # update as update will most likely needlessly update previously updated
    # neurons.
    def partial
      value = @bias + @connections.sum(&:value)
      mu!
      self.value = value
    end

    # The backpropagate method modifies
    # the neuron's bias in proportion to the given error and
    # passes on this error to each of its connection's backpropagate method.
    # While updates flows from input to output,
    # back-propagation of errors flows from output to input.
    def backpropagate(error)
      # mu divides the error among the neuron's constituents!
      @bias += Neuronet.noise[error/@mu]
      if @bias.abs > Neuronet.maxb
        @bias = @bias.positive? ? Neuronet.maxb : -Neuronet.maxb
      end
      @connections.each{|connection| connection.backpropagate(error, @mu)}
      self
    end

    # Connects the neuron to another node.
    # Updates the activation with the new connection.
    # The default weight=0 means there is no initial association.
    # The connect method is how the implementation adds a connection,
    # the way to connect the neuron to another.
    # To connect "salida" to "entrada", for example, it is:
    #	entrada = Neuronet::Neuron.new
    #	salida = Neuronet::Neuron.new
    #	salida.connect(entrada)
    # Think output(salida) connects to input(entrada).
    def connect(node, weight=0.0)
      @connections.push(Connection.new(node, weight))
      self
    end

    def inspect
      super + '|' + [(Neuronet.format % @bias), *@connections].join('+')
    end
  end

  # Neuronet::InputLayer is an Array of Neuronet::Node's.
  # It can be used for the input layer of a feed forward network.
  class InputLayer < Array
    # number of nodes
    def initialize(length, inputs=[])
      super(length)
      0.upto(length-1){self[_1] = Neuronet::Node.new inputs[_1].to_f}
    end

    # This is where one enters the "real world" inputs.
    def set(inputs)
      0.upto(length-1){|index| self[index].value = inputs[index].to_f}
      self
    end

    def values
      map(&:value)
    end

    def inspect
      map(&:inspect).join(',')
    end

    def to_s
      map(&:to_s).join(',')
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
      # creates the neuron matrix...
      # note that node can be either Neuron or Node class.
      i = -1
      each do |neuron|
        layer.each{|node| neuron.connect(node, weight[i+=1].to_f)}
      end
    end

    # updates layer with current values of the previous layer
    def partial
      each(&:partial)
    end

    # Takes the real world target for each node in this layer
    # and backpropagates the error to each node.
    # Note that the learning constant is really a value
    # that needs to be determined for each network.
    def train(target, learning)
      0.upto(length-1) do |index|
        node = self[index]
        error = target[index] - node.value
        node.backpropagate(learning*error)
      end
      self
    end

    # Returns the real world values of this layer.
    def values
      map(&:value)
    end

    def inspect
      map(&:inspect).join(',')
    end

    def to_s
      map(&:to_s).join(',')
    end
  end

  # A Feed Forward Network
  class FeedForward < Array
    attr_reader :entrada, :salida, :yin, :yang
    attr_accessor :learning

    # I find very useful to name certain layers:
    #  [0]    @entrada   Input Layer
    #  [1]    @yin       Typically the first middle layer
    #  [-2]   @yang      Typically the last middle layer
    #  [-1]   @salida    Output Layer
    def initialize(layers)
      length = layers.length
      raise 'Need at least 2 layers' if length < 2
      super(length)
      self[0] = Neuronet::InputLayer.new(layers[0])
      1.upto(length-1) do |index|
        self[index] = Neuronet::Layer.new(layers[index])
        self[index].connect(self[index-1])
      end
      @entrada, @salida = first, last
      @yin, @yang = self[1], self[-2]
      @learning = 1.0 / (length-1)
    end

    def number(n)
      mu = Math.sqrt(n)*(length-1)
      @learning = 1.0 / mu
    end

    def set(input)
      @entrada.set(input)
      self
    end

    def input
      @entrada.values
    end

    def update
      # update up the layers
      1.upto(length-1){|index| self[index].partial}
      self
    end

    def output
      @salida.values
    end

    def *(other)
      set(other)
      update
      @salida.values
    end

    def train(target)
      @salida.train(target, @learning)
      self
    end

    def pairs(pairs)
      pairs.shuffle.each{|input, target| set(input).update.train(target)}
      if block_given?
        while yield
          pairs.shuffle.each{|input, target| set(input).update.train(target)}
        end
      end
      self
    end

    def inspect
     "#learning:#{Neuronet.format % @learning}\n" + map(&:inspect).join("\n")
    end

    def to_s
      map(&:to_s).join("\n")
    end

    class << self
      attr_accessor :color, :colorize
    end

    COLORIZED = ''.respond_to? :colorize
    COLOR = lambda do |v|
      c = nil
      if COLORIZED
        c = :light_white
        if v > 1.0
          c = :green
        elsif v < -1.0
          c = :red
        elsif v < 0.0
          c = :white
        end
      else
        c = :white
        if v > 1.0
          c = :green
        elsif v < -1.0
          c = :red
        elsif v < 0.0
          c = :gray
        end
      end
      c
    end
    FeedForward.color = COLOR
    COLORIZE = ->(s, c){COLORIZED ? s.colorize(color: c) : s.color(c)}
    FeedForward.colorize = COLORIZE

    def colorize(verbose: false, nodes: false, biases: true, connections: true)
      parts = inspect.scan(/[: ,|+*\n]|[^: ,|+*\n]+/)
      each do |layer|
        layer.each do |node|
          l, v = node.label, node.value
          0.upto(parts.length-1) do |i|
            case parts[i]
            when l
              if nodes
                parts[i] = FeedForward.colorize[l, FeedForward.color[v]]
              end
            when '|'
              if biases
                parts[i] = FeedForward.colorize['|',
                           FeedForward.color[parts[i+1].to_f]]
              end
            when '*'
              if connections
                parts[i] = FeedForward.colorize['*',
                           FeedForward.color[parts[i-1].to_f]]
              end
            end
          end
        end
      end
      parts.delete_if{_1=~/^[\d.+-]+$/} unless verbose
      parts.join
    end
  end

  # Neuronet::Scale is a class to help scale problems to fit within a network's
  # "field of view". Given a list of values, it finds the minimum and maximum
  # values and establishes a mapping to a scaled set of numbers between minus
  # one and one (-1,1).
  class Scale
    attr_accessor :spread, :center

    # If the value of center is provided, then
    # that value will be used instead of
    # calculating it from the values passed to method #set.
    # Likewise, if spread is provided, that value of spread will be used.
    def initialize(factor: 1.0, center: nil, spread: nil)
      @factor, @center, @spread = factor, center, spread
    end

    def set(inputs)
      min, max = inputs.minmax
      @center ||= (max + min) / 2.0
      @spread ||= (max - min) / 2.0
      self
    end

    def reset(inputs)
      @center = @spread = nil
      set(inputs)
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
  # Gaussian sub-classes Scale and is used exactly the same way. The only
  # changes are that it calculates the arithmetic mean (average) for center and
  # the standard deviation for spread.
  class Gaussian < Scale
    def set(inputs)
      @center ||= inputs.sum.to_f/inputs.length
      unless @spread
        sum2 = inputs.map{|v| e = @center - v; e*e}.sum.to_f
        @spread = Math.sqrt(sum2/(inputs.length - 1.0))
      end
      self
    end
  end

  # "Log-Normal Distribution"
  # LogNormal sub-classes Gaussian to transform the values to a logarithmic
  # scale.
  class LogNormal < Gaussian
    def set(inputs)
      super(inputs.map{|value| Math.log(value)})
    end

    def mapped(inputs)
      super(inputs.map{|value| Math.log(value)})
    end

    def unmapped(outputs)
      super(outputs).map{|value| Math.exp(value)}
    end
  end

  # ScaledNetwork is a subclass of FeedForwardNetwork.
  # It automatically scales the problem given to it
  # by using a Scale type instance set in @distribution.
  # The attribute, @distribution, is set to Neuronet::Gaussian.new by default,
  # but one can change this to Scale, LogNormal, or one's own custom mapper.
  class ScaledNetwork < FeedForward
    attr_accessor :distribution, :reset

    def initialize(layers, distribution: Gaussian.new, reset: false)
      super(layers)
      @distribution, @reset = distribution, reset
    end

    # ScaledNetwork set works just like FeedForwardNetwork's set method,
    # but calls @distribution.set(values) first if @reset is true.
    # Sometimes you'll want to set the distribution with the entire data set,
    # and then there will be times you'll want to reset the distribution
    # with each input.
    def set(input)
      @distribution.reset(input) if @reset
      super(@distribution.mapped_input(input))
    end

    def input
      @distribution.unmapped_input(super)
    end

    def output
      @distribution.unmapped_output(super)
    end

    def *(_other)
      @distribution.unmapped_output(super)
    end

    def train(target)
      super(@distribution.mapped_output(target))
    end

    def inspect
      distribution = @distribution.class.to_s.split(':').last
      "#distribution:#{distribution} #reset:#{@reset} " + super
    end
  end

  # A Perceptron Hybrid,
  # Tao directly connects the output layer to the input layer.
  module Tao
    # Tao.bless connects the network's output layer to the input layer.
    def self.bless(myself)
      # @salida directly connects to @entrada
      myself.salida.connect(myself.entrada)
      myself.extend Tao
      myself
    end

    def inspect
      '#Tao '+super
    end
  end

  # Yin is a network which has its @yin layer initially mirroring @entrada.
  module Yin
    # Yin.bless sets the bias of each @yin[i] to bzero, and
    # the weight of pairing (@yin[i], @entrada[i]) connections to wone.
    # This makes @yin initially mirror @entrada.
    def self.bless(myself)
      yin = myself.yin
      # just mirror as much of myself.entrada as you can
      in_length = [myself.entrada.length, yin.length].min
      # connections from yin[i] to entrada[i] are wone... mirroring to start.
      0.upto(in_length-1) do |index|
        node = yin[index]
        node.connections[index].weight = Neuronet.wone
        node.bias = Neuronet.bzero
      end
      myself.extend Yin
      myself
    end

    def inspect
      '#Yin '+super
    end
  end

  # Yang is a network which has its @salida layer initially mirroring @yang.
  module Yang
    # Yang.bless sets the bias of each @salida[i] to bzero, and
    # the weight of pairing (@salida[i], @yang[i]) connections to wone.
    # This makes @salida initially mirror @yang.
    def self.bless(myself)
      salida = myself.salida
      # just mirror as much of myself.yang as you can
      yang_length = [myself.yang.length, salida.length].min
      # connections from salida[i] to yang[i] are wone... mirroring to start.
      0.upto(yang_length-1) do |index|
        node = salida[index]
        node.connections[index].weight = Neuronet.wone
        node.bias = Neuronet.bzero
      end
      myself.extend Yang
      myself
    end

    def inspect
      '#Yang '+super
    end
  end

  # Neo is a network which has its @yang layer initially mirroring @yin.
  module Neo
    # Neo.bless sets the bias of each @yang[i] to bzero, and
    # the weight of pairing (@yang[i], @yin[i]) connections to wone.
    # This makes @yang initially mirror @yin.
    def self.bless(myself)
      yang = myself.yang
      # just mirror as much of myself.yang as you can
      yin_length = [myself.yin.length, yang.length].min
      # connections from yang[i] to yin[i] are wone... mirroring to start.
      0.upto(yin_length-1) do |index|
        node = yang[index]
        node.connections[index].weight = Neuronet.wone
        node.bias = Neuronet.bzero
      end
      myself.extend Neo
      myself
    end

    def inspect
      '#Neo '+super
    end
  end

  # Brahma is a network which has its @yin layer initially mirror and
  # "shadow" @entrada.
  module Brahma
    # Brahma.bless sets the weights of pairing even yin (@yin[2*i], @entrada[i])
    # connections to wone, and pairing odd yin (@yin[2*i+1], @entrada[i])
    # connections to negative wone. Likewise the bias with bzero.
    # This makes @yin initially mirror and shadow @entrada. The pairing is done
    # starting with (@yin[0], @entrada[0]).
    # That is, starting with (@yin.first, @entrada.first).
    def self.bless(myself)
      yin = myself.yin
      # just cover as much as you can
      in_length = [myself.entrada.length, yin.length/2].min
      # connections from yin[2*i] to entrada[i] are wone, mirroring to start.
      # connections from yin[2*i+1] to entrada[i] are -wone, shadowing to start.
      0.upto(in_length-1) do |index|
        even = yin[2*index]
        odd = yin[(2*index)+1]
        even.connections[index].weight = Neuronet.wone
        even.bias = Neuronet.bzero
        odd.connections[index].weight = -Neuronet.wone
        odd.bias = -Neuronet.bzero
      end
      myself.extend Brahma
      myself
    end

    def inspect
      '#Brahma '+super
    end
  end

  # Vishnu is a network which has its @yang layer initially mirror
  # and "shadow" @yin.
  module Vishnu
    # Vishnu.bless sets the weights of pairing even yang (@yang[2*i], @yin[i])
    # connections to wone, and pairing odd yang (@yang[2*i+1], @yin[i])
    # connections to negative wone. Likewise the bias with bzero.
    # This makes @yang initially mirror and shadow @yin.
    # The pairing is done starting with (@yang[0], @yin[0]).
    # That is, starting with (@yang.first, @yin.first).
    def self.bless(myself)
      yang = myself.yang
      # just cover as much as you can
      yin_length = [myself.yin.length, yang.length/2].min
      # connections from yang[2*i] to yin[i] are wone... mirroring to start.
      # connections from yang[2*i+1] to yin[i] are -wone... shadowing to start.
      0.upto(yin_length-1) do |index|
        even = yang[2*index]
        odd = yang[(2*index)+1]
        even.connections[index].weight = Neuronet.wone
        even.bias = Neuronet.bzero
        odd.connections[index].weight = -Neuronet.wone
        odd.bias = -Neuronet.bzero
      end
      myself.extend Vishnu
      myself
    end

    def inspect
      '#Vishnu '+super
    end
  end

  # Shiva is a network which has its @salida layer initially mirror
  # and "shadow" @yang.
  module Shiva
    # Shiva.bless sets the weights of pairing even salida
    # (@salida[2*i], @yang[i]) connections to wone, and pairing odd
    # salida (@salida[2*i+1], @yang[i]) connections to negative wone.
    # Likewise the bias with bzero.
    # This makes @salida initially mirror and shadow @yang.
    # The pairing is done starting with (@salida[0], @yang[0]).
    # That is, starting with (@salida.first, @yang.first).
    def self.bless(myself)
      salida = myself.salida
      # just cover as much as you can
      yang_length = [myself.yang.length, salida.length/2].min
      # connections from salida[2*i] to yang[i] are wone, mirroring to start.
      # connections from salida[2*i+1] to yang[i] are -wone, shadowing to start.
      0.upto(yang_length-1) do |index|
        even = salida[2*index]
        odd = salida[(2*index)+1]
        even.connections[index].weight = Neuronet.wone
        even.bias = Neuronet.bzero
        odd.connections[index].weight = -Neuronet.wone
        odd.bias = -Neuronet.bzero
      end
      myself.extend Shiva
      myself
    end

    def inspect
      '#Shiva '+super
    end
  end

  # Summa is a network which has each yin neuron sum two "corresponding" neurons
  # above(entrada). See code for "corresponding" semantic.
  module Summa
    def self.bless(myself)
      yin = myself.yin
      # just cover as much as you can
      in_length = [myself.entrada.length/2, yin.length].min
      0.upto(in_length-1) do |index|
        neuron = yin[index]
        neuron.bias = Neuronet.bzero
        neuron.connections[2*index].weight = Neuronet.wone/2.0
        neuron.connections[2*index+1].weight = Neuronet.wone/2.0
      end
      myself.extend Summa
      myself
    end

    def inspect
      '#Summa '+super
    end
  end

  # Sintezo is a network which has each @yang neuron sum two "corresponding"
  # neurons above(ambiguous layer). See code for "corresponding" semantic.
  module Sintezo
    def self.bless(myself)
      yang = myself.yang
      # just cover as much as you can
      in_length = [myself[-3].length/2, yang.length].min
      0.upto(in_length-1) do |index|
        neuron = yang[index]
        neuron.bias = Neuronet.bzero
        neuron.connections[2*index].weight = Neuronet.wone/2.0
        neuron.connections[2*index+1].weight = Neuronet.wone/2.0
      end
      myself.extend Sintezo
      myself
    end

    def inspect
      '#Sintezo '+super
    end
  end

  # Synthesis is a network which has each @salida neuron sum two "corresponding"
  # neurons above(yang). See code for "corresponding" semantic.
  module Synthesis
    def self.bless(myself)
      salida = myself.salida
      # just cover as much as you can
      in_length = [myself.yang.length/2, salida.length].min
      0.upto(in_length-1) do |index|
        neuron = salida[index]
        neuron.bias = Neuronet.bzero
        neuron.connections[2*index].weight = Neuronet.wone/2.0
        neuron.connections[2*index+1].weight = Neuronet.wone/2.0
      end
      myself.extend Synthesis
      myself
    end

    def inspect
      '#Synthesis '+super
    end
  end

  # Promedio is a network which has each yin neuron sum three neurons "directly"
  # above(entrada). See code for "directly" semantic.
  module Promedio
    def self.bless(myself)
      yin = myself.yin
      # just cover as much as you can
      in_length = [myself.entrada.length, yin.length].min
      0.upto(in_length-1) do |index|
        neuron = yin[index]
        neuron.bias = Neuronet.bzero
        (-1..1).each do |i|
          connection = neuron.connections[index+i]
          connection.weight = Neuronet.wone/3.0 if connection
        end
      end
      myself.extend Promedio
      myself
    end

    def inspect
      '#Promedio '+super
    end
  end

  # Mediocris is a network which has each @yang neuron sum three neurons
  # "directly" above(ambiguous layer). See code for "directly" semantic.
  module Mediocris
    def self.bless(myself)
      yang = myself.yang
      # just cover as much as you can
      in_length = [myself[-3].length, yang.length].min
      0.upto(in_length-1) do |index|
        neuron = yang[index]
        neuron.bias = Neuronet.bzero
        (-1..1).each do |i|
          connection = neuron.connections[index+i]
          connection.weight = Neuronet.wone/3.0 if connection
        end
      end
      myself.extend Mediocris
      myself
    end

    def inspect
      'Mediocris '+super
    end
  end

  # Average is a network which has each @salida neuron sum three neurons
  # "directly" above(yang). See code for "directly" semantic.
  module Average
    def self.bless(myself)
      salida = myself.salida
      # just cover as much as you can
      in_length = [myself.yang.length, salida.length].min
      0.upto(in_length-1) do |index|
        neuron = salida[index]
        neuron.bias = Neuronet.bzero
        neuron.bias = Neuronet.bzero
        (-1..1).each do |i|
          connection = neuron.connections[index+i]
          connection.weight = Neuronet.wone/3.0 if connection
        end
      end
      myself.extend Average
      myself
    end

    def inspect
      'Average '+super
    end
  end

  # Contructor Combos!
  module Tao
    # The obvious Tao ScaledNetwork
    def self.[](size)
      Tao.bless ScaledNetwork.new([size, size, size])
    end
  end
  module YinYang
    # The obvious YinYang ScaledNetwork
    def self.[](size)
      Yin.bless Yang.bless ScaledNetwork.new [size, size, size]
    end
  end
  module TaoYinYang
    # The obvious TaoYinYang ScaledNetwork
    def self.[](size)
      Tao.bless Yin.bless Yang.bless ScaledNetwork.new [size, size, size]
    end
  end
  module NeoYinYang
    # The obvious NeoYinYang ScaledNetwork
    def self.[](size)
      Neo.bless Yin.bless Yang.bless ScaledNetwork.new [size, size, size, size]
    end
  end
  module BrahmaSynthesis
    # The obvious BrahmaSynthesis ScaledNetwork
    def self.[](size)
      Brahma.bless Synthesis.bless ScaledNetwork.new [size, 2*size, size]
    end
  end
end
