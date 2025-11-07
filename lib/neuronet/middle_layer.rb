# frozen_string_literal: true

module Neuronet
  # Neuron Layer
  class MiddleLayer
    include LayerPresets
    include Arrayable

    def initialize(length, middle_neuron: MiddleNeuron)
      @layer = Array.new(length) { middle_neuron.new }
    end

    def update = @layer.each(&:update)

    def connect(layer)
      each do |neuron|
        layer.each { neuron.connect(it) }
      end
    end

    def to_a = @layer
  end
end
