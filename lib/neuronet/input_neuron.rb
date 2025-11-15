# frozen_string_literal: true

module Neuronet
  # Input Neuron
  class InputNeuron
    include NeuronStats
    include Squash

    EMPTY = [].freeze

    def initialize
      @activation = 0.5
    end

    attr_reader :activation

    def bias = nil
    def connections = EMPTY
    def value = nil

    def set(value)
      @activation = squash(value)
    end

    def backpropagate(_) = nil
    def reset_backpropagated! = nil
  end
end
