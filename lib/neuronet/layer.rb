# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Layer is an array of neurons.
  class Layer < Array
    # Mu is a measure of sensitivity to errors.
    def mu = sum(Neuronet.zero, &:mu)

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
    def mirror
      each_with_index do |neuron, index|
        next if neuron.connections[index].nil? # Has mirroring input?

        @bias = Neuronet.bzero
        @weight = Neuronet.wone
      end
    end

    # Could not think of a good name for this method and I just thought "redux".
    # Mirrors and anti-mirrors the input(+/-).
    # rubocop:disable Metrics/AbcSize
    def redux
      each_with_index do |n, i|
        j = i * 2
        next unless (a = n.connections[j]) && (b = n.connections[j + 1])

        b.bias = -(a.bias = Neuronet.bzero)
        b.weight = -(a.weight = Neuronet.wone)
      end
    end
    # rubocop:enable Metrics/AbcSize

    # updates layer with current values of the previous layer
    def partial
      each(&:partial)
    end

    # Takes the real world target for each neuron in this layer and
    # backpropagates the error to each neuron.
    def train(target, mju = mu)
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
