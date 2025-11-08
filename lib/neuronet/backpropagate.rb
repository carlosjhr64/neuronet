# frozen_string_literal: true

module Neuronet
  # Backpropagate provides simple, clamp-limited weight/bias updates.
  module Backpropagate
    # Back-propagates errors, updating bias and connection weights.
    # Clamps updates to [-max, +max].
    # Recursively calls on connected neurons.
    # rubocop: disable Metrics, Style
    def backpropagate(error)
      bmax = Clamp.bias
      b = bias + error
      self.bias = b.abs > bmax ? (b.positive? ? bmax : -bmax) : b

      wmax = Clamp.weight
      connections.each do |c|
        n = c.neuron
        w = c.weight + (n.activation * error)
        c.weight = w.abs > wmax ? (w.positive? ? wmax : -wmax) : w
        n.backpropagate(error)
      end
    end
    # rubocop: enable Metrics, Style
  end
end
