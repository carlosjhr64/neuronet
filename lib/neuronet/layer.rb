# frozen_string_literal: true

module Neuronet
  # Layer is a collection of neurons with array-like behavior.
  class Layer
    # [LayerPresets](layer_presets.rb)
    include LayerPresets
    # [Arrayable](arrayable.rb)
    include Arrayable

    # Creates layer with `length` number of neurons.
    def initialize(length, full_neuron: Neuron)
      @layer = Array.new(length) { full_neuron.new }
      @endex = length - 1
    end

    # Set each neuron's activation from values array.
    # Allows the layer to be used as an input layer.
    def set(values)
      0.upto(@endex) { @layer[it].set values[it] }
    end

    # For each neuron in the layer, updates the neuron's activation.
    def update = @layer.each(&:update)

    # Fully connects this layer to another.
    def connect(layer)
      each do |neuron|
        layer.each { neuron.connect(it) }
      end
    end

    # Raw pre-squashed values of all neurons in the layer.
    # Allows the layer to be use as an output layer.
    def values
      @layer.map(&:value)
    end

    def to_a = @layer
  end
end
