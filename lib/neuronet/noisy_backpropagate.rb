# frozen_string_literal: true

module Neuronet
  # Noisy Backpropagate
  module NoisyBackpropagate
    M = self
    class << M; attr_accessor :clamp; end
    M.clamp = 12.0

    # rubocop: disable Metrics, Style
    def backpropagate(error)
      max = M.clamp
      b = bias + (error * (rand + rand))
      self.bias = b.abs > max ? (b.positive? ? max : -max) : b
      connections.each do |c|
        n = c.neuron
        w = c.weight + (n.activation * error * (rand + rand))
        c.weight = w.abs > max ? (w.positive? ? max : -max) : w
        n.backpropagate(error)
      end
    end
    # rubocop: enable Metrics, Style
  end
end
