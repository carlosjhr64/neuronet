# frozen_string_literal: true

module Neuronet
  # Perceptron
  class Perceptron
    include NetworkStats
    include Exportable
    include Trainable
    include Arrayable

    def initialize(input_size, output_size,
                   input_neuron: InputNeuron, output_neuron: OutputNeuron)
      @input_layer = InputLayer.new(input_size, input_neuron:)
      @output_layer = OutputLayer.new(output_size, output_neuron:)
      @output_layer.connect(@input_layer)
    end

    attr_reader :input_layer, :output_layer

    def set(values)
      @input_layer.set(values)
    end

    def values
      @output_layer.values
    end

    def *(other)
      set(other)
      values
    end

    def to_a = [@input_layer, @output_layer]
  end
end
