# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Just a regular Layer. InputLayer is to Layer what Node is to Neuron.
  class Layer < InputLayer
    def initialize(length, zero: Neuronet.vzero, node: Neuronet::Neuron)
      super
    end

    # Allows one to fully connect layers.
    def connect(layer, weight = [])
      # creates the neuron matrix...
      # note that node can be either Neuron or Node class.
      each_with_index do |neuron, i|
        layer.each { |node| neuron.connect(node, weight[i].to_f) }
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
  end
end
