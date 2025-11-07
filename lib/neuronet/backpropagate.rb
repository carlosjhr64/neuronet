# frozen_string_literal: true

module Neuronet
  # Backpropagate provides simple, clamp-limited weight/bias updates.
  module Backpropagate
    M = self
    class << M; attr_accessor :clamp; end
    M.clamp = 12.0 # adjustable weight & bias clamping

    # Back-propagates errors, updating bias and connection weights.
    # Clamps updates to [-clamp, +clamp].
    # Recursively calls on connected neurons.
    # rubocop: disable Metrics, Style
    def backpropagate(error)
      max = M.clamp
      b = bias + error
      self.bias = b.abs > max ? (b.positive? ? max : -max) : b
      connections.each do |c|
        n = c.neuron
        w = c.weight + (n.activation * error)
        c.weight = w.abs > max ? (w.positive? ? max : -max) : w
        n.backpropagate(error)
      end
    end
    # rubocop: enable Metrics, Style
  end
end
