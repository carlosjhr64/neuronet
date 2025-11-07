# frozen_string_literal: true

module Neuronet
  # Neuron represents a single node in a neural network.
  # It holds @activation, @bias, and incoming @connections.
  class Neuron
    # [nju computation](neuron_stats.rb)
    include NeuronStats
    # [back-propagation of errors](backpropagate.rb)
    include Backpropagate
    # [squash/unsquash methods](squash.rb)
    include Squash

    # Initializes a neuron with default activation 0.5 and zero bias.
    def initialize
      @activation  = 0.5
      @bias        = 0.0
      @connections = [] # incoming connections
    end

    attr_accessor :bias # bias is settable
    attr_reader   :activation, :connections # activation is read-only

    # Sets activation by applying squash to raw input value.
    def set(value)
      @activation = squash(value)
    end

    # Creates a weighted connection to another neuron.
    # See [Neuronet::Connection](connection.rb)
    def connect(neuron, weight = 0.0)
      @connections << Connection.new(neuron, weight)
    end

    # Computes(raw output)value: bias + sum of incoming connection values.
    def value
      @bias + @connections.sum(&:value)
    end

    # Updates activation by squashing the current value(see above).
    def update
      @activation = squash(value)
    end
  end
end
