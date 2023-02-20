# frozen_string_literal: true

# Neuronet module / Neuron class
module Neuronet
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
      @mu = 1.0 + @connections.sum { |connection| connection.node.activation }
    end

    def initialize(value = 0.0, bias: 0.0, connections: [])
      super(value)
      @connections = connections
      @bias        = bias
      @mu          = nil # to be set later
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
      @bias += Neuronet.noise[error / @mu]
      if @bias.abs > Neuronet.maxb
        @bias = @bias.positive? ? Neuronet.maxb : -Neuronet.maxb
      end
      @connections.each { |connection| connection.backpropagate(error, @mu) }
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
    def connect(node, weight = 0.0)
      @connections.push(Connection.new(node, weight))
      self
    end

    def inspect
      "#{super}|#{[(Neuronet.format % @bias), *@connections].join('+')}"
    end
  end
end
