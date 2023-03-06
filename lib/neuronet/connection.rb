# frozen_string_literal: true

# Neuronet module / Connection class
module Neuronet
  # Connections between neurons are there own separate objects. In Neuronet, a
  # neuron contains it's bias, and a list of it's connections. Each connection
  # contains it's weight (strength) and connected neuron.
  class Connection
    attr_accessor :neuron, :weight

    # Mu is a measure of sensitivity to errors.  It's the derivative of the
    # squash function.
    def mu = Neuronet.derivative[@neuron.activation]

    # Connection#initialize takes a neuron and a weight with a default of 0.0.
    def initialize(neuron, weight = Neuronet.zero)
      @neuron = neuron
      @weight = weight
    end

    # The activation of a connection is the weighted activation of the connected
    # neuron.
    def activation
      @neuron.activation * @weight
    end

    # Consistent with Neuron#partial
    alias partial activation

    # Connection#update returns the updated activation of a connection, which is
    # the weighted updated activation of the neuron it's connected to:
    #   weight * neuron.update
    # This method is the one to use whenever the value of the inputs are changed
    # (or right after training).  Otherwise, both update and value should give
    # the same result.  When back calculation are not needed, use
    # Connection#activation instead.
    def update
      @neuron.update * @weight
    end

    # Connection#backpropagate modifies the connection's weight in proportion to
    # the error given and passes that error to its connected neuron via the
    # neuron's backpropagate method.
    def backpropagate(error)
      @weight += @neuron.activation * Neuronet.noise[error]
      if @weight.abs > Neuronet.maxw
        @weight = @weight.positive? ? Neuronet.maxw : -Neuronet.maxw
      end
      @neuron.backpropagate(error)
      self
    end

    # A connection inspects itself as "weight*label:...".
    def inspect
      "#{Neuronet.format % @weight}*#{@neuron.inspect}"
    end

    # A connection puts itself as "weight*label".
    def to_s
      "#{Neuronet.format % @weight}*#{@neuron}"
    end
  end
end
