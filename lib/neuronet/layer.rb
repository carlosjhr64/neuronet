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
    def connect(layer, weight = [], zero: Neuronet.zero)
      # creates the neuron matrix...
      each_with_index do |neuron, i|
        layer.each { neuron.connect(_1, weight[i] || zero) }
      end
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

    # Could not think of a good name for this method and I just thought "redux".
    # Mirrors and anti-mirrors the input(+/-).
    # Input should be half the size of the layer.
    def redux
      each_slice(2).with_index do |ab, i|
        a, b = ab
        b.bias = -(a.bias = Neuronet.bzero)
        b.connections[i].weight = -(a.connections[i].weight = Neuronet.wone)
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
