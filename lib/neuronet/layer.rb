# frozen_string_literal: true

# Neuronet module
module Neuronet
  # Just a regular Layer. InputLayer is to Layer what Node is to Neuron.
  class Layer < InputLayer
    def initialize(length, vzero: Neuronet.vzero, node: Neuronet::Neuron)
      super
    end

    def mu
      sum { |neuron| neuron.connections.sum { |c| c.node.activation } }
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
  end
end
