# frozen_string_literal: true

module Neuronet
  # Output Layer
  class OutputLayer
    include LayerPresets
    include Arrayable

    def initialize(length, output_neuron: OutputNeuron)
      @layer = Array.new(length) { output_neuron.new }
    end

    def connect(layer)
      each do |neuron|
        layer.each { neuron.connect(it) }
      end
    end

    def values
      @layer.map(&:value)
    end

    def to_a = @layer
  end
end
