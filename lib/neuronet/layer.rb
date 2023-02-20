# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Just a regular Layer.
  # InputLayer is to Layer what Node is to Neuron.
  # But Layer does not sub-class InputLayer(it's different enough).
  class Layer < Array
    def initialize(length)
      super(length)
      0.upto(length - 1) { |index| self[index] = Neuronet::Neuron.new }
    end

    # Allows one to fully connect layers.
    def connect(layer, weight = [])
      # creates the neuron matrix...
      # note that node can be either Neuron or Node class.
      i = -1
      each do |neuron|
        layer.each { |node| neuron.connect(node, weight[i += 1].to_f) }
      end
    end

    # updates layer with current values of the previous layer
    def partial
      each(&:partial)
    end

    # Takes the real world target for each node in this layer
    # and backpropagates the error to each node.
    # Note that the learning constant is really a value
    # that needs to be determined for each network.
    def train(target, learning)
      0.upto(length - 1) do |index|
        node = self[index]
        error = target[index] - node.value
        node.backpropagate(learning * error)
      end
      self
    end

    # Returns the real world values of this layer.
    def values
      map(&:value)
    end

    def inspect
      map(&:inspect).join(',')
    end

    def to_s
      map(&:to_s).join(',')
    end
  end
end
