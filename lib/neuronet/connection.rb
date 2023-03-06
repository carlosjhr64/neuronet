# frozen_string_literal: true

# Neuronet module / Connection class
module Neuronet
  # Connections between neurons (and nodes) are there own separate objects.
  # In Neuronet, a neuron contains it's bias, and a list of it's connections.
  # Each connection contains it's weight (strength) and connected node.
  class Connection
    attr_accessor :node, :weight

    # Mu is a measure of sensitivity to errors.  It's the derivative of the
    # squash function.
    def mu = Neuronet.derivative[@node.activation]

    # Connection#initialize takes a node and a weight with a default of 0.0.
    def initialize(node, weight = Neuronet.zero)
      @node   = node
      @weight = weight
    end

    # The activation of a connection is the weighted activation of the connected
    # node.
    def activation
      @node.activation * @weight
    end

    # Consistent with Neuron#partial
    alias partial activation

    # Connection#update returns the updated value of a connection, which is the
    # weighted updated activation of the node it's connected to:
    #   weight * node.update
    # This method is the one to use whenever the value of the inputs are changed
    # (or right after training).  Otherwise, both update and value should give
    # the same result.  When back calculation are not needed, use
    # Connection#value instead.
    def update
      @node.update * @weight
    end

    # Connection#backpropagate modifies the connection's weight in proportion to
    # the error given and passes that error to its connected node via the node's
    # backpropagate method.
    def backpropagate(error)
      @weight += @node.activation * Neuronet.noise[error]
      if @weight.abs > Neuronet.maxw
        @weight = @weight.positive? ? Neuronet.maxw : -Neuronet.maxw
      end
      @node.backpropagate(error)
      self
    end

    # A connection inspects itself as "weight*label:...".
    def inspect
      "#{Neuronet.format % @weight}*#{@node.inspect}"
    end

    # A connection puts itself as "weight*label".
    def to_s
      "#{Neuronet.format % @weight}*#{@node}"
    end
  end
end
