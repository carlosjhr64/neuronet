# frozen_string_literal: true

module Neuronet
  # Input Layer
  class InputLayer
    include Arrayable

    def initialize(length, input_neuron: InputNeuron)
      @layer = Array.new(length) { input_neuron.new }
      @endex = length - 1
    end

    def set(values)
      0.upto(@endex) { @layer[it].set values[it] }
    end

    def to_a = @layer
  end
end
