# frozen_string_literal: true

module Neuronet
  # Noisy Backpropagate
  module NoisyBackpropagate
    # rubocop: disable Metrics, Style
    def backpropagate(error)
      bmax = Config.bias_clamp
      b = bias + (error * (rand + rand))
      self.bias = b.abs > bmax ? (b.positive? ? bmax : -bmax) : b

      wmax = Config.weight_clamp
      connections.each do |c|
        n = c.neuron
        w = c.weight + (n.activation * error * (rand + rand))
        c.weight = w.abs > wmax ? (w.positive? ? wmax : -wmax) : w
        n.backpropagate(error)
      end
    end
    # rubocop: enable Metrics, Style
  end
end
