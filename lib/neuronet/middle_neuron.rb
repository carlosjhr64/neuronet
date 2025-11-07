# frozen_string_literal: true

module Neuronet
  # Middle Neuron
  class MiddleNeuron
    include NeuronStats
    include Backpropagate
    include Squash

    def initialize
      @activation  = 0.5
      @bias        = 0.0
      @connections = []
    end

    attr_accessor :bias
    attr_reader   :activation, :connections

    def connect(neuron, weight = 0.0)
      @connections << Connection.new(neuron, weight)
    end

    def value
      @bias + @connections.sum(&:value)
    end

    def update
      @activation = squash(value)
    end
  end
end
