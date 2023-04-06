# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Layer is an array of neurons.
  class Layer < Array
    # Length is the number of neurons in the layer.
    def initialize(length)
      super(length) { Neuron.new }
    end

    # This is where one enters the "real world" inputs.
    def set(inputs, vzero: Neuronet.vzero)
      0.upto(length - 1) { self[_1].value = inputs[_1] || vzero }
      self
    end

    # Returns the real world values: [value, ...]
    def values
      map(&:value)
    end

    # Allows one to fully connect layers.
    def connect(layer = Layer.new(length), weights: [], zero: Neuronet.zero)
      # creates the neuron matrix...
      each_with_index do |neuron, i|
        weight = weights[i] || zero
        layer.each { neuron.connect(_1, weight:) }
      end
      # NOTE: the layer is returned for chaining.
      layer
    end

    # Set layer to mirror input:
    #   bias   = BZERO.
    #   weight = WONE
    # Input should be the same size as the layer.
    def mirror
      each_with_index do |neuron, index|
        neuron.bias = Neuronet.bzero
        neuron.connections[index].weight = Neuronet.wone
      end
    end

    # Doubles up the input mirroring it.  The layer should by twice the size of
    # the input.
    def redux
      each.with_index do |n, i|
        n.bias = Neuronet.bzero
        j = i * 2
        n.connections[j].weight = Neuronet.wone
        n.connections[j + 1].weight = Neuronet.wone
      end
    end

    # Antithesis alternates mirror and anti-mirror.  The input should be the
    # same even size of the layer.  Typically used with redux.
    def antithesis
      sign = 1
      each.with_index do |n, i|
        n.bias = sign * Neuronet.bzero
        n.connections[i].weight = sign * Neuronet.wone
        sign = -sign
      end
    end

    # Sums two corresponding input neurons above each neuron in the layer.
    # Input should be twice the size of the layer.
    def synthesis
      each_with_index do |n, i|
        j = i * 2
        c = n.connections
        n.bias = Neuronet.bzero
        c[j].weight = Neuronet.wone / 2
        c[j + 1].weight = Neuronet.wone / 2
      end
    end

    # updates layer with current values of the previous layer
    def partial
      each(&:partial)
    end

    # Takes the real world target for each neuron in this layer and
    # backpropagates the error to each neuron.
    # TODO: a per neuron mju.
    def train(target, mju)
      0.upto(length - 1) do |index|
        neuron = self[index]
        error = (target[index] - neuron.value) / mju
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
