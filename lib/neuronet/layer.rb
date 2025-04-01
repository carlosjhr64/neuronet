# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Layer is an array of neurons.
  class Layer < Array
    # Length is the number of neurons in the layer.
    def initialize(length)
      super { Neuron.new }
    end

    # This is where one enters the "real world" inputs.
    def set(inputs)
      0.upto(length - 1) { self[it].value = inputs[it] || 0.0 }
      self
    end

    # Returns the real world values: [value, ...]
    def values
      map(&:value)
    end

    # Allows one to fully connect layers.
    def connect(layer = Layer.new(length), weights: [])
      # creates the neuron matrix...
      each_with_index do |neuron, i|
        weight = weights[i] || 0.0
        layer.each { neuron.connect(it, weight:) }
      end
      # The layer is returned for chaining.
      layer
    end

    # Set layer to mirror input:
    #   bias   = BZERO.
    #   weight = WONE
    # Input should be the same size as the layer.  One can set sign to -1 to
    # anti-mirror.  One can set sign to other than |1| to scale.
    def mirror(sign = 1)
      each_with_index do |neuron, index|
        neuron.bias = sign * Neuronet.bzero
        neuron.connections[index].weight = sign * Neuronet.wone
      end
    end

    # Doubles up the input mirroring and anti-mirroring it.  The layer should be
    # twice the size of the input.
    def antithesis
      sign = 1
      each_with_index do |n, i|
        n.connections[i / 2].weight = sign * Neuronet.wone
        n.bias = sign * Neuronet.bzero
        sign = -sign
      end
    end

    # Sums two corresponding input neurons above each neuron in the layer.
    # Input should be twice the size of the layer.
    def synthesis
      semi = Neuronet.wone / 2
      each_with_index do |n, i|
        j = i * 2
        c = n.connections
        n.bias = Neuronet.bzero
        c[j].weight = semi
        c[j + 1].weight = semi
      end
    end

    # Set layer to average input.
    # :reek:DuplicateMethodCall
    def average(sign = 1)
      bias = sign * Neuronet.bzero
      each do |n|
        n.bias = bias
        weight = sign * Neuronet.wone / n.connections.length
        n.connections.each { it.weight = weight }
      end
    end

    # updates layer with current values of the previous layer
    def partial
      each(&:partial)
    end

    def average_mju
      Neuronet.learning * sum { Neuron.mju(it) } / length
    end

    # Takes the real world target for each neuron in this layer and
    # backpropagates the error to each neuron.
    def train(target, mju = nil)
      0.upto(length - 1) do |index|
        neuron = self[index]
        error = (target[index] - neuron.value) /
                (mju || (Neuronet.learning * Neuron.mju(neuron)))
        neuron.backpropagate(error)
      end
      self
    end

    # Layer inspects as "label:value,..."
    def inspect
      map(&:inspect).join(',')
    end

    # Layer puts as "label,..."
    def to_s
      map(&:to_s).join(',')
    end
  end
end
