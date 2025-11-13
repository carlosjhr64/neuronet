# frozen_string_literal: true

module Neuronet
  # Noisy Backpropagate
  module NoisyBackpropagate
    # rubocop: disable Metrics, Style
    def backpropagate(error)
      bmax = Clamp.bias
      b = bias + (error * (rand + rand))
      self.bias = b.abs > bmax ? (b.positive? ? bmax : -bmax) : b

      wmax = Clamp.weight
      connections.each do |c|
        n = c.neuron
        w = c.weight + (error * (rand + rand))
        c.weight = w.abs > wmax ? (w.positive? ? wmax : -wmax) : w
        n.backpropagate(error)
      end
    end
    # rubocop: enable Metrics, Style
  end
end
