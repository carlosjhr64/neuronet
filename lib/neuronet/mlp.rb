# frozen_string_literal: true

module Neuronet
  # Multi Layer Perceptron(3 layers)
  class MLP
    include NetworkStats
    include Exportable
    include Trainable
    include Arrayable

    # rubocop: disable Metrics
    def initialize(input_size, middle_size, output_size,
                   input_neuron: InputNeuron,
                   middle_neuron: MiddleNeuron,
                   output_neuron: OutputNeuron)
      @input_layer = InputLayer.new(input_size, input_neuron:)
      @middle_layer = MiddleLayer.new(middle_size, middle_neuron:)
      @output_layer = OutputLayer.new(output_size, output_neuron:)
      @middle_layer.connect(@input_layer)
      @output_layer.connect(@middle_layer)
    end
    # rubocop: enable Metrics

    attr_reader :input_layer, :middle_layer, :output_layer

    def set(values)
      @input_layer.set(values)
    end

    def update
      @middle_layer.update
    end

    def values
      @output_layer.values
    end

    def *(other)
      set(other)
      update
      values
    end

    def to_a = [@input_layer, @middle_layer, @output_layer]
  end
end
