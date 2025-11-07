# frozen_string_literal: true

module Neuronet
  # Feed Forward
  class Deep
    include NetworkStats
    include Exportable
    include Trainable
    include Arrayable

    # rubocop: disable Metrics
    def initialize(*sizes, input_neuron: InputNeuron,
                   middle_neuron: MiddleNeuron,
                   output_neuron: OutputNeuron)
      length = sizes.length
      raise 'Need at least 3 layers' if length < 3

      @input_layer = InputLayer.new(sizes.shift, input_neuron:)
      @output_layer = OutputLayer.new(sizes.pop, output_neuron:)
      @hidden_layers = sizes.map { MiddleLayer.new(it, middle_neuron:) }
      previous = @input_layer
      @hidden_layers.each do |layer|
        layer.connect(previous)
        previous = layer
      end
      @output_layer.connect(previous)
    end
    # rubocop: enable Metrics

    attr_reader :input_layer, :hidden_layers, :output_layer

    def set(values)
      @input_layer.set(values)
    end

    def update
      @hidden_layers.each(&:update)
    end

    def values
      @output_layer.values
    end

    def *(other)
      set(other)
      update
      values
    end

    def to_a = [@input_layer, *@hidden_layers, @output_layer]
  end
end
