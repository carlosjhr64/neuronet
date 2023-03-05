# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Just a regular Layer. InputLayer is to Layer what Node is to Neuron.
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
      # note that node can be either Neuron or Node class.
      each_with_index do |neuron, i|
        layer.each { |node| neuron.connect(node, weight[i] || zero) }
      end
    end

    # updates layer with current values of the previous layer
    def partial
      each(&:partial)
    end

    # Takes the real world target for each node in this layer
    # and backpropagates the error to each node.
    def train(target, mju = mu)
      0.upto(length - 1) do |index|
        node = self[index]
        error = (target[index] - node.value) / mju
        node.backpropagate(error)
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
