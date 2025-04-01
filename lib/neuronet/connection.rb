# frozen_string_literal: true

# Neuronet module / Connection class
module Neuronet
  # Connections between neurons are there own separate objects. In Neuronet, a
  # neuron contains it's bias, and a list of it's connections. Each connection
  # contains it's weight (strength) and connected neuron.
  # :reek:Attribute Need to be able to write to neron and weight.
  class Connection
    attr_accessor :neuron, :weight

    # Connection#initialize takes a neuron and a weight with a default of 0.0.
    def initialize(neuron = Neuron.new, weight: 0.0)
      @neuron = neuron
      @weight = weight
    end

    # The connection's mu is the activation of the connected neuron.
    def mu = @neuron.activation
    alias activation mu

    # The connection's mju is 𝑾𝓑𝒂'.
    def mju = @weight * @neuron.derivative

    # The connection kappa is a component of the neuron's sum kappa:
    #   𝜿 := 𝑾 𝝀'
    def kappa = @weight * @neuron.lamda

    # The weighted activation of the connected neuron.
    def weighted_activation = @neuron.activation * @weight

    # Consistent with #update
    alias partial weighted_activation

    # Connection#update returns the updated activation of a connection, which is
    # the weighted updated activation of the neuron it's connected to:
    #   weight * neuron.update
    # This method is the one to use whenever the value of the inputs are changed
    # (or right after training).  Otherwise, both update and value should give
    # the same result.  When back calculation are not needed, use
    # Connection#weighted_activation instead.
    def update = @neuron.update * @weight

    # Connection#backpropagate modifies the connection's weight in proportion to
    # the error given and passes that error to its connected neuron via the
    # neuron's backpropagate method.
    def backpropagate(error, maxw = Neuronet.maxw)
      @weight += @neuron.activation * Neuronet.noise[error]
      if @weight.abs > maxw
        @weight = @weight.positive? ? maxw : -maxw
      end
      @neuron.backpropagate(error)
      self
    end
    # On how to reduce the error, the above makes it obvious how to interpret
    # the equipartition of errors among the connections.  Backpropagation is
    # symmetric to forward propagation of errors. The error variable is the
    # reduced error, 𝛆(see the wiki notes).

    # A connection inspects itself as "weight*label:...".
    def inspect = "#{Neuronet.format % @weight}*#{@neuron.inspect}"

    # A connection puts itself as "weight*label".
    def to_s = "#{Neuronet.format % @weight}*#{@neuron}"
  end
end
