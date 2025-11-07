# frozen_string_literal: true

module Neuronet
  # LayerPresets initializes layer weights/biases for interpret-able functions.
  module LayerPresets
    BZERO = 0.5 / (0.5 - Squash.squash(1.0))
    WONE = -2.0 * BZERO

    # Set layer to roughly mirror it's input.
    # Input should be the same size as the layer.
    def mirror(sign = 1.0)
      each_with_index do |neuron, index|
        neuron.bias = sign * BZERO
        neuron.connections[index].weight = sign * WONE
      end
    end

    # Doubles up the input both mirroring and anti-mirroring it.
    # The layer should be twice the size of the input.
    def antithesis
      sign = 1.0
      each_with_index do |neuron, index|
        neuron.bias = sign * BZERO
        neuron.connections[index / 2].weight = sign * WONE
        sign = -sign
      end
    end

    # Sums two corresponding input neurons above each neuron in the layer.
    # Input should be twice the size of the layer.
    def synthesis(sign = 1.0)
      semi = sign * WONE / 2.0
      each_with_index do |neuron, index|
        neuron.bias = sign * BZERO
        j = index * 2
        connections = neuron.connections
        connections[j].weight = semi
        connections[j + 1].weight = semi
      end
    end

    # Set layer to average input.
    def average(sign = 1.0)
      bias = sign * BZERO
      each do |neuron|
        neuron.bias = bias
        connections = neuron.connections
        weight = sign * WONE / connections.size
        connections.each { it.weight = weight }
      end
    end
  end
end
