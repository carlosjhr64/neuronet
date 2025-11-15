# frozen_string_literal: true

module Neuronet
  # Backpropagate provides simple, clamp-limited weight/bias updates.
  module Backpropagate
    # Back-propagates errors, updating bias and connection weights.
    # Clamps updates to [-max, +max].
    # Recursively calls on connected neurons.
    def backpropagate(error)
      return if @backpropagated

      @backpropagated = true
      update_bias(error)
      update_connections(error)
    end

    # rubocop: disable Style/NestedTernaryOperator
    def update_bias(error)
      bmax = Config.bias_clamp
      b = bias + error
      self.bias = b.abs > bmax ? (b.positive? ? bmax : -bmax) : b
    end

    def update_connections(error)
      wmax = Config.weight_clamp
      connections.each do |c|
        n = c.neuron
        w = c.weight + (n.activation * error)
        c.weight = w.abs > wmax ? (w.positive? ? wmax : -wmax) : w
        n.backpropagate(error)
      end
    end
    # rubocop: enable Style/NestedTernaryOperator

    def reset_backpropagated!
      return unless @backpropagated

      @backpropagated = false
      connections.each { |c| c.neuron.reset_backpropagated! }
    end

    def backpropagate!(error)
      reset_backpropagated!
      backpropagate(error)
    end
  end
end
