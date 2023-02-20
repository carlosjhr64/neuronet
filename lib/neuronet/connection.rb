# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Connections between neurons (and nodes) are there own separate objects.
  # In Neuronet, a neuron contains it's bias, and a list of it's connections.
  # Each connection contains it's weight (strength) and connected node.
  class Connection
    attr_accessor :node, :weight

    def initialize(node, weight = 0.0)
      @node   = node
      @weight = weight
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
    def backpropagate(error, mju)
      # mju divides the error among the neuron's constituents!
      @weight += @node.activation * Neuronet.noise[error / mju]
      if @weight.abs > Neuronet.maxw
        @weight = @weight.positive? ? Neuronet.maxw : -Neuronet.maxw
      end
      @node.backpropagate(error)
      self
    end

    def inspect
      "#{Neuronet.format % @weight}*#{@node.inspect}"
    end

    def to_s
      "#{Neuronet.format % @weight}*#{@node}"
    end
  end
end
