# frozen_string_literal: true

module Neuronet
  # Output Neuron
  class OutputNeuron
    include NeuronStats
    include Backpropagate

    def initialize
      @bias        = 0.0
      @connections = []
    end

    attr_accessor :bias
    attr_reader   :connections

    def activation = nil

    def connect(neuron, weight = 0.0)
      @connections << Connection.new(neuron, weight)
    end

    def value
      @bias + @connections.sum(&:value)
    end
  end
end
